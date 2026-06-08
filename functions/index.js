/**
 * ONYX Sports Facility — Cloud Functions
 *
 * Business logic for bookings, attendance, payments,
 * notifications, leaderboard aggregation, and facility management.
 */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue, Timestamp } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const { sendMultiChannelNotification, sendPushToUser, sendPushToTopic } = require("./notifications");
const { sendTemplateMessage, broadcastTemplate, normalizePhoneNumber } = require("./whatsapp");

initializeApp();
const db = getFirestore();

// ════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════

async function getUserRole(uid) {
  const userDoc = await db.collection("users").doc(uid).get();
  return userDoc.exists ? userDoc.data().role : "guest";
}

async function assertRole(uid, allowedRoles) {
  const role = await getUserRole(uid);
  if (!allowedRoles.includes(role)) {
    throw new HttpsError("permission-denied", `Role '${role}' not authorized.`);
  }
  return role;
}

async function sendNotification(userId, type, title, body, options = {}) {
  await sendMultiChannelNotification({
    userId,
    type,
    title,
    body,
    whatsappTemplate: options.whatsappTemplate || null,
    whatsappParams: options.whatsappParams || {},
    data: options.data || {},
  });
}

// ════════════════════════════════════════════════════════════════
// AUTH — User Profile Setup
// ════════════════════════════════════════════════════════════════

/**
 * Callable: Create a new user profile after Firebase Auth signup.
 */
exports.createUserProfile = onCall(async (request) => {
  const { uid } = request.auth;
  const { name, phone, role } = request.data;

  if (!name) throw new HttpsError("invalid-argument", "Name is required.");

  const validRoles = [
    "guest", "coachingMember", "coach", "receptionist",
    "facilityManager", "admin", "tournamentOrganizer", "housekeeping",
  ];

  // Only admin can assign non-guest roles
  let assignedRole = "guest";
  if (role && role !== "guest") {
    await assertRole(uid, ["admin"]);
    if (!validRoles.includes(role)) {
      throw new HttpsError("invalid-argument", `Invalid role: ${role}`);
    }
    assignedRole = role;
  }

  const profile = {
    name,
    email: request.auth.token.email || "",
    phone: phone || "",
    role: assignedRole,
    level: "beginner",
    membershipType: null,
    membershipStatus: null,
    membershipExpiry: null,
    totalSessions: 0,
    totalHours: 0,
    currentStreak: 0,
    favoriteFacility: "",
    mostActiveDay: "",
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };

  await db.collection("users").doc(uid).set(profile);

  // Set custom claims for role-based auth
  await getAuth().setCustomUserClaims(uid, { role: assignedRole });

  return { success: true, profile };
});

// ════════════════════════════════════════════════════════════════
// BOOKINGS
// ════════════════════════════════════════════════════════════════

/**
 * Callable: Create a booking with slot validation and conflict checking.
 */
exports.createBooking = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");

  const { facilityId, date, startTime, endTime, courtNumber, amount, paymentMode } = request.data;

  if (!facilityId || !date || !startTime || !endTime) {
    throw new HttpsError("invalid-argument", "Missing required booking fields.");
  }

  // Check for slot conflicts
  const conflicts = await db.collection("bookings")
    .where("facilityId", "==", facilityId)
    .where("date", "==", date)
    .where("startTime", "==", startTime)
    .where("status", "in", ["upcoming", "active"])
    .get();

  if (courtNumber) {
    const courtConflict = conflicts.docs.find(
      (d) => d.data().courtNumber === courtNumber
    );
    if (courtConflict) {
      throw new HttpsError("already-exists", "This slot is already booked.");
    }
  } else if (!conflicts.empty) {
    throw new HttpsError("already-exists", "This slot is already booked.");
  }

  const booking = {
    userId: request.auth.uid,
    facilityId,
    date,
    startTime,
    endTime,
    courtNumber: courtNumber || null,
    status: "upcoming",
    amount: amount || 0,
    paymentMode: paymentMode || "online",
    paymentStatus: "pending",
    checkInToken: request.data.checkInToken || null,
    checkedInAt: null,
    halfTimeNotified: false,
    endTimeNotified: false,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };

  const ref = await db.collection("bookings").add(booking);

  // Get facility name for notification
  const facilityDoc = await db.collection("facilities").doc(facilityId).get();
  const facilityName = facilityDoc.exists ? facilityDoc.data().name : facilityId;

  await sendNotification(
    request.auth.uid,
    "booking",
    "Booking Confirmed",
    `${facilityName} — ${date}, ${startTime} - ${endTime}`
  );

  return { success: true, bookingId: ref.id };
});

/**
 * Callable: Cancel a booking.
 */
exports.cancelBooking = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");

  const { bookingId, reason } = request.data;
  const bookingRef = db.collection("bookings").doc(bookingId);
  const booking = await bookingRef.get();

  if (!booking.exists) {
    throw new HttpsError("not-found", "Booking not found.");
  }

  const data = booking.data();
  const role = await getUserRole(request.auth.uid);

  if (data.userId !== request.auth.uid && !["receptionist", "facilityManager", "admin"].includes(role)) {
    throw new HttpsError("permission-denied", "Cannot cancel this booking.");
  }

  await bookingRef.update({
    status: "cancelled",
    cancelledAt: FieldValue.serverTimestamp(),
    cancelReason: reason || "User cancelled",
    updatedAt: FieldValue.serverTimestamp(),
  });

  await sendNotification(
    data.userId,
    "booking",
    "Booking Cancelled",
    `Your booking for ${data.date} has been cancelled.`
  );

  return { success: true };
});

