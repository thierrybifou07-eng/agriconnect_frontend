import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/presentation/controllers/delivery_progress_controller.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';

class DriverDeliveryDetailPage extends GetView<DeliveryProgressController> {
  const DriverDeliveryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.driverDetailTitle)),
      body: Obx(() {
        final state = controller.state.value;
        if (state is Loading<DriverDelivery>) {
          return const Center(child: CircularProgressIndicator());
        }
        final delivery = controller.current;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusProgress(status: delivery.status),
            const SizedBox(height: 20),
            _AddressCard(
              title: l10n.driverPickupAddress,
              address: delivery.pickupAddress,
              latitude: delivery.pickupLatitude,
              longitude: delivery.pickupLongitude,
              mapLabel: l10n.driverOpenMap,
            ),
            const SizedBox(height: 12),
            _AddressCard(
              title: l10n.driverDropoffAddress,
              address: delivery.dropoffAddress,
              latitude: delivery.dropoffLatitude,
              longitude: delivery.dropoffLongitude,
              mapLabel: l10n.driverOpenMap,
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.route_outlined),
                title: Text(
                  '${l10n.driverDistance}: ${delivery.distanceKm} km',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.driverItems,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final item in delivery.items)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(item.productName),
                  subtitle: Text(item.categoryName),
                  trailing: Text('${item.quantity}'),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              l10n.driverCustomerLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (delivery.buyer case final buyer?)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(buyer.fullName),
                  subtitle: Text(buyer.phone),
                  trailing: IconButton(
                    tooltip: l10n.driverCallBuyer,
                    onPressed: () => _callBuyer(context, buyer),
                    icon: const Icon(Icons.call_outlined),
                  ),
                ),
              )
            else
              Text(l10n.driverBuyerUnavailable),
            const SizedBox(height: 20),
            if (delivery.failureReason?.isNotEmpty == true)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(l10n.driverFailureReason),
                  subtitle: Text(delivery.failureReason!),
                ),
              ),
            if (controller.lastFailure.value case final failure?)
              _ActionFailure(failure: failure),
            if (delivery.status.driverNextStatus != null ||
                delivery.status.canFail) ...[
              const SizedBox(height: 20),
              if (delivery.status.driverNextStatus != null)
                Obx(
                  () => FilledButton.icon(
                    onPressed: controller.submitting.value
                        ? null
                        : () => _advance(context),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      controller.submitting.value
                          ? l10n.driverUpdating
                          : _nextActionLabel(
                              delivery.status.driverNextStatus!,
                              l10n,
                            ),
                    ),
                  ),
                ),
              if (delivery.status.canFail)
                TextButton.icon(
                  onPressed: controller.submitting.value
                      ? null
                      : () => _showFailureDialog(context),
                  icon: const Icon(Icons.report_gmailerrorred_outlined),
                  label: Text(l10n.driverFailureAction),
                ),
            ],
          ],
        );
      }),
    );
  }

  Future<void> _advance(BuildContext context) async {
    final failure = await controller.advance();
    if (context.mounted && failure != null) {
      _showActionFailure(context, failure);
    }
  }

  Future<void> _showFailureDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final reason = await Get.dialog<String>(
      AlertDialog(
        title: Text(l10n.driverFailureAction),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            autofocus: true,
            maxLength: 500,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.driverFailureReason,
              hintText: l10n.driverFailureReasonHint,
            ),
            validator: (value) => value?.trim().isNotEmpty == true
                ? null
                : l10n.driverFailureReasonRequired,
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Get.back(result: reasonController.text.trim());
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (reason == null || !context.mounted) {
      return;
    }
    final failure = await controller.fail(reason);
    if (context.mounted && failure != null) {
      _showActionFailure(context, failure);
    }
  }

  void _showActionFailure(BuildContext context, ApiFailure failure) {
    final l10n = AppLocalizations.of(context);
    AppNotifier.error(AppNotifier.failureMessage(failure, l10n));
  }

  Future<void> _callBuyer(BuildContext context, DriverBuyer buyer) async {
    final uri = Uri(scheme: 'tel', path: buyer.phone);
    if (!await launchUrl(uri) && context.mounted) {
      AppNotifier.error(AppLocalizations.of(context).driverLaunchError);
    }
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.mapLabel,
  });

  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final String mapLabel;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.place_outlined),
          title: Text(title),
          subtitle: Text(address),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () async {
              final uri = Uri.https('www.google.com', '/maps/dir/', {
                'api': '1',
                'destination': '$latitude,$longitude',
              });
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
                  context.mounted) {
                AppNotifier.error(
                  AppLocalizations.of(context).driverLaunchError,
                );
              }
            },
            icon: const Icon(Icons.map_outlined),
            label: Text(mapLabel),
          ),
        ),
      ],
    ),
  );
}

class _StatusProgress extends StatelessWidget {
  const _StatusProgress({required this.status});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const statuses = [
      DeliveryStatus.accepted,
      DeliveryStatus.pickedUp,
      DeliveryStatus.inTransit,
      DeliveryStatus.delivered,
    ];
    final reached = statuses.indexOf(status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _statusLabel(status, l10n),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < statuses.length; index++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  index <= reached ? Icons.check_circle : Icons.circle_outlined,
                  color: index <= reached
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                title: Text(_statusLabel(statuses[index], l10n)),
              ),
            if (status == DeliveryStatus.failed ||
                status == DeliveryStatus.cancelled)
              Text(_statusLabel(status, l10n)),
          ],
        ),
      ),
    );
  }
}

class _ActionFailure extends StatelessWidget {
  const _ActionFailure({required this.failure});

  final ApiFailure failure;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Text(
      AppNotifier.failureMessage(failure, AppLocalizations.of(context)),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}

String _nextActionLabel(DeliveryStatus next, AppLocalizations l10n) =>
    switch (next) {
      DeliveryStatus.pickedUp => l10n.driverMarkPickedUp,
      DeliveryStatus.inTransit => l10n.driverStartTransit,
      DeliveryStatus.delivered => l10n.driverMarkDelivered,
      _ => l10n.driverUpdating,
    };

String _statusLabel(DeliveryStatus status, AppLocalizations l10n) =>
    switch (status) {
      DeliveryStatus.pending => l10n.deliveryStatusPending,
      DeliveryStatus.accepted => l10n.deliveryStatusAccepted,
      DeliveryStatus.pickedUp => l10n.deliveryStatusPickedUp,
      DeliveryStatus.inTransit => l10n.deliveryStatusInTransit,
      DeliveryStatus.delivered => l10n.deliveryStatusDelivered,
      DeliveryStatus.failed => l10n.deliveryStatusFailed,
      DeliveryStatus.cancelled => l10n.deliveryStatusCancelled,
    };
