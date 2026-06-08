import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/timeline_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';

/// Facility Detail Screen — Full detail view for any facility.
/// Shows current user, booking timeline, stats, and CTAs.
class FacilityDetailScreen extends StatelessWidget {
  final Facility facility;
  const FacilityDetailScreen({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    final isAvailable = facility.status == FacilityStatus.available;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            title: Text(facility.name, style: AppTypography.titleLarge),
            actions: [
              StatusChip(status: facility.status),
              const SizedBox(width: 16),
            ],
          ),

          // ── Current Status Banner ──────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAvailable
                    ? AppColors.success.withValues(alpha: 0.05)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAvailable
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.border,
                ),
              ),
              child: isAvailable
                  ? Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Available Now', style: AppTypography.titleMedium.copyWith(color: AppColors.success)),
                              const SizedBox(height: 2),
                              Text('Ready to book', style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Currently in Use', style: AppTypography.titleMedium),
                            if (facility.timeRemainingMinutes != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warningMuted,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${facility.timeRemainingMinutes} min remaining',
                                  style: AppTypography.mono.copyWith(color: AppColors.warning, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(label: 'Current User', value: facility.currentUser ?? '—'),
                        _DetailRow(label: 'Booking Ends', value: facility.bookingEndTime ?? '—'),
                        _DetailRow(label: 'Next Available', value: facility.nextAvailableTime ?? '—'),

                      ],
                    ),
            ),
          ),

          // ── Stats Row ──────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Today\'s Activity',
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Expanded(child: StatCard(label: 'Sessions', value: '12', icon: Icons.sports_tennis_rounded)),
                  SizedBox(width: 8),
                  Expanded(child: StatCard(label: 'Peak Hour', value: '6 PM', icon: Icons.trending_up_rounded)),
                  SizedBox(width: 8),
                  Expanded(child: StatCard(label: 'Avg Duration', value: '52m', icon: Icons.timer_rounded)),
                ],
              ),
            ),
          ),

          // ── Booking Timeline ───────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Booking Timeline',
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('bookings')
                  .where('facilityId', isEqualTo: facility.id)
                  .where('date', isEqualTo: 'Today') // Or specific date format
                  .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No upcoming bookings today.', style: AppTypography.bodySmall)),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return Column(
                    children: List.generate(docs.length, (index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return TimelineItemWidget(
                        time: data['timeSlot'] ?? '',
                        title: data['userName'] ?? 'Unknown User',
                        subtitle: 'Session',
                        isCurrent: data['status'] == 'active',
                        isLast: index == docs.length - 1,
                      );
                    }),
                  );
                },
              ),
            ),
          ),



          // Bottom padding for CTAs
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── Bottom CTA Bar ─────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Row(
            children: [

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(isAvailable ? 'Book Now' : 'Schedule'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Detail Row ───────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.titleSmall),
        ],
      ),
    );
  }
}