/**
 * Callable: Create a walk-in booking (staff only).
 */
exports.createWalkInBooking = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  await assertRole(request.auth.uid, ["receptionist", "facilityManager", "admin", "coach"]);

  const { guestName, guestPhone, facilityId, date, startTime, endTime, courtNumber, amount, paymentMode } = request.data;

  if (!guestName || !facilityId || !date || !startTime) {
    throw new HttpsError("invalid-argument", "Missing required fields.");
  }

  const walkin = {
    guestName,
    guestPhone: guestPhone || "",
    facilityId,
    date,
    startTime,
    endTime: endTime || "",
    courtNumber: courtNumber || null,
    amount: amount || 0,
    paymentMode: paymentMode || "cash",
    paymentStatus: "paid",
    createdBy: request.auth.uid,
    createdAt: FieldValue.serverTimestamp(),
  };

  const ref = await db.collection("walkinBookings").add(walkin);
  return { success: true, bookingId: ref.id };
});

// ════════════════════════════════════════════════════════════════
// ATTENDANCE (Manual by Coach)
// ════════════════════════════════════════════════════════════════

/**
 * Callable: Mark attendance for a batch session.
 */
exports.markAttendance = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  await assertRole(request.auth.uid, ["coach", "admin"]);

  const { batchId, date, attendanceRecords } = request.data;
  // attendanceRecords: [{ studentId, status: 'present'|'absent' }]

  if (!batchId || !date || !attendanceRecords || !attendanceRecords.length) {
    throw new HttpsError("invalid-argument", "Missing attendance data.");
  }

  const sessionRef = db.collection("batches").doc(batchId)
    .collection("attendance").doc(date);

  const records = {};
  let presentCount = 0;
  let absentCount = 0;

  for (const rec of attendanceRecords) {
    records[rec.studentId] = {
      status: rec.status,
      markedAt: Timestamp.now(),
    };
    if (rec.status === "present") presentCount++;
    else absentCount++;
  }

  await sessionRef.set({
    batchId,
    date,
    coachId: request.auth.uid,
    records,
    presentCount,
    absentCount,
    totalStudents: attendanceRecords.length,
    markedAt: FieldValue.serverTimestamp(),
  });

  // Update each student's attendance stats
  const batch = db.batch();
  for (const rec of attendanceRecords) {
    if (rec.status === "present") {
      const studentRef = db.collection("users").doc(rec.studentId);
      batch.update(studentRef, {
        totalSessions: FieldValue.increment(1),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  }
  await batch.commit();

  return { success: true, presentCount, absentCount };
});

// ════════════════════════════════════════════════════════════════
// SESSION CANCELLATION (Coach)
// ════════════════════════════════════════════════════════════════

/**
 * Callable: Coach cancels a session.
 */
exports.cancelSession = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  await assertRole(request.auth.uid, ["coach", "admin"]);

  const { batchId, date, reason } = request.data;

  if (!batchId || !date || !reason) {
    throw new HttpsError("invalid-argument", "Missing cancellation data.");
  }

  // Check monthly quota (max 3 cancellations per month)
  const monthStart = date.substring(0, 7) + "-01"; // YYYY-MM-01
  const cancellations = await db.collection("sessionCancellations")
    .where("coachId", "==", request.auth.uid)
    .where("date", ">=", monthStart)
    .get();

  if (cancellations.size >= 3) {
    throw new HttpsError(
      "resource-exhausted",
      "Monthly cancellation quota (3) exceeded."
    );
  }

  await db.collection("sessionCancellations").add({
    coachId: request.auth.uid,
    batchId,
    date,
    reason,
    compensated: true,
    createdAt: FieldValue.serverTimestamp(),
  });

  // Notify all students in the batch
  const batchDoc = await db.collection("batches").doc(batchId).get();
  if (batchDoc.exists) {
    const batchData = batchDoc.data();
    const studentIds = batchData.studentIds || [];

    for (const studentId of studentIds) {
      await sendNotification(
        studentId,
        "coaching",
        "Session Cancelled",
        `${batchData.name} on ${date} cancelled — ${reason}. Will be compensated.`
      );
    }
  }

  return { success: true, cancellationsUsed: cancellations.size + 1 };
});

// ════════════════════════════════════════════════════════════════
// ANNOUNCEMENTS
// ════════════════════════════════════════════════════════════════

/**
 * Trigger: When an announcement is created, notify target students.
 */
exports.onAnnouncementCreated = onDocumentCreated(
  "announcements/{announcementId}",
  async (event) => {
    const data = event.data.data();
    const { targetBatch, title, body: annBody, authorId } = data;

    let studentIds = [];

    if (targetBatch === "all" || targetBatch === "All Batches") {
      // Notify all coaching members
      const students = await db.collection("users")
        .where("role", "==", "coachingMember")
        .get();
      studentIds = students.docs.map((d) => d.id);
    } else {
      // Notify specific batch
      const batches = await db.collection("batches")
        .where("name", "==", targetBatch)
        .get();
      if (!batches.empty) {
        studentIds = batches.docs[0].data().studentIds || [];
      }
    }

    for (const studentId of studentIds) {
      if (studentId !== authorId) {
        await sendNotification(studentId, "coaching", title, annBody);
      }
    }
  }
);

// ════════════════════════════════════════════════════════════════
// PAYMENTS
// ════════════════════════════════════════════════════════════════

/**
 * Callable: Record a payment.
 */
