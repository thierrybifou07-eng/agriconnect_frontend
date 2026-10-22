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
import 'package:agri_connect/features/buyer/application/buyer_order_filters_controller.dart';
import 'package:agri_connect/features/buyer/application/buyer_orders_controller.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// Orders placed by the current buyer, grouped along the delivery progression
/// and filterable by the statuses the loaded orders really contain.
class BuyerOrdersPage extends ConsumerWidget {
  const BuyerOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(buyerOrdersControllerProvider);
    final orders = state.orders;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(buyerOrdersControllerProvider.notifier).refresh(),
        child: _buildContent(context, ref, l10n, state, orders),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    BuyerOrdersState state,
    List<BuyerOrder> orders,
  ) {
    // The total is unknown until the first load answers, and a header that
    // claims "0" while the skeleton is still up would be a figure nobody can
    // trust. The pill simply waits with the data.
    final total = orders.isEmpty && state.isLoading ? null : orders.length;
    final header = _OrdersHeader(count: total);
    final padding = const EdgeInsets.all(AppSizes.pagePadding);

    if (state.isLoading && orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          header,
          const SizedBox(height: 12),
          const CardListSkeleton(itemCount: 3),
        ],
      );
    }

    if (state.failure != null && orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          header,
          FailureView(
            failure: state.failure!,
            onRetry: () =>
                ref.read(buyerOrdersControllerProvider.notifier).refresh(),
          ),
        ],
      );
    }

    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          header,
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: l10n.buyerOrdersEmptyTitle,
            body: l10n.buyerOrdersEmptyBody,
            actionLabel: l10n.dashboardQuickExplore,
            actionIcon: Icons.storefront_outlined,
            onAction: () => context.go(RoutePaths.buyerCatalog),
          ),
        ],
      );
    }

    final filtered = ref.watch(filteredBuyerOrdersProvider);
    final summary = ref.watch(buyerOrdersSummaryProvider);
    final ongoing = filtered
        .where((order) => order.status.isOngoing)
        .toList(growable: false);
    final closed = filtered
        .where((order) => order.status.isClosed)
        .toList(growable: false);

    if (filtered.isEmpty) {
      // The orders are there, the filter is what hides them: say so instead of
      // showing an empty list the buyer cannot tell apart from a real one.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          header,
          const SizedBox(height: 12),
          _StatusFilters(summary: summary),
          const SizedBox(height: 12),
          EmptyState(
            icon: Icons.filter_alt_off_outlined,
            title: l10n.ordersNoResultTitle,
            body: l10n.buyerOrdersFilterBody,
            actionLabel: l10n.ordersClearFilters,
            actionIcon: Icons.restart_alt_rounded,
            onAction: () =>
                ref.read(buyerOrderFiltersProvider.notifier).clearStatus(),
          ),
        ],
      );
    }

    final sections = <(String, List<BuyerOrder>)>[
      (l10n.buyerOrdersOngoingTitle, ongoing),
      (l10n.buyerOrdersClosedTitle, closed),
    ].where((section) => section.$2.isNotEmpty).toList(growable: false);

    // The header, the filter row and the section titles all scroll away with
    // the list, so a long history never pins them at the top of the screen.
    final rows = <Widget>[];
    for (var index = 0; index < sections.length; index++) {
      final section = sections[index];
      if (index > 0) rows.add(const SizedBox(height: 20));
      rows.add(_SectionLabel(title: section.$1, count: section.$2.length));
      rows.add(const SizedBox(height: 10));
      for (final order in section.$2) {
        rows
          ..add(BuyerOrderCard(order: order))
          ..add(const SizedBox(height: 10));
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      children: [
        header,
        const SizedBox(height: 12),
        _StatusFilters(summary: summary),
        const SizedBox(height: 16),
        ...rows,
      ],
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.count});

  /// Total orders, or `null` while the first load is still in flight.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final total = count;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.sectionOrders,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        // The figure is announced with its unit, as on the dashboard: a bare
        // "3" tells a screen reader nothing about what it counts.
        if (total != null)
          Semantics(
            label: l10n.ordersResultsCount(total),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$total',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Status chips of the list, driven by the statuses the orders really have.
///
/// Each chip carries the number of orders behind it, so a buyer sees what a
/// filter is worth before spending a tap on it.
class _StatusFilters extends ConsumerWidget {
  const _StatusFilters({required this.summary});

  final BuyerOrdersSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(buyerOrderFiltersProvider).status;
    final statuses = summary.availableStatuses;

    // A single status, or none at all: a row of chips would only repeat what
    // each card already shows.
    if (statuses.length < 2) return const SizedBox.shrink();

    final controller = ref.read(buyerOrderFiltersProvider.notifier);

    // Unbounded width on purpose: a row of statuses would overflow on a narrow
    // screen, and squeezing the labels is worse than scrolling them.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          BuyerOrderFilterChip(
            label: l10n.filterAll,
            count: summary.total,
            selected: selected == null,
            onSelected: controller.clearStatus,
          ),
          for (final status in statuses)
            BuyerOrderFilterChip(
              label: status.label(l10n),
              count: summary.countOf(status),
              selected: selected == status,
              onSelected: () => controller.toggleStatus(status),
            ),
        ],
      ),
    );
  }
}

/// Status chip of the orders list, labelled with the number of orders behind it.
class BuyerOrderFilterChip extends StatelessWidget {
  const BuyerOrderFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label · $count'),
        selected: selected,
        onSelected: (_) => onSelected(),
        // The checkmark is replaced by the brand fill, as on the catalog
        // filters: the active chip is obvious without spending width on it.
        showCheckmark: false,
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: l10n.ordersResultsCount(count),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// One order as a buyer reads it: what was ordered, where it goes, how much it
/// costs and where it stands.
class BuyerOrderCard extends StatelessWidget {
  const BuyerOrderCard({super.key, required this.order});

  final BuyerOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final first = order.items.isEmpty ? null : order.items.first;
    final extraItems = order.items.length - 1;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RoutePaths.buyerOrder(order.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (first != null) ...[
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.tileRadius,
                        ),
                        child: ProductImage(
                          imageUrl: DemoAssets.photoForProduct(first.productId),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The reference comes first: it is what a buyer quotes
                        // to a seller or to support.
                        Text(
                          l10n.orderNumber(order.id),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          first?.productName ?? order.productSummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (extraItems > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            l10n.ordersMoreItems(extraItems),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${AppFormats.date(order.createdAt, locale: context.localeCode)}'
                      ' · ${l10n.orderNumberItems(order.items.length)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.deliveryAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (order.hasDriver)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_shipping_rounded,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    order.driver!.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // The amount is the figure a buyer scans the list for: it
                  // keeps its own space and gives up characters before its box.
                  Flexible(
                    child: Text(
                      Money.format(
                        order.totalAmount,
                        locale: context.localeCode,
                      ),
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
      ),
    );
  }
}
