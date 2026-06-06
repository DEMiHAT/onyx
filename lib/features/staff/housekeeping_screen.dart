import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../auth/login_screen.dart';

/// Housekeeping Staff Dashboard — Task list, cleaning schedule, attendance.
class HousekeepingScreen extends StatelessWidget {
  const HousekeepingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Row(children: [
              Icon(Icons.cleaning_services_rounded, size: 20, color: AppColors.accent),
              const SizedBox(width: 8),
              Text('Housekeeping', style: AppTypography.titleLarge),
            ]),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Sign Out?', style: AppTypography.titleLarge),
                    content: Text('You will be signed out of your account.', style: AppTypography.bodyMedium),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Today's Summary ────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                _SummaryItem(label: 'Pending', value: '3', color: AppColors.warning),
                const SizedBox(width: 16),
                _SummaryItem(label: 'Completed', value: '5', color: AppColors.success),
                const SizedBox(width: 16),
                _SummaryItem(label: 'Shift', value: '6A-2P', color: AppColors.accent),
              ]),
            ),
          ),

          // ── Assigned Tasks ─────────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Assigned Tasks', padding: EdgeInsets.fromLTRB(16, 4, 16, 8))),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(children: const [
                _TaskRow(area: 'Court 1', task: 'Floor mopping', time: '6:30 AM', status: 'done'),
                _TaskRow(area: 'Court 2', task: 'Floor mopping', time: '7:00 AM', status: 'done'),
                _TaskRow(area: 'Washrooms', task: 'Deep cleaning', time: '7:30 AM', status: 'done'),
                _TaskRow(area: 'Cricket Turf', task: 'Equipment setup', time: '8:00 AM', status: 'done'),
                _TaskRow(area: 'Lobby', task: 'Dusting & vacuuming', time: '8:30 AM', status: 'done'),
                _TaskRow(area: 'Court 3', task: 'Post-session cleaning', time: '10:00 AM', status: 'pending'),
                _TaskRow(area: 'Washrooms', task: 'Routine check', time: '12:00 PM', status: 'pending'),
                _TaskRow(area: 'All Courts', task: 'Evening prep', time: '1:30 PM', status: 'pending', isLast: true),
              ]),
            ),
          ),

          // ── Work Schedule ──────────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'This Week', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(children: const [
                _ScheduleRow(day: 'Monday', shift: '6 AM – 2 PM', status: 'Completed'),
                _ScheduleRow(day: 'Tuesday', shift: '6 AM – 2 PM', status: 'Completed'),
                _ScheduleRow(day: 'Wednesday', shift: '6 AM – 2 PM', status: 'Completed'),
                _ScheduleRow(day: 'Thursday', shift: '6 AM – 2 PM', status: 'Today'),
                _ScheduleRow(day: 'Friday', shift: '6 AM – 2 PM', status: 'Upcoming'),
                _ScheduleRow(day: 'Saturday', shift: '2 PM – 10 PM', status: 'Upcoming'),
                _ScheduleRow(day: 'Sunday', shift: 'Off', status: 'Off', isLast: true),
              ]),
            ),
          ),

          // ── Attendance & Salary ────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Attendance & Salary', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                _InfoRow(label: 'Days Worked', value: '22 / 26'),
                const Divider(height: 16),
                _InfoRow(label: 'Attendance', value: '84.6%'),
                const Divider(height: 16),
                _InfoRow(label: 'Leaves Taken', value: '4'),
                const Divider(height: 16),
                _InfoRow(label: 'Base Salary', value: '₹12,000'),
                const Divider(height: 16),
                _InfoRow(label: 'Overtime', value: '₹1,500'),
                const Divider(height: 16),
                _InfoRow(label: 'Net Payable', value: '₹13,500'),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label; final String value; final Color color;
  const _SummaryItem({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(value, style: AppTypography.headlineMedium.copyWith(color: color)),
      const SizedBox(height: 2),
      Text(label, style: AppTypography.labelSmall),
    ]));
  }
}

class _TaskRow extends StatelessWidget {
  final String area; final String task; final String time; final String status; final bool isLast;
  const _TaskRow({required this.area, required this.task, required this.time, required this.status, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    final isDone = status == 'done';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 18, color: isDone ? AppColors.success : AppColors.textTertiary),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(area, style: AppTypography.titleSmall.copyWith(decoration: isDone ? TextDecoration.lineThrough : null, color: isDone ? AppColors.textTertiary : AppColors.textPrimary)),
          Text(task, style: AppTypography.bodySmall),
        ])),
        Text(time, style: AppTypography.monoSmall),
      ]),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String day; final String shift; final String status; final bool isLast;
  const _ScheduleRow({required this.day, required this.shift, required this.status, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    Color statusColor = switch (status) { 'Completed' => AppColors.success, 'Today' => AppColors.accent, 'Off' => AppColors.textDisabled, _ => AppColors.textTertiary };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: status == 'Today' ? AppColors.accentSubtle : Colors.transparent,
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Expanded(flex: 2, child: Text(day, style: AppTypography.titleSmall.copyWith(color: status == 'Today' ? AppColors.accent : AppColors.textPrimary))),
        Expanded(flex: 2, child: Text(shift, style: AppTypography.bodySmall)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
          child: Text(status, style: AppTypography.labelSmall.copyWith(color: statusColor, fontSize: 10)),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label; final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTypography.bodySmall),
      Text(value, style: AppTypography.titleSmall),
    ]);
  }
}
