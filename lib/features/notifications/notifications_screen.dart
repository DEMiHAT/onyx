import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/notification_item.dart';
import '../../core/constants/mock_data.dart';

/// Notifications Screen — Grouped notification feed.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = MockData.notifications.where((n) => !n.isRead).toList();
    final read = MockData.notifications.where((n) => n.isRead).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.titleLarge),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Mark all read', style: AppTypography.labelSmall.copyWith(color: AppColors.accent)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        children: [
          if (unread.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text('NEW', style: AppTypography.overline),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${unread.length}',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.accent, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            ...unread.map((n) => NotificationItemWidget(notification: n, onTap: () {})),
          ],
          if (read.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('EARLIER', style: AppTypography.overline),
            ),
            ...read.map((n) => NotificationItemWidget(notification: n, onTap: () {})),
          ],
        ],
      ),
    );
  }
}