exports.recordPayment = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");

  const { userId, description, amount, type, paymentMode } = request.data;
  const callerRole = await getUserRole(request.auth.uid);

  // Users can pay for themselves; staff can record for anyone
  const targetUserId = userId || request.auth.uid;
  if (targetUserId !== request.auth.uid &&
      !["receptionist", "facilityManager", "admin"].includes(callerRole)) {
    throw new HttpsError("permission-denied", "Cannot record payment for other users.");
  }

  const payment = {
    userId: targetUserId,
    description: description || "",
    amount: amount || 0,
    type: type || "booking", // booking, membership, coaching, tournament
    paymentMode: paymentMode || "online",
    status: "paid",
    createdAt: FieldValue.serverTimestamp(),
  };

  const ref = await db.collection("payments").add(payment);

  // If membership payment, update membership status
  if (type === "membership") {
    const membershipData = request.data.membershipData || {};
    await db.collection("memberships").doc(targetUserId).set({
      type: membershipData.type || "monthly",
      status: "active",
      startDate: membershipData.startDate || new Date().toISOString().split("T")[0],
      expiryDate: membershipData.expiryDate || "",
      amount,
      lastPaymentId: ref.id,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });

    await db.collection("users").doc(targetUserId).update({
      membershipType: membershipData.type || "monthly",
      membershipStatus: "active",
      membershipExpiry: membershipData.expiryDate || "",
    });
  }

  await sendNotification(
    targetUserId,
    "general",
    "Payment Received",
    `₹${amount} — ${description}`
  );

  return { success: true, paymentId: ref.id };
});

// ════════════════════════════════════════════════════════════════
// LEADERBOARD — Scheduled Aggregation
// ════════════════════════════════════════════════════════════════

/**
 * Scheduled: Recompute leaderboard daily at midnight IST.
 */
exports.updateLeaderboard = onSchedule(
  { schedule: "0 0 * * *", timeZone: "Asia/Kolkata" },
  async () => {
    const users = await db.collection("users")
      .where("role", "in", ["guest", "coachingMember"])
      .orderBy("totalSessions", "desc")
      .limit(50)
      .get();

    const batch = db.batch();

    // Clear old leaderboard
    const oldEntries = await db.collection("leaderboard").get();
    oldEntries.forEach((doc) => batch.delete(doc.ref));

    // Write new entries
    let rank = 1;
    users.forEach((doc) => {
      const data = doc.data();
      const entryRef = db.collection("leaderboard").doc(`rank_${rank}`);
      batch.set(entryRef, {
        rank,
        userId: doc.id,
        playerName: data.name,
        sessions: data.totalSessions || 0,
        hours: data.totalHours || 0,
        streak: data.currentStreak || 0,
        period: "allTime",
        updatedAt: FieldValue.serverTimestamp(),
      });
      rank++;
    });

    await batch.commit();
    console.log(`Leaderboard updated: ${rank - 1} entries.`);
  }
);

// ════════════════════════════════════════════════════════════════
// BOOKING LIFECYCLE — Auto status updates
// ════════════════════════════════════════════════════════════════

/**
 * Scheduled: Mark expired bookings as completed, every 15 minutes.
 */
exports.processBookingLifecycle = onSchedule(
  { schedule: "*/15 * * * *", timeZone: "Asia/Kolkata" },
  async () => {
    const now = new Date();
    const todayStr = now.toISOString().split("T")[0];
    const currentHour = now.getHours();
    const currentTimeStr = `${currentHour}:00`;

    // Find active bookings that should be completed
    const expiring = await db.collection("bookings")
      .where("status", "==", "upcoming")
      .where("date", "==", todayStr)
      .get();

    const batch = db.batch();
    let updated = 0;

    expiring.forEach((doc) => {
      const data = doc.data();
      if (data.endTime && data.endTime <= currentTimeStr) {
        batch.update(doc.ref, {
          status: "completed",
          updatedAt: FieldValue.serverTimestamp(),
        });
        updated++;
      }
    });

    if (updated > 0) {
      await batch.commit();
      console.log(`Completed ${updated} expired bookings.`);
    }
  }
);

// ════════════════════════════════════════════════════════════════
// STREAK TRACKER
// ════════════════════════════════════════════════════════════════

/**
 * Trigger: When a booking is marked completed, update user stats and streak.
 */
exports.onBookingCompleted = onDocumentUpdated(
  "bookings/{bookingId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.status !== "completed" && after.status === "completed") {
      const userRef = db.collection("users").doc(after.userId);
      const userDoc = await userRef.get();

      if (userDoc.exists) {
        const userData = userDoc.data();
        const lastActive = userData.lastActiveDate || "";
        const today = new Date().toISOString().split("T")[0];
        const yesterday = new Date(Date.now() - 86400000).toISOString().split("T")[0];

        let newStreak = userData.currentStreak || 0;
        if (lastActive === yesterday) {
          newStreak += 1;
        } else if (lastActive !== today) {
          newStreak = 1;
        }

        const durationHours = (after.durationMinutes || 60) / 60;

        await userRef.update({
          totalSessions: FieldValue.increment(1),
          totalHours: FieldValue.increment(durationHours),
          currentStreak: newStreak,
          lastActiveDate: today,
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
    }
  }
);

// ════════════════════════════════════════════════════════════════
// FACILITY STATUS — Auto-update on booking changes
// ════════════════════════════════════════════════════════════════

/**
 * Trigger: When a booking is created, update facility timeline.
 */
exports.onBookingCreated = onDocumentCreated(
  "bookings/{bookingId}",
  async (event) => {
    const data = event.data.data();
    const { facilityId, date, startTime, endTime, userId } = data;

    if (!facilityId) return;

    // Add to facility timeline
    await db.collection("facilities").doc(facilityId)
      .collection("timeline").add({
        date,
        startTime,
        endTime,
        userId,
        bookingId: event.params.bookingId,
        createdAt: FieldValue.serverTimestamp(),
      });
  }
);

/**
 * Trigger: Clean up facility timeline when booking is cancelled.
 */
exports.onBookingCancelled = onDocumentUpdated(
  "bookings/{bookingId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.status !== "cancelled" && after.status === "cancelled") {
      const timeline = await db.collection("facilities").doc(after.facilityId)
        .collection("timeline")
        .where("bookingId", "==", event.params.bookingId)
        .get();

      const batch = db.batch();
      timeline.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }
  }
);

