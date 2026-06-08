/// ONYX Firebase Service — Centralized backend interface.
///
/// Wraps Firestore, Cloud Functions, and Auth calls.
/// Replace MockData references with these methods for live data.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  final _db = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;
  final _auth = FirebaseAuth.instance;

  // ── Auth ──────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signUpWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> createUserProfile({required String name, String? phone}) async {
    await _functions.httpsCallable('createUserProfile').call({
      'name': name,
      'phone': phone ?? '',
    });
  }

  // ── User Profile ─────────────────────────────────────────────

  Stream<DocumentSnapshot> userProfileStream(String uid) =>
      _db.collection('users').doc(uid).snapshots();

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) =>
      _db.collection('users').doc(uid).update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  // ── Facilities ────────────────────────────────────────────────

  Stream<QuerySnapshot> facilitiesStream() =>
      _db.collection('facilities').snapshots();

  Stream<QuerySnapshot> facilityTimelineStream(String facilityId, String date) =>
      _db.collection('facilities').doc(facilityId)
          .collection('timeline')
          .where('date', isEqualTo: date)
          .orderBy('startTime')
          .snapshots();

  // ── Bookings ──────────────────────────────────────────────────

  Future<String> createBooking({
    required String facilityId,
    required String date,
    required String startTime,
    required String endTime,
    String? courtNumber,
    double amount = 0,
    String paymentMode = 'online',
  }) async {
    final result = await _functions.httpsCallable('createBooking').call({
      'facilityId': facilityId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'courtNumber': courtNumber,
      'amount': amount,
      'paymentMode': paymentMode,
    });
    return result.data['bookingId'];
  }

  Future<void> cancelBooking(String bookingId, {String? reason}) =>
      _functions.httpsCallable('cancelBooking').call({
        'bookingId': bookingId,
        'reason': reason ?? 'User cancelled',
      });

  Stream<QuerySnapshot> userBookingsStream(String uid) =>
      _db.collection('bookings')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots();

  Stream<QuerySnapshot> todayBookingsStream(String date) =>
      _db.collection('bookings')
          .where('date', isEqualTo: date)
          .where('status', whereIn: ['upcoming', 'active'])
          .snapshots();

  // Walk-in bookings
  Future<String> createWalkInBooking({
    required String guestName,
    String? guestPhone,
    required String facilityId,
    required String date,
    required String startTime,
    String? endTime,
    String? courtNumber,
    double amount = 0,
    String paymentMode = 'cash',
  }) async {
    final result = await _functions.httpsCallable('createWalkInBooking').call({
      'guestName': guestName,
      'guestPhone': guestPhone ?? '',
      'facilityId': facilityId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime ?? '',
      'courtNumber': courtNumber,
      'amount': amount,
      'paymentMode': paymentMode,
    });
    return result.data['bookingId'];
  }

  // ── Coaching & Attendance ─────────────────────────────────────

  Stream<QuerySnapshot> batchesStream(String coachId) =>
      _db.collection('batches')
          .where('coachId', isEqualTo: coachId)
          .snapshots();

  Future<void> markAttendance({
    required String batchId,
    required String date,
    required List<Map<String, String>> attendanceRecords,
  }) => _functions.httpsCallable('markAttendance').call({
    'batchId': batchId,
    'date': date,
    'attendanceRecords': attendanceRecords,
  });

  Stream<QuerySnapshot> studentAttendanceStream(String batchId) =>
      _db.collection('batches').doc(batchId)
          .collection('attendance')
          .orderBy('markedAt', descending: true)
          .limit(30)
          .snapshots();

  // ── Session Cancellation ──────────────────────────────────────

  Future<int> cancelSession({
    required String batchId,
    required String date,
    required String reason,
  }) async {
    final result = await _functions.httpsCallable('cancelSession').call({
      'batchId': batchId,
      'date': date,
      'reason': reason,
    });
    return result.data['cancellationsUsed'];
  }

  Stream<QuerySnapshot> cancellationsStream(String coachId) =>
      _db.collection('sessionCancellations')
          .where('coachId', isEqualTo: coachId)
          .orderBy('createdAt', descending: true)
          .snapshots();

  // ── Student Biodata ───────────────────────────────────────────

  Future<Map<String, dynamic>?> getStudentProfile(String uid) async {
    final doc = await _db.collection('studentProfiles').doc(uid).get();
    return doc.data();
  }

  Future<void> updateStudentProfile(String uid, Map<String, dynamic> data) =>
      _db.collection('studentProfiles').doc(uid).set(data, SetOptions(merge: true));

  // ── Announcements ─────────────────────────────────────────────

  Future<void> createAnnouncement({
    required String title,
    required String body,
    required String type,
    required String targetBatch,
  }) => _db.collection('announcements').add({
    'title': title,
    'body': body,
    'type': type,
    'targetBatch': targetBatch,
    'authorId': currentUser?.uid ?? '',
    'createdAt': FieldValue.serverTimestamp(),
  });

  Stream<QuerySnapshot> announcementsStream({String? batchName}) {
    Query query = _db.collection('announcements').orderBy('createdAt', descending: true).limit(20);
    if (batchName != null) {
      query = query.where('targetBatch', whereIn: [batchName, 'all', 'All Batches']);
    }
    return query.snapshots();
  }

  // ── Tournaments ───────────────────────────────────────────────

  Stream<QuerySnapshot> tournamentsStream() =>
      _db.collection('tournaments').orderBy('date').snapshots();

  Future<void> registerForTournament(String tournamentId) =>
      _db.collection('tournaments').doc(tournamentId)
          .collection('registrations').doc(currentUser!.uid).set({
        'userId': currentUser!.uid,
        'registeredAt': FieldValue.serverTimestamp(),
      });

  // ── Payments ──────────────────────────────────────────────────

  Future<String> recordPayment({
    String? userId,
    required String description,
    required double amount,
    String type = 'booking',
    String paymentMode = 'online',
    Map<String, dynamic>? membershipData,
  }) async {
    final result = await _functions.httpsCallable('recordPayment').call({
      'userId': userId,
      'description': description,
      'amount': amount,
      'type': type,
      'paymentMode': paymentMode,
      if (membershipData != null) 'membershipData': membershipData,
    });
    return result.data['paymentId'];
  }

  Stream<QuerySnapshot> paymentHistoryStream(String uid) =>
      _db.collection('payments')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots();

  // ── Notifications ─────────────────────────────────────────────

  Stream<QuerySnapshot> notificationsStream(String uid) =>
      _db.collection('notifications')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .snapshots();

  Future<void> markNotificationRead(String notifId) =>
      _db.collection('notifications').doc(notifId).update({'isRead': true});

  // ── Leaderboard ───────────────────────────────────────────────

  Stream<QuerySnapshot> leaderboardStream() =>
      _db.collection('leaderboard')
          .orderBy('rank')
          .limit(50)
          .snapshots();

  // ── Community — Open Play ─────────────────────────────────────

  Stream<QuerySnapshot> openPlayStream() =>
      _db.collection('openPlayRequests')
          .orderBy('date')
          .snapshots();

  Future<void> createOpenPlayRequest(Map<String, dynamic> data) =>
      _db.collection('openPlayRequests').add({
        ...data,
        'creatorId': currentUser?.uid ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> joinOpenPlay(String requestId) =>
      _db.collection('openPlayRequests').doc(requestId)
          .collection('participants').doc(currentUser!.uid).set({
        'joinedAt': FieldValue.serverTimestamp(),
      });

  // ── Housekeeping ──────────────────────────────────────────────

  Stream<QuerySnapshot> housekeepingTasksStream() =>
      _db.collection('housekeepingTasks')
          .orderBy('dueDate')
          .snapshots();

  Future<void> completeTask(String taskId) =>
      _db.collection('housekeepingTasks').doc(taskId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

  // ── Config ────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getConfig() async {
    final doc = await _db.collection('config').doc('pricing').get();
    return doc.data();
  }

  // ── Seed (Development) ────────────────────────────────────────

  Future<void> seedDatabase() =>
      _functions.httpsCallable('seedDatabase').call();
}
