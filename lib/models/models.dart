/// ONYX Data Models
///
/// Simple Dart classes for UI-only mock data.
library;

// ── Enums ──────────────────────────────────────────────────────

enum FacilityType { badmintonCourt, cricketTurf, cricketNets }
enum FacilityStatus { available, occupied, maintenance, reserved }
enum BookingStatus { upcoming, active, completed, cancelled }
enum PaymentStatus { pending, paid, failed, refunded }
enum ExperienceLevel { beginner, intermediate, advanced, expert }
enum MembershipType { monthly, quarterly, annual }
enum MembershipStatus { active, expired, expiringSoon }
enum NotificationType { booking, facility, membership, tournament, coaching, matchFound, general }
enum PlayFormat { singles, doubles }
enum SportType { badminton, cricket }
enum UserRole { guest, member, coachingMember, coach, receptionist, facilityManager, admin, tournamentOrganizer, housekeeping }

// ── Facility ───────────────────────────────────────────────────

class Facility {
  final String id;
  final String name;
  final String shortName;
  final FacilityType type;
  final FacilityStatus status;
  final String? currentUser;
  final int? timeRemainingMinutes;

  final String? nextAvailableTime;
  final String? bookingEndTime;

  const Facility({
    required this.id, required this.name, required this.shortName,
    required this.type, required this.status, this.currentUser,
    this.timeRemainingMinutes,
    this.nextAvailableTime, this.bookingEndTime,
  });

  factory Facility.fromFirestore(Map<String, dynamic> data, String id) {
    return Facility(
      id: id,
      name: data['name'] ?? '',
      shortName: data['shortName'] ?? '',
      type: _parseFacilityType(data['type']),
      status: _parseFacilityStatus(data['status']),
      currentUser: data['currentUser'],
      timeRemainingMinutes: data['timeRemainingMinutes'],
      nextAvailableTime: data['nextAvailableTime'],
      bookingEndTime: data['bookingEndTime'],
    );
  }

  static FacilityType _parseFacilityType(String? s) => switch (s) {
    'badmintonCourt' => FacilityType.badmintonCourt,
    'cricketTurf' => FacilityType.cricketTurf,
    'cricketNets' => FacilityType.cricketNets,
    _ => FacilityType.badmintonCourt,
  };

  static FacilityStatus _parseFacilityStatus(String? s) => switch (s) {
    'available' => FacilityStatus.available,
    'occupied' => FacilityStatus.occupied,
    'maintenance' => FacilityStatus.maintenance,
    'reserved' => FacilityStatus.reserved,
    _ => FacilityStatus.available,
  };
}

// ── Booking ────────────────────────────────────────────────────

class Booking {
  final String id;
  final String facilityName;
  final String? facilityId;
  final FacilityType facilityType;
  final String date;
  final String timeSlot;
  final BookingStatus status;
  final String? courtNumber;
  final int durationMinutes;
  final double? amount;
  final String? checkInToken;
  final String? paymentStatus;
  final String? paymentMode;

  const Booking({
    required this.id, required this.facilityName, this.facilityId,
    required this.facilityType, required this.date, required this.timeSlot,
    required this.status, this.courtNumber, this.durationMinutes = 60,
    this.amount, this.checkInToken, this.paymentStatus, this.paymentMode,
  });

  factory Booking.fromFirestore(Map<String, dynamic> data, String id) {
    final facilityId = data['facilityId'] ?? '';
    return Booking(
      id: id,
      facilityId: facilityId,
      facilityName: data['courtNumber'] ?? _facilityLabel(facilityId),
      facilityType: _typeFromId(facilityId),
      date: data['date'] ?? '',
      timeSlot: '${data['startTime'] ?? ''} — ${data['endTime'] ?? ''}',
      status: _parseStatus(data['status']),
      courtNumber: data['courtNumber'],
      durationMinutes: data['durationMinutes'] ?? 60,
      amount: (data['amount'] ?? 0).toDouble(),
      checkInToken: data['checkInToken'],
      paymentStatus: data['paymentStatus'],
      paymentMode: data['paymentMode'],
    );
  }

  static BookingStatus _parseStatus(String? s) => switch (s) {
    'upcoming' => BookingStatus.upcoming,
    'active' => BookingStatus.active,
    'completed' => BookingStatus.completed,
    'cancelled' => BookingStatus.cancelled,
    _ => BookingStatus.upcoming,
  };

  static FacilityType _typeFromId(String id) {
    if (id.startsWith('court')) return FacilityType.badmintonCourt;
    if (id == 'turf') return FacilityType.cricketTurf;
    return FacilityType.cricketNets;
  }

