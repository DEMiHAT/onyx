import '../../models/models.dart';

/// ONYX Mock Data — Realistic sample data for all screens.
class MockData {
  MockData._();

  // ── Facilities ───────────────────────────────────────────────

  static const List<Facility> facilities = [
    Facility(
      id: 'court-1', name: 'Badminton Court 1', shortName: 'Court 1',
      type: FacilityType.badmintonCourt, status: FacilityStatus.occupied,
      currentUser: 'Arjun Mehta', timeRemainingMinutes: 12,
      nextAvailableTime: '6:42 PM', bookingEndTime: '6:30 PM',
    ),
    Facility(
      id: 'court-2', name: 'Badminton Court 2', shortName: 'Court 2',
      type: FacilityType.badmintonCourt, status: FacilityStatus.available,
      nextAvailableTime: 'Now',
    ),
    Facility(
      id: 'court-3', name: 'Badminton Court 3', shortName: 'Court 3',
      type: FacilityType.badmintonCourt, status: FacilityStatus.occupied,
      currentUser: 'Priya Sharma', timeRemainingMinutes: 28,
      nextAvailableTime: '7:08 PM', bookingEndTime: '6:58 PM',
    ),
    Facility(
      id: 'nets', name: 'Cricket Nets', shortName: 'Nets',
      type: FacilityType.cricketNets, status: FacilityStatus.occupied,
      currentUser: 'Rahul Verma', timeRemainingMinutes: 45,
      nextAvailableTime: '7:15 PM', bookingEndTime: '7:15 PM',
    ),
    Facility(
      id: 'turf', name: 'Cricket Turf', shortName: 'Turf',
      type: FacilityType.cricketTurf, status: FacilityStatus.available,
      nextAvailableTime: 'Now',
    ),
  ];

  // ── Bookings ─────────────────────────────────────────────────

  static const List<Booking> bookings = [
    Booking(
      id: 'BK001', facilityName: 'Court 1', facilityType: FacilityType.badmintonCourt,
      date: 'Today', timeSlot: '7:00 PM - 8:00 PM', status: BookingStatus.upcoming,
      courtNumber: '1', amount: 600,
    ),
    Booking(
      id: 'BK002', facilityName: 'Cricket Turf', facilityType: FacilityType.cricketTurf,
      date: 'Tomorrow', timeSlot: '6:00 AM - 7:00 AM', status: BookingStatus.upcoming,
      amount: 1200,
    ),
    Booking(
      id: 'BK003', facilityName: 'Court 3', facilityType: FacilityType.badmintonCourt,
      date: 'Jun 4', timeSlot: '8:00 PM - 9:00 PM', status: BookingStatus.completed,
      courtNumber: '3', amount: 600,
    ),
    Booking(
      id: 'BK004', facilityName: 'Cricket Nets', facilityType: FacilityType.cricketNets,
      date: 'Jun 3', timeSlot: '5:00 PM - 6:00 PM', status: BookingStatus.completed,
      amount: 400,
    ),
    Booking(
      id: 'BK005', facilityName: 'Court 2', facilityType: FacilityType.badmintonCourt,
      date: 'Jun 2', timeSlot: '7:00 PM - 8:00 PM', status: BookingStatus.cancelled,
      courtNumber: '2', amount: 600,
    ),
  ];

  // ── Time Slots ───────────────────────────────────────────────

  static const List<TimeSlot> badmintonTimeSlots = [
    TimeSlot(time: '6:00 AM', isAvailable: true, price: 400),
    TimeSlot(time: '7:00 AM', isAvailable: true, price: 400),
    TimeSlot(time: '8:00 AM', isAvailable: false, price: 500, isPeak: true),
    TimeSlot(time: '9:00 AM', isAvailable: false, price: 500, isPeak: true),
    TimeSlot(time: '10:00 AM', isAvailable: true, price: 400),
    TimeSlot(time: '4:00 PM', isAvailable: true, price: 500, isPeak: true),
    TimeSlot(time: '5:00 PM', isAvailable: false, price: 600, isPeak: true),
    TimeSlot(time: '6:00 PM', isAvailable: false, price: 600, isPeak: true),
    TimeSlot(time: '7:00 PM', isAvailable: true, price: 600, isPeak: true),
    TimeSlot(time: '8:00 PM', isAvailable: true, price: 600, isPeak: true),
    TimeSlot(time: '9:00 PM', isAvailable: true, price: 500),
  ];



  // ── User Profile ─────────────────────────────────────────────

  static const UserProfile currentUser = UserProfile(
    id: 'u001', name: 'Sriram Kumar', email: 'sriram@onyx.app',
    phone: '+91 98765 43210', level: ExperienceLevel.advanced,
    membershipType: MembershipType.quarterly,
    membershipStatus: MembershipStatus.active,
    membershipExpiry: 'Aug 15, 2026',
    totalSessions: 142, totalHours: 213, currentStreak: 14,
    favoriteFacility: 'Court 1', mostActiveDay: 'Wednesday',
  );

