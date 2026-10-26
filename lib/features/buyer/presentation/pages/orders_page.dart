import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/utils/dates.dart';
import 'package:agri_connect/core/utils/money.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/presentation/controllers/orders_controller.dart';
import 'package:agri_connect/shared/domain/order_status.dart';

class BuyerOrdersPage extends GetView<BuyerOrdersController> {
  const BuyerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.buyerOrdersTab)),
      body: Obx(() {
        final state = controller.state.value;
        if (state is Loading<List<BuyerOrder>> ||
            state is Idle<List<BuyerOrder>>) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is Failure<List<BuyerOrder>>) {
          return _OrdersError(
            message: AppNotifier.failureMessage(state.failure, l10n),
            retry: controller.loadFirst,
          );
        }
        final orders = (state as Success<List<BuyerOrder>>).data;
        final countFailure = controller.quotedCountState.value;
        if (orders.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.loadFirst,
            child: ListView(
              children: [
                const SizedBox(height: 140),
                Center(child: Text(l10n.buyerOrdersEmptyMessage)),
                if (countFailure is Failure<int>)
                  Center(
                    child: TextButton(
                      onPressed: controller.loadFirst,
                      child: Text(
                        AppNotifier.failureMessage(countFailure.failure, l10n),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadFirst,
          child: Column(
            children: [
              if (countFailure is Failure<int>)
                MaterialBanner(
                  content: Text(
                    AppNotifier.failureMessage(countFailure.failure, l10n),
                  ),
                  actions: [
                    TextButton(
                      onPressed: controller.loadFirst,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >
                        notification.metrics.maxScrollExtent - 300) {
                      controller.loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length + (controller.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == orders.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final order = orders[index];
                      return _OrderCard(
                        order: order,
                        onTap: () =>
                            Get.toNamed(AppRoutes.buyerOrder(order.id)),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final BuyerOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quoted = order.status == OrderStatus.quoted;
    return Card(
      color: quoted ? Theme.of(context).colorScheme.secondaryContainer : null,
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Expanded(child: Text(order.orderNumber)),
            if (quoted)
              Chip(
                label: Text(l10n.buyerOrderActionRequired),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        subtitle: Text(
          '${_statusLabel(order.status, l10n)} · ${Dates.short(order.createdAt)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Money.format(order.total)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

String buyerOrderStatusLabel(OrderStatus status, AppLocalizations l10n) =>
    _statusLabel(status, l10n);

String _statusLabel(OrderStatus status, AppLocalizations l10n) =>
    switch (status) {
      OrderStatus.quoted => l10n.buyerStatusQuoted,
      OrderStatus.confirmed => l10n.buyerStatusConfirmed,
      OrderStatus.preparing => l10n.buyerStatusPreparing,
      OrderStatus.readyForPickup => l10n.buyerStatusReadyForPickup,
      OrderStatus.outForDelivery => l10n.buyerStatusOutForDelivery,
      OrderStatus.completed => l10n.buyerStatusCompleted,
      OrderStatus.cancelled => l10n.buyerStatusCancelled,
    };

class _OrdersError extends StatelessWidget {
  const _OrdersError({required this.message, required this.retry});

  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
        TextButton(
          onPressed: retry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      ],
    ),
  );
}
