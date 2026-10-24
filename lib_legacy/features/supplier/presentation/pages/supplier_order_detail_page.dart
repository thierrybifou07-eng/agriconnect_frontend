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
import 'package:agri_connect/features/supplier/application/supplier_orders_controller.dart';
import 'package:agri_connect/features/supplier/domain/supplier_order.dart';
import 'package:agri_connect/features/supplier/presentation/widgets/confirm_failure_banner.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/info_row.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Full order sheet ("fiche commande") of an order received by a supplier:
/// reference, buyer, items with their amounts and the confirmation action.
///
/// The only action offered is the one the repository can actually perform:
/// confirming a pending order.
class SupplierOrderDetailPage extends ConsumerWidget {
  const SupplierOrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(supplierOrdersControllerProvider);
    final appBar = AppBar(
      title: Text(l10n.orderDetailTitle),
      // Reached by pushing over the orders tab, so the gesture back pops it.
      // A deep link opens it with nothing to pop, hence the fallback: the
      // supplier is never stuck on the sheet with no way back to the list.
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.canPop()
            ? context.pop()
            : context.go(RoutePaths.supplierOrders),
      ),
    );
    SupplierOrder? order;
    for (final candidate in state.orders) {
      if (candidate.id == orderId) {
        order = candidate;
        break;
      }
    }

    if (order == null) {
      return _buildUnresolved(context, l10n, ref, state, appBar);
    }
    final currentOrder = order;
    final isConfirming = state.isConfirming(currentOrder.id);
    final failure = state.confirmFailure;
    final failedThisOrder = state.failedConfirmId == currentOrder.id;

    return Scaffold(
      appBar: appBar,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          _StatusHeader(order: currentOrder),
          const SizedBox(height: 20),
          if (failure != null && failedThisOrder) ...[
            ConfirmFailureBanner(
              onVerify: state.isRefreshing
                  ? null
                  : () => ref
                        .read(supplierOrdersControllerProvider.notifier)
                        .refresh(),
              onRetry: isConfirming
                  ? null
                  : () => ref
                        .read(supplierOrdersControllerProvider.notifier)
                        .confirm(currentOrder.id),
            ),
            const SizedBox(height: 20),
          ],
          SectionHeader(title: l10n.ordersSummaryTitle),
          const SizedBox(height: 10),
          _SummaryCard(order: currentOrder),
          const SizedBox(height: 20),
          SectionHeader(
            title: l10n.orderItemsLabel,
            actionLabel: l10n.orderNumberItems(currentOrder.items.length),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  for (final item in currentOrder.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _OrderItemRow(item: item),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: l10n.ordersBuyerTitle),
          const SizedBox(height: 10),
          _BuyerCard(order: currentOrder),
          const SizedBox(height: 20),
          _TotalCard(order: currentOrder),
          if (currentOrder.isPending) ...[
            const SizedBox(height: 20),
            Text(
              l10n.ordersConfirmHelp,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: isConfirming
                  ? l10n.confirmingOrder
                  : l10n.confirmOrderAction,
              loading: isConfirming,
              onPressed: isConfirming
                  ? null
                  : () => _confirm(context, ref, currentOrder.id),
              icon: isConfirming ? null : Icons.check_circle_outline_rounded,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await ref
        .read(supplierOrdersControllerProvider.notifier)
        .confirm(id);
    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.orderConfirmed)));
    }
  }

  /// Loading, failure and not-found states while the order list is unresolved.
  ///
  /// The sheet is reachable by deep link, so an order can legitimately be
  /// missing from the state: it is still loading, it failed to load, or it
  /// does not exist. Only the last one deserves the "not found" message, the
  /// other two must not announce a lost order that is on its way.
  Widget _buildUnresolved(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    SupplierOrdersState state,
    AppBar appBar,
  ) {
    final failure = state.failure;
    if (failure != null) {
      return Scaffold(
        appBar: appBar,
        body: FailureView(
          failure: failure,
          onRetry: () =>
              ref.read(supplierOrdersControllerProvider.notifier).refresh(),
        ),
      );
    }

    if (state.isLoading) {
      return Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            children: const [CardListSkeleton(itemCount: 3)],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: _MissingOrder(
        onRetry: () =>
            ref.read(supplierOrdersControllerProvider.notifier).refresh(),
      ),
    );
  }
}

/// Recovery state of a missing order: reload the data, or leave the sheet.
class _MissingOrder extends StatelessWidget {
  const _MissingOrder({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: l10n.ordersNotFoundTitle,
      body: l10n.ordersNotFoundBody,
      actionLabel: l10n.ordersBackToList,
      actionIcon: Icons.arrow_back_rounded,
      onAction: () => context.canPop()
          ? context.pop()
          : context.go(RoutePaths.supplierOrders),
      secondaryActionLabel: l10n.retry,
      onSecondaryAction: onRetry,
    );
  }
}

/// Reference, buyer and current status of the order.
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order});

  final SupplierOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          UserAvatar(name: order.buyerName, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderNumber(order.id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.buyerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(
            label: order.status.label(l10n),
            color: order.status.color(context),
          ),
        ],
      ),
    );
  }
}

/// Order facts available in the domain: date, article count and amount.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.order});

  final SupplierOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totalArticles = order.items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InfoRow(
              icon: Icons.tag_rounded,
              label: l10n.ordersReferenceLabel,
              value: order.id,
            ),
            const Divider(height: 20),
            InfoRow(
              icon: Icons.schedule_rounded,
              label: l10n.orderDateLabel,
              value: AppFormats.date(
                order.createdAt,
                locale: context.localeCode,
              ),
            ),
            const Divider(height: 20),
            InfoRow(
              icon: Icons.inventory_2_outlined,
              label: l10n.ordersArticlesLabel,
              value: l10n.ordersArticlesCount(
                order.items.length,
                totalArticles,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Buyer contact details, showing the phone only when the domain has one.
///
/// The buyer name is already carried by the header, so the card only exposes
/// the contact details.
class _BuyerCard extends StatelessWidget {
  const _BuyerCard({required this.order});

  final SupplierOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phone = order.buyerPhone;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InfoRow(
              icon: Icons.mail_outline_rounded,
              label: l10n.buyerEmailLabel,
              value: order.buyerEmail,
            ),
            if (phone != null && phone.isNotEmpty) ...[
              const Divider(height: 20),
              InfoRow(
                icon: Icons.phone_outlined,
                label: l10n.ordersPhoneLabel,
                value: phone,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Total amount of the order, highlighted as the figure that matters.
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.order});

  final SupplierOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.payments_outlined,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.totalLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Money.format(order.totalAmount, locale: context.localeCode),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: ProductImage(
            imageUrl: DemoAssets.photoForProduct(item.productId),
            fit: BoxFit.cover,
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
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.ordersItemDetail(
                  item.quantity,
                  Money.format(item.unitPrice, locale: context.localeCode),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          Money.format(item.total, locale: context.localeCode),
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