  // ── Leaderboard ──────────────────────────────────────────────

  static const List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry(rank: 1, playerName: 'Vikram Patel', sessions: 234, hours: 351, streak: 42),
    LeaderboardEntry(rank: 2, playerName: 'Ananya Desai', sessions: 198, hours: 297, streak: 28),
    LeaderboardEntry(rank: 3, playerName: 'Rohan Iyer', sessions: 187, hours: 280, streak: 35),
    LeaderboardEntry(rank: 4, playerName: 'Sriram Kumar', sessions: 142, hours: 213, streak: 14),
    LeaderboardEntry(rank: 5, playerName: 'Kavitha Nair', sessions: 136, hours: 204, streak: 21),
    LeaderboardEntry(rank: 6, playerName: 'Aditya Rao', sessions: 128, hours: 192, streak: 7),
    LeaderboardEntry(rank: 7, playerName: 'Meera Joshi', sessions: 119, hours: 178, streak: 19),
    LeaderboardEntry(rank: 8, playerName: 'Karthik Menon', sessions: 112, hours: 168, streak: 11),
    LeaderboardEntry(rank: 9, playerName: 'Sneha Reddy', sessions: 105, hours: 157, streak: 8),
    LeaderboardEntry(rank: 10, playerName: 'Arjun Mehta', sessions: 98, hours: 147, streak: 15),
  ];

  // ── Tournaments ──────────────────────────────────────────────

  static const List<Tournament> tournaments = [
    Tournament(
      id: 't001', name: 'ONYX Summer Smash 2026', date: 'Jun 22, 2026',
      endDate: 'Jun 23, 2026', entryFee: 500, prizePool: 25000,
      participants: 28, maxParticipants: 32, status: 'upcoming',
      sport: SportType.badminton,
      rules: 'Single elimination. Best of 3 sets. 21 points per set.',
      schedule: ['Round of 32 — Jun 22, 9:00 AM', 'Quarter Finals — Jun 22, 2:00 PM', 'Semi Finals — Jun 23, 10:00 AM', 'Finals — Jun 23, 4:00 PM'],
    ),
    Tournament(
      id: 't002', name: 'Weekend Warriors Cup', date: 'Jun 15, 2026',
      entryFee: 300, prizePool: 15000, participants: 16,
      maxParticipants: 16, status: 'ongoing', sport: SportType.badminton,
    ),
    Tournament(
      id: 't003', name: 'ONYX Cricket Bash', date: 'Jul 5, 2026',
      entryFee: 1000, prizePool: 50000, participants: 8,
      maxParticipants: 12, status: 'upcoming', sport: SportType.cricket,
    ),
  ];

  // ── Coaching Sessions ────────────────────────────────────────

  static const List<CoachingSession> coachingSessions = [
    CoachingSession(id: 'cs001', coachName: 'Coach Rajesh', batchName: 'Advanced A', date: 'Today', time: '6:00 AM', attended: true),
    CoachingSession(id: 'cs002', coachName: 'Coach Rajesh', batchName: 'Advanced A', date: 'Tomorrow', time: '6:00 AM'),
    CoachingSession(id: 'cs003', coachName: 'Coach Rajesh', batchName: 'Advanced A', date: 'Jun 8', time: '6:00 AM'),
    CoachingSession(id: 'cs004', coachName: 'Coach Rajesh', batchName: 'Advanced A', date: 'Jun 9', time: '6:00 AM'),
  ];

  // ── Coach Batches ────────────────────────────────────────────

  static const List<CoachBatch> coachBatches = [
    CoachBatch(id: 'b001', name: 'Advanced A', time: '6:00 AM - 7:30 AM', studentCount: 8, studentNames: ['Sriram', 'Ananya', 'Rohan', 'Kavitha', 'Aditya', 'Meera', 'Karthik', 'Sneha'], level: 'Advanced'),
    CoachBatch(id: 'b002', name: 'Intermediate B', time: '7:30 AM - 9:00 AM', studentCount: 10, studentNames: ['Rahul', 'Priya', 'Vikram', 'Neha', 'Suresh', 'Divya', 'Amit', 'Pooja', 'Ravi', 'Anjali'], level: 'Intermediate'),
    CoachBatch(id: 'b003', name: 'Beginner C', time: '5:00 PM - 6:30 PM', studentCount: 12, studentNames: ['Student 1', 'Student 2', 'Student 3', 'Student 4', 'Student 5', 'Student 6', 'Student 7', 'Student 8', 'Student 9', 'Student 10', 'Student 11', 'Student 12'], level: 'Beginner'),
  ];

  // ── Notifications ────────────────────────────────────────────

  static const List<NotificationItem> notifications = [
    NotificationItem(id: 'n001', type: NotificationType.booking, title: 'Booking Confirmed', body: 'Court 1 — Today, 7:00 PM', timestamp: '2 min ago'),

    NotificationItem(id: 'n003', type: NotificationType.facility, title: 'Court 2 Available', body: 'Court 2 is now free. Book now!', timestamp: '12 min ago'),
    NotificationItem(id: 'n004', type: NotificationType.tournament, title: 'Tournament Registration Open', body: 'ONYX Summer Smash 2026 — 4 spots left', timestamp: '1 hour ago'),
    NotificationItem(id: 'n005', type: NotificationType.membership, title: 'Membership Renewal', body: 'Your quarterly plan expires Aug 15', timestamp: '3 hours ago', isRead: true),
    NotificationItem(id: 'n006', type: NotificationType.coaching, title: 'Session Tomorrow', body: 'Advanced A batch — 6:00 AM, Court 1', timestamp: '5 hours ago', isRead: true),
    NotificationItem(id: 'n007', type: NotificationType.matchFound, title: 'Match Found!', body: 'Rohan Iyer wants to play doubles', timestamp: 'Yesterday', isRead: true),
  ];

  // ── Open Play Requests ───────────────────────────────────────

  static const List<OpenPlayRequest> openPlayRequests = [
    OpenPlayRequest(id: 'op001', creatorName: 'Rohan Iyer', sport: SportType.badminton, format: PlayFormat.doubles, level: ExperienceLevel.advanced, date: 'Tomorrow', time: '7:00 AM', facility: 'Court 2', playersNeeded: 3, playersJoined: 1),
    OpenPlayRequest(id: 'op002', creatorName: 'Kavitha Nair', sport: SportType.badminton, format: PlayFormat.singles, level: ExperienceLevel.intermediate, date: 'Tomorrow', time: '6:00 PM', playersNeeded: 1),
    OpenPlayRequest(id: 'op003', creatorName: 'Aditya Rao', sport: SportType.cricket, format: PlayFormat.doubles, level: ExperienceLevel.beginner, date: 'Jun 8', time: '5:00 PM', facility: 'Turf', playersNeeded: 10, playersJoined: 4),
  ];

  // ── Payment History ──────────────────────────────────────────

  static const List<PaymentRecord> payments = [
    PaymentRecord(id: 'p001', description: 'Court 1 Booking', amount: 600, date: 'Jun 5', status: 'paid'),
    PaymentRecord(id: 'p002', description: 'Quarterly Membership', amount: 8500, date: 'May 15', status: 'paid'),
    PaymentRecord(id: 'p003', description: 'Tournament Entry', amount: 500, date: 'May 10', status: 'paid'),
    PaymentRecord(id: 'p004', description: 'Cricket Turf Booking', amount: 1200, date: 'May 8', status: 'paid'),
    PaymentRecord(id: 'p005', description: 'Coaching Fee — June', amount: 3000, date: 'Jun 1', status: 'pending'),
  ];

  // ── Facility Timeline ────────────────────────────────────────

  static const List<FacilityTimelineEntry> court1Timeline = [
    FacilityTimelineEntry(time: '5:00 PM', userName: 'Vikram Patel', durationMinutes: 60),
    FacilityTimelineEntry(time: '6:00 PM', userName: 'Arjun Mehta', durationMinutes: 60, isCurrent: true),
    FacilityTimelineEntry(time: '7:00 PM', userName: 'Sriram Kumar', durationMinutes: 60),
    FacilityTimelineEntry(time: '8:00 PM', userName: 'Available', durationMinutes: 60),
    FacilityTimelineEntry(time: '9:00 PM', userName: 'Rohan Iyer', durationMinutes: 60),
  ];

  // ── Achievements ─────────────────────────────────────────────

  static const List<Achievement> achievements = [
    Achievement(title: 'First Rally', description: 'Complete your first session', icon: '🏸', unlocked: true, unlockedDate: 'Jan 15, 2026'),
    Achievement(title: 'Century Club', description: 'Complete 100 sessions', icon: '💯', unlocked: true, unlockedDate: 'Apr 20, 2026'),
    Achievement(title: 'Iron Will', description: 'Maintain a 7-day streak', icon: '🔥', unlocked: true, unlockedDate: 'May 2, 2026'),
    Achievement(title: 'Court Master', description: 'Play 200 hours', icon: '👑', unlocked: true, unlockedDate: 'May 28, 2026'),
    Achievement(title: 'All-Rounder', description: 'Use every facility', icon: '⭐', unlocked: true, unlockedDate: 'Mar 10, 2026'),
    Achievement(title: 'Tournament Victor', description: 'Win a tournament', icon: '🏆', unlocked: false),
    Achievement(title: 'Marathon Player', description: 'Play 500 hours', icon: '⚡', unlocked: false),
    Achievement(title: 'Legendary Streak', description: 'Maintain a 30-day streak', icon: '🌟', unlocked: false),
  ];
}
