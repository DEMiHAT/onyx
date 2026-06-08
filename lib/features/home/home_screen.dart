import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

/// Home Screen — Live Operations Dashboard
///
/// Clean, structured, information-dense layout.
/// Shows: greeting, quick stats, live facility board,
/// quick actions, upcoming bookings.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final userName = auth.displayName.split(' ').first;


    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            title: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('ONYX', style: AppTypography.titleLarge.copyWith(letterSpacing: 2, fontWeight: FontWeight.w700)),
            ]),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 22),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Greeting ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back,', style: AppTypography.bodySmall),
                  Text(userName, style: AppTypography.headlineMedium),
                ],
              ),
            ),
          ),

          // ── Quick Stats ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: StreamBuilder<List<Facility>>(
                stream: BookingService.instance.getFacilities(),
                builder: (ctx, snap) {
                  final open = snap.data?.where((f) => f.status == FacilityStatus.available).length ?? 0;
                  return Row(children: [
                    _MiniStat(label: 'Open', value: '$open', color: AppColors.success),
                    const SizedBox(width: 8),
                    _MiniStat(label: 'Total', value: '${snap.data?.length ?? 0}', color: AppColors.accent),
                    const SizedBox(width: 8),
                    _MiniStat(label: 'Booked', value: '${(snap.data?.length ?? 0) - open}', color: AppColors.textTertiary),
                  ]);
                },
              ),
            ),
          ),

          // ── Live Facility Board ────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Live Status', padding: EdgeInsets.fromLTRB(16, 20, 16, 6)),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Facility>>(
              stream: BookingService.instance.getFacilities(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AppColors.accent)));
                final facilities = snap.data!;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: Column(children: facilities.asMap().entries.map((entry) => _FacilityTile(facility: entry.value, isLast: entry.key == facilities.length - 1)).toList()),
                );
              },
            ),
          ),

          // ── Quick Actions ──────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Quick Actions', padding: EdgeInsets.fromLTRB(16, 20, 16, 6)),
          ),
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

          // ── Upcoming Bookings (Firestore) ──────────────────────
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings')
                  .where('status', whereIn: ['upcoming', 'active'])
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (ctx, snap) {
                final bookings = snap.data?.docs.map((d) => Booking.fromFirestore(d.data() as Map<String, dynamic>, d.id)).toList() ?? [];
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('UPCOMING', style: AppTypography.overline),
                      Text('${bookings.length} bookings', style: AppTypography.bodySmall),
                    ]),
                  ),
                  ...bookings.map((b) => _BookingTile(booking: b)),
                ]);
              },
            ),
          ),

          // ── Announcement ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                Icon(Icons.emoji_events_rounded, size: 18, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ONYX Summer Smash 2026', style: AppTypography.titleSmall),
                    const SizedBox(height: 2),
                    Text('Registration open · 4 spots left · Jun 22-23', style: AppTypography.bodySmall),
                  ],
                )),
                Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Stat Chip ──────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          Text(value, style: AppTypography.titleLarge.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
        ]),
      ),
    );
  }
}

// ── Facility Tile ───────────────────────────────────────────────

class _FacilityTile extends StatelessWidget {
  final Facility facility;
  final bool isLast;
  const _FacilityTile({required this.facility, required this.isLast});

  IconData get _icon => switch (facility.type) {
    FacilityType.badmintonCourt => Icons.sports_tennis_rounded,
    FacilityType.cricketTurf => Icons.sports_cricket_rounded,
    FacilityType.cricketNets => Icons.sports_baseball_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final isAvail = facility.status == FacilityStatus.available;
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FacilityDetailScreen(facility: facility))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          Icon(_icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(facility.shortName, style: AppTypography.titleSmall),
          ),
          Expanded(
            flex: 2,
            child: StatusChip(status: facility.status, compact: true),
          ),
          SizedBox(
            width: 70,
            child: Text(
              isAvail ? 'Book Now' : '${facility.timeRemainingMinutes}m left',
              style: AppTypography.bodySmall.copyWith(
                color: isAvail ? AppColors.success : AppColors.textSecondary,
                fontWeight: isAvail ? FontWeight.w500 : FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),

        ]),
      ),
    );
  }
}

// ── Quick Action ────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

// ── Booking Tile ────────────────────────────────────────────────

class _BookingTile extends StatelessWidget {
  final Booking booking;
  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(6)),
          child: Icon(
            booking.facilityType == FacilityType.badmintonCourt ? Icons.sports_tennis_rounded : Icons.sports_cricket_rounded,
            size: 18, color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.facilityName, style: AppTypography.titleSmall),
            const SizedBox(height: 2),
            Text('${booking.date} · ${booking.timeSlot}', style: AppTypography.bodySmall),
          ],
        )),
        if (booking.amount != null)
          Text('₹${booking.amount!.toInt()}', style: AppTypography.mono.copyWith(color: AppColors.textSecondary)),
      ]),
    );
  }
}