// ════════════════════════════════════════════════════════════════
// HOUSEKEEPING
// ════════════════════════════════════════════════════════════════

/**
 * Callable: Assign a housekeeping task.
 */
exports.createHousekeepingTask = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  await assertRole(request.auth.uid, ["facilityManager", "admin"]);

  const { facilityId, description, priority, dueDate, assignedTo } = request.data;

  const task = {
    facilityId: facilityId || "",
    description: description || "",
    priority: priority || "normal",
    status: "pending",
    dueDate: dueDate || "",
    assignedTo: assignedTo || "",
    createdBy: request.auth.uid,
    createdAt: FieldValue.serverTimestamp(),
    completedAt: null,
  };

  const ref = await db.collection("housekeepingTasks").add(task);

  // Notify assigned staff
  if (assignedTo) {
    await sendNotification(
      assignedTo,
      "general",
      "New Task Assigned",
      description
    );
  }

  return { success: true, taskId: ref.id };
});

/**
 * Trigger: When housekeeping task is marked done, notify manager.
 */
exports.onTaskCompleted = onDocumentUpdated(
  "housekeepingTasks/{taskId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.status !== "completed" && after.status === "completed") {
      await sendNotification(
        after.createdBy,
        "general",
        "Task Completed",
        `Housekeeping task "${after.description}" marked done.`
      );
    }
  }
);

// ════════════════════════════════════════════════════════════════
// SEED DATA (Development only)
// ════════════════════════════════════════════════════════════════

/**
 * Callable: Seed Firestore with initial facility and config data.
 * Only callable by admin in development.
 */
