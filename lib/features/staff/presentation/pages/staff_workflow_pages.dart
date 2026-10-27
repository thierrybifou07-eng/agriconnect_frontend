import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/state_views.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/utils/dates.dart';
import 'package:agri_connect/core/utils/money.dart';
import 'package:agri_connect/features/reference/presentation/widgets/reference_pickers.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_entities.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_quote_controller.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_workflow_controllers.dart';
import 'package:agri_connect/shared/domain/order_status.dart';

class StaffOrdersPage extends StatelessWidget {
  const StaffOrdersPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).staffOrders)),
    body: const StaffOrdersPanel(),
  );
}

class StaffOrdersPanel extends GetView<StaffOrdersController> {
  const StaffOrdersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Obx(() {
      final current = controller.state.value;
      if (current is Loading<List<StaffOrder>>) return const LoadingView();
      if (current is Failure<List<StaffOrder>>) {
        return ErrorView(failure: current.failure, onRetry: controller.load);
      }
      final orders = current is Success<List<StaffOrder>>
          ? current.data
          : const <StaffOrder>[];
      if (orders.isEmpty) return EmptyView(message: labels.staffNoOrders);
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 240) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: orders.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == orders.length) {
              return TextButton(
                onPressed: controller.loadingMore.value
                    ? null
                    : controller.loadMore,
                child: Text(labels.staffLoadMore),
              );
            }
            final order = orders[index];
            final buyer =
                '${order.buyer['firstname'] ?? ''} ${order.buyer['lastname'] ?? ''}'
                    .trim();
            return ListTile(
              title: Text(order.reference ?? '#${order.id}'),
              subtitle: Text(
                '$buyer · ${_orderStatusLabel(labels, order.status)} · ${Money.format(order.total)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(AppRoutes.staffOrder(order.id)),
            );
          },
        ),
      );
    });
  }
}

class StaffOrderDetailPage extends StatelessWidget {
  const StaffOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StaffOrdersController>();
    final rawId = int.tryParse(Get.parameters['orderId'] ?? '');
    if (rawId != null && controller.selected.value?.id != rawId) {
      controller.open(rawId);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).staffOrderDetail),
      ),
      body: StaffOrderDetailPanel(controller: controller),
    );
  }
}

class StaffOrderDetailPanel extends GetView<StaffOrdersController> {
  const StaffOrderDetailPanel({super.key, required this.controller});
  @override
  final StaffOrdersController controller;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Obx(() {
      final current = controller.detailState.value;
      if (current is Loading<StaffOrder> || current is Idle<StaffOrder>) {
        return const LoadingView();
      }
      if (current is Failure<StaffOrder>) {
        return ErrorView(
          failure: current.failure,
          onRetry: () {
            final id = int.tryParse(Get.parameters['orderId'] ?? '');
            if (id != null) controller.open(id);
          },
        );
      }
      final order = (current as Success<StaffOrder>).data;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            order.reference ?? '#${order.id}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            '${_orderStatusLabel(labels, order.status)} · ${_orderPaymentStatusLabel(labels, order.paymentStatus)}',
          ),
          if (order.reservedUntil != null)
            Text(
              '${labels.staffQuoteExpires}: ${Dates.shortDateTime(order.reservedUntil!)} · ${Dates.countdown(order.reservedUntil!, now: controller.clock.value)}',
            ),
          const SizedBox(height: 12),
          Text(
            '${order.buyer['firstname'] ?? ''} ${order.buyer['lastname'] ?? ''}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final item in order.items)
            Card(
              child: ListTile(
                title: Text(
                  item.listingTitle ??
                      item.listingReference ??
                      '#${item.listingId}',
                ),
                subtitle: Text(
                  '${item.quantity} × ${Money.format(item.unitPrice)}'
                  '${item.supplierUnitPrice == null ? '' : ' · ${labels.staffSupplierUnitPrice}: ${Money.format(item.supplierUnitPrice!)}'}'
                  '${item.commissionAmount == null ? '' : ' · ${labels.staffCommission}: ${Money.format(item.commissionAmount!)}'}'
                  '${item.supplierNetAmount == null ? '' : ' · ${labels.staffSupplierNet}: ${Money.format(item.supplierNetAmount!)}'}',
                ),
                trailing: Text(Money.format(item.lineTotal)),
              ),
            ),
          _OrderTotals(order: order),
          const SizedBox(height: 12),
          if (controller.canProcessOrders)
            _OrderActions(controller: controller, order: order),
          if (controller.canFollowPayments) ...[
            const Divider(height: 32),
            _PaymentsPanel(controller: controller, order: order),
          ],
          if (controller.canDispatch) ...[
            const Divider(height: 32),
            _DeliveriesPanel(controller: controller, order: order),
          ],
        ],
      );
    });
  }
}

