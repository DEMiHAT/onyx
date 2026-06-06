import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../models/models.dart';

/// Compact status chip — Available / Occupied / Maintenance
/// Uses a small dot indicator + label. Minimal footprint.
class StatusChip extends StatelessWidget {
  final FacilityStatus status;
  final bool compact;

  const StatusChip({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      FacilityStatus.available => ('Available', AppColors.success),
      FacilityStatus.occupied => ('Occupied', AppColors.warning),
      FacilityStatus.maintenance => ('Maintenance', AppColors.error),
      FacilityStatus.reserved => ('Reserved', AppColors.accent),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: (compact ? AppTypography.labelSmall : AppTypography.labelMedium)
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