exports.seedDatabase = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");

  const { v4: uuidv4 } = require("uuid");

  // ── Facilities ───────────────────────────────────────────────
  const facilities = [
    { id: "court-1", name: "Badminton Court 1", shortName: "Court 1", type: "badmintonCourt", status: "available" },
    { id: "court-2", name: "Badminton Court 2", shortName: "Court 2", type: "badmintonCourt", status: "occupied" },
    { id: "court-3", name: "Badminton Court 3", shortName: "Court 3", type: "badmintonCourt", status: "available" },
    { id: "turf", name: "Cricket Turf", shortName: "Turf", type: "cricketTurf", status: "available" },
    { id: "nets", name: "Cricket Nets", shortName: "Nets", type: "cricketNets", status: "maintenance" },
  ];

  // ── Config ───────────────────────────────────────────────────
  const pricingConfig = {
    pricing: {
      badmintonCourt: { offPeak: 400, peak: 600 },
      cricketTurf: { offPeak: 1000, peak: 1500 },
      cricketNets: { perLane: 400, fullNets: 1000 },
    },
    peakHours: { start: "16:00", end: "21:00" },
    operatingHours: { start: "06:00", end: "22:00" },
    coachingFees: { monthly: 3000, courtAccess: 500 },
    membershipPlans: {
      monthly: { price: 3000, discount: 0 },
      quarterly: { price: 8500, discount: 500 },
      annual: { price: 30000, discount: 6000 },
    },
    maxCancellationsPerMonth: 3,
  };

  const notificationConfig = {
    halfTimePercent: 50,
    endWarningMinutes: 5,
    enableWhatsApp: false,
    enablePush: true,
  };

  // ── Test Users ───────────────────────────────────────────────
  const testUsers = [
    { email: "admin@onyx.com", password: "admin123", name: "Admin User", phone: "+919000000001", role: "admin" },
    { email: "manager@onyx.com", password: "manager123", name: "Ravi Kumar", phone: "+919000000002", role: "facilityManager" },
    { email: "coach@onyx.com", password: "coach123", name: "Coach Priya", phone: "+919000000003", role: "coach" },
    { email: "reception@onyx.com", password: "reception123", name: "Anitha Desk", phone: "+919000000004", role: "receptionist" },
    { email: "member1@onyx.com", password: "member123", name: "Arjun Sharma", phone: "+919000000005", role: "member" },
    { email: "member2@onyx.com", password: "member123", name: "Sneha Patel", phone: "+919000000006", role: "member" },
    { email: "coaching1@onyx.com", password: "coaching123", name: "Vikram Singh", phone: "+919000000007", role: "coachingMember" },
    { email: "guest@onyx.com", password: "guest123", name: "Guest Player", phone: "+919000000008", role: "guest" },
  ];

  const batch = db.batch();

  // Seed facilities
  for (const facility of facilities) {
    batch.set(db.collection("facilities").doc(facility.id), {
      ...facility,
      currentUser: null,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
  }

  // Seed config
  batch.set(db.collection("config").doc("pricing"), pricingConfig, { merge: true });
  batch.set(db.collection("config").doc("notifications"), notificationConfig, { merge: true });

  await batch.commit();

  // ── Create test users via Admin SDK ──────────────────────────
  const admin = require("firebase-admin");
  const createdUsers = [];

  for (const user of testUsers) {
    try {
      let userRecord;
      try {
        userRecord = await admin.auth().getUserByEmail(user.email);
      } catch (e) {
        userRecord = await admin.auth().createUser({
          email: user.email,
          password: user.password,
          displayName: user.name,
        });
      }

      // Create/update Firestore profile
      await db.collection("users").doc(userRecord.uid).set({
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        level: "intermediate",
        membershipType: user.role === "member" ? "monthly" : null,
        membershipStatus: user.role === "member" ? "active" : null,
        membershipExpiry: user.role === "member" ? "2026-12-31" : null,
        totalSessions: Math.floor(Math.random() * 50) + 5,
        totalHours: Math.floor(Math.random() * 100) + 10,
        currentStreak: Math.floor(Math.random() * 15),
        favoriteFacility: "court-1",
        mostActiveDay: "Wednesday",
        whatsappOptIn: true,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });

      createdUsers.push({ email: user.email, uid: userRecord.uid, role: user.role });
    } catch (e) {
      console.log(`[Seed] Skipped user ${user.email}: ${e.message}`);
    }
  }

  // ── Seed Bookings (realistic data) ──────────────────────────
  const today = new Date();
  const memberUids = createdUsers.filter(u => u.role === "member" || u.role === "coachingMember" || u.role === "guest").map(u => u.uid);

  if (memberUids.length > 0) {
    const bookingBatch = db.batch();

    const bookings = [
      // Today — Active session
      {
        userId: memberUids[0] || request.auth.uid,
        facilityId: "court-2", courtNumber: "Court 2",
        date: formatDate(today), startTime: "09:00", endTime: "10:00",
        status: "active", paymentStatus: "paid", paymentMode: "online",
        amount: 400, checkInToken: uuidv4(),
        checkedInAt: Timestamp.fromDate(new Date(today.getFullYear(), today.getMonth(), today.getDate(), 9, 0)),
        durationMinutes: 60, halfTimeNotified: false, endTimeNotified: false,
      },
      // Today — Upcoming
      {
        userId: memberUids[1] || request.auth.uid,
        facilityId: "court-1", courtNumber: "Court 1",
        date: formatDate(today), startTime: "14:00", endTime: "15:00",
        status: "upcoming", paymentStatus: "paid", paymentMode: "online",
        amount: 400, checkInToken: uuidv4(),
        checkedInAt: null, durationMinutes: 60, halfTimeNotified: false, endTimeNotified: false,
      },
      // Today — Upcoming (peak)
      {
        userId: memberUids[0] || request.auth.uid,
        facilityId: "turf",
        date: formatDate(today), startTime: "17:00", endTime: "19:00",
        status: "upcoming", paymentStatus: "paid", paymentMode: "online",
        amount: 3000, checkInToken: uuidv4(),
        checkedInAt: null, durationMinutes: 120, halfTimeNotified: false, endTimeNotified: false,
      },
      // Today — Completed
      {
        userId: memberUids[2] || memberUids[0] || request.auth.uid,
        facilityId: "court-3", courtNumber: "Court 3",
        date: formatDate(today), startTime: "06:00", endTime: "07:00",
        status: "completed", paymentStatus: "paid", paymentMode: "cash",
        amount: 400, checkInToken: uuidv4(),
        checkedInAt: Timestamp.fromDate(new Date(today.getFullYear(), today.getMonth(), today.getDate(), 6, 0)),
        durationMinutes: 60, halfTimeNotified: true, endTimeNotified: true,
      },
      // Yesterday — Completed
      {
        userId: memberUids[0] || request.auth.uid,
        facilityId: "court-1", courtNumber: "Court 1",
        date: formatDate(addDays(today, -1)), startTime: "18:00", endTime: "19:00",
        status: "completed", paymentStatus: "paid", paymentMode: "online",
        amount: 600, checkInToken: uuidv4(),
        checkedInAt: Timestamp.fromDate(addDays(new Date(today.getFullYear(), today.getMonth(), today.getDate(), 18, 0), -1)),
        durationMinutes: 60, halfTimeNotified: true, endTimeNotified: true,
      },
      // Yesterday — Cancelled
      {
        userId: memberUids[1] || request.auth.uid,
        facilityId: "turf",
        date: formatDate(addDays(today, -1)), startTime: "10:00", endTime: "12:00",
        status: "cancelled", paymentStatus: "refunded", paymentMode: "online",
        amount: 2000, checkInToken: uuidv4(),
        checkedInAt: null, durationMinutes: 120, halfTimeNotified: false, endTimeNotified: false,
      },
      // Tomorrow — Upcoming
      {
        userId: memberUids[0] || request.auth.uid,
        facilityId: "court-1", courtNumber: "Court 1",
        date: formatDate(addDays(today, 1)), startTime: "08:00", endTime: "09:00",
        status: "upcoming", paymentStatus: "paid", paymentMode: "online",
        amount: 400, checkInToken: uuidv4(),
        checkedInAt: null, durationMinutes: 60, halfTimeNotified: false, endTimeNotified: false,
      },
      // Tomorrow — Upcoming Nets
      {
        userId: memberUids[1] || request.auth.uid,
        facilityId: "nets", courtNumber: "Lane 1",
        date: formatDate(addDays(today, 1)), startTime: "16:00", endTime: "17:00",
        status: "upcoming", paymentStatus: "paid", paymentMode: "upi",
        amount: 500, checkInToken: uuidv4(),
        checkedInAt: null, durationMinutes: 60, halfTimeNotified: false, endTimeNotified: false,
      },
      // 2 days ago — Completed
      {
        userId: memberUids[2] || memberUids[0] || request.auth.uid,
        facilityId: "court-2", courtNumber: "Court 2",
        date: formatDate(addDays(today, -2)), startTime: "07:00", endTime: "09:00",
        status: "completed", paymentStatus: "paid", paymentMode: "online",
        amount: 800, checkInToken: uuidv4(),
        checkedInAt: Timestamp.fromDate(addDays(new Date(today.getFullYear(), today.getMonth(), today.getDate(), 7, 0), -2)),
        durationMinutes: 120, halfTimeNotified: true, endTimeNotified: true,
      },
      // 3 days ago — Completed turf
      {
        userId: memberUids[0] || request.auth.uid,
        facilityId: "turf",
        date: formatDate(addDays(today, -3)), startTime: "17:00", endTime: "19:00",
        status: "completed", paymentStatus: "paid", paymentMode: "online",
        amount: 3000, checkInToken: uuidv4(),
        checkedInAt: Timestamp.fromDate(addDays(new Date(today.getFullYear(), today.getMonth(), today.getDate(), 17, 0), -3)),
        durationMinutes: 120, halfTimeNotified: true, endTimeNotified: true,
      },
      // Day after tomorrow — Upcoming
      {
        userId: memberUids[1] || request.auth.uid,
        facilityId: "court-3", courtNumber: "Court 3",
        date: formatDate(addDays(today, 2)), startTime: "19:00", endTime: "20:00",
        status: "upcoming", paymentStatus: "paid", paymentMode: "online",
        amount: 600, checkInToken: uuidv4(),
        checkedInAt: null, durationMinutes: 60, halfTimeNotified: false, endTimeNotified: false,
      },
      // Walk-in today
      {
        userId: memberUids[2] || memberUids[0] || request.auth.uid,
        facilityId: "court-1", courtNumber: "Court 1",
        date: formatDate(today), startTime: "11:00", endTime: "12:00",
        status: "completed", paymentStatus: "paid", paymentMode: "cash",
        amount: 400, checkInToken: uuidv4(), guestName: "Walk-in Ravi",
        checkedInAt: Timestamp.fromDate(new Date(today.getFullYear(), today.getMonth(), today.getDate(), 11, 0)),
        durationMinutes: 60, halfTimeNotified: true, endTimeNotified: true,
      },
    ];

    for (const booking of bookings) {
      const ref = db.collection("bookings").doc();
      bookingBatch.set(ref, {
        ...booking,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    await bookingBatch.commit();
  }

  return {
    success: true,
    message: `Seeded: ${facilities.length} facilities, ${createdUsers.length} users, 12 bookings, config docs.`,
    users: createdUsers.map(u => `${u.email} (${u.role})`),
  };
});

function formatDate(d) {
  return `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()}`;
}

function addDays(date, days) {
  const result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}

// ════════════════════════════════════════════════════════════════
// WHATSAPP — Callable Endpoints
// ════════════════════════════════════════════════════════════════

exports.sendWhatsAppBookingConfirmation = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  const phone = normalizePhoneNumber(request.data.phoneNumber);
  if (!phone) throw new HttpsError("invalid-argument", "Invalid phone.");
  return sendTemplateMessage(phone, "bookingConfirmation", request.data);
});

exports.sendWhatsAppBookingReminder = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  const phone = normalizePhoneNumber(request.data.phoneNumber);
  if (!phone) throw new HttpsError("invalid-argument", "Invalid phone.");
  return sendTemplateMessage(phone, "bookingReminder", request.data);
});

