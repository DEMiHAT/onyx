import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/section_header.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/booking_service.dart';
import '../../models/models.dart';
import '../facility/facility_detail_screen.dart';
import '../bookings/court_booking_screen.dart';
import '../bookings/turf_booking_screen.dart';
import '../bookings/nets_booking_screen.dart';
import '../notifications/notifications_screen.dart';

/// Student Home — Coaching-focused with today's session, attendance, schedule.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.instance.displayName.split(' ').first;
    final CoachingSession? nextSession = null; // TODO: Fetch from Firestore when coaching is migrated

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('ONYX', style: AppTypography.titleLarge.copyWith(letterSpacing: 2, fontWeight: FontWeight.w700)),
            ]),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none_rounded, size: 22), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
              const SizedBox(width: 4),
            ],
          ),

          // ── Greeting ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Good morning,', style: AppTypography.bodySmall),
                  Text(userName, style: AppTypography.headlineMedium),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('Keep going!', style: AppTypography.labelSmall.copyWith(color: AppColors.accent)),
                  ]),
                ),
              ]),
            ),
          ),

          // ── Next Session Card ──────────────────────────────
          if (nextSession != null) ...[
            const SliverToBoxAdapter(child: SectionHeader(title: "Today's Session", padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.12), AppColors.accent.withValues(alpha: 0.04)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Center(child: Text('R', style: AppTypography.titleLarge.copyWith(color: AppColors.accent)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Coach Rajesh', style: AppTypography.titleMedium),
                      Text('${nextSession.batchName} · ${nextSession.time}', style: AppTypography.bodySmall),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('In 30 min', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    _SessionChip(icon: Icons.location_on_outlined, label: 'Court 1 & 2'),
                    const SizedBox(width: 8),
                    _SessionChip(icon: Icons.timer_outlined, label: '90 min'),
                    const SizedBox(width: 8),
                    _SessionChip(icon: Icons.people_outline_rounded, label: '12 students'),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
                    child: Row(children: [
                      Icon(Icons.how_to_reg_rounded, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 8),
                      Text('Attendance marked by coach during session', style: AppTypography.bodySmall),
                    ]),
                  ),
                ]),
              ),
            ),
          ],

          // ── Training Stats ─────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Your Progress', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _StatCard(label: 'Attendance', value: '92%', sub: '+4% vs last month', color: AppColors.success, icon: Icons.check_circle_outline_rounded),
                const SizedBox(width: 8),
                _StatCard(label: 'Sessions', value: '58', sub: '6 this week', color: AppColors.accent, icon: Icons.sports_tennis_rounded),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                _StatCard(label: 'Training Hrs', value: '86', sub: '12 this month', color: AppColors.badminton, icon: Icons.timer_rounded),
                const SizedBox(width: 8),
                _StatCard(label: 'Level', value: 'Adv', sub: 'Since Mar 2026', color: AppColors.warning, icon: Icons.trending_up_rounded),
              ]),
            ),
          ),

          // ── Fee Status ─────────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Fees', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.warningMuted, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.warning.withValues(alpha: 0.2))),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('June Fee Pending', style: AppTypography.titleSmall.copyWith(color: AppColors.warning)),
                  Text('₹3,000 · Due Jun 10', style: AppTypography.bodySmall),
                ])),
                OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.warning), foregroundColor: AppColors.warning, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)), child: const Text('Pay')),
              ]),
            ),
          ),

          // ── Book a Court ───────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Book a Facility', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _QuickBook(icon: Icons.sports_tennis_rounded, label: 'Court', color: AppColors.badminton, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourtBookingScreen()))),
                const SizedBox(width: 8),
                _QuickBook(icon: Icons.sports_cricket_rounded, label: 'Turf', color: AppColors.cricketTurf, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TurfBookingScreen()))),
                const SizedBox(width: 8),
                _QuickBook(icon: Icons.sports_baseball_rounded, label: 'Nets', color: AppColors.cricketNets, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NetsBookingScreen()))),
              ]),
            ),
          ),

          // ── Live Facility Board ────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Facility Status', padding: EdgeInsets.fromLTRB(16, 20, 16, 6))),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Facility>>(
              stream: BookingService.instance.getFacilities(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AppColors.accent)));
                final facilities = snap.data!;
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: Column(children: facilities.asMap().entries.map((e) {
                    final f = e.value;
                    final isLast = e.key == facilities.length - 1;
                    return InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FacilityDetailScreen(facility: f))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
                        child: Row(children: [
                          Icon(f.type == FacilityType.badmintonCourt ? Icons.sports_tennis_rounded : f.type == FacilityType.cricketTurf ? Icons.sports_cricket_rounded : Icons.sports_baseball_rounded, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(f.shortName, style: AppTypography.titleSmall)),
                          StatusChip(status: f.status, compact: true),
                        ]),
                      ),
                    );
                  }).toList()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionChip extends StatelessWidget {
  final IconData icon; final String label;
  const _SessionChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.border)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: AppColors.textTertiary), const SizedBox(width: 4), Text(label, style: AppTypography.labelSmall)]),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value, sub; final Color color; final IconData icon;
  const _StatCard({required this.label, required this.value, required this.sub, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: AppTypography.titleLarge.copyWith(color: color)),
        Text(label, style: AppTypography.labelSmall),
      ])),
    ]),
  ));
}

class _QuickBook extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _QuickBook({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
    child: Column(children: [Icon(icon, size: 20, color: color), const SizedBox(height: 6), Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary))]),
  )));
}
