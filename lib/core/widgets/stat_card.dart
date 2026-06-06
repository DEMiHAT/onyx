import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Compact analytics stat card — label, large value, optional trend.
/// Designed for dense dashboard layouts. No oversized cards.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final bool isPositiveTrend;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.isPositiveTrend = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.headlineMedium),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Text(
              trend!,
              style: AppTypography.labelSmall.copyWith(
                color: isPositiveTrend ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
