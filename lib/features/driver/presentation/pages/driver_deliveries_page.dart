import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/media/demo_assets.dart';
import 'package:agri_connect/core/media/product_image.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/driver/application/driver_deliveries_controller.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/presentation/widgets/driver_content.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Deliveries assigned to the driver, with pickup and drop-off management.
class DriverDeliveriesPage extends ConsumerWidget {
  const DriverDeliveriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(driverDeliveriesControllerProvider);
    final deliveries = state.deliveries;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(driverDeliveriesControllerProvider.notifier).refresh(),
        child: _buildContent(context, ref, l10n, state, deliveries),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DriverDeliveriesState state,
    List<DriverDelivery> deliveries,
  ) {
    final header = DriverContent(
      child: _DeliveriesHeader(count: deliveries.length),
    );

    if (state.isLoading && deliveries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          header,
          const SizedBox(height: 12),
          const DriverContent(child: CardListSkeleton(itemCount: 3)),
        ],
      );
    }

    if (state.failure != null && deliveries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          header,
          DriverContent(
            child: FailureView(
              failure: state.failure!,
              onRetry: () => ref
                  .read(driverDeliveriesControllerProvider.notifier)
                  .refresh(),
            ),
          ),
        ],
      );
    }

    if (deliveries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          header,
          DriverContent(
            child: EmptyState(
              icon: Icons.local_shipping_outlined,
              title: l10n.driverDeliveriesEmptyTitle,
              body: l10n.driverDeliveriesEmptyBody,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      itemCount: deliveries.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return DriverContent(child: _DeliveriesTop(state: state));
        }
        return DriverContent(
          child: _DeliveryCard(delivery: deliveries[index - 1]),
        );
      },
    );
  }
}

/// Wraps the action failure banner.
class _DeliveriesTop extends ConsumerWidget {
  const _DeliveriesTop({required this.state});

  final DriverDeliveriesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actionFailure = state.actionFailure;
    final failedId = state.failedDeliveryId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (actionFailure != null) ...[
          const SizedBox(height: 12),
          Material(
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
                                    .read(
                                      driverDeliveriesControllerProvider
                                          .notifier,
                                    )
                                    .refresh(),
                          icon: const Icon(
                            Icons.verified_user_outlined,
                            size: 18,
                          ),
                          label: Text(l10n.verifyStatus),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: failedId == null
                              ? null
                              : () => _retry(context, ref, failedId),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(l10n.retry),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _retry(
    BuildContext context,
    WidgetRef ref,
    String deliveryId,
  ) async {
    final notifier = ref.read(driverDeliveriesControllerProvider.notifier);
    final state = ref.read(driverDeliveriesControllerProvider);
    for (final delivery in state.deliveries) {
      if (delivery.id != deliveryId) continue;
      // The progression is the single source of the allowed transition: a
      // delivery with none left cannot be retried into anything.
      final next = delivery.nextStatus;
      if (next == null) return;
      final ok = await notifier.updateStatus(deliveryId, next);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_successMessage(context, delivery))),
        );
      }
      return;
    }
  }

  String _successMessage(BuildContext context, DriverDelivery delivery) {
    final l10n = context.l10n;
    return delivery.isPickUp
        ? l10n.driverDeliveryStarted
        : l10n.driverDeliveryDelivered;
  }
}

class _DeliveriesHeader extends StatelessWidget {
  const _DeliveriesHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.sectionDeliveries,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeliveryCard extends ConsumerWidget {
  const _DeliveryCard({required this.delivery});

  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isUpdating = ref
        .watch(driverDeliveriesControllerProvider)
        .isUpdating(delivery.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isUpdating
            ? null
            : () => context.push(RoutePaths.driverDelivery(delivery.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(name: delivery.customerName, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          l10n.orderNumber(delivery.orderId),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: delivery.status.label(l10n),
                    color: delivery.status.color(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _RouteLine(
                pickup: delivery.pickupLocation,
                dropOff: delivery.deliveryAddress,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ItemsPreview(items: delivery.items),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      AppFormats.date(
                        delivery.scheduledAt,
                        locale: context.localeCode,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${delivery.itemCount}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (delivery.isPickUp || delivery.isInTransit) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: isUpdating
                        ? null
                        : () => _update(context, ref, delivery),
                    icon: isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Icon(
                            delivery.isPickUp
                                ? Icons.navigation_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 20,
                          ),
                    label: Text(
                      isUpdating
                          ? (delivery.isPickUp
                                ? l10n.driverStartingDelivery
                                : l10n.driverMarkingDelivered)
                          : (delivery.isPickUp
                                ? l10n.driverStartDelivery
                                : l10n.driverMarkDelivered),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    DriverDelivery delivery,
  ) async {
    final next = delivery.nextStatus;
    if (next == null) return;
    final ok = await ref
        .read(driverDeliveriesControllerProvider.notifier)
        .updateStatus(delivery.id, next);
    if (ok && context.mounted) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            delivery.isPickUp
                ? l10n.driverDeliveryStarted
                : l10n.driverDeliveryDelivered,
          ),
        ),
      );
    }
  }
}

/// Compact pickup → drop-off summary.
class _RouteLine extends StatelessWidget {
  const _RouteLine({required this.pickup, required this.dropOff});

  final String pickup;
  final String dropOff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Marker(color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pickup,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dropOff,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
        ],
      ),
    );
  }
}

/// Horizontal strip of the carried product thumbnails.
class _ItemsPreview extends StatelessWidget {
  const _ItemsPreview({required this.items});

  /// Thumbnails shown on the row. The number of items is stated next to them,
  /// so a long list is summarised instead of pushing the card off its width.
  static const int maxThumbnails = 3;

  final List<DriverDeliveryItem> items;

  @override
  Widget build(BuildContext context) {
    final shown = items.take(maxThumbnails).toList(growable: false);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: 30,
            height: 30,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ProductImage(
              imageUrl: DemoAssets.photoForProduct(shown[i].productId),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}