  static String _facilityLabel(String id) {
    if (id == 'court-1') return 'Court 1';
    if (id == 'court-2') return 'Court 2';
    if (id == 'court-3') return 'Court 3';
    if (id == 'turf') return 'Cricket Turf';
    if (id == 'nets') return 'Cricket Nets';
    return id;
  }
}

// ── TimeSlot ───────────────────────────────────────────────────

class TimeSlot {
  final String time;
  final bool isAvailable;
  final double? price;
  final bool isPeak;

  const TimeSlot({required this.time, this.isAvailable = true, this.price, this.isPeak = false});
}



// ── User Profile ───────────────────────────────────────────────

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final ExperienceLevel level;
  final MembershipType? membershipType;
  final MembershipStatus? membershipStatus;
  final String? membershipExpiry;
  final int totalSessions;
  final int totalHours;
  final int currentStreak;
  final String favoriteFacility;
  final String mostActiveDay;

  const UserProfile({
    required this.id, required this.name, required this.email,
    this.phone, required this.level, this.membershipType,
    this.membershipStatus, this.membershipExpiry,
    this.totalSessions = 0, this.totalHours = 0, this.currentStreak = 0,
    this.favoriteFacility = '', this.mostActiveDay = '',
  });
}

// ── Leaderboard Entry ──────────────────────────────────────────

class LeaderboardEntry {
  final int rank;
  final String playerName;
  final int sessions;
  final int hours;
  final int streak;

  const LeaderboardEntry({
    required this.rank, required this.playerName,
    required this.sessions, required this.hours, this.streak = 0,
  });
}

// ── Tournament ─────────────────────────────────────────────────

class Tournament {
  final String id;
  final String name;
  final String date;
  final String? endDate;
  final double entryFee;
  final double prizePool;
  final int participants;
  final int maxParticipants;
  final String status;
  final SportType sport;
  final String rules;
  final List<String> schedule;

  const Tournament({
    required this.id, required this.name, required this.date,
    this.endDate, required this.entryFee, required this.prizePool,
    required this.participants, required this.maxParticipants,
    required this.status, required this.sport,
    this.rules = '', this.schedule = const [],
  });
}

// ── Coaching Session ───────────────────────────────────────────

class CoachingSession {
  final String id;
  final String coachName;
  final String batchName;
  final String date;
  final String time;
  final int durationMinutes;
  final bool attended;
  final String? notes;

  const CoachingSession({
    required this.id, required this.coachName, required this.batchName,
    required this.date, required this.time,
    this.durationMinutes = 90, this.attended = false, this.notes,
  });
}

// ── Coach Batch ────────────────────────────────────────────────

class CoachBatch {
  final String id;
  final String name;
  final String time;
  final int studentCount;
  final List<String> studentNames;
  final String level;

  const CoachBatch({
    required this.id, required this.name, required this.time,
    required this.studentCount, required this.studentNames, required this.level,
  });
}

// ── Notification Item ──────────────────────────────────────────

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String timestamp;
  final bool isRead;

  const NotificationItem({
    required this.id, required this.type, required this.title,
    required this.body, required this.timestamp, this.isRead = false,
  });
}

// ── Open Play Request ──────────────────────────────────────────

class OpenPlayRequest {
  final String id;
  final String creatorName;
  final SportType sport;
  final PlayFormat format;
  final ExperienceLevel level;
  final String date;
  final String time;
  final String? facility;
  final int playersNeeded;
  final int playersJoined;

  const OpenPlayRequest({
    required this.id, required this.creatorName, required this.sport,
    required this.format, required this.level, required this.date,
    required this.time, this.facility, required this.playersNeeded,
    this.playersJoined = 0,
  });
}

// ── Payment Record ─────────────────────────────────────────────

class PaymentRecord {
  final String id;
  final String description;
  final double amount;
  final String date;
  final String status;

  const PaymentRecord({
    required this.id, required this.description, required this.amount,
    required this.date, required this.status,
  });
}

// ── Facility Timeline Entry ────────────────────────────────────

class FacilityTimelineEntry {
  final String time;
  final String userName;
  final int durationMinutes;
  final bool isCurrent;

  const FacilityTimelineEntry({
    required this.time, required this.userName,
    required this.durationMinutes, this.isCurrent = false,
  });
}

// ── Achievement ────────────────────────────────────────────────

class Achievement {
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final String? unlockedDate;

  const Achievement({
    required this.title, required this.description,
    required this.icon, this.unlocked = false, this.unlockedDate,
  });
}
