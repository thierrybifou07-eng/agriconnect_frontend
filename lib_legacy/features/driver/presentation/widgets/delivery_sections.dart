import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/media/demo_assets.dart';
import 'package:agri_connect/core/media/product_image.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/driver/application/driver_deliveries_controller.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';
import 'package:agri_connect/shared/widgets/fact_row.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Pickup, drop-off and the note left with the delivery.
class DeliveryRouteCard extends StatelessWidget {
  const DeliveryRouteCard({super.key, required this.delivery});

  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FactRow(
              icon: Icons.storefront_outlined,
              label: l10n.driverPickupLabel,
              value: delivery.pickupLocation,
            ),
            _RouteConnector(color: colorScheme.primary),
            FactRow(
              icon: Icons.place_outlined,
              label: l10n.deliveryAddressLabel,
              value: delivery.deliveryAddress,
            ),
            const Divider(height: 28),
            FactRow(
              icon: Icons.schedule_rounded,
              label: l10n.driverScheduledLabel,
              value: AppFormats.date(
                delivery.scheduledAt,
                locale: context.localeCode,
              ),
            ),
            if (delivery.note != null && delivery.note!.isNotEmpty) ...[
              const Divider(height: 28),
              FactRow(
                icon: Icons.notes_rounded,
                label: l10n.noteLabel,
                value: delivery.note!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Link drawn between the two ends of the route.
class _RouteConnector extends StatelessWidget {
  const _RouteConnector({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 9, top: 10, bottom: 10),
      child: Row(
        children: [
          Container(width: 2, height: 22, color: color.withValues(alpha: 0.35)),
          const SizedBox(width: 8),
          Icon(Icons.arrow_downward_rounded, size: 14, color: color),
        ],
      ),
    );
  }
}

/// Products carried by the delivery, with the volume they represent.
class DeliveryItemsCard extends StatelessWidget {
  const DeliveryItemsCard({super.key, required this.delivery});

  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ordersArticlesCount(
                delivery.items.length,
                delivery.itemCount,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            for (final item in delivery.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _DeliveryItemRow(item: item),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryItemRow extends StatelessWidget {
  const _DeliveryItemRow({required this.item});

  final DriverDeliveryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unit = item.unit;

    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.tileRadius),
            child: ProductImage(
              imageUrl: DemoAssets.photoForProduct(item.productId),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.productName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // The quantity is stated once, with its unit: the volume of the whole
        // delivery is the summary above, not a second figure on every line.
        Flexible(
          child: Text(
            unit == null || unit.isEmpty
                ? '${item.quantity}'
                : '${item.quantity} $unit',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/// Trip carrying the delivery: the route, the vehicle and how far it stands.
class DeliveryTripCard extends StatelessWidget {
  const DeliveryTripCard({
    super.key,
    required this.trip,
    required this.deliveries,
  });

  final DeliveryTrip trip;
  final List<DriverDelivery> deliveries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final status = trip.statusFrom(deliveries);
    var delivered = 0;
    for (final delivery in deliveries) {
      if (trip.deliveryIds.contains(delivery.id) && delivery.isDelivered) {
        delivered++;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.route_rounded,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.routeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trip.vehicleLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    l10n.tripStopsProgress(delivered, trip.deliveryIds.length),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: status.label(l10n),
              color: status.color(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Customer the parcel goes to, with the phone the driver can reach.
class DeliveryCustomerCard extends StatelessWidget {
  const DeliveryCustomerCard({super.key, required this.delivery});

  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                UserAvatar(name: delivery.customerName, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.customerName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        delivery.customerPhone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _contactCustomer(context),
              icon: const Icon(Icons.phone_outlined),
              label: Text(l10n.driverContactCustomer),
            ),
          ),
        ],
      ),
    );
  }

  /// The phone is the contact the delivery really carries: the app has no way
  /// to call, so the number is shown and left to be copied. No chat is offered
  /// here — no conversation is tied to a delivery by the chat contract.
  void _contactCustomer(BuildContext context) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      // Scrollable because a bottom sheet is capped by the screen: with a large
      // system font on a short phone the copy button used to sit below the cap,
      // unreachable behind the sheet's own edge.
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(name: delivery.customerName, size: 56),
            const SizedBox(height: 12),
            Text(
              delivery.customerName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              delivery.deliveryAddress,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      delivery.customerPhone,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: delivery.customerPhone),
                  );
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.phoneCopied)),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: Text(l10n.copyNumber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Explains that a status action failed, and offers the two real ways out.
///
/// Nothing is retried on its own: a driver has to either verify the status the
/// server really holds, or send the same transition again.
class ActionFailureBanner extends ConsumerWidget {
  const ActionFailureBanner({super.key, required this.delivery});

  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final state = ref.watch(driverDeliveriesControllerProvider);

    return Material(
      color: colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.driverActionError,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.driverActionHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isRefreshing
                        ? null
                        : () => ref
                              .read(driverDeliveriesControllerProvider.notifier)
                              .refresh(),
                    icon: const Icon(Icons.verified_user_outlined, size: 18),
                    label: Text(l10n.verifyStatus),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: state.isUpdating(delivery.id)
                        ? null
                        : () => _retry(context, ref),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.retry),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _retry(BuildContext context, WidgetRef ref) async {
    final next = delivery.nextStatus;
    if (next == null) return;
    final wasStart = delivery.status == DriverDeliveryStatus.pickUp;
    final l10n = context.l10n;

    final ok = await ref
        .read(driverDeliveriesControllerProvider.notifier)
        .updateStatus(delivery.id, next);
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasStart
                ? l10n.driverDeliveryStarted
                : l10n.driverDeliveryDelivered,
          ),
        ),
      );
    }
  }
}
