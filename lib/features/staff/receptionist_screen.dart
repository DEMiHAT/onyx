import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/services/booking_service.dart';
import '../../models/models.dart';
import 'qr_scanner_screen.dart';

/// Receptionist / Front Desk Dashboard.
/// Walk-in bookings, check-ins, payments, daily operations.
class ReceptionistScreen extends StatelessWidget {
  const ReceptionistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Row(
              children: [
                Icon(Icons.support_agent_rounded, size: 20, color: AppColors.accent),
                const SizedBox(width: 8),
                Text('Front Desk', style: AppTypography.titleLarge),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('On Duty', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),

          // ── Today's Stats ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Expanded(child: StatCard(label: 'Check-Ins', value: '24', trend: '+6 vs yesterday', icon: Icons.login_rounded)),
                  SizedBox(width: 8),
                  Expanded(child: StatCard(label: 'Revenue', value: '₹14.2K', trend: '+₹3.2K', icon: Icons.payments_rounded)),
                  SizedBox(width: 8),
                  Expanded(child: StatCard(label: 'Walk-Ins', value: '8', icon: Icons.directions_walk_rounded)),
                ],
              ),
            ),
          ),

          // ── Facility Status ────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Facility Occupancy', padding: EdgeInsets.fromLTRB(16, 4, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Facility>>(
              stream: BookingService.instance.getFacilities(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AppColors.accent)));
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: Column(children: snap.data!.map((f) => _FacilityOccupancyRow(facility: f)).toList()),
                );
              },
            ),
          ),

          // ── Quick Actions ──────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Quick Actions', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.3,
                children: [
                  _ActionTile(icon: Icons.add_circle_outline_rounded, label: 'Walk-In\nBooking', color: AppColors.accent),
                  _ActionTile(icon: Icons.qr_code_scanner_rounded, label: 'Scan\nCheck-In', color: AppColors.success, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerScreen()))),
                  _ActionTile(icon: Icons.exit_to_app_rounded, label: 'Check-Out', color: AppColors.warning),
                  _ActionTile(icon: Icons.payment_rounded, label: 'Collect\nPayment', color: AppColors.accent),
                  _ActionTile(icon: Icons.receipt_long_rounded, label: 'Issue\nReceipt', color: AppColors.textTertiary),

                ],
              ),
            ),
          ),

          // ── Recent Check-Ins ───────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Recent Activity', actionText: 'View All', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: const [
                  _ActivityRow(time: '6:28 PM', event: 'Check-In', name: 'Arjun Mehta', detail: 'Court 1 · Booking BK001', icon: Icons.login_rounded, color: AppColors.success),
                  _ActivityRow(time: '6:22 PM', event: 'Payment', name: 'Priya Sharma', detail: '₹600 · Cash', icon: Icons.payments_rounded, color: AppColors.accent),
                  _ActivityRow(time: '6:15 PM', event: 'Walk-In', name: 'Guest #08', detail: 'Court 2 · Walk-in booking', icon: Icons.directions_walk_rounded, color: AppColors.warning),
                  _ActivityRow(time: '6:02 PM', event: 'Check-Out', name: 'Vikram Patel', detail: 'Court 1 · 58 min', icon: Icons.exit_to_app_rounded, color: AppColors.textTertiary, isLast: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityOccupancyRow extends StatelessWidget {
  final Facility facility;
  const _FacilityOccupancyRow({required this.facility});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(facility.shortName, style: AppTypography.titleSmall)),
          Expanded(flex: 2, child: StatusChip(status: facility.status, compact: true)),
          Expanded(
            flex: 2,
            child: Text(
              facility.currentUser ?? '—',
              style: AppTypography.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded, size: 18),
                  onPressed: () {},
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionTile({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(label, style: AppTypography.labelSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String time;
  final String event;
  final String name;
  final String detail;
  final IconData icon;
  final Color color;
  final bool isLast;

  const _ActivityRow({required this.time, required this.event, required this.name, required this.detail, required this.icon, required this.color, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: AppTypography.titleSmall),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                      child: Text(event, style: AppTypography.labelSmall.copyWith(color: color, fontSize: 9)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(detail, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Text(time, style: AppTypography.monoSmall),
        ],
      ),
    );
  }
}
