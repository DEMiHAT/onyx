import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';

/// Student Biodata Screen — Coach views detailed student profile.
class StudentBiodataScreen extends StatelessWidget {
  final String studentName;
  const StudentBiodataScreen({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Profile', style: AppTypography.titleLarge)),
      body: CustomScrollView(
        slivers: [
          // ── Profile Header ─────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                CircleAvatar(radius: 32, backgroundColor: AppColors.accentSubtle, child: Text(studentName[0], style: AppTypography.headlineMedium.copyWith(color: AppColors.accent))),
                const SizedBox(height: 12),
                Text(studentName, style: AppTypography.headlineSmall),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(4)),
                  child: Text('Advanced · Batch A', style: AppTypography.labelSmall),
                ),
              ]),
            ),
          ),

          // ── Personal Details ───────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Personal Details', padding: EdgeInsets.fromLTRB(16, 4, 16, 8))),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Column(children: [
                _DetailRow(label: 'Age', value: '17 years', icon: Icons.cake_rounded),
                _DetailRow(label: 'Gender', value: 'Male', icon: Icons.person_rounded),
                _DetailRow(label: 'Phone', value: '+91 98765 43210', icon: Icons.phone_rounded),
                _DetailRow(label: 'Parent', value: 'Mr. Kumar Rajan', icon: Icons.family_restroom_rounded),
                _DetailRow(label: 'Parent Phone', value: '+91 98765 43211', icon: Icons.phone_in_talk_rounded),
                _DetailRow(label: 'Joined', value: 'Jan 2025', icon: Icons.calendar_today_rounded, isLast: true),
              ]),
            ),
          ),

          // ── Training Stats ─────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Training Summary', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _StatBox(label: 'Attendance', value: '92%', color: AppColors.success),
                const SizedBox(width: 8),
                _StatBox(label: 'Sessions', value: '58', color: AppColors.accent),
                const SizedBox(width: 8),
                _StatBox(label: 'Hours', value: '86', color: AppColors.badminton),
              ]),
            ),
          ),

          // ── Attendance History (last 10) ───────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Recent Attendance', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(children: List.generate(10, (i) {
                final isPresent = i != 3 && i != 7;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(border: i < 9 ? const Border(bottom: BorderSide(color: AppColors.border)) : null),
                  child: Row(children: [
                    Icon(isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 16, color: isPresent ? AppColors.success : AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Jun ${6 - i}, 2026', style: AppTypography.bodyMedium)),
                    Text(isPresent ? 'Present' : 'Absent', style: AppTypography.labelSmall.copyWith(color: isPresent ? AppColors.success : AppColors.error)),
                  ]),
                );
              })),
            ),
          ),

          // ── Fee History ────────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Fee History', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Column(children: [
                _FeeRow(month: 'June 2026', amount: '₹3,000', status: 'Pending', isPaid: false),
                _FeeRow(month: 'May 2026', amount: '₹3,000', status: 'Paid May 8', isPaid: true),
                _FeeRow(month: 'Apr 2026', amount: '₹3,000', status: 'Paid Apr 5', isPaid: true),
                _FeeRow(month: 'Mar 2026', amount: '₹3,000', status: 'Paid Mar 10', isPaid: true, isLast: true),
              ]),
            ),
          ),

          // ── Coach Notes ────────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Coach Notes', padding: EdgeInsets.fromLTRB(16, 0, 16, 8))),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Latest Note', style: AppTypography.titleSmall),
                  Text('Jun 4', style: AppTypography.monoSmall),
                ]),
                const SizedBox(height: 8),
                Text('Excellent improvement in net play and footwork. Need to work on backhand clears. Good consistency in drills.', style: AppTypography.bodyMedium),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value; final IconData icon; final bool isLast;
  const _DetailRow({required this.label, required this.value, required this.icon, this.isLast = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.textTertiary),
      const SizedBox(width: 10),
      SizedBox(width: 100, child: Text(label, style: AppTypography.bodySmall)),
      Expanded(child: Text(value, style: AppTypography.titleSmall)),
    ]),
  );
}

class _StatBox extends StatelessWidget {
  final String label, value; final Color color;
  const _StatBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Text(value, style: AppTypography.titleLarge.copyWith(color: color)),
      const SizedBox(height: 2),
      Text(label, style: AppTypography.labelSmall),
    ]),
  ));
}

class _FeeRow extends StatelessWidget {
  final String month, amount, status; final bool isPaid, isLast;
  const _FeeRow({required this.month, required this.amount, required this.status, required this.isPaid, this.isLast = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
    child: Row(children: [
      Icon(isPaid ? Icons.check_circle_rounded : Icons.pending_rounded, size: 16, color: isPaid ? AppColors.success : AppColors.warning),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(month, style: AppTypography.titleSmall),
        Text(status, style: AppTypography.bodySmall),
      ])),
      Text(amount, style: AppTypography.mono.copyWith(color: AppColors.textSecondary)),
    ]),
  );
}