class _OrderTotals extends StatelessWidget {
  const _OrderTotals({required this.order});
  final StaffOrder order;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order.subtotal != null)
              _total(labels.staffSubtotal, order.subtotal!),
            if (order.buyerFee != null)
              _total(labels.staffBuyerFee, order.buyerFee!),
            if (order.deliveryFee != null)
              _total(labels.staffDeliveryFee, order.deliveryFee!),
            if (order.commissionTotal != null)
              _total(labels.staffCommission, order.commissionTotal!),
            _total(labels.staffOrderTotal, order.total, emphasized: true),
          ],
        ),
      ),
    );
  }

  Widget _total(String label, double value, {bool emphasized = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              Money.format(value),
              style: emphasized
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
          ],
        ),
      );
}

class _OrderActions extends StatelessWidget {
  const _OrderActions({required this.controller, required this.order});
  final StaffOrdersController controller;
  final StaffOrder order;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final actions = <Widget>[];
    if (order.status == OrderStatus.quoted) {
      actions.add(
        FilledButton(
          onPressed: () async =>
              _showFailure(labels, await controller.confirm(), null),
          child: Text(labels.staffConfirmQuote),
        ),
      );
    }
    for (final next
        in StaffOrdersController.manualTransitions[order.status] ??
            const <OrderStatus>{}) {
      if (next == OrderStatus.confirmed || next == OrderStatus.cancelled) {
        if (next == OrderStatus.cancelled) {
          actions.add(
            OutlinedButton(
              onPressed: () async => _showFailure(
                labels,
                await controller.changeStatus(next),
                null,
              ),
              child: Text(labels.staffCancelOrder),
            ),
          );
        }
        continue;
      }
      if (next == OrderStatus.readyForPickup &&
          order.deliveryMode != 'HUB_PICKUP') {
        continue;
      }
      actions.add(
        FilledButton.tonal(
          onPressed: () async {
            final failure = await controller.changeStatus(next);
            _showFailure(labels, failure, next);
          },
          child: Text(_orderStatusLabel(labels, next)),
        ),
      );
    }
    if (controller.canDispatch &&
        order.deliveryMode == 'AGENCY_DELIVERY' &&
        (order.status == OrderStatus.confirmed ||
            order.status == OrderStatus.preparing)) {
      actions.add(
        OutlinedButton(
          onPressed: () async =>
              _showFailure(labels, await controller.createDeliveries(), null),
          child: Text(labels.staffCreateDeliveries),
        ),
      );
    }
    if (actions.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: actions);
  }

  void _showFailure(
    AppLocalizations labels,
    ApiFailure? failure,
    OrderStatus? attemptedStatus,
  ) {
    if (failure == null) return;
    if (attemptedStatus == OrderStatus.preparing && failure.status == 409) {
      AppNotifier.error(labels.staffPaymentRequired);
      return;
    }
    AppNotifier.error(_workflowFailure(labels, failure));
  }
}

