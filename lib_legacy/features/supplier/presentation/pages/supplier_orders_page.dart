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
import 'package:agri_connect/features/supplier/application/order_filters_controller.dart';
import 'package:agri_connect/features/supplier/domain/supplier_order.dart';
import 'package:agri_connect/features/supplier/presentation/widgets/confirm_failure_banner.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Orders received by the supplier, with manual order confirmation.
class SupplierOrdersPage extends ConsumerStatefulWidget {
  const SupplierOrdersPage({super.key});

  @override
  ConsumerState<SupplierOrdersPage> createState() => _SupplierOrdersPageState();
}

class _SupplierOrdersPageState extends ConsumerState<SupplierOrdersPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(supplierOrdersControllerProvider);
    final orders = ref.watch(filteredSupplierOrdersProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(supplierOrdersControllerProvider.notifier).refresh(),
        child: _buildContent(context, ref, l10n, state, orders),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    SupplierOrdersState state,
    List<SupplierOrder> orders,
  ) {
    if (state.isLoading && state.orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: const [CardListSkeleton(itemCount: 4)],
      );
    }

    if (state.failure != null && state.orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          FailureView(
            failure: state.failure!,
            onRetry: () =>
                ref.read(supplierOrdersControllerProvider.notifier).refresh(),
          ),
        ],
      );
    }

    if (state.orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: l10n.ordersEmptyTitle,
            body: l10n.ordersEmptyBody,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      itemCount: orders.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) return _OrdersTop(searchController: _searchController);
        return _OrderCard(order: orders[index - 1]);
      },
    );
  }
}

/// Overview, search, status filters, confirmation banner and result count.
class _OrdersTop extends ConsumerWidget {
  const _OrdersTop({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(supplierOrdersControllerProvider);
    final summary = ref.watch(supplierOrdersSummaryProvider);
    final filters = ref.watch(orderFiltersProvider);
    final visible = ref.watch(filteredSupplierOrdersProvider);
    final controller = ref.read(supplierOrdersControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OrdersHeader(summary: summary),
        const SizedBox(height: 14),
        StatGrid(
          values: [
            '${summary.pending}',
            '${summary.confirmed}',
            '${summary.cancelled}',
          ],
          labels: [
            l10n.ordersStatPending,
            l10n.ordersStatConfirmed,
            l10n.ordersStatCancelled,
          ],
          icons: const [
            Icons.hourglass_top_rounded,
            Icons.check_circle_rounded,
            Icons.cancel_outlined,
          ],
          accents: const [true, false, false],
          onTap: [
            () => ref
                .read(orderFiltersProvider.notifier)
                .toggleStatus(OrderStatus.pending),
            () => ref
                .read(orderFiltersProvider.notifier)
                .toggleStatus(OrderStatus.confirmed),
            () => ref
                .read(orderFiltersProvider.notifier)
                .toggleStatus(OrderStatus.cancelled),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: searchController,
          onChanged: (value) =>
              ref.read(orderFiltersProvider.notifier).setQuery(value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.ordersSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: filters.query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      searchController.clear();
                      ref.read(orderFiltersProvider.notifier).setQuery('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        _StatusFilters(selected: filters.status),
        const SizedBox(height: 12),
        if (state.confirmFailure != null) ...[
          ConfirmFailureBanner(
            onVerify: state.isRefreshing ? null : controller.refresh,
            onRetry: state.failedConfirmId == null
                ? null
                : () => controller.confirm(state.failedConfirmId!),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.ordersResultsCount(visible.length),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (filters.isActive)
              TextButton.icon(
                onPressed: () {
                  searchController.clear();
                  ref.read(orderFiltersProvider.notifier).clear();
                },
                icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                label: Text(l10n.ordersClearFilters),
              ),
          ],
        ),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: l10n.ordersNoResultTitle,
              body: l10n.ordersNoResultBody,
            ),
          ),
        if (visible.isNotEmpty) const SizedBox(height: 2),
      ],
    );
  }
}

/// Title, live count and the confirmed revenue of the workspace.
class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.summary});

  final OrderSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.sectionOrders,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.ordersConfirmedRevenue(
                  Money.format(
                    summary.confirmedAmount,
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
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${summary.total}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/// Status chips of the order list, driven by the domain statuses.
class _StatusFilters extends ConsumerWidget {
  const _StatusFilters({required this.selected});

  final OrderStatus? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(orderFiltersProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          FilterChip(
            label: Text(l10n.filterAll),
            selected: selected == null,
            onSelected: (_) => controller.clearStatus(),
          ),
          for (final status in OrderStatus.values) ...[
            const SizedBox(width: 8),
            FilterChip(
              label: Text(status.label(l10n)),
              selected: selected == status,
              onSelected: (_) => controller.toggleStatus(status),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order});

  final SupplierOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final state = ref.watch(supplierOrdersControllerProvider);
    final isConfirming = state.isConfirming(order.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      // While the confirmation is in flight the action button is disabled, which
      // would let a second tap fall through to the card and open the order
      // sheet behind the spinner. Swallowing the gesture keeps the row stable.
      child: IgnorePointer(
        ignoring: isConfirming,
        child: InkWell(
          onTap: () => context.push(RoutePaths.supplierOrder(order.id)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(name: order.buyerName, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.orderNumber(order.id),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            order.buyerName,
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
                      label: order.status.label(l10n),
                      color: order.status.color(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Expanded, not Flexible: two loose flex children are each
                    // offered the whole remaining width, so the row overflowed
                    // by a wide margin instead of ellipsizing the labels.
                    Expanded(
                      child: _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: AppFormats.date(
                          order.createdAt,
                          locale: context.localeCode,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetaChip(
                        icon: Icons.inventory_2_outlined,
                        label: l10n.orderNumberItems(order.items.length),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _OrderItemsPreview(items: order.items),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // The label yields characters before the row overflows: two
                    // rigid labels plus the spacer stop fitting as soon as the
                    // reader enlarges the font.
                    Flexible(
                      child: Text(
                        l10n.totalLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      Money.format(
                        order.totalAmount,
                        locale: context.localeCode,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (order.isPending) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: isConfirming
                          ? null
                          : () => _confirmOrder(context, ref, order.id),
                      icon: isConfirming
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 20,
                            ),
                      label: Text(
                        isConfirming
                            ? l10n.confirmingOrder
                            : l10n.confirmOrderAction,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmOrder(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await ref
        .read(supplierOrdersControllerProvider.notifier)
        .confirm(id);
    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.orderConfirmed)));
    }
  }
}

/// Compact icon + value metadata, used for the date and the article count.
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontal strip of the ordered product thumbnails.
class _OrderItemsPreview extends StatelessWidget {
  const _OrderItemsPreview({required this.items});

  /// Capped to the first few items: the full list belongs to the order sheet,
  /// and a long strip would not fit a card on a narrow screen.
  static const int _maxThumbnails = 4;

  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final previewed = items.take(_maxThumbnails);
    final hidden = items.length - previewed.length;

    return Row(
      children: [
        for (final item in previewed)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              width: 34,
              height: 34,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: ProductImage(
                imageUrl: DemoAssets.photoForProduct(item.productId),
                fit: BoxFit.cover,
              ),
            ),
          ),
        if (hidden > 0)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              l10n.ordersMoreItems(hidden),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
