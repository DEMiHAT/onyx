import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';

/// Administrator (Super Admin) Dashboard — Full system overview.
/// User management, system analytics, revenue, configuration.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded, size: 20, color: AppColors.error),
                const SizedBox(width: 8),
                Text('Admin Console', style: AppTypography.titleLarge),
              ],
            ),
          ),

          // ── System Overview ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(child: StatCard(label: 'Total Users', value: '346', trend: '+28 this month', icon: Icons.people_rounded)),
                      SizedBox(width: 8),
                      Expanded(child: StatCard(label: 'Active Members', value: '124', icon: Icons.card_membership_rounded)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Expanded(child: StatCard(label: 'Monthly Revenue', value: '₹4.28L', trend: '+18%', icon: Icons.trending_up_rounded)),
                      SizedBox(width: 8),
                      Expanded(child: StatCard(label: 'Active Coaches', value: '6', icon: Icons.fitness_center_rounded)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── User Management ────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'User Management', padding: EdgeInsets.fromLTRB(16, 4, 16, 8)),
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
                  _UserTypeRow(label: 'Guest Players', count: 189, icon: Icons.sports_tennis_rounded, color: AppColors.badminton),
                  _UserTypeRow(label: 'Coaching Members', count: 87, icon: Icons.school_rounded, color: AppColors.accent),
                  _UserTypeRow(label: 'Coaches', count: 6, icon: Icons.fitness_center_rounded, color: AppColors.success),
                  _UserTypeRow(label: 'Receptionists', count: 3, icon: Icons.support_agent_rounded, color: AppColors.warning),
                  _UserTypeRow(label: 'Managers', count: 2, icon: Icons.business_rounded, color: AppColors.textSecondary),
                  _UserTypeRow(label: 'Tournament Organizers', count: 2, icon: Icons.emoji_events_rounded, color: AppColors.cricketTurf),
                  _UserTypeRow(label: 'Housekeeping', count: 4, icon: Icons.cleaning_services_rounded, color: AppColors.textTertiary, isLast: true),
                ],
              ),
            ),
          ),

          // ── Configuration ──────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'System Configuration', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
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
                children: const [
                  _ConfigItem(icon: Icons.calendar_today_rounded, label: 'Booking Rules', value: '60 min default'),
                  _ConfigItem(icon: Icons.attach_money_rounded, label: 'Pricing Config', value: 'Last updated Jun 1'),
                  _ConfigItem(icon: Icons.card_membership_rounded, label: 'Membership Plans', value: '3 active plans'),
                  _ConfigItem(icon: Icons.notifications_rounded, label: 'Notification Templates', value: 'WhatsApp + Push'),
                  _ConfigItem(icon: Icons.security_rounded, label: 'Access Control', value: '8 role types', isLast: true),
                ],
              ),
            ),
          ),

          // ── Revenue Analytics ──────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Revenue Breakdown', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: const [
                  _RevenueItem(source: 'Court Bookings', amount: '₹2,14,300', percentage: 50, color: AppColors.badminton),
                  SizedBox(height: 10),
                  _RevenueItem(source: 'Coaching Fees', amount: '₹1,28,580', percentage: 30, color: AppColors.accent),
                  SizedBox(height: 10),
                  _RevenueItem(source: 'Memberships', amount: '₹52,800', percentage: 12, color: AppColors.success),
                  SizedBox(height: 10),
                  _RevenueItem(source: 'Tournament Entries', amount: '₹32,920', percentage: 8, color: AppColors.warning),
                ],
              ),
            ),
          ),

          // ── Reports & Logs ─────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Reports', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
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
                children: const [
                  _ConfigItem(icon: Icons.analytics_rounded, label: 'System Analytics', value: 'Real-time'),
                  _ConfigItem(icon: Icons.bar_chart_rounded, label: 'Utilization Reports', value: 'Monthly'),
                  _ConfigItem(icon: Icons.receipt_long_rounded, label: 'Financial Reports', value: 'Export CSV'),
                  _ConfigItem(icon: Icons.history_rounded, label: 'Audit Logs', value: 'Last 90 days', isLast: true),
                ],
              ),
            ),
          ),

          // ── Housekeeping Staff Tracking ─────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Housekeeping Staff', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
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
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: Row(children: [
                      Expanded(flex: 3, child: Text('STAFF', style: AppTypography.overline)),
                      Expanded(flex: 2, child: Text('TASKS', style: AppTypography.overline, textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('SALARY', style: AppTypography.overline, textAlign: TextAlign.center)),
                      SizedBox(width: 56, child: Text('STATUS', style: AppTypography.overline, textAlign: TextAlign.center)),
                    ]),
                  ),
                  const _StaffRow(name: 'Ramesh K.', tasksCompleted: 5, tasksTotal: 8, salary: '₹13.5K', paymentStatus: 'paid', paidDate: 'Jun 1'),
                  const _StaffRow(name: 'Suresh M.', tasksCompleted: 6, tasksTotal: 8, salary: '₹12.0K', paymentStatus: 'paid', paidDate: 'Jun 1'),
                  const _StaffRow(name: 'Lakshmi R.', tasksCompleted: 4, tasksTotal: 6, salary: '₹11.5K', paymentStatus: 'pending', paidDate: ''),
                  const _StaffRow(name: 'Anand S.', tasksCompleted: 7, tasksTotal: 8, salary: '₹14.0K', paymentStatus: 'paid', paidDate: 'Jun 2', isLast: true),
                ],
              ),
            ),
          ),

          // ── Housekeeping Service Log ────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Service Completion Log', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
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
                  _ServiceLogRow(area: 'Court 1', task: 'Floor mopping', staff: 'Ramesh K.', time: '6:30 AM', status: 'done'),
                  _ServiceLogRow(area: 'Court 2', task: 'Floor mopping', staff: 'Suresh M.', time: '7:00 AM', status: 'done'),
                  _ServiceLogRow(area: 'Washrooms', task: 'Deep cleaning', staff: 'Lakshmi R.', time: '7:30 AM', status: 'done'),
                  _ServiceLogRow(area: 'Cricket Turf', task: 'Equipment setup', staff: 'Anand S.', time: '8:00 AM', status: 'done'),
                  _ServiceLogRow(area: 'Court 3', task: 'Post-session cleaning', staff: 'Ramesh K.', time: '10:00 AM', status: 'pending'),
                  _ServiceLogRow(area: 'Washrooms', task: 'Routine check', staff: 'Lakshmi R.', time: '12:00 PM', status: 'pending', isLast: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTypeRow extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final bool isLast;
  const _UserTypeRow({required this.label, required this.count, required this.icon, required this.color, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.bodyLarge)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(4)),
              child: Text('$count', style: AppTypography.mono.copyWith(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _ConfigItem({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textTertiary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.bodyLarge)),
            Text(value, style: AppTypography.bodySmall),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _RevenueItem extends StatelessWidget {
  final String source;
  final String amount;
  final int percentage;
  final Color color;
  const _RevenueItem({required this.source, required this.amount, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Expanded(child: Text(source, style: AppTypography.bodyLarge)),
            Text(amount, style: AppTypography.mono.copyWith(fontSize: 12)),
            const SizedBox(width: 8),
            Text('$percentage%', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.surfaceSecondary,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 3,
          ),
        ),
      ],
    );
  }
}

class _StaffRow extends StatelessWidget {
  final String name;
  final int tasksCompleted;
  final int tasksTotal;
  final String salary;
  final String paymentStatus;
  final String paidDate;
  final bool isLast;
  const _StaffRow({required this.name, required this.tasksCompleted, required this.tasksTotal, required this.salary, required this.paymentStatus, required this.paidDate, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isPaid = paymentStatus == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Expanded(flex: 3, child: Row(children: [
          CircleAvatar(radius: 12, backgroundColor: AppColors.surfaceSecondary, child: Text(name[0], style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textPrimary))),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: AppTypography.titleSmall, overflow: TextOverflow.ellipsis)),
        ])),
        Expanded(flex: 2, child: Text('$tasksCompleted/$tasksTotal', style: AppTypography.mono.copyWith(fontSize: 12), textAlign: TextAlign.center)),
        Expanded(flex: 2, child: Text(salary, style: AppTypography.mono.copyWith(fontSize: 12), textAlign: TextAlign.center)),
        SizedBox(
          width: 56,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: (isPaid ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(isPaid ? 'Paid' : 'Pending', style: AppTypography.labelSmall.copyWith(color: isPaid ? AppColors.success : AppColors.warning, fontSize: 9), textAlign: TextAlign.center),
            ),
            if (isPaid && paidDate.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(paidDate, style: AppTypography.monoSmall.copyWith(fontSize: 8)),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _ServiceLogRow extends StatelessWidget {
  final String area;
  final String task;
  final String staff;
  final String time;
  final String status;
  final bool isLast;
  const _ServiceLogRow({required this.area, required this.task, required this.staff, required this.time, required this.status, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'done';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Icon(isDone ? Icons.check_circle_rounded : Icons.schedule_rounded, size: 16, color: isDone ? AppColors.success : AppColors.warning),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$area — $task', style: AppTypography.titleSmall),
          Text(staff, style: AppTypography.bodySmall),
        ])),
        Text(time, style: AppTypography.monoSmall),
      ]),
    );
  }
}