class _PaymentsPanel extends StatelessWidget {
  const _PaymentsPanel({required this.controller, required this.order});
  final StaffOrdersController controller;
  final StaffOrder order;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labels.staffPayments,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            FilledButton.tonal(
              onPressed: () => _paymentDialog(context, controller, order),
              child: Text(labels.staffRecordPayment),
            ),
          ],
        ),
        Obx(() {
          final current = controller.paymentsState.value;
          if (current is Loading<List<StaffPayment>>) {
            return const LinearProgressIndicator();
          }
          if (current is Failure<List<StaffPayment>>) {
            return ErrorView(
              failure: current.failure,
              onRetry: () => controller.loadPayments(order.id),
            );
          }
          final payments = current is Success<List<StaffPayment>>
              ? current.data
              : const <StaffPayment>[];
          if (payments.isEmpty) return Text(labels.staffNoPayments);
          return Column(
            children: [
              for (final payment in payments)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${Money.format(payment.amount)} · ${_paymentMethodLabel(labels, payment.method)}',
                  ),
                  subtitle: Text(
                    '${payment.status}${payment.reference == null ? '' : ' · ${payment.reference}'}',
                  ),
                  trailing:
                      controller.canRefund && payment.status == 'CONFIRMED'
                      ? TextButton(
                          onPressed: () async {
                            final failure = await controller.refund(payment.id);
                            if (failure != null) {
                              AppNotifier.error(
                                _workflowFailure(labels, failure),
                              );
                            }
                          },
                          child: Text(labels.staffRefund),
                        )
                      : null,
                ),
            ],
          );
        }),
      ],
    );
  }
}

Future<void> _paymentDialog(
  BuildContext context,
  StaffOrdersController controller,
  StaffOrder order,
) async {
  final labels = AppLocalizations.of(context);
  final amount = TextEditingController();
  final reference = TextEditingController();
  var method = 'CASH';
  final formKey = GlobalKey<FormState>();
  final result = await Get.dialog<(double, String, String?)>(
    StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(labels.staffRecordPayment),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: labels.staffAmount),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  return parsed == null || parsed <= 0
                      ? labels.staffPositiveAmount
                      : null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: InputDecoration(
                  labelText: labels.staffPaymentMethod,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'CASH',
                    child: Text(labels.staffCash),
                  ),
                  DropdownMenuItem(
                    value: 'MOBILE_MONEY',
                    child: Text(labels.staffMobileMoney),
                  ),
                  DropdownMenuItem(
                    value: 'BANK_TRANSFER',
                    child: Text(labels.staffBankTransfer),
                  ),
                ],
                onChanged: (value) => setState(() => method = value ?? 'CASH'),
              ),
              TextField(
                controller: reference,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: labels.staffReferenceOptional,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(labels.cancel)),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Get.back(
                result: (
                  double.parse(amount.text),
                  method,
                  reference.text.trim().isEmpty ? null : reference.text.trim(),
                ),
              );
            },
            child: Text(labels.staffRecordPayment),
          ),
        ],
      ),
    ),
  );
  amount.dispose();
  reference.dispose();
  if (result == null) return;
  final failure = await controller.recordPayment(
    order.id,
    amount: result.$1,
    method: result.$2,
    reference: result.$3,
  );
  if (failure != null) AppNotifier.error(_workflowFailure(labels, failure));
}

