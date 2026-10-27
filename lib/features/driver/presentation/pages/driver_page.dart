import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/presentation/controllers/driver_controller.dart';
import 'package:agri_connect/features/notifications/presentation/controllers/notification_center.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';

class DriverPage extends GetView<DriverController> {
  const DriverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final index = controller.selectedTab.value;
      final title = switch (index) {
        0 => l10n.driverAvailableTab,
        1 => l10n.driverMineTab,
        _ => l10n.driverAccountTab,
      };
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            Obx(() {
              final count = Get.find<NotificationCenter>().unreadCount.value;
              return IconButton(
                tooltip: l10n.notificationsTitle,
                onPressed: () => Get.toNamed(AppRoutes.notifications),
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.notifications_outlined),
                ),
              );
            }),
          ],
        ),
        body: Column(
          children: [
            Obx(() {
              final active = controller.activeDelivery;
              if (active == null) return const SizedBox.shrink();
              return Material(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: Text(l10n.driverActiveCourse),
                  subtitle: Text(active.dropoffAddress),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.toNamed(
                    AppRoutes.driverDelivery(active.id),
                    arguments: active,
                  ),
                ),
              );
            }),
            Expanded(
              child: IndexedStack(
                index: index,
                children: const [
                  DriverAvailablePage(),
                  DriverMinePage(),
                  DriverAccountPage(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.selectTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.work_outline),
              label: l10n.driverAvailableTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.local_shipping_outlined),
              label: l10n.driverMineTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              label: l10n.driverAccountTab,
            ),
          ],
        ),
      );
    });
  }
}

class DriverAvailablePage extends GetView<DriverController> {
  const DriverAvailablePage({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final state = controller.availableState.value;
    if (state is Loading<List<DriverDelivery>>) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is Failure<List<DriverDelivery>>) {
      return _ApiFailureView(
        message: AppNotifier.failureMessage(
          state.failure,
          AppLocalizations.of(context),
        ),
        onRetry: controller.loadAvailable,
      );
    }
    final deliveries = state is Success<List<DriverDelivery>>
        ? state.data
        : const <DriverDelivery>[];
    return RefreshIndicator(
      onRefresh: controller.loadAvailable,
      child: deliveries.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                EmptyState(
                  icon: Icons.inbox_outlined,
                  title: AppLocalizations.of(context).driverAvailableEmptyTitle,
                  body: AppLocalizations.of(context).driverAvailableEmptyBody,
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: deliveries.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == deliveries.length) {
                  return TextButton(
                    onPressed: controller.loadMoreAvailable,
                    child: Text(AppLocalizations.of(context).loadMore),
                  );
                }
                return DeliveryCard(
                  delivery: deliveries[index],
                  showAccept: true,
                );
              },
            ),
    );
  });
}

class DriverMinePage extends GetView<DriverController> {
  const DriverMinePage({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final l10n = AppLocalizations.of(context);
    final state = controller.mineState.value;
    final deliveries = state is Success<List<DriverDelivery>>
        ? state.data
        : const <DriverDelivery>[];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: DropdownButtonFormField<DeliveryStatus?>(
            initialValue: controller.statusFilter.value,
            decoration: InputDecoration(
              labelText: l10n.driverFilterStatus,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<DeliveryStatus?>(child: Text(l10n.allStatuses)),
              for (final status in DeliveryStatus.values)
                DropdownMenuItem<DeliveryStatus?>(
                  value: status,
                  child: Text(deliveryStatusLabel(status, l10n)),
                ),
            ],
            onChanged: controller.setStatusFilter,
          ),
        ),
        Expanded(
          child: switch (state) {
            Loading<List<DriverDelivery>>() => const Center(
              child: CircularProgressIndicator(),
            ),
            Failure<List<DriverDelivery>>(:final failure) => _ApiFailureView(
              message: AppNotifier.failureMessage(failure, l10n),
              onRetry: controller.loadMine,
            ),
            _ => RefreshIndicator(
              onRefresh: controller.loadMine,
              child: deliveries.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.local_shipping_outlined,
                          title: l10n.driverMineEmptyTitle,
                          body: l10n.driverMineEmptyBody,
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: deliveries.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == deliveries.length) {
                          return TextButton(
                            onPressed: controller.loadMoreMine,
                            child: Text(l10n.loadMore),
                          );
                        }
                        return DeliveryCard(delivery: deliveries[index]);
                      },
                    ),
            ),
          },
        ),
      ],
    );
  });
}

class DeliveryCard extends GetView<DriverController> {
  const DeliveryCard({
    super.key,
    required this.delivery,
    this.showAccept = false,
  });

  final DriverDelivery delivery;
  final bool showAccept;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l10n.driverPickupAddress}: ${delivery.pickupAddress}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text('${l10n.driverDropoffAddress}: ${delivery.dropoffAddress}'),
            const SizedBox(height: 6),
            Text('${l10n.driverDistance}: ${delivery.distanceKm} km'),
            const SizedBox(height: 8),
            for (final item in delivery.items)
              Text(
                '${item.productName} · ${item.categoryName} · ${item.quantity}',
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    deliveryStatusLabel(delivery.status, l10n),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(
                    AppRoutes.driverDelivery(delivery.id),
                    arguments: delivery,
                  ),
                  child: Text(l10n.driverDetailTitle),
                ),
              ],
            ),
            if (showAccept)
              Obx(() {
                final isAccepting = controller.acceptingIds.contains(
                  delivery.id,
                );
                return FilledButton(
                  onPressed: isAccepting ? null : () => _accept(context),
                  child: Text(
                    isAccepting ? l10n.driverAccepting : l10n.driverAccept,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    final failure = await controller.accept(delivery.id);
    if (!context.mounted || failure == null) return;
    final l10n = AppLocalizations.of(context);
    final message = switch (failure.code) {
      'DELIVERY_ALREADY_ACTIVE' => l10n.driverAlreadyActive,
      'DELIVERY_ALREADY_TAKEN' => l10n.driverAlreadyTaken,
      _ when failure.status == 404 => l10n.driverAlreadyTaken,
      _ => AppNotifier.failureMessage(failure, l10n),
    };
    AppNotifier.error(message);
  }
}

class DriverAccountPage extends GetView<DriverController> {
  const DriverAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().currentUser;
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(
            [user?.firstname, user?.lastname]
                .whereType<String>()
                .where((name) => name.isNotEmpty)
                .join(' ')
                .ifEmpty(l10n.driverAccountTab),
          ),
          subtitle: Text(l10n.driverTitle),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.profile),
          icon: const Icon(Icons.manage_accounts_outlined),
          label: Text(l10n.sectionProfile),
        ),
        OutlinedButton.icon(
          onPressed: Get.find<AuthController>().signOut,
          icon: const Icon(Icons.logout),
          label: Text(l10n.signOut),
        ),
      ],
    );
  }
}

String deliveryStatusLabel(DeliveryStatus status, AppLocalizations l10n) =>
    switch (status) {
      DeliveryStatus.pending => l10n.deliveryStatusPending,
      DeliveryStatus.accepted => l10n.deliveryStatusAccepted,
      DeliveryStatus.pickedUp => l10n.deliveryStatusPickedUp,
      DeliveryStatus.inTransit => l10n.deliveryStatusInTransit,
      DeliveryStatus.delivered => l10n.deliveryStatusDelivered,
      DeliveryStatus.failed => l10n.deliveryStatusFailed,
      DeliveryStatus.cancelled => l10n.deliveryStatusCancelled,
    };

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class _ApiFailureView extends StatelessWidget {
  const _ApiFailureView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    ),
  );
}
