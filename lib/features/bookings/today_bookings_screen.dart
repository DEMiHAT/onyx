import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';

/// Today's Bookings Screen — Staff view of all bookings for today.
/// Shows check-in status, facility, time, and player info. No booking creation.
class TodayBookingsScreen extends StatelessWidget {
  const TodayBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Bookings", style: AppTypography.titleLarge),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings')
            .where('date', isEqualTo: 'Today') // Simplify or match current day format
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final allBookings = snapshot.data!.docs
              .map((doc) => Booking.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          final active = allBookings.where((b) => b.status == BookingStatus.active).toList();
          final upcoming = allBookings.where((b) => b.status == BookingStatus.upcoming).toList();
          final completed = allBookings.where((b) => b.status == BookingStatus.completed).toList();

          return CustomScrollView(
            slivers: [
              // ── Summary ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    _CountChip(label: 'Active', count: active.length, color: AppColors.success),
                    const SizedBox(width: 12),
                    _CountChip(label: 'Upcoming', count: upcoming.length, color: AppColors.accent),
                    const SizedBox(width: 12),
                    _CountChip(label: 'Completed', count: completed.length, color: AppColors.textTertiary),
                    const SizedBox(width: 12),
                    _CountChip(label: 'Total', count: allBookings.length, color: AppColors.textPrimary),
                  ]),
                ),
              ),

              // ── Active Now ─────────────────────────────────────────
              if (active.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SectionHeader(title: 'Active Now', padding: EdgeInsets.fromLTRB(16, 4, 16, 8))),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _StaffBookingCard(booking: active[i], showCheckIn: false),
                    childCount: active.length,
                  ),
                ),
              ],

              // ── Upcoming ───────────────────────────────────────────
              if (upcoming.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SectionHeader(title: 'Upcoming', padding: EdgeInsets.fromLTRB(16, 16, 16, 8))),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _StaffBookingCard(booking: upcoming[i], showCheckIn: true),
                    childCount: upcoming.length,
                  ),
                ),
              ],

              // ── Completed ──────────────────────────────────────────
              if (completed.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SectionHeader(title: 'Completed', padding: EdgeInsets.fromLTRB(16, 16, 16, 8))),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _StaffBookingCard(booking: completed[i], showCheckIn: false),
                    childCount: completed.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        }
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CountChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text('$count', style: AppTypography.titleLarge.copyWith(color: color)),
      const SizedBox(height: 2),
      Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
    ]));
  }
}

class _StaffBookingCard extends StatelessWidget {
  final Booking booking;
  final bool showCheckIn;
  const _StaffBookingCard({required this.booking, required this.showCheckIn});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = switch (booking.status) {
      BookingStatus.active => ('Active', AppColors.success),
      BookingStatus.upcoming => ('Upcoming', AppColors.accent),
      BookingStatus.completed => ('Completed', AppColors.textTertiary),
      BookingStatus.cancelled => ('Cancelled', AppColors.error),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                booking.facilityType == FacilityType.badmintonCourt ? Icons.sports_tennis_rounded : Icons.sports_cricket_rounded,
                size: 18, color: statusColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(booking.facilityName, style: AppTypography.titleSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                  child: Text(statusLabel, style: AppTypography.labelSmall.copyWith(color: statusColor, fontSize: 10)),
                ),
              ]),
              const SizedBox(height: 2),
              Text('${booking.timeSlot} · ${booking.durationMinutes}min · ${booking.id}', style: AppTypography.bodySmall),
            ])),
          ]),
          if (showCheckIn) ...[
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 14),
                label: const Text('Check In'),
              )),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Cancel'))),
            ]),
          ],
        ],
      ),
    );
  }
}