class _DeliveriesPanel extends StatelessWidget {
  const _DeliveriesPanel({required this.controller, required this.order});
  final StaffOrdersController controller;
  final StaffOrder order;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labels.staffDeliveries,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Obx(
          () => Text(
            '${controller.deliveryStatus.value.isEmpty ? labels.staffDeliveryUnknown : _deliveryStatusLabel(labels, controller.deliveryStatus.value)} · ${controller.deliveryAvailable.value ? labels.staffDeliveryAvailable : labels.staffDeliveryUnavailable}',
          ),
        ),
        Obx(
          () => DropdownButton<String>(
            value: controller.deliveryStatusFilter.value,
            hint: Text(labels.staffStatusFilter),
            items: [
              DropdownMenuItem(value: '', child: Text(labels.staffInboxAll)),
              for (final status in const [
                'PENDING',
                'ACCEPTED',
                'PICKED_UP',
                'IN_TRANSIT',
                'DELIVERED',
                'FAILED',
                'CANCELLED',
              ])
                DropdownMenuItem(
                  value: status,
                  child: Text(_deliveryStatusLabel(labels, status)),
                ),
            ],
            onChanged: (status) {
              if (status != null) controller.setDeliveryStatus(status);
            },
          ),
        ),
        Obx(() {
          final current = controller.deliveriesState.value;
          if (current is Loading<List<StaffDelivery>>) {
            return const LinearProgressIndicator();
          }
          if (current is Failure<List<StaffDelivery>>) {
            return ErrorView(
              failure: current.failure,
              onRetry: () => controller.loadDeliveries(order.id),
            );
          }
          final deliveries = current is Success<List<StaffDelivery>>
              ? current.data
              : const <StaffDelivery>[];
          if (deliveries.isEmpty) {
            return Text(
              '${labels.staffNoDeliveries} · ${controller.deliveryStatus.value.isEmpty ? labels.staffDeliveryUnknown : _deliveryStatusLabel(labels, controller.deliveryStatus.value)} · ${controller.deliveryAvailable.value ? labels.staffDeliveryAvailable : labels.staffDeliveryUnavailable}',
            );
          }
          return Column(
            children: [
              for (final delivery in deliveries)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${delivery.agencyName ?? labels.staffAgency} · ${_deliveryStatusLabel(labels, delivery.status)}',
                        ),
                        if (delivery.pickupAddress != null)
                          Text(
                            '${labels.staffPickup}: ${delivery.pickupAddress}',
                          ),
                        if (delivery.dropoffAddress != null)
                          Text(
                            '${labels.staffDropoff}: ${delivery.dropoffAddress}',
                          ),
                        if (delivery.agencyCost != null)
                          Text(
                            '${labels.staffAgencyCost}: ${Money.format(delivery.agencyCost!)}',
                          ),
                        if (delivery.deliveryFee != null)
                          Text(
                            '${labels.staffDeliveryFee}: ${Money.format(delivery.deliveryFee!)}',
                          ),
                        if (delivery.insuredValue != null)
                          Text(
                            '${labels.staffInsuredValue}: ${Money.format(delivery.insuredValue!)}',
                          ),
                        if (delivery.insurancePolicyNumber != null)
                          Text(
                            '${labels.staffInsurancePolicy}: ${delivery.insurancePolicyNumber}',
                          ),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (delivery.status == 'ACCEPTED')
                              TextButton(
                                onPressed: () => _deliveryAction(
                                  context,
                                  controller,
                                  delivery,
                                  'release',
                                ),
                                child: Text(labels.staffReleaseDelivery),
                              ),
                            if (delivery.status == 'FAILED')
                              TextButton(
                                onPressed: () => _deliveryAction(
                                  context,
                                  controller,
                                  delivery,
                                  'redispatch',
                                ),
                                child: Text(labels.staffRedispatchDelivery),
                              ),
                            if (const {
                              'PENDING',
                              'ACCEPTED',
                              'FAILED',
                            }.contains(delivery.status))
                              TextButton(
                                onPressed: () => _deliveryAction(
                                  context,
                                  controller,
                                  delivery,
                                  'cancel',
                                ),
                                child: Text(labels.staffCancelDelivery),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (controller.hasMoreDeliveries.value)
                TextButton(
                  onPressed: controller.loadingMoreDeliveries.value
                      ? null
                      : controller.loadMoreDeliveries,
                  child: Text(labels.staffLoadMore),
                ),
            ],
          );
        }),
      ],
    );
  }
}

Future<void> _deliveryAction(
  BuildContext context,
  StaffOrdersController controller,
  StaffDelivery delivery,
  String action,
) async {
  final labels = AppLocalizations.of(context);
  String? reason;
  if (action == 'cancel' || action == 'release') {
    reason = await _reasonDialog(
      labels,
      action == 'cancel'
          ? labels.staffCancelDelivery
          : labels.staffReasonOptional,
      required: action == 'cancel',
    );
    if (reason == null) return;
  }
  final failure = await controller.deliveryAction(
    delivery,
    action,
    reason: reason,
  );
  if (failure != null) AppNotifier.error(_workflowFailure(labels, failure));
}

