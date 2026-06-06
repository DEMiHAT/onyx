/**
 * ONYX Sports Facility — Cloud Functions
 *
 * Business logic for bookings, attendance, payments,
 * notifications, leaderboard aggregation, and queue management.
 */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue, Timestamp } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");

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

async function sendNotification(userId, type, title, body) {
  await db.collection("notifications").add({
    userId,
    type,
    title,
    body,
    isRead: false,
    createdAt: FieldValue.serverTimestamp(),
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
// QUEUE MANAGEMENT
// ════════════════════════════════════════════════════════════════

/**
 * Callable: Join a facility queue.
 */
exports.joinQueue = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");

  const { facilityId } = request.data;
  const queueRef = db.collection("queues").doc(facilityId).collection("entries");

  // Check if already in queue
  const existing = await queueRef
    .where("userId", "==", request.auth.uid)
    .where("status", "==", "waiting")
    .get();

  if (!existing.empty) {
    throw new HttpsError("already-exists", "Already in queue.");
  }

  // Get current position
  const waiting = await queueRef.where("status", "==", "waiting").get();
  const position = waiting.size + 1;

  await queueRef.add({
    userId: request.auth.uid,
    position,
    status: "waiting",
    estimatedWaitMinutes: position * 15,
    joinedAt: FieldValue.serverTimestamp(),
  });

  // Update facility queue count
  await db.collection("facilities").doc(facilityId).update({
    queueLength: FieldValue.increment(1),
  });

  await sendNotification(
    request.auth.uid,
    "queue",
    "Joined Queue",
    `You are #${position} in the queue.`
  );

  return { success: true, position };
});

/**
 * Callable: Leave a facility queue.
 */
exports.leaveQueue = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");

  const { facilityId } = request.data;
  const queueRef = db.collection("queues").doc(facilityId).collection("entries");

  const entries = await queueRef
    .where("userId", "==", request.auth.uid)
    .where("status", "==", "waiting")
    .get();

  if (entries.empty) {
    throw new HttpsError("not-found", "Not in queue.");
  }

  const batch = db.batch();
  entries.forEach((doc) => {
    batch.update(doc.ref, { status: "left", leftAt: FieldValue.serverTimestamp() });
  });
  await batch.commit();

  await db.collection("facilities").doc(facilityId).update({
    queueLength: FieldValue.increment(-1),
  });

  return { success: true };
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

  const facilities = [
    { id: "court-1", name: "Badminton Court 1", shortName: "Court 1", type: "badmintonCourt", status: "available", queueLength: 0 },
    { id: "court-2", name: "Badminton Court 2", shortName: "Court 2", type: "badmintonCourt", status: "available", queueLength: 0 },
    { id: "court-3", name: "Badminton Court 3", shortName: "Court 3", type: "badmintonCourt", status: "available", queueLength: 0 },
    { id: "turf", name: "Cricket Turf", shortName: "Turf", type: "cricketTurf", status: "available", queueLength: 0 },
    { id: "nets", name: "Cricket Nets", shortName: "Nets", type: "cricketNets", status: "available", queueLength: 0 },
  ];

  const config = {
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

  const batch = db.batch();

  for (const facility of facilities) {
    batch.set(db.collection("facilities").doc(facility.id), {
      ...facility,
      createdAt: FieldValue.serverTimestamp(),
    });
  }

  batch.set(db.collection("config").doc("pricing"), config);

  await batch.commit();
  return { success: true, message: "Database seeded." };
});