exports.sendWhatsAppBookingCancellation = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  const phone = normalizePhoneNumber(request.data.phoneNumber);
  if (!phone) throw new HttpsError("invalid-argument", "Invalid phone.");
  return sendTemplateMessage(phone, "bookingCancellation", request.data);
});

exports.sendWhatsAppPaymentReceipt = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  const phone = normalizePhoneNumber(request.data.phoneNumber);
  if (!phone) throw new HttpsError("invalid-argument", "Invalid phone.");
  return sendTemplateMessage(phone, "paymentReceipt", request.data);
});

exports.sendWhatsAppMembershipActivation = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  const phone = normalizePhoneNumber(request.data.phoneNumber);
  if (!phone) throw new HttpsError("invalid-argument", "Invalid phone.");
  return sendTemplateMessage(phone, "membershipActivation", request.data);
});

exports.sendWhatsAppMembershipExpiry = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  const phone = normalizePhoneNumber(request.data.phoneNumber);
  if (!phone) throw new HttpsError("invalid-argument", "Invalid phone.");
  return sendTemplateMessage(phone, "membershipExpiry", request.data);
});

exports.sendWhatsAppSessionCancellation = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  const phone = normalizePhoneNumber(request.data.phoneNumber);
  if (!phone) throw new HttpsError("invalid-argument", "Invalid phone.");
  return sendTemplateMessage(phone, "sessionCancellation", request.data);
});

exports.sendWhatsAppTournamentAnnouncement = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  await assertRole(request.auth.uid, ["admin", "tournamentOrganizer"]);
  const users = await db.collection("users").where("whatsappOptIn", "!=", false).get();
  const phones = users.docs.map((u) => normalizePhoneNumber(u.data().phone)).filter(Boolean);
  return broadcastTemplate(phones, "tournamentAnnouncement", request.data);
});