Future<String?> _reasonDialog(
  AppLocalizations labels,
  String title, {
  required bool required,
}) async {
  final text = TextEditingController();
  final result = await Get.dialog<String>(
    AlertDialog(
      title: Text(title),
      content: TextField(controller: text, maxLength: 500, autofocus: true),
      actions: [
        TextButton(onPressed: Get.back, child: Text(labels.cancel)),
        FilledButton(
          onPressed: () {
            final value = text.text.trim();
            if (required && value.isEmpty) return;
            Get.back(result: value);
          },
          child: Text(labels.confirm),
        ),
      ],
    ),
  );
  text.dispose();
  return result;
}

class StaffQuotePage extends GetView<StaffQuoteController> {
  const StaffQuotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(labels.staffCreateQuote)),
      body: Obx(() {
        controller.formVersion.value;
        final listingsState =
            controller.ordersController.activeListingsState.value;
        if (listingsState is Loading<List<StaffListing>>) {
          return const LoadingView();
        }
        if (listingsState is Failure<List<StaffListing>>) {
          return ErrorView(
            failure: listingsState.failure,
            onRetry: controller.ordersController.loadActiveListings,
          );
        }
        final activeListings = listingsState is Success<List<StaffListing>>
            ? listingsState.data
            : const [];
        return Form(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${labels.staffBuyer}: #${controller.buyerId}'),
              for (final line in controller.lines)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        DropdownButtonFormField<StaffListing>(
                          initialValue: line.listing.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: labels.staffActiveListing,
                          ),
                          items: [
                            for (final listing in activeListings)
                              DropdownMenuItem(
                                value: listing,
                                child: Text(
                                  '${listing.title} · ${Money.format(listing.unitPrice)}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (StaffListing? value) {
                            line.listing.value = value;
                            controller.refreshForm();
                          },
                        ),
                        TextFormField(
                          controller: line.quantity,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: labels.staffQuantity,
                          ),
                          onChanged: (_) => controller.refreshForm(),
                        ),
                        TextFormField(
                          controller: line.unitPrice,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: labels.staffUnitPriceOptional,
                            hintText: line.listing.value == null
                                ? null
                                : Money.format(line.listing.value!.unitPrice),
                          ),
                          onChanged: (_) => controller.refreshForm(),
                        ),
                        if (controller.lines.length > 1)
                          TextButton(
                            onPressed: () => controller.removeLine(line),
                            child: Text(labels.staffRemoveLine),
                          ),
                      ],
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: controller.addLine,
                icon: const Icon(Icons.add),
                label: Text(labels.staffAddLine),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: controller.deliveryMode.value,
                decoration: InputDecoration(
                  labelText: labels.staffDeliveryMode,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'HUB_PICKUP',
                    child: Text(labels.staffHubPickup),
                  ),
                  DropdownMenuItem(
                    value: 'AGENCY_DELIVERY',
                    child: Text(labels.staffAgencyDelivery),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.deliveryMode.value = value;
                    controller.refreshForm();
                  }
                },
              ),
              if (controller.deliveryMode.value == 'HUB_PICKUP')
                HubPicker(
                  repository: controller.referenceRepository,
                  value: controller.pickupHub,
                  label: labels.staffPickupHub,
                  acceptsPickup: true,
                )
              else ...[
                ZonePicker(
                  repository: controller.referenceRepository,
                  value: controller.zone,
                  label: labels.staffDeliveryZone,
                ),
                TextField(
                  controller: controller.address,
                  maxLength: 500,
                  decoration: InputDecoration(labelText: labels.staffAddress),
                  onChanged: (_) => controller.refreshForm(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.latitude,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          labelText: labels.staffLatitude,
                        ),
                        onChanged: (_) => controller.refreshForm(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller.longitude,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          labelText: labels.staffLongitude,
                        ),
                        onChanged: (_) => controller.refreshForm(),
                      ),
                    ),
                  ],
                ),
              ],
              TextField(
                controller: controller.notes,
                maxLength: 1000,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: labels.staffNotesOptional,
                ),
                onChanged: (_) => controller.refreshForm(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(labels.staffServerCalculatesTotals),
              ),
              Obx(
                () => FilledButton(
                  onPressed:
                      controller.isValid &&
                          !controller.ordersController.submitting.value
                      ? () => _submitQuote(context, controller)
                      : null,
                  child: controller.ordersController.submitting.value
                      ? const CircularProgressIndicator()
                      : Text(labels.staffCreateQuote),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

Future<void> _submitQuote(
  BuildContext context,
  StaffQuoteController controller,
) async {
  final labels = AppLocalizations.of(context);
  final order = await controller.submit(
    (created) => labels.staffQuoteCreatedMessage(
      created.reservedUntil == null
          ? labels.staffDeadlineNotProvided
          : Dates.shortDateTime(created.reservedUntil!),
    ),
  );
  if (order == null) {
    final failure =
        controller.ordersController.actionFailure.value ??
        controller.validationFailure.value;
    if (failure != null) AppNotifier.error(_workflowFailure(labels, failure));
    return;
  }
  final messageFailure = controller.ordersController.quoteMessageFailure.value;
  Get.back(result: order.id);
  AppNotifier.success(labels.staffQuoteCreated);
  if (messageFailure != null) {
    AppNotifier.error(_workflowFailure(labels, messageFailure));
  }
}

class StaffVerificationsPage extends StatefulWidget {
  const StaffVerificationsPage({super.key});

  @override
  State<StaffVerificationsPage> createState() => _StaffVerificationsPageState();
}

class _StaffVerificationsPageState extends State<StaffVerificationsPage> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<StaffVerificationsController>();
    final userId = Get.parameters['userId'];
    if (userId != null && userId != controller.userIdFilter.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(controller.setFilters(userId: userId));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).staffVerifications),
      ),
      body: const StaffVerificationsPanel(),
    );
  }
}

