import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../models/models.dart';

/// Coaching Member Dashboard — For coaching students.
/// Shows coach, batch, attendance, sessions, detailed fees, and progress.
class CoachingMemberScreen extends StatelessWidget {
  const CoachingMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coaching', style: AppTypography.titleLarge),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Coach & Batch Info ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.accentSubtle,
                  child: Text('R', style: AppTypography.titleLarge.copyWith(color: AppColors.accent)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Coach Rajesh', style: AppTypography.titleMedium),
                  const SizedBox(height: 2),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(3), border: Border.all(color: AppColors.border)),
                      child: Text('Advanced A', style: AppTypography.labelSmall),
                    ),
                    const SizedBox(width: 8),
                    Text('6:00 AM - 7:30 AM', style: AppTypography.bodySmall),
                  ]),
                ])),
                Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
              ]),
            ),
          ),

          // ── Stats ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: const [
                Expanded(child: StatCard(label: 'Attendance', value: '92%', trend: '+4% this month', icon: Icons.check_circle_outline_rounded)),
                SizedBox(width: 8),
                Expanded(child: StatCard(label: 'Training Hrs', value: '86', icon: Icons.timer_rounded)),
                SizedBox(width: 8),
                Expanded(child: StatCard(label: 'Sessions', value: '58', icon: Icons.sports_tennis_rounded)),
              ]),
            ),
          ),

          // ── Fee Details (expanded) ──────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Fee Details', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                // Current month dues
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppColors.warningMuted, borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('June 2026 — Pending', style: AppTypography.titleSmall.copyWith(color: AppColors.warning)),
                      const SizedBox(height: 2),
                      Text('Due by Jun 10 · 4 days remaining', style: AppTypography.bodySmall),
                    ])),
                    Text('₹3,000', style: AppTypography.headlineSmall.copyWith(color: AppColors.warning)),
                  ]),
                ),

                // Fee breakdown
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    _FeeRow(label: 'Monthly Coaching', value: '₹3,000'),
                    _FeeRow(label: 'Court Access Fee', value: '₹500'),
                    _FeeRow(label: 'Member Discount', value: '-₹500', isDiscount: true),
                    const Divider(height: 16, color: AppColors.border),
                    _FeeRow(label: 'Total Due', value: '₹3,000', isBold: true),
                  ]),
                ),

                // Pay button
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: () {}, child: const Text('Pay ₹3,000')),
                  ),
                ),
              ]),
            ),
          ),

          // ── Payment History ──────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Payment History', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(children: const [
                _PaymentHistoryRow(month: 'May 2026', amount: '₹3,000', date: 'Paid May 8', isPaid: true),
                _PaymentHistoryRow(month: 'Apr 2026', amount: '₹3,000', date: 'Paid Apr 5', isPaid: true),
                _PaymentHistoryRow(month: 'Mar 2026', amount: '₹3,000', date: 'Paid Mar 10', isPaid: true),
                _PaymentHistoryRow(month: 'Feb 2026', amount: '₹3,000', date: 'Paid Feb 7', isPaid: true, isLast: true),
              ]),
            ),
          ),

          // ── Upcoming Sessions ──────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Upcoming Sessions', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(
                children: () {
                  final sessions = <CoachingSession>[]; // TODO: Fetch from Firestore
                  if (sessions.isEmpty) {
                    return [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: Text('No upcoming sessions', style: AppTypography.bodySmall)),
                      )
                    ];
                  }
                  return sessions.map((session) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: session != sessions.last ? const Border(bottom: BorderSide(color: AppColors.border)) : null,
                      ),
                      child: Row(children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: session.attended ? AppColors.success : AppColors.textTertiary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(session.date, style: AppTypography.titleSmall),
                          Text('${session.time} · ${session.batchName}', style: AppTypography.bodySmall),
                        ])),
                        if (session.attended)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                            child: Text('Present', style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontSize: 10)),
                          )
                        else
                          Text(session.time, style: AppTypography.monoSmall),
                      ]),
                    );
                  }).toList();
                }(),
              ),
            ),
          ),

          // ── Recent Feedback ────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Recent Feedback', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Coach Rajesh', style: AppTypography.titleSmall),
                  Text('Jun 4', style: AppTypography.monoSmall),
                ]),
                const SizedBox(height: 8),
                Text(
                  'Excellent improvement in net play and footwork. Need to work on backhand clears. Overall good consistency in drills.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label, value;
  final bool isBold, isDiscount;
  const _FeeRow({required this.label, required this.value, this.isBold = false, this.isDiscount = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: isBold ? AppTypography.titleSmall : AppTypography.bodyMedium),
        Text(value, style: (isBold ? AppTypography.titleSmall : AppTypography.mono).copyWith(
          color: isDiscount ? AppColors.success : isBold ? AppColors.textPrimary : AppColors.textSecondary,
        )),
      ]),
    );
  }
}

class _PaymentHistoryRow extends StatelessWidget {
  final String month, amount, date;
  final bool isPaid, isLast;
  const _PaymentHistoryRow({required this.month, required this.amount, required this.date, required this.isPaid, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Icon(isPaid ? Icons.check_circle_rounded : Icons.pending_rounded, size: 16, color: isPaid ? AppColors.success : AppColors.warning),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(month, style: AppTypography.titleSmall),
          Text(date, style: AppTypography.bodySmall),
        ])),
        Text(amount, style: AppTypography.mono.copyWith(color: AppColors.textSecondary)),
      ]),
    );
  }
}
