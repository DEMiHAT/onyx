import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/queue_indicator.dart';
import '../../core/widgets/section_header.dart';
import '../../core/constants/mock_data.dart';

/// Queue Management Screen — Real-time queue position and status updates.
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = MockData.currentQueue;

    return Scaffold(
      appBar: AppBar(
        title: Text('Queue Status', style: AppTypography.titleLarge),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Queue Position Card ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: QueueIndicator(
                position: queue.position,
                estimatedWaitMinutes: queue.estimatedWaitMinutes,
                facilityName: queue.facilityName,
              ),
            ),
          ),

          // ── Progress Visual ────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QUEUE PROGRESS', style: AppTypography.overline),
                  const SizedBox(height: 16),
                  // Progress steps
                  _ProgressStep(label: 'Joined Queue', time: '6:20 PM', isComplete: true),
                  _ProgressConnector(),
                  _ProgressStep(label: 'Position #3 → #2', time: '6:28 PM', isComplete: true),
                  _ProgressConnector(),
                  _ProgressStep(label: 'Waiting for Court 3', time: 'Now', isComplete: false, isCurrent: true),
                  _ProgressConnector(isUpcoming: true),
                  _ProgressStep(label: 'Court Available', time: '~6:48 PM', isComplete: false),
                ],
              ),
            ),
          ),

          // ── Queue Details ──────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Details', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
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
                children: [
                  _InfoRow(label: 'Facility', value: queue.facilityName),
                  const Divider(height: 16),
                  _InfoRow(label: 'Current Player', value: 'Priya Sharma'),
                  const Divider(height: 16),
                  _InfoRow(label: 'Session Ends', value: '6:58 PM'),
                  const Divider(height: 16),
                  _InfoRow(label: 'Ahead of You', value: '${queue.peopleAhead} player'),
                  const Divider(height: 16),
                  _InfoRow(label: 'Your Est. Start', value: '~6:48 PM'),
                ],
              ),
            ),
          ),

          // ── Status Updates ─────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Status Updates', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
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
                  _UpdateRow(time: '6:28 PM', message: 'Moved to position #2', icon: Icons.arrow_upward_rounded, color: AppColors.success),
                  _UpdateRow(time: '6:25 PM', message: 'Court 1 became available, player #1 assigned', icon: Icons.info_outline_rounded, color: AppColors.accent),
                  _UpdateRow(time: '6:20 PM', message: 'Joined queue for Court 3 at position #3', icon: Icons.add_rounded, color: AppColors.textTertiary, isLast: true),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── Bottom Bar ─────────────────────────────────────────────
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
                child: OutlinedButton(
                  onPressed: () => _showLeaveConfirmation(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text('Leave Queue'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_active_rounded, size: 18),
                  label: const Text('Notify Me'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Queue?', style: AppTypography.titleLarge),
        content: Text(
          'You will lose your position (#2) in the queue for Court 3.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final String time;
  final bool isComplete;
  final bool isCurrent;

  const _ProgressStep({required this.label, required this.time, required this.isComplete, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete
                ? AppColors.success.withValues(alpha: 0.15)
                : isCurrent
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : AppColors.surfaceSecondary,
            border: Border.all(
              color: isComplete ? AppColors.success : isCurrent ? AppColors.accent : AppColors.border,
              width: 1.5,
            ),
          ),
          child: isComplete
              ? const Icon(Icons.check_rounded, size: 14, color: AppColors.success)
              : isCurrent
                  ? Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
                    )
                  : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTypography.bodyLarge.copyWith(
          color: isComplete || isCurrent ? AppColors.textPrimary : AppColors.textTertiary,
        ))),
        Text(time, style: AppTypography.monoSmall.copyWith(
          color: isCurrent ? AppColors.accent : AppColors.textTertiary,
        )),
      ],
    );
  }
}

class _ProgressConnector extends StatelessWidget {
  final bool isUpcoming;
  const _ProgressConnector({this.isUpcoming = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      width: 1.5,
      height: 20,
      color: isUpcoming ? AppColors.border : AppColors.success.withValues(alpha: 0.3),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.titleSmall),
      ],
    );
  }
}

class _UpdateRow extends StatelessWidget {
  final String time;
  final String message;
  final IconData icon;
  final Color color;
  final bool isLast;

  const _UpdateRow({required this.time, required this.message, required this.icon, required this.color, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary))),
          Text(time, style: AppTypography.monoSmall),
        ],
      ),
    );
  }
}