class StaffVerificationsPanel extends GetView<StaffVerificationsController> {
  const StaffVerificationsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _verificationFilter(
                value: controller.statusFilter.value,
                label: labels.staffDocumentStatus,
                values: ['', 'PENDING', 'VERIFIED', 'REJECTED'],
                onChanged: (value) => controller.setFilters(status: value),
              ),
              _verificationFilter(
                value: controller.typeFilter.value,
                label: labels.staffDocumentType,
                values: [
                  '',
                  'ID_CARD',
                  'BUSINESS_REGISTRATION',
                  'FARM_PROOF',
                  'OTHER',
                ],
                onChanged: (value) => controller.setFilters(type: value),
              ),
              _verificationFilter(
                value: controller.roleFilter.value,
                label: labels.staffAccountRole,
                values: ['', 'BUYER', 'SUPPLIER'],
                onChanged: (value) => controller.setFilters(role: value),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: labels.staffUserId),
                  onSubmitted: (value) => controller.setFilters(userId: value),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final current = controller.state.value;
            if (current is Loading<List<StaffVerification>>) {
              return const LoadingView();
            }
            if (current is Failure<List<StaffVerification>>) {
              return ErrorView(
                failure: current.failure,
                onRetry: controller.load,
              );
            }
            final documents = current is Success<List<StaffVerification>>
                ? current.data
                : const <StaffVerification>[];
            if (documents.isEmpty) {
              return EmptyView(message: labels.staffNoVerifications);
            }
            return ListView(
              children: [
                for (final document in documents)
                  ListTile(
                    title: Text(
                      '${_documentTypeLabel(labels, document.type)} · ${_documentStatusLabel(labels, document.status)}',
                    ),
                    subtitle: Text(
                      '${_accountRoleLabel(labels, '${document.user['role'] ?? ''}')} · ${_documentStatusLabel(labels, '${document.user['profileVerificationStatus'] ?? ''}')} · ${document.mimeType} · ${_fileSizeLabel(document.fileSize)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => controller.open(document.id),
                  ),
                if (controller.hasMore.value)
                  TextButton(
                    onPressed: controller.loadingMore.value
                        ? null
                        : controller.loadMore,
                    child: Text(labels.staffLoadMore),
                  ),
              ],
            );
          }),
        ),
        _VerificationReview(controller: controller),
      ],
    );
  }
}

