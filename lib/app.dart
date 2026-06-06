import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'models/models.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/guest_home_screen.dart';
import 'features/home/student_home_screen.dart';
import 'features/bookings/bookings_screen.dart';
import 'features/community/community_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/coaching/coaching_member_screen.dart';
import 'features/coaching/coach_dashboard_screen.dart';
import 'features/staff/receptionist_screen.dart';
import 'features/staff/facility_manager_screen.dart';
import 'features/staff/admin_screen.dart';
import 'features/staff/tournament_organizer_screen.dart';
import 'features/staff/housekeeping_screen.dart';
import 'features/bookings/today_bookings_screen.dart';
import 'features/bookings/walkin_booking_screen.dart';

class OnyxApp extends StatelessWidget {
  const OnyxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ONYX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}

/// Role-specific tab configuration.
class _TabConfig {
  final IconData icon;
  final String label;
  final Widget screen;
  const _TabConfig({required this.icon, required this.label, required this.screen});
}

/// Main navigation shell — fully adapts tabs per user role.
class OnyxShell extends StatefulWidget {
  final UserRole role;
  const OnyxShell({super.key, this.role = UserRole.guest});

  @override
  State<OnyxShell> createState() => _OnyxShellState();
}

class _OnyxShellState extends State<OnyxShell> {
  int _currentIndex = 0;

  List<_TabConfig> get _tabs => switch (widget.role) {
    // ── Guest Player ─────────────────────────────────────
    UserRole.guest => [
      const _TabConfig(icon: Icons.dashboard_rounded, label: 'Home', screen: GuestHomeScreen()),
      const _TabConfig(icon: Icons.calendar_today_rounded, label: 'Bookings', screen: BookingsScreen()),
      const _TabConfig(icon: Icons.people_outline_rounded, label: 'Community', screen: CommunityScreen()),
      const _TabConfig(icon: Icons.leaderboard_outlined, label: 'Leaderboard', screen: LeaderboardScreen()),
      _TabConfig(icon: Icons.person_outline_rounded, label: 'Profile', screen: ProfileScreen(role: widget.role)),
    ],

    // ── Coaching Member ──────────────────────────────────
    UserRole.coachingMember => [
      const _TabConfig(icon: Icons.dashboard_rounded, label: 'Home', screen: StudentHomeScreen()),
      const _TabConfig(icon: Icons.calendar_today_rounded, label: 'Bookings', screen: BookingsScreen()),
      const _TabConfig(icon: Icons.school_rounded, label: 'Coaching', screen: CoachingMemberScreen()),
      const _TabConfig(icon: Icons.people_outline_rounded, label: 'Community', screen: CommunityScreen()),
      _TabConfig(icon: Icons.person_outline_rounded, label: 'Profile', screen: ProfileScreen(role: widget.role)),
    ],

    // ── Coach ────────────────────────────────────────────
    UserRole.coach => [
      const _TabConfig(icon: Icons.dashboard_rounded, label: 'Dashboard', screen: CoachDashboardScreen()),
      const _TabConfig(icon: Icons.directions_walk_rounded, label: 'Walk-In', screen: WalkInBookingScreen()),
      const _TabConfig(icon: Icons.leaderboard_outlined, label: 'Leaderboard', screen: LeaderboardScreen()),
      _TabConfig(icon: Icons.person_outline_rounded, label: 'Profile', screen: ProfileScreen(role: widget.role)),
    ],

    // ── Receptionist ─────────────────────────────────────
    UserRole.receptionist => [
      const _TabConfig(icon: Icons.dashboard_rounded, label: 'Dashboard', screen: ReceptionistScreen()),
      const _TabConfig(icon: Icons.calendar_today_rounded, label: 'Today', screen: TodayBookingsScreen()),
      _TabConfig(icon: Icons.person_outline_rounded, label: 'Profile', screen: ProfileScreen(role: widget.role)),
    ],

    // ── Facility Manager ─────────────────────────────────
    UserRole.facilityManager => [
      const _TabConfig(icon: Icons.dashboard_rounded, label: 'Dashboard', screen: FacilityManagerScreen()),
      const _TabConfig(icon: Icons.directions_walk_rounded, label: 'Walk-In', screen: WalkInBookingScreen()),
      _TabConfig(icon: Icons.person_outline_rounded, label: 'Profile', screen: ProfileScreen(role: widget.role)),
    ],

    // ── Administrator ────────────────────────────────────
    UserRole.admin => [
      const _TabConfig(icon: Icons.dashboard_rounded, label: 'Dashboard', screen: AdminScreen()),
      const _TabConfig(icon: Icons.directions_walk_rounded, label: 'Walk-In', screen: WalkInBookingScreen()),
      _TabConfig(icon: Icons.person_outline_rounded, label: 'Profile', screen: ProfileScreen(role: widget.role)),
    ],

    // ── Tournament Organizer ─────────────────────────────
    UserRole.tournamentOrganizer => [
      const _TabConfig(icon: Icons.dashboard_rounded, label: 'Dashboard', screen: TournamentOrganizerScreen()),
      const _TabConfig(icon: Icons.calendar_today_rounded, label: 'Bookings', screen: BookingsScreen()),
      _TabConfig(icon: Icons.person_outline_rounded, label: 'Profile', screen: ProfileScreen(role: widget.role)),
    ],

    // ── Housekeeping (NO profile tab) ────────────────────
    UserRole.housekeeping => const [
      _TabConfig(icon: Icons.cleaning_services_rounded, label: 'Tasks', screen: HousekeepingScreen()),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;

    // Housekeeping: single screen, no bottom nav
    if (widget.role == UserRole.housekeeping) {
      return const HousekeepingScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: tabs.map((t) => BottomNavigationBarItem(
            icon: Icon(t.icon, size: 22),
            label: t.label,
          )).toList(),
        ),
      ),
    );
  }
}