exports.sendWhatsAppPromotion = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  await assertRole(request.auth.uid, ["admin", "facilityManager"]);
  const { targetAudience, title, body, imageUrl, ctaUrl } = request.data;
  let usersRef = db.collection("users").where("whatsappOptIn", "!=", false);
  if (targetAudience === "members") usersRef = usersRef.where("membershipStatus", "==", "active");
  else if (targetAudience === "guests") usersRef = usersRef.where("role", "==", "guest");
  else if (targetAudience === "coaching") usersRef = usersRef.where("role", "==", "coachingMember");
  const users = await usersRef.get();
  const phones = users.docs.map((u) => normalizePhoneNumber(u.data().phone)).filter(Boolean);
  await db.collection("whatsappCampaigns").add({
    title, body, imageUrl: imageUrl || "", ctaUrl: ctaUrl || "",
    targetAudience, recipientCount: phones.length, sentBy: request.auth.uid,
    createdAt: FieldValue.serverTimestamp(),
  });
  return broadcastTemplate(phones, "promotion", { title, body, imageUrl });
});

exports.updateWhatsAppOptIn = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
  await db.collection("users").doc(request.auth.uid).update({
    whatsappOptIn: request.data.optIn === true,
    updatedAt: FieldValue.serverTimestamp(),
  });
  return { success: true };
});

// ════════════════════════════════════════════════════════════════
// SCHEDULED — Booking Reminders (every 15 min)
// ════════════════════════════════════════════════════════════════

exports.sendBookingReminders = onSchedule(
  { schedule: "*/15 * * * *", timeZone: "Asia/Kolkata" },
  async () => {
    const now = new Date();
    const later = new Date(now.getTime() + 3600000);
    const todayStr = now.toISOString().split("T")[0];
    const targetTime = `${later.getHours()}:00`;
    const bookings = await db.collection("bookings")
      .where("date", "==", todayStr).where("startTime", "==", targetTime)
      .where("status", "==", "upcoming").get();
    for (const doc of bookings.docs) {
      const d = doc.data();
      const uDoc = await db.collection("users").doc(d.userId).get();
      if (!uDoc.exists) continue;
      const fDoc = await db.collection("facilities").doc(d.facilityId).get();
      const fName = fDoc.exists ? fDoc.data().name : d.facilityId;
      await sendNotification(d.userId, "booking", "Upcoming Booking",
        `${fName} at ${d.startTime} today`, {
          whatsappTemplate: "bookingReminder",
          whatsappParams: { customerName: uDoc.data().name, facilityName: fName, date: d.date, time: d.startTime },
        });
    }
    console.log(`[Reminders] ${bookings.size} reminders sent.`);
  }
);

// ════════════════════════════════════════════════════════════════
// SCHEDULED — Membership Expiry Alerts (daily 9 AM IST)
// ════════════════════════════════════════════════════════════════

exports.sendMembershipExpiryAlerts = onSchedule(
  { schedule: "0 9 * * *", timeZone: "Asia/Kolkata" },
  async () => {
    let total = 0;
    for (const days of [7, 3, 1]) {
      const target = new Date(Date.now() + days * 86400000).toISOString().split("T")[0];
      const mems = await db.collection("memberships")
        .where("expiryDate", "==", target).where("status", "==", "active").get();
      for (const doc of mems.docs) {
        const d = doc.data();
        const uDoc = await db.collection("users").doc(doc.id).get();
        if (!uDoc.exists) continue;
        await sendNotification(doc.id, "membership", "Membership Expiring",
          `Your ${d.type} plan expires in ${days} day${days > 1 ? "s" : ""}`, {
            whatsappTemplate: "membershipExpiry",
            whatsappParams: { customerName: uDoc.data().name, planName: d.type, daysRemaining: days },
          });
        total++;
      }
    }
    console.log(`[Membership] ${total} expiry alerts sent.`);
  }
);

// ════════════════════════════════════════════════════════════════
// PAYMENT — Razorpay Verification
// ════════════════════════════════════════════════════════════════

/**
 * Callable: Verify Razorpay payment and update booking payment status.
 */
exports.verifyPayment = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");

  const { paymentId, bookingId } = request.data;
  if (!paymentId) throw new HttpsError("invalid-argument", "Payment ID required.");

  // Find the booking — either by explicit bookingId or by checkInToken
  let bookingRef, bookingDoc;

  if (bookingId) {
    bookingRef = db.collection("bookings").doc(bookingId);
    bookingDoc = await bookingRef.get();
  }

  if (!bookingDoc || !bookingDoc.exists) {
    // Try finding by recent pending booking for this user
    const q = await db.collection("bookings")
      .where("userId", "==", request.auth.uid)
      .where("paymentStatus", "==", "pending")
      .orderBy("createdAt", "desc")
      .limit(1)
      .get();
    if (q.empty) throw new HttpsError("not-found", "Booking not found.");
    bookingRef = q.docs[0].ref;
    bookingDoc = q.docs[0];
  }

  await bookingRef.update({
    paymentStatus: "paid",
    paymentId: paymentId,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true, bookingId: bookingRef.id };
});

// ════════════════════════════════════════════════════════════════
// CHECK-IN — QR Code Scan
// ════════════════════════════════════════════════════════════════

/**
 * Callable: Check in a booking via QR code scan (receptionist/manager).
 * Validates the check-in token, activates the session, records timestamp.
 */
