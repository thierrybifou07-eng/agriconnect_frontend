import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/utils/dates.dart';
import 'package:agri_connect/core/utils/money.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/presentation/controllers/orders_controller.dart';
import 'package:agri_connect/features/buyer/presentation/pages/orders_page.dart';
import 'package:agri_connect/shared/domain/order_status.dart';

class BuyerOrderQuoteExpiry extends StatelessWidget {
  const BuyerOrderQuoteExpiry({super.key, required this.controller});

  final BuyerOrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      if (controller.expired.value) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            l10n.buyerQuoteExpired,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(l10n.buyerQuoteExpiresIn(controller.countdown.value)),
      );
    });
  }
}

class BuyerQuoteActions extends StatelessWidget {
  const BuyerQuoteActions({
    super.key,
    required this.controller,
    required this.onConfirm,
    required this.onCancel,
  });

  final BuyerOrderDetailController controller;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final unavailable =
          controller.expired.value || controller.submitting.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: unavailable ? null : onConfirm,
            child: controller.submitting.value
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.buyerConfirmQuote),
          ),
          TextButton(
            onPressed: unavailable ? null : onCancel,
            child: Text(l10n.buyerCancelQuote),
          ),
        ],
      );
    });
  }
}

class BuyerCancelOrderButton extends StatelessWidget {
  const BuyerCancelOrderButton({
    super.key,
    required this.controller,
    required this.onPressed,
  });

  final BuyerOrderDetailController controller;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Obx(
    () => TextButton(
      onPressed: controller.submitting.value ? null : onPressed,
      child: Text(AppLocalizations.of(context).buyerCancelOrder),
    ),
  );
}

class BuyerCancellationDialog extends StatefulWidget {
  const BuyerCancellationDialog({super.key, required this.isQuote});

  final bool isQuote;

  @override
  State<BuyerCancellationDialog> createState() =>
      _BuyerCancellationDialogState();
}

class _BuyerCancellationDialogState extends State<BuyerCancellationDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.isQuote
            ? l10n.buyerCancelQuoteQuestion
            : l10n.buyerCancelOrderQuestion,
      ),
      content: TextField(
        controller: _reason,
        maxLength: 500,
        maxLines: 3,
        decoration: InputDecoration(hintText: l10n.buyerCancellationReasonHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _reason.text),
          child: Text(
            widget.isQuote ? l10n.buyerCancelQuote : l10n.buyerCancelOrder,
          ),
        ),
      ],
    );
  }
}

class BuyerOrderAmountRow extends StatelessWidget {
  const BuyerOrderAmountRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasized ? Theme.of(context).textTheme.titleMedium : null,
          ),
        ),
        Text(
          Money.format(value),
          style: emphasized ? Theme.of(context).textTheme.titleMedium : null,
        ),
      ],
    ),
  );
}

class BuyerOrderStatusTimeline extends StatelessWidget {
  const BuyerOrderStatusTimeline({super.key, required this.order});

  final BuyerOrder order;

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    final statuses = switch (status) {
      OrderStatus.quoted => [OrderStatus.quoted],
      OrderStatus.confirmed => [OrderStatus.quoted, OrderStatus.confirmed],
      OrderStatus.preparing => [
        OrderStatus.quoted,
        OrderStatus.confirmed,
        OrderStatus.preparing,
      ],
      OrderStatus.readyForPickup => [
        OrderStatus.quoted,
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.readyForPickup,
      ],
      OrderStatus.outForDelivery => [
        OrderStatus.quoted,
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.outForDelivery,
      ],
      OrderStatus.completed => [
        OrderStatus.quoted,
        OrderStatus.confirmed,
        OrderStatus.preparing,
        if (order.deliveryMode == 'HUB_PICKUP')
          OrderStatus.readyForPickup
        else if (order.deliveryMode == 'AGENCY_DELIVERY')
          OrderStatus.outForDelivery,
        OrderStatus.completed,
      ],
      OrderStatus.cancelled =>
        order.confirmedAt == null
            ? [OrderStatus.quoted, OrderStatus.cancelled]
            : [
                OrderStatus.quoted,
                OrderStatus.confirmed,
                OrderStatus.cancelled,
              ],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).trackingTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (var index = 0; index < statuses.length; index++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              index == statuses.length - 1
                  ? Icons.radio_button_checked
                  : Icons.check_circle_outline,
            ),
            title: Text(
              buyerOrderStatusLabel(
                statuses[index],
                AppLocalizations.of(context),
              ),
            ),
            subtitle: _statusDate(statuses[index]) == null
                ? null
                : Text(Dates.short(_statusDate(statuses[index])!)),
          ),
      ],
    );
  }

  DateTime? _statusDate(OrderStatus status) => switch (status) {
    OrderStatus.quoted => order.createdAt,
    OrderStatus.confirmed => order.confirmedAt,
    OrderStatus.completed => order.completedAt,
    OrderStatus.cancelled => order.cancelledAt,
    _ => null,
  };
}
