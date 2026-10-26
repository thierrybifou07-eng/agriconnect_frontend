import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/notifications/domain/app_notification.dart';
import 'package:agri_connect/features/notifications/presentation/controllers/notification_center.dart';

class NotificationsPage extends GetView<NotificationCenter> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(labels.notificationsTitle),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: Text(labels.notificationsMarkAllRead),
          ),
        ],
      ),
      body: Obx(() {
        final items = controller.notifications;
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    labels.notificationsEmptyTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels.notificationsEmptyBody,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final notification = items[index];
            return _NotificationTile(
              notification: notification,
              onTap: () {
                controller.markRead(notification.id);
                final route = notification.route;
                if (route != null) {
                  Get.toNamed(route, arguments: notification.args);
                }
              },
            );
          },
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(_icon(notification.kind)),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(notification.body),
      trailing: notification.read
          ? null
          : Icon(Icons.circle, size: 10, color: theme.colorScheme.primary),
    );
  }

  IconData _icon(AppNotificationKind kind) => switch (kind) {
    AppNotificationKind.message => Icons.forum_outlined,
    AppNotificationKind.deliveryAvailable => Icons.local_shipping_outlined,
    AppNotificationKind.deliveryStatus => Icons.local_shipping_outlined,
    AppNotificationKind.expiring => Icons.warning_amber_outlined,
    AppNotificationKind.aiSuggestion => Icons.auto_awesome_outlined,
  };
}
