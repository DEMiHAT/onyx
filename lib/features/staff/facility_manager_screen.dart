import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/constants/mock_data.dart';
import '../../models/models.dart';

/// Facility Manager Dashboard — Monitor facilities, revenue, utilization, pricing.
class FacilityManagerScreen extends StatelessWidget {
  const FacilityManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Row(
              children: [
                Icon(Icons.business_rounded, size: 20, color: AppColors.accent),
                const SizedBox(width: 8),
                Text('Facility Manager', style: AppTypography.titleLarge),
              ],
            ),
          ),

          // ── Revenue Stats ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Expanded(child: StatCard(label: 'Today Revenue', value: '₹28.6K', trend: '+18%', icon: Icons.trending_up_rounded)),
                  SizedBox(width: 8),
                  Expanded(child: StatCard(label: 'Utilization', value: '78%', trend: '+5%', icon: Icons.pie_chart_rounded)),
                  SizedBox(width: 8),
                  Expanded(child: StatCard(label: 'Bookings', value: '42', icon: Icons.calendar_today_rounded)),
                ],
              ),
            ),
          ),

          // ── Facility Status ────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'All Facilities', padding: EdgeInsets.fromLTRB(16, 4, 16, 8)),
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
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('FACILITY', style: AppTypography.overline)),
                        Expanded(flex: 2, child: Text('STATUS', style: AppTypography.overline)),
                        Expanded(flex: 2, child: Text('REVENUE', style: AppTypography.overline, textAlign: TextAlign.right)),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  ...MockData.facilities.asMap().entries.map((e) {
                    final revenues = ['₹8.4K', '₹6.2K', '₹5.8K', '₹4.2K', '₹4.0K'];
                    return _FacilityManageRow(facility: e.value, revenue: revenues[e.key]);
                  }),
                ],
              ),
            ),
          ),

          // ── Actions ────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Management', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
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
                children: [
                  _MenuItem(icon: Icons.block_rounded, label: 'Block Facility for Maintenance', color: AppColors.error),
                  _MenuItem(icon: Icons.schedule_rounded, label: 'Manage Availability Schedules', color: AppColors.accent),
                  _MenuItem(icon: Icons.attach_money_rounded, label: 'Update Pricing', color: AppColors.success),
                  _MenuItem(icon: Icons.card_membership_rounded, label: 'Manage Membership Plans', color: AppColors.accent),
                  _MenuItem(icon: Icons.event_rounded, label: 'Approve Tournament Schedules', color: AppColors.warning),
                  _MenuItem(icon: Icons.bar_chart_rounded, label: 'Utilization Reports', color: AppColors.textTertiary, isLast: true),
                ],
              ),
            ),
          ),

          // ── Monthly Revenue ────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Monthly Revenue', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: const [
                  _RevenueRow(month: 'June 2026', amount: '₹4,28,600', trend: '+18%', isPositive: true),
                  _RevenueRow(month: 'May 2026', amount: '₹3,62,400', trend: '+12%', isPositive: true),
                  _RevenueRow(month: 'April 2026', amount: '₹3,24,100', trend: '-3%', isPositive: false),
                  _RevenueRow(month: 'March 2026', amount: '₹3,34,200', trend: '+8%', isPositive: true, isLast: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityManageRow extends StatelessWidget {
  final Facility facility;
  final String revenue;
  const _FacilityManageRow({required this.facility, required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(facility.shortName, style: AppTypography.titleSmall)),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: facility.status == FacilityStatus.available
                    ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                facility.status == FacilityStatus.available ? 'Open' : 'In Use',
                style: AppTypography.labelSmall.copyWith(
                  color: facility.status == FacilityStatus.available ? AppColors.success : AppColors.warning,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(revenue, style: AppTypography.mono.copyWith(fontSize: 12), textAlign: TextAlign.right)),
          SizedBox(width: 40, child: IconButton(icon: const Icon(Icons.settings_rounded, size: 16), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32))),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLast;
  const _MenuItem({required this.icon, required this.label, required this.color, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.bodyLarge)),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _RevenueRow extends StatelessWidget {
  final String month;
  final String amount;
  final String trend;
  final bool isPositive;
  final bool isLast;
  const _RevenueRow({required this.month, required this.amount, required this.trend, required this.isPositive, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10, top: 4),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(child: Text(month, style: AppTypography.bodyLarge)),
          Text(amount, style: AppTypography.mono),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(trend, style: AppTypography.labelSmall.copyWith(color: isPositive ? AppColors.success : AppColors.error, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
