import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/utils/dates.dart';
import 'package:agri_connect/core/utils/money.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/presentation/controllers/orders_controller.dart';
import 'package:agri_connect/features/buyer/presentation/pages/orders_page.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/order_detail_widgets.dart';
import 'package:agri_connect/shared/domain/order_status.dart';

class BuyerOrderDetailPage extends GetView<BuyerOrderDetailController> {
  const BuyerOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderDetailTitle)),
      body: Obx(() {
        final state = controller.state.value;
        if (state is Loading<BuyerOrder> || state is Idle<BuyerOrder>) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is Failure<BuyerOrder>) {
          return _DetailError(
            message: state.failure.status == 404
                ? l10n.orderNotFound
                : AppNotifier.failureMessage(state.failure, l10n),
            onRetry: controller.load,
          );
        }
        final order = (state as Success<BuyerOrder>).data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              order.orderNumber,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(buyerOrderStatusLabel(order.status, l10n)),
            Text('${l10n.orderDateLabel}: ${Dates.short(order.createdAt)}'),
            if (order.status == OrderStatus.quoted &&
                order.reservedUntil != null)
              BuyerOrderQuoteExpiry(controller: controller),
            const SizedBox(height: 20),
            Text(
              l10n.buyerOrderItems,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final item in order.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.listingTitle),
                subtitle: Text(
                  '${item.listingReference} · ${_quantity(item.quantity)} × ${Money.format(item.unitPrice)}',
                ),
                trailing: Text(Money.format(item.lineTotal)),
              ),
            const Divider(),
            Text(
              l10n.buyerQuoteTotals,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            BuyerOrderAmountRow(
              label: l10n.buyerOrderSubtotalLabel,
              value: order.subtotal,
            ),
            BuyerOrderAmountRow(
              label: l10n.buyerOrderBuyerFeeLabel,
              value: order.buyerFee,
            ),
            BuyerOrderAmountRow(
              label: l10n.buyerOrderDeliveryFeeLabel,
              value: order.deliveryFee,
            ),
            BuyerOrderAmountRow(
              label: l10n.totalLabel,
              value: order.total,
              emphasized: true,
            ),
            const SizedBox(height: 16),
            if (order.deliveryMode == 'HUB_PICKUP' && order.pickup != null) ...[
              Text(
                l10n.buyerDeliveryModePickup,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(order.pickup!.name),
              Text(
                '${l10n.buyerPickupAddress}: ${order.pickup!.address}, ${order.pickup!.city}',
              ),
            ],
            if (order.deliveryMode == 'AGENCY_DELIVERY' &&
                order.delivery != null) ...[
              Text(
                l10n.buyerDeliveryModeAgency,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text('${l10n.buyerDeliveryAddress}: ${order.delivery!.address}'),
            ],
            if (order.cancellationReason?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  l10n.buyerOrderCancellationReason(order.cancellationReason!),
                ),
              ),
            const SizedBox(height: 20),
            BuyerOrderStatusTimeline(order: order),
            if (order.status == OrderStatus.quoted)
              BuyerQuoteActions(
                controller: controller,
                onConfirm: () => _confirm(context, controller),
                onCancel: () => _cancel(context, controller, isQuote: true),
              ),
            if (order.status.canCancel && order.status != OrderStatus.quoted)
              BuyerCancelOrderButton(
                controller: controller,
                onPressed: () => _cancel(context, controller, isQuote: false),
              ),
          ],
        );
      }),
    );
  }
}

Future<void> _confirm(
  BuildContext context,
  BuyerOrderDetailController controller,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      content: Text(l10n.buyerConfirmQuoteQuestion),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Get.back(result: true),
          child: Text(l10n.buyerConfirmQuote),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  final failure = await controller.confirm();
  if (failure != null) {
    if (failure.isProfileNotVerified) {
      await AppNotifier.showProfileNotVerifiedDialog();
    } else {
      AppNotifier.error(AppNotifier.failureMessage(failure, l10n));
    }
  }
}

Future<void> _cancel(
  BuildContext context,
  BuyerOrderDetailController controller, {
  required bool isQuote,
}) async {
  final l10n = AppLocalizations.of(context);
  final reason = await showDialog<String>(
    context: context,
    builder: (_) => BuyerCancellationDialog(isQuote: isQuote),
  );
  if (reason == null) return;
  final failure = await controller.cancel(
    reason: reason.trim().isEmpty ? null : reason.trim(),
  );
  if (failure != null) {
    AppNotifier.error(AppNotifier.failureMessage(failure, l10n));
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
          onPressed: onRetry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      ],
    ),
  );
}

String _quantity(double value) => value == value.truncateToDouble()
    ? value.toInt().toString()
    : value.toString();