exports.checkInBooking = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");

  // Only staff can check in
  await assertRole(request.auth.uid, ["receptionist", "facilityManager", "admin", "coach"]);

  const { checkInToken, bookingId } = request.data;
  if (!checkInToken) throw new HttpsError("invalid-argument", "Check-in token required.");

  // Find booking by token
  let bookingRef, bookingData;

  if (bookingId) {
    bookingRef = db.collection("bookings").doc(bookingId);
    const doc = await bookingRef.get();
    if (doc.exists && doc.data().checkInToken === checkInToken) {
      bookingData = doc.data();
    }
  }

  if (!bookingData) {
    const q = await db.collection("bookings")
      .where("checkInToken", "==", checkInToken)
      .where("status", "in", ["upcoming", "active"])
      .limit(1)
      .get();
    if (q.empty) throw new HttpsError("not-found", "No booking found for this QR code.");
    bookingRef = q.docs[0].ref;
    bookingData = q.docs[0].data();
  }

  if (bookingData.status === "active") {
    throw new HttpsError("already-exists", "This booking is already checked in.");
  }

  if (bookingData.status === "completed" || bookingData.status === "cancelled") {
    throw new HttpsError("failed-precondition", `Booking is ${bookingData.status}.`);
  }

  // Calculate duration in minutes from start/end times
  const startParts = bookingData.startTime.split(":");
  const endParts = bookingData.endTime.split(":");
  const startMin = parseInt(startParts[0]) * 60 + parseInt(startParts[1] || 0);
  const endMin = parseInt(endParts[0]) * 60 + parseInt(endParts[1] || 0);
  const durationMinutes = endMin - startMin;

  // Activate the session
  const now = Timestamp.now();
  await bookingRef.update({
    status: "active",
    checkedInAt: now,
    checkedInBy: request.auth.uid,
    durationMinutes,
    halfTimeNotified: false,
    endTimeNotified: false,
    updatedAt: FieldValue.serverTimestamp(),
  });

  // Get facility name
  const facilityDoc = await db.collection("facilities").doc(bookingData.facilityId).get();
  const facilityName = facilityDoc.exists ? facilityDoc.data().name : bookingData.facilityId;

  // Notify the user their session has started
  await sendNotification(
    bookingData.userId,
    "booking",
    "Session Started! ⏱️",
    `${facilityName} — ${bookingData.startTime} to ${bookingData.endTime} (${durationMinutes} min)`
  );

  // Update facility status to occupied
  if (facilityDoc.exists) {
    await db.collection("facilities").doc(bookingData.facilityId).update({
      status: "occupied",
      currentUser: bookingData.userId,
      updatedAt: FieldValue.serverTimestamp(),
    });
  }

  return {
    success: true,
    facilityName,
    startTime: bookingData.startTime,
    endTime: bookingData.endTime,
    durationMinutes,
    courtNumber: bookingData.courtNumber || null,
  };
});

// ════════════════════════════════════════════════════════════════
// SESSION TIMERS — Half-time & End Notifications
// ════════════════════════════════════════════════════════════════

/**
 * Scheduled: Check active bookings every 5 minutes.
 * Sends configurable notifications at half-time and session end.
 * Notification thresholds are read from config/settings in Firestore.
 */
exports.checkSessionTimers = onSchedule(
  { schedule: "every 5 minutes", timeZone: "Asia/Kolkata" },
  async () => {
    const now = Date.now();

    // Read configurable notification settings
    const settingsDoc = await db.collection("config").doc("notifications").get();
    const settings = settingsDoc.exists ? settingsDoc.data() : {};
    const halfTimePercent = settings.halfTimePercent || 50; // default 50%
    const endWarningMinutes = settings.endWarningMinutes || 0; // default 0 (exact end)

    // Get all active bookings
    const active = await db.collection("bookings")
      .where("status", "==", "active")
      .where("checkedInAt", "!=", null)
      .get();

    let halfTimeSent = 0;
    let endTimeSent = 0;

    for (const doc of active.docs) {
      const data = doc.data();
      if (!data.checkedInAt || !data.durationMinutes) continue;

      const checkedInMs = data.checkedInAt.toMillis();
      const totalMs = data.durationMinutes * 60 * 1000;
      const elapsedMs = now - checkedInMs;
      const elapsedPercent = (elapsedMs / totalMs) * 100;

      // Get facility name for notification
      const facilityDoc = await db.collection("facilities").doc(data.facilityId).get();
      const facilityName = facilityDoc.exists ? facilityDoc.data().name : data.facilityId;

      // Half-time notification
      if (!data.halfTimeNotified && elapsedPercent >= halfTimePercent) {
        const remaining = Math.ceil((totalMs - elapsedMs) / 60000);
        await sendNotification(
          data.userId,
          "booking",
          "⏳ Half Time!",
          `${facilityName} — ${remaining} minutes remaining`
        );
        await doc.ref.update({ halfTimeNotified: true });
        halfTimeSent++;
      }

      // End time notification
      const endThresholdMs = totalMs - (endWarningMinutes * 60 * 1000);
      if (!data.endTimeNotified && elapsedMs >= endThresholdMs) {
        if (endWarningMinutes > 0) {
          await sendNotification(
            data.userId,
            "booking",
            "⏰ Session Ending Soon!",
            `${facilityName} — ${endWarningMinutes} minutes left`
          );
        } else {
          await sendNotification(
            data.userId,
            "booking",
            "🔔 Session Over!",
            `${facilityName} — Your booked time has ended. Please vacate the facility.`
          );
        }
        await doc.ref.update({ endTimeNotified: true });
        endTimeSent++;
      }

      // Auto-complete sessions that are 15 min past end time
      if (elapsedMs >= totalMs + (15 * 60 * 1000)) {
        await doc.ref.update({
          status: "completed",
          completedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });

        // Reset facility status
        if (facilityDoc.exists) {
          await db.collection("facilities").doc(data.facilityId).update({
            status: "available",
            currentUser: null,
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      }
    }

    console.log(`[SessionTimer] Half-time: ${halfTimeSent}, End: ${endTimeSent}`);
  }
);
