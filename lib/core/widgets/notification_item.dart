import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../models/models.dart';

/// Notification type icon and color mapping
class NotificationItemWidget extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onTap,
  });

  (IconData, Color) get _typeConfig => switch (notification.type) {
    NotificationType.booking => (Icons.calendar_today_rounded, AppColors.accent),
    NotificationType.facility => (Icons.sports_tennis_rounded, AppColors.success),
    NotificationType.membership => (Icons.card_membership_rounded, AppColors.accent),
    NotificationType.tournament => (Icons.emoji_events_rounded, AppColors.warning),
    NotificationType.coaching => (Icons.school_rounded, AppColors.accent),
    NotificationType.matchFound => (Icons.people_rounded, AppColors.success),
    NotificationType.general => (Icons.notifications_rounded, AppColors.textTertiary),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _typeConfig;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: notification.isRead
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(notification.body, style: AppTypography.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(notification.timestamp, style: AppTypography.labelSmall),
          ],
        ),
      ),
    );
  }
}
