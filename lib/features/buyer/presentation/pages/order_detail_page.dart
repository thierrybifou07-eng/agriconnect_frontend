import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/media/demo_assets.dart';
import 'package:agri_connect/core/media/product_image.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/buyer/application/buyer_orders_controller.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/tracking_timeline.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/fact_row.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Order detail with delivery tracking and driver contact.
class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(buyerOrdersControllerProvider);
    final order = _findOrder(state.orders);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.orderDetailTitle)),
        body: _buildMissingOrder(context, ref, l10n, state),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderDetailTitle)),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(buyerOrdersControllerProvider.notifier).refresh(),
        child: ListView(
          // A delivered or cancelled order is short: without this the list
          // would never be scrollable and the pull-to-refresh would stay dead.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          children: [
            _SummaryCard(order: order),
            const SizedBox(height: 20),
            if (order.status == BuyerOrderStatus.cancelled)
              const _CancelledBanner()
            else ...[
              Text(
                l10n.trackingTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TrackingTimeline(status: order.status),
                ),
              ),
            ],
            if (order.hasDriver) ...[
              const SizedBox(height: 20),
              Text(
                l10n.driverTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _DriverCard(order: order),
            ] else if (order.status.isOngoing) ...[
              const SizedBox(height: 12),
              const _DriverHint(),
            ],
            const SizedBox(height: 20),
            Text(
              l10n.checkoutItemsTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _ItemsCard(order: order),
            const SizedBox(height: 20),
            Text(
              l10n.deliveryInfoLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _DeliveryCard(order: order),
          ],
        ),
      ),
    );
  }

  /// The order is missing from the loaded list, which is not always a lost
  /// order: a failed load must offer its retry instead of claiming the order
  /// does not exist.
  Widget _buildMissingOrder(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    BuyerOrdersState state,
  ) {
    if (state.failure != null && state.orders.isEmpty) {
      return FailureView(
        failure: state.failure!,
        onRetry: () =>
            ref.read(buyerOrdersControllerProvider.notifier).refresh(),
      );
    }
    if (state.isLoading && state.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: l10n.buyerOrdersEmptyTitle,
      body: l10n.orderNotFound,
      actionLabel: l10n.ordersBackToList,
      actionIcon: Icons.receipt_long_outlined,
      onAction: () => context.go(RoutePaths.buyerOrders),
    );
  }

  BuyerOrder? _findOrder(List<BuyerOrder> orders) {
    for (final order in orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }
}

/// Ordered products with the figures a buyer checks before the parcel arrives.
class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final BuyerOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.tileRadius,
                        ),
                        child: ProductImage(
                          imageUrl: DemoAssets.photoForProduct(item.productId),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.ordersItemDetail(
                              item.quantity,
                              Money.format(
                                item.unitPrice,
                                locale: context.localeCode,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Line sub-total: the unit price alone never tells what the
                    // quantity costs.
                    Flexible(
                      child: Text(
                        Money.format(item.total, locale: context.localeCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.totalLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    Money.format(order.totalAmount, locale: context.localeCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Delivery facts the order actually carries.
///
/// No distance and no fee are shown: the buyer order has never held them, and
/// a delivery fee invented on the fly would be a number nobody can check.
class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.order});

  final BuyerOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            FactRow(
              icon: Icons.local_shipping_outlined,
              label: l10n.orderDeliveryStatusLabel,
              value: order.status.label(l10n),
              valueColor: order.status.color(context),
            ),
            const SizedBox(height: 12),
            FactRow(
              icon: Icons.place_outlined,
              label: l10n.deliveryAddressLabel,
              value: order.deliveryAddress,
            ),
            const SizedBox(height: 12),
            FactRow(
              icon: Icons.phone_outlined,
              label: l10n.phoneLabel,
              value: order.buyerPhone,
            ),
            if (order.deliveryNote != null && order.deliveryNote!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FactRow(
                  icon: Icons.notes_rounded,
                  label: l10n.noteLabel,
                  value: order.deliveryNote!,
                ),
              ),
            if (order.hasDriver)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FactRow(
                  icon: Icons.person_outline_rounded,
                  label: l10n.driverTitle,
                  value: order.driver!.fullName,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.order});

  final BuyerOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
            AppColors.primaryDeep,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.orderNumber(order.id),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusBadge(
                label: order.status.label(l10n),
                color: _badgeColor(order.status),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.placedOn} '
            '${AppFormats.date(order.createdAt, locale: context.localeCode)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            Money.format(order.totalAmount, locale: context.localeCode),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge tints chosen for the dark summary header.
  ///
  /// The status colors are built for light surfaces and would sink into the
  /// green gradient, so the header uses its own softer set.
  Color _badgeColor(BuyerOrderStatus status) => switch (status) {
    BuyerOrderStatus.pending => AppColors.accentSoft,
    BuyerOrderStatus.confirmed => AppColors.successSoft,
    BuyerOrderStatus.inTransit => AppColors.accentSoft,
    BuyerOrderStatus.delivered => AppColors.successSoft,
    BuyerOrderStatus.cancelled => AppColors.dangerSoft,
  };
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.order});

  final BuyerOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final driver = order.driver!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                UserAvatar(name: driver.fullName, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              driver.vehicleLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
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
              onPressed: () => _contactDriver(context),
              icon: const Icon(Icons.phone_outlined),
              label: Text(l10n.contactDriver),
            ),
          ),
        ],
      ),
    );
  }

  void _contactDriver(BuildContext context) {
    final l10n = context.l10n;
    final driver = order.driver!;
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
            UserAvatar(name: driver.fullName, size: 56),
            const SizedBox(height: 12),
            Text(
              driver.fullName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              driver.vehicleLabel,
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
                      driver.phone,
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
                  await Clipboard.setData(ClipboardData(text: driver.phone));
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

class _DriverHint extends StatelessWidget {
  const _DriverHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.driverAssignedLater,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.orderCancelled,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
