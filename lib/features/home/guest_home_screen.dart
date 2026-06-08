import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/section_header.dart';
import '../../core/constants/mock_data.dart';
import '../../models/models.dart';
import '../facility/facility_detail_screen.dart';
import '../bookings/court_booking_screen.dart';
import '../bookings/turf_booking_screen.dart';
import '../bookings/nets_booking_screen.dart';

import '../notifications/notifications_screen.dart';
import '../membership/membership_payment_screen.dart';

/// Guest Home — Focused on booking, discovery, open play.
class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final availableCount = MockData.facilities.where((f) => f.status == FacilityStatus.available).length;

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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hey ${user.name.split(' ').first} 👋', style: AppTypography.headlineMedium),
                const SizedBox(height: 2),
                Text('$availableCount facilities available right now', style: AppTypography.bodySmall),
              ]),
            ),
          ),

          // ── Book Now Cards ─────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Book Now', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _BookCard(title: 'Badminton', subtitle: '3 Courts', price: 'From ₹300/hr', icon: Icons.sports_tennis_rounded, color: AppColors.badminton, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourtBookingScreen()))),
                  _BookCard(title: 'Cricket Turf', subtitle: '1 Turf', price: 'From ₹1000/hr', icon: Icons.sports_cricket_rounded, color: AppColors.cricketTurf, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TurfBookingScreen()))),
                  _BookCard(title: 'Cricket Nets', subtitle: '3 Lanes', price: 'From ₹400/hr', icon: Icons.sports_baseball_rounded, color: AppColors.cricketNets, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NetsBookingScreen()))),
                ],
              ),
            ),
          ),

          // ── Membership CTA ─────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.accent.withValues(alpha: 0.05)]),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipPaymentScreen())),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.card_membership_rounded, size: 20, color: AppColors.accent)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Become a Member', style: AppTypography.titleSmall.copyWith(color: AppColors.accent)),
                    Text('Unlock priority slots, discounts & more', style: AppTypography.bodySmall),
                  ])),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.accent),
                ]),
              ),
            ),
          ),

          // ── Live Facility Board ────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Live Status', padding: EdgeInsets.fromLTRB(16, 20, 16, 6))),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(
                children: MockData.facilities.asMap().entries.map((entry) {
                  final f = entry.value;
                  final isLast = entry.key == MockData.facilities.length - 1;
                  final isAvail = f.status == FacilityStatus.available;
                  return InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FacilityDetailScreen(facility: f))),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
                      child: Row(children: [
                        Icon(f.type == FacilityType.badmintonCourt ? Icons.sports_tennis_rounded : f.type == FacilityType.cricketTurf ? Icons.sports_cricket_rounded : Icons.sports_baseball_rounded, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 8),
                        Expanded(flex: 3, child: Text(f.shortName, style: AppTypography.titleSmall)),
                        Expanded(flex: 2, child: StatusChip(status: f.status, compact: true)),
                        SizedBox(width: 60, child: Text(isAvail ? 'Book' : '${f.timeRemainingMinutes}m', style: AppTypography.bodySmall.copyWith(color: isAvail ? AppColors.success : AppColors.textSecondary), textAlign: TextAlign.right)),

                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Quick Actions ──────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Quick Actions', padding: EdgeInsets.fromLTRB(16, 20, 16, 6))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _QuickAction(icon: Icons.sports_tennis_rounded, label: 'Court', color: AppColors.badminton, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourtBookingScreen()))),
                const SizedBox(width: 8),
                _QuickAction(icon: Icons.sports_cricket_rounded, label: 'Turf', color: AppColors.cricketTurf, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TurfBookingScreen()))),
                const SizedBox(width: 8),
                _QuickAction(icon: Icons.sports_baseball_rounded, label: 'Nets', color: AppColors.cricketNets, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NetsBookingScreen()))),

              ]),
            ),
          ),

          // ── Upcoming Bookings ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('UPCOMING', style: AppTypography.overline),
                Text('${MockData.bookings.where((b) => b.status == BookingStatus.upcoming).length} bookings', style: AppTypography.bodySmall),
              ]),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              final upcoming = MockData.bookings.where((b) => b.status == BookingStatus.upcoming).toList();
              if (i >= upcoming.length) return null;
              final b = upcoming[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(6)), child: Icon(b.facilityType == FacilityType.badmintonCourt ? Icons.sports_tennis_rounded : Icons.sports_cricket_rounded, size: 18, color: AppColors.accent)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.facilityName, style: AppTypography.titleSmall),
                    const SizedBox(height: 2),
                    Text('${b.date} · ${b.timeSlot}', style: AppTypography.bodySmall),
                  ])),
                  if (b.amount != null) Text('₹${b.amount!.toInt()}', style: AppTypography.mono.copyWith(color: AppColors.textSecondary)),
                ]),
              );
            }, childCount: MockData.bookings.where((b) => b.status == BookingStatus.upcoming).length),
          ),

          // ── Tournament Banner ──────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
              child: Row(children: [
                Icon(Icons.emoji_events_rounded, size: 18, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ONYX Summer Smash 2026', style: AppTypography.titleSmall),
                  const SizedBox(height: 2),
                  Text('Registration open · 4 spots left', style: AppTypography.bodySmall),
                ])),
                Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final String title, subtitle, price;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _BookCard({required this.title, required this.subtitle, required this.price, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140, margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: color)),
          const Spacer(),
          Text(title, style: AppTypography.titleSmall),
          Text(subtitle, style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Text(price, style: AppTypography.labelSmall.copyWith(color: AppColors.accent)),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
      child: Column(children: [Icon(icon, size: 20, color: color), const SizedBox(height: 6), Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary))]),
    )));
  }
}
