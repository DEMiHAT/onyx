import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Queue position indicator — shows position, estimated wait, and progress.
class QueueIndicator extends StatelessWidget {
  final int position;
  final int estimatedWaitMinutes;
  final String facilityName;
  final bool compact;

  const QueueIndicator({
    super.key,
    required this.position,
    required this.estimatedWaitMinutes,
    required this.facilityName,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.queue_rounded, size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            '#$position · ${estimatedWaitMinutes}m',
            style: AppTypography.labelSmall.copyWith(color: AppColors.warning),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text('QUEUE POSITION', style: AppTypography.overline),
          const SizedBox(height: 8),
          Text(
            '#$position',
            style: AppTypography.displayLarge.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoColumn(label: 'Est. Wait', value: '$estimatedWaitMinutes min'),
              Container(width: 1, height: 28, color: AppColors.border),
              _InfoColumn(label: 'Facility', value: facilityName),
              Container(width: 1, height: 28, color: AppColors.border),
              _InfoColumn(label: 'Ahead', value: '${position - 1}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.titleSmall),
      ],
    );
  }
}
