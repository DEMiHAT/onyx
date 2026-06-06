import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Vertical timeline component for booking/session schedules.
class TimelineItemWidget extends StatelessWidget {
  final String time;
  final String title;
  final String? subtitle;
  final bool isCurrent;
  final bool isLast;

  const TimelineItemWidget({
    super.key,
    required this.time,
    required this.title,
    this.subtitle,
    this.isCurrent = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 56,
            child: Text(
              time,
              style: AppTypography.monoSmall.copyWith(
                color: isCurrent ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ),
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? AppColors.accent : AppColors.border,
                  border: isCurrent
                      ? Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 3)
                      : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.accentSubtle : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCurrent ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: isCurrent ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTypography.bodySmall),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
