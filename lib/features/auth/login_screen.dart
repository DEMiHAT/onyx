import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/models.dart';
import '../../app.dart';

/// Login Screen — Demo-friendly with quick role cards.
/// Tap any role card to instantly enter as that role.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text('O', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800, color: Colors.white, height: 1))),
                      ),
                      const SizedBox(width: 10),
                      Text('ONYX', style: AppTypography.headlineLarge.copyWith(letterSpacing: 4, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 6),
                    Text('Premium Sports Facility', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
                    const SizedBox(height: 32),
                    Text('Select your role to continue', style: AppTypography.titleMedium),
                    const SizedBox(height: 4),
                    Text('Tap a role card to sign in as that user', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ),

            // ── Player Roles ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text('PLAYERS', style: AppTypography.overline),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(children: [
                  _RoleCard(
                    role: UserRole.guest,
                    title: 'Guest Player',
                    subtitle: 'Book courts, join queues, tournaments',
                    icon: Icons.sports_tennis_rounded,
                    color: AppColors.badminton,
                  ),
                  const SizedBox(height: 8),
                  _RoleCard(
                    role: UserRole.coachingMember,
                    title: 'Coaching Member',
                    subtitle: 'Coaching + booking + membership',
                    icon: Icons.school_rounded,
                    color: AppColors.accent,
                  ),
                ]),
              ),
            ),

            // ── Staff Roles ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text('STAFF', style: AppTypography.overline),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(children: [
                  _RoleCard(
                    role: UserRole.coach,
                    title: 'Coach',
                    subtitle: 'Manage batches, students, attendance',
                    icon: Icons.fitness_center_rounded,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  _RoleCard(
                    role: UserRole.receptionist,
                    title: 'Receptionist',
                    subtitle: 'Check-ins, walk-ins, payments',
                    icon: Icons.support_agent_rounded,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  _RoleCard(
                    role: UserRole.housekeeping,
                    title: 'Housekeeping',
                    subtitle: 'Tasks, schedule, attendance',
                    icon: Icons.cleaning_services_rounded,
                    color: AppColors.textTertiary,
                  ),
                ]),
              ),
            ),

            // ── Management ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text('MANAGEMENT', style: AppTypography.overline),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(children: [
                  _RoleCard(
                    role: UserRole.facilityManager,
                    title: 'Facility Manager',
                    subtitle: 'Revenue, utilization, pricing',
                    icon: Icons.business_rounded,
                    color: AppColors.cricketTurf,
                  ),
                  const SizedBox(height: 8),
                  _RoleCard(
                    role: UserRole.tournamentOrganizer,
                    title: 'Tournament Organizer',
                    subtitle: 'Create tournaments, manage brackets',
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  _RoleCard(
                    role: UserRole.admin,
                    title: 'Administrator',
                    subtitle: 'Full system access, all reports',
                    icon: Icons.admin_panel_settings_rounded,
                    color: AppColors.error,
                  ),
                ]),
              ),
            ),

            // ── Footer ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Center(
                  child: Text(
                    'Demo Mode — No authentication required',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textDisabled),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _RoleCard({required this.role, required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => OnyxShell(role: role)),
        (route) => false,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleSmall),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.bodySmall),
            ],
          )),
          Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textTertiary),
        ]),
      ),
    );
  }
}
