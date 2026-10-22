import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/notifications/application/notifications_controller.dart';
import 'package:agri_connect/features/notifications/domain/notification_item.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(
      authControllerProvider.select((state) => state.user),
    );
    final notifications = ref.watch(notificationsControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.back,
          onPressed: () {
            final role = user?.role;
            context.go(role?.homePath ?? '/');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(l10n.notificationsTitle),
      ),
      body: notifications.hasError && !notifications.hasValue
          ? _LoadFailure(
              onRetry: () => ref.invalidate(notificationsControllerProvider),
            )
          : notifications.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoadFailure(
                onRetry: () => ref.invalidate(notificationsControllerProvider),
              ),
              data: (items) {
                final unreadCount = items.where((item) => !item.isRead).length;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(notificationsControllerProvider.future),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: [
                          Material(
                            color: colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.science_outlined,
                                    color: colors.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      l10n.notificationsDemoNotice,
                                      style: TextStyle(
                                        color: colors.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final count = Text(
                                l10n.notificationsUnreadCount('$unreadCount'),
                                style: Theme.of(context).textTheme.titleMedium,
                              );
                              if (unreadCount == 0) return count;
                              if (constraints.maxWidth < 500) {
                                return Row(
                                  children: [
                                    Expanded(child: count),
                                    IconButton(
                                      tooltip: l10n.notificationsMarkAllRead,
                                      onPressed: () =>
                                          _markAllRead(context, ref),
                                      icon: const Icon(Icons.done_all_rounded),
                                    ),
                                  ],
                                );
                              }
                              return Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                runSpacing: 4,
                                children: [
                                  count,
                                  TextButton.icon(
                                    onPressed: () => _markAllRead(context, ref),
                                    icon: const Icon(Icons.done_all_rounded),
                                    label: Text(l10n.notificationsMarkAllRead),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          if (items.isEmpty)
                            _EmptyNotifications()
                          else
                            for (final item in items)
                              _NotificationCard(
                                item: item,
                                onOpen: () =>
                                    _openNotification(context, ref, user, item),
                                onMarkRead: () =>
                                    _markRead(context, ref, item.id),
                              ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _openNotification(
    BuildContext context,
    WidgetRef ref,
    AuthUser? user,
    NotificationItem item,
  ) async {
    if (user == null) return;
    if (!item.isRead) {
      try {
        await ref
            .read(notificationsControllerProvider.notifier)
            .markRead(item.id);
      } on Failure catch (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message(context.l10n))),
          );
        }
        return;
      }
    }
    if (context.mounted) {
      context.go('${user.role.routePrefix}/${item.destination.routeName}');
    }
  }

  Future<void> _markRead(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(notificationsControllerProvider.notifier).markRead(id);
    } on Failure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message(context.l10n))));
      }
    }
  }

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(notificationsControllerProvider.notifier).markAllRead();
    } on Failure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message(context.l10n))));
      }
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onOpen,
    required this.onMarkRead,
  });

  final NotificationItem item;
  final VoidCallback onOpen;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMd(locale).add_jm().format(item.createdAt);
    final message = _messageText(item.message, l10n);
    final details = Semantics(
      button: true,
      label: '${message.$1}. ${message.$2}',
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    message.$1,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: item.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                  _CategoryChip(category: item.category),
                ],
              ),
              const SizedBox(height: 4),
              Text(message.$2),
              const SizedBox(height: 6),
              Text(
                date,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final markRead = IconButton(
      tooltip: l10n.notificationsMarkRead,
      onPressed: onMarkRead,
      icon: const Icon(Icons.mark_email_read_outlined),
      color: colors.primary,
    );
    final status = item.isRead
        ? Padding(
            padding: const EdgeInsetsDirectional.only(top: 12, end: 12),
            child: Icon(
              Icons.done_all_rounded,
              size: 18,
              color: colors.onSurfaceVariant,
              semanticLabel: l10n.notificationsRead,
            ),
          )
        : markRead;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 14,
          top: 12,
          bottom: 12,
          end: 4,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final icon = Padding(
              padding: const EdgeInsetsDirectional.only(top: 2, end: 12),
              child: Icon(
                _categoryIcon(item.category),
                color: item.isRead ? colors.onSurfaceVariant : colors.primary,
              ),
            );
            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      icon,
                      Expanded(child: details),
                    ],
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: status,
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                Expanded(child: details),
                status,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final NotificationCategory category;

  @override
  Widget build(BuildContext context) {
    final label = switch (category) {
      NotificationCategory.orders => context.l10n.notificationsCategoryOrders,
      NotificationCategory.products =>
        context.l10n.notificationsCategoryProducts,
      NotificationCategory.deliveries =>
        context.l10n.notificationsCategoryDeliveries,
      NotificationCategory.support => context.l10n.notificationsCategorySupport,
      NotificationCategory.administration =>
        context.l10n.notificationsCategoryAdministration,
    };
    return Chip(visualDensity: VisualDensity.compact, label: Text(label));
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.notificationsEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.notificationsEmptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.notificationsLoadError,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(NotificationCategory category) => switch (category) {
  NotificationCategory.orders => Icons.receipt_long_outlined,
  NotificationCategory.products => Icons.inventory_2_outlined,
  NotificationCategory.deliveries => Icons.local_shipping_outlined,
  NotificationCategory.support => Icons.support_agent_outlined,
  NotificationCategory.administration => Icons.admin_panel_settings_outlined,
};

(String, String) _messageText(
  DemoNotificationMessage message,
  AppLocalizations l10n,
) => switch (message) {
  DemoNotificationMessage.buyerOrderUpdate => (
    l10n.notificationBuyerOrderTitle,
    l10n.notificationBuyerOrderBody,
  ),
  DemoNotificationMessage.buyerDeliveryUpdate => (
    l10n.notificationBuyerDeliveryTitle,
    l10n.notificationBuyerDeliveryBody,
  ),
  DemoNotificationMessage.supplierNewOrder => (
    l10n.notificationSupplierOrderTitle,
    l10n.notificationSupplierOrderBody,
  ),
  DemoNotificationMessage.supplierProductAction => (
    l10n.notificationSupplierProductTitle,
    l10n.notificationSupplierProductBody,
  ),
  DemoNotificationMessage.driverDeliveryAssigned => (
    l10n.notificationDriverDeliveryTitle,
    l10n.notificationDriverDeliveryBody,
  ),
  DemoNotificationMessage.driverTripUpdate => (
    l10n.notificationDriverTripTitle,
    l10n.notificationDriverTripBody,
  ),
  DemoNotificationMessage.agentSupportRequest => (
    l10n.notificationAgentSupportTitle,
    l10n.notificationAgentSupportBody,
  ),
  DemoNotificationMessage.agentOrderAction => (
    l10n.notificationAgentOrderTitle,
    l10n.notificationAgentOrderBody,
  ),
  DemoNotificationMessage.agentStockReview => (
    l10n.notificationAgentStockTitle,
    l10n.notificationAgentStockBody,
  ),
  DemoNotificationMessage.adminProductReview => (
    l10n.notificationAdminProductTitle,
    l10n.notificationAdminProductBody,
  ),
  DemoNotificationMessage.adminOrderReview => (
    l10n.notificationAdminOrderTitle,
    l10n.notificationAdminOrderBody,
  ),
  DemoNotificationMessage.rootPlatformActivity => (
    l10n.notificationRootPlatformTitle,
    l10n.notificationRootPlatformBody,
  ),
  DemoNotificationMessage.rootStaffActivity => (
    l10n.notificationRootStaffTitle,
    l10n.notificationRootStaffBody,
  ),
};
