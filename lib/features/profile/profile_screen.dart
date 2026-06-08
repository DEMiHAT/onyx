import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/services/auth_service.dart';
import '../../models/models.dart';
import '../analytics/analytics_screen.dart';
import '../coaching/coaching_member_screen.dart';
import '../membership/membership_screen.dart';
import '../membership/membership_payment_screen.dart';
import '../bookings/bookings_screen.dart';
import '../auth/login_screen.dart';

/// Profile Screen — Role-aware user profile.
///
/// Sections shown per role:
///   Achievements:  Guest, CoachingMember only
///   Membership:    Guest, CoachingMember only
///   Activity:      Guest, CoachingMember, Coach
///   Quick Links:   Tailored per role
class ProfileScreen extends StatelessWidget {
  final UserRole role;
  const ProfileScreen({super.key, this.role = UserRole.guest});

  // Roles that are "players" (use the facility to play)
  bool get _isPlayer => role == UserRole.guest || role == UserRole.coachingMember;
  bool get _isCoach => role == UserRole.coach;
  bool get _isStaff => !_isPlayer && !_isCoach;

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final profile = auth.profile ?? {};
    final userName = auth.displayName;
    final initials = userName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();
    
    final level = profile['level'] ?? 'Beginner';
    final hasMembership = profile['membershipStatus'] == 'active';
    final membershipType = profile['membershipType'] ?? '';
    final totalSessions = profile['totalSessions'] ?? 0;
    final totalHours = profile['totalHours'] ?? 0;
    final currentStreak = profile['currentStreak'] ?? 0;
    final favoriteFacility = profile['favoriteFacility'] ?? 'N/A';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            title: Text('Profile', style: AppTypography.titleLarge),
            actions: [
              IconButton(icon: const Icon(Icons.settings_rounded, size: 22), onPressed: () {}),
              const SizedBox(width: 4),
            ],
          ),

          // ── Profile Header ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.surfaceSecondary,
                    child: Text(
                      initials,
                      style: AppTypography.titleLarge.copyWith(color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: AppTypography.headlineSmall),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _RoleBadge(role: role),
                            if (_isPlayer) ...[
                              const SizedBox(width: 8),
                              _LevelBadge(level: level),
                            ],
                            if (_isPlayer && hasMembership) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  membershipType.isNotEmpty ? '${membershipType[0].toUpperCase()}${membershipType.substring(1)}' : 'Member',
                                  style: AppTypography.labelSmall.copyWith(color: AppColors.success),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    onPressed: () {},
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Activity Stats (players + coach only) ─────────────
          if (_isPlayer || _isCoach) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Activity', padding: EdgeInsets.fromLTRB(16, 8, 16, 8)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: StatCard(label: 'Sessions', value: '$totalSessions', icon: Icons.sports_tennis_rounded)),
                        const SizedBox(width: 8),
                        Expanded(child: StatCard(label: 'Hours', value: '$totalHours', icon: Icons.access_time_rounded)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: StatCard(label: 'Streak', value: '${currentStreak}d', trend: 'Personal best: 21d', icon: Icons.local_fire_department_rounded)),
                        const SizedBox(width: 8),
                        Expanded(child: StatCard(label: 'Favorite', value: favoriteFacility, icon: Icons.favorite_rounded)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Achievements (players only) ───────────────────────
          if (_isPlayer) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Achievements',
                actionText: 'View All',
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Play matches to earn achievements', style: AppTypography.bodySmall),
              ),
            ),
          ],

          // ── Membership (players only — guest + coaching member) ─
          if (_isPlayer) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Membership', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
            ),
            SliverToBoxAdapter(
              child: profile['membershipStatus'] == 'active'
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Quarterly Plan', style: AppTypography.titleSmall),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text('Active', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textTertiary),
                          const SizedBox(width: 6),
                          Text('Expires ${profile['membershipExpiry'] ?? 'N/A'}', style: AppTypography.bodySmall),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: OutlinedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen())),
                            child: const Text('Manage'),
                          )),
                          const SizedBox(width: 8),
                          Expanded(child: OutlinedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipPaymentScreen())),
                            child: const Text('Renew'),
                          )),
                        ]),
                      ]),
                    )
                  // ── Non-member state ───────────────────────
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Column(children: [
                        Row(children: [
                          Icon(Icons.card_membership_rounded, size: 20, color: AppColors.accent),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Become a Member', style: AppTypography.titleSmall),
                            const SizedBox(height: 2),
                            Text('Unlock member-only slots, exclusive discounts, and more', style: AppTypography.bodySmall),
                          ])),
                        ]),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipPaymentScreen())),
                            child: const Text('View Plans & Join'),
                          ),
                        ),
                      ]),
                    ),
            ),
          ],

          // ── Quick Links (role-tailored) ────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Quick Links', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: _buildQuickLinks(context),
              ),
            ),
          ),

          // ── Logout ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutConfirmation(context),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    foregroundColor: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuickLinks(BuildContext context) {
    final links = <Widget>[];

    // Guest: Bookings, Analytics, Membership, Payment, QR, Help
    if (role == UserRole.guest) {
      links.addAll([
        _ProfileMenuItem(icon: Icons.calendar_today_rounded, label: 'My Bookings', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen()))),
        _ProfileMenuItem(icon: Icons.analytics_rounded, label: 'Analytics', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()))),
        _ProfileMenuItem(icon: Icons.card_membership_rounded, label: 'Membership', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen()))),
        _ProfileMenuItem(icon: Icons.payment_rounded, label: 'Payment History', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen()))),
        _ProfileMenuItem(icon: Icons.qr_code_rounded, label: 'QR Access Pass', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen()))),
        _ProfileMenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}, isLast: true),
      ]);
    }

    // Coaching Member: Bookings, Coaching, Analytics, Membership, Payment, QR, Help
    if (role == UserRole.coachingMember) {
      links.addAll([
        _ProfileMenuItem(icon: Icons.calendar_today_rounded, label: 'My Bookings', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen()))),
        _ProfileMenuItem(icon: Icons.school_rounded, label: 'Coaching', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoachingMemberScreen()))),
        _ProfileMenuItem(icon: Icons.analytics_rounded, label: 'Analytics', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()))),
        _ProfileMenuItem(icon: Icons.card_membership_rounded, label: 'Membership', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen()))),
        _ProfileMenuItem(icon: Icons.payment_rounded, label: 'Payment History', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen()))),
        _ProfileMenuItem(icon: Icons.qr_code_rounded, label: 'QR Access Pass', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen()))),
        _ProfileMenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}, isLast: true),
      ]);
    }

    // Coach: Analytics, Help
    if (role == UserRole.coach) {
      links.addAll([
        _ProfileMenuItem(icon: Icons.analytics_rounded, label: 'Analytics', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()))),
        _ProfileMenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}, isLast: true),
      ]);
    }

    // Staff roles: Help only
    if (_isStaff) {
      links.addAll([
        _ProfileMenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}, isLast: true),
      ]);
    }

    return links;
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out?', style: AppTypography.titleLarge),
        content: Text('You will need to sign in again to access your account.', style: AppTypography.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  String get _label => switch (role) {
    UserRole.guest => 'Guest',
    UserRole.member => 'Member',
    UserRole.coachingMember => 'Coaching',
    UserRole.coach => 'Coach',
    UserRole.receptionist => 'Receptionist',
    UserRole.facilityManager => 'Manager',
    UserRole.admin => 'Admin',
    UserRole.tournamentOrganizer => 'Organizer',
    UserRole.housekeeping => 'Staff',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentSubtle,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Text(_label, style: AppTypography.labelSmall.copyWith(color: AppColors.accent)),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final label = level.isNotEmpty ? '${level[0].toUpperCase()}${level.substring(1)}' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTypography.labelSmall),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.bodyLarge)),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