Widget _verificationFilter({
  required String value,
  required String label,
  required List<String> values,
  required ValueChanged<String> onChanged,
}) => DropdownButton<String>(
  value: values.contains(value) ? value : '',
  hint: Text(label),
  items: [
    for (final item in values)
      DropdownMenuItem(value: item, child: Text(item.isEmpty ? label : item)),
  ],
  onChanged: (item) {
    if (item != null) onChanged(item);
  },
);

class _VerificationReview extends StatelessWidget {
  const _VerificationReview({required this.controller});
  final StaffVerificationsController controller;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Obx(() {
      final current = controller.detailState.value;
      if (current is Idle<StaffVerificationDetail>) {
        return const SizedBox.shrink();
      }
      if (current is Loading<StaffVerificationDetail>) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        );
      }
      if (current is Failure<StaffVerificationDetail>) {
        return Column(
          children: [
            Text(_verificationFailure(labels, current.failure)),
            TextButton(
              onPressed: () {
                final id = controller.selectedId;
                if (id != null) controller.open(id);
              },
              child: Text(labels.retry),
            ),
          ],
        );
      }
      final detail = (current as Success<StaffVerificationDetail>).data;
      return Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${labels.staffVerificationRuleApprove} ${labels.staffVerificationRuleReject}',
              ),
              const SizedBox(height: 8),
              if (detail.mimeType.startsWith('image/') &&
                  controller.documentBytes.isNotEmpty)
                SizedBox(
                  height: 260,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: Image.memory(
                      Uint8List.fromList(controller.documentBytes.toList()),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Text(labels.staffFileMissing),
                    ),
                  ),
                )
              else if (detail.mimeType.startsWith('image/'))
                TextButton(
                  onPressed: () => controller.open(detail.id),
                  child: Text(labels.staffFileMissing),
                )
              else if (detail.mimeType == 'application/pdf')
                OutlinedButton.icon(
                  onPressed: () async {
                    final failure = await controller.openPdf();
                    if (failure != null) {
                      AppNotifier.error(_verificationFailure(labels, failure));
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(labels.staffOpenPrivatePdf),
                )
              else
                Text(labels.staffUnsupportedDocument),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: () =>
                        _decideDocument(context, controller, 'APPROVE'),
                    child: Text(labels.staffApprove),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        _decideDocument(context, controller, 'REJECT'),
                    child: Text(labels.staffReject),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

Future<void> _decideDocument(
  BuildContext context,
  StaffVerificationsController controller,
  String decision,
) async {
  final labels = AppLocalizations.of(context);
  String? note;
  if (decision == 'REJECT') {
    final text = TextEditingController();
    note = await Get.dialog<String>(
      AlertDialog(
        title: Text(labels.staffReject),
        content: TextField(
          controller: text,
          maxLength: 2000,
          maxLines: 4,
          decoration: InputDecoration(labelText: labels.staffRejectionNote),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(labels.cancel)),
          FilledButton(
            onPressed: () {
              if (text.text.trim().isEmpty) return;
              Get.back(result: text.text.trim());
            },
            child: Text(labels.confirm),
          ),
        ],
      ),
    );
    text.dispose();
    if (note == null) return;
  }
  final failure = await controller.decide(decision: decision, note: note);
  if (failure != null) AppNotifier.error(_verificationFailure(labels, failure));
}

String _fileSizeLabel(int? size) => size == null ? '' : '$size B';

String _paymentMethodLabel(AppLocalizations labels, String method) =>
    switch (method) {
      'CASH' => labels.staffCash,
      'MOBILE_MONEY' => labels.staffMobileMoney,
      'BANK_TRANSFER' => labels.staffBankTransfer,
      _ => method,
    };

String _orderPaymentStatusLabel(AppLocalizations labels, String? status) =>
    switch (status) {
      'UNPAID' => labels.staffPaymentUnpaid,
      'PARTIALLY_PAID' => labels.staffPaymentPartiallyPaid,
      'PAID' => labels.staffPaymentPaid,
      'REFUNDED' => labels.staffPaymentRefunded,
      _ => labels.staffPaymentUnknown,
    };

String _deliveryStatusLabel(AppLocalizations labels, String status) =>
    switch (status) {
      'PENDING' => labels.staffDeliveryPending,
      'ACCEPTED' => labels.staffDeliveryAccepted,
      'PICKED_UP' => labels.staffDeliveryPickedUp,
      'IN_TRANSIT' => labels.staffDeliveryInTransit,
      'DELIVERED' => labels.staffDeliveryDelivered,
      'FAILED' => labels.staffDeliveryFailed,
      'CANCELLED' => labels.staffDeliveryCancelled,
      _ => status,
    };

String _documentStatusLabel(AppLocalizations labels, String status) =>
    switch (status) {
      'PENDING' => labels.staffDocumentPending,
      'VERIFIED' => labels.staffDocumentVerified,
      'REJECTED' => labels.staffDocumentRejected,
      _ => status,
    };

String _documentTypeLabel(AppLocalizations labels, String type) =>
    switch (type) {
      'ID_CARD' => labels.staffDocumentIdCard,
      'BUSINESS_REGISTRATION' => labels.staffDocumentBusinessRegistration,
      'FARM_PROOF' => labels.staffDocumentFarmProof,
      'OTHER' => labels.staffDocumentOther,
      _ => type,
    };

String _accountRoleLabel(AppLocalizations labels, String role) =>
    switch (role) {
      'BUYER' => labels.roleBuyer,
      'SUPPLIER' => labels.roleSupplier,
      _ => role,
    };

String _orderStatusLabel(AppLocalizations labels, OrderStatus status) =>
    switch (status) {
      OrderStatus.quoted => labels.staffStatusQuoted,
      OrderStatus.confirmed => labels.staffStatusConfirmed,
      OrderStatus.preparing => labels.staffStatusPreparing,
      OrderStatus.readyForPickup => labels.staffStatusReadyForPickup,
      OrderStatus.outForDelivery => labels.staffStatusOutForDelivery,
      OrderStatus.completed => labels.staffStatusCompleted,
      OrderStatus.cancelled => labels.staffStatusCancelled,
    };

String _workflowFailure(AppLocalizations labels, ApiFailure failure) {
  if (failure.code == 'HUMAN_ACTOR_REQUIRED') {
    return labels.staffHumanActorRequired;
  }
  if (failure.code == 'INSUFFICIENT_STOCK') {
    return labels.staffInsufficientStock;
  }
  if (failure.code == 'PRICE_BELOW_SUPPLIER') {
    return labels.staffPriceBelowSupplier;
  }
  if (failure.code == 'ZONE_NOT_COVERED') return labels.staffZoneNotCovered;
  if (failure.code == 'INVALID_HUB' || failure.code == 'HUB_NOT_FOUND') {
    return labels.staffInvalidHub;
  }
  if (failure.code == 'COMPENSATION_RATE_ZERO') {
    return labels.staffCompensationRateZero;
  }
  if (failure.code == 'FILE_MISSING') return labels.staffFileMissing;
  if (failure.code == 'PRIVATE_FILE_OPEN_FAILED') {
    return labels.staffPrivateDocumentOpenFailed;
  }
  return AppNotifier.failureMessage(failure, labels);
}

String _verificationFailure(AppLocalizations labels, ApiFailure failure) {
  if (failure.status == 403) return labels.staffPrivateFileWrongReviewer;
  if (failure.code == 'FILE_MISSING') return labels.staffFileMissing;
  if (failure.status == 409) return labels.staffVerificationAlreadyReviewed;
  return _workflowFailure(labels, failure);
}
