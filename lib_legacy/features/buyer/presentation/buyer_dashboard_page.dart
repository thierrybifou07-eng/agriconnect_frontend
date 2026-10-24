import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/buyer/application/buyer_cart_controller.dart';
import 'package:agri_connect/features/buyer/application/buyer_catalog_controller.dart';
import 'package:agri_connect/features/buyer/application/buyer_orders_controller.dart';
import 'package:agri_connect/features/buyer/application/catalog_filters_controller.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';
import 'package:agri_connect/features/buyer/presentation/cart_feedback.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_filter_bar.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_filter_chip.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_search_field.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/buyer_hero.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/buyer_quick_actions.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/buyer_welcome_panel.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/featured_product_card.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/recent_order_tile.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';

/// Width beyond which the dashboard stops stretching: a dashboard read on a
/// desktop window has to stay a column, not a full-bleed page of empty space.
const double _maxContentWidth = 720;

/// Buyer workspace home: a premium welcome banner, the four shopping
/// shortcuts, an orders summary, the featured catalog and the latest orders.
///
/// Every figure comes from the catalog, the orders or the cart already held by
/// the buyer controllers; the page never computes a statistic of its own.
class BuyerDashboardPage extends ConsumerStatefulWidget {
  const BuyerDashboardPage({super.key});

  @override
  ConsumerState<BuyerDashboardPage> createState() => _BuyerDashboardPageState();
}

class _BuyerDashboardPageState extends ConsumerState<BuyerDashboardPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(catalogFiltersProvider).query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    // The shell only exists for a signed-in buyer, but the session can be
    // dropped in the same frame the router is redirecting: rendering nothing
    // beats a null assertion crash on the way out.
    if (user == null) return const SizedBox.shrink();

    final catalogState = ref.watch(buyerCatalogControllerProvider);
    final ordersState = ref.watch(buyerOrdersControllerProvider);
    final cart = ref.watch(cartControllerProvider);
    final products = catalogState.products;
    final orders = ordersState.orders;
    final filters = ref.watch(catalogFiltersProvider);
    ref.listen<CatalogFilters>(catalogFiltersProvider, (previous, next) {
      if (_searchController.text == next.query) return;
      _searchController.value = TextEditingValue(
        text: next.query,
        selection: TextSelection.collapsed(offset: next.query.length),
      );
    });

    return RefreshIndicator(
      onRefresh: () => Future.wait([
        ref.read(buyerCatalogControllerProvider.notifier).refresh(),
        ref.read(buyerOrdersControllerProvider.notifier).refresh(),
      ]),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: BuyerHero(
                firstName: user.fullName.split(' ').first,
                fullName: user.fullName,
                cart: cart,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: _catalogDiscovery(context, ref, l10n, filters),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: BuyerWelcomePanel(
                firstName: user.fullName.split(' ').first,
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(context, l10n.dashboardQuickActions),
                  const SizedBox(height: 10),
                  BuyerQuickActions(
                    actions: [
                      BuyerQuickAction(
                        label: l10n.dashboardQuickExplore,
                        icon: Icons.storefront_rounded,
                        onTap: () => context.go(RoutePaths.buyerCatalog),
                        primary: true,
                      ),
                      BuyerQuickAction(
                        label: l10n.dashboardQuickCart,
                        icon: Icons.shopping_basket_outlined,
                        onTap: () => context.push(RoutePaths.buyerCart),
                        badgeCount: cart.isEmpty ? null : cart.itemCount,
                      ),
                      BuyerQuickAction(
                        label: l10n.dashboardQuickMyOrders,
                        icon: Icons.receipt_long_rounded,
                        onTap: () => context.go(RoutePaths.buyerOrders),
                      ),
                      // Pushed, like the cart: the inbox lives outside the
                      // shell, so replacing the shell with it would make the
                      // platform back gesture leave the app instead of coming
                      // back to this dashboard.
                      BuyerQuickAction(
                        label: l10n.chatTitle,
                        icon: Icons.forum_rounded,
                        onTap: () => context.push(RoutePaths.buyerMessages),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _OrdersSummary(
                    orders: orders,
                    onOpenOrders: () => context.go(RoutePaths.buyerOrders),
                  ),
                  const SizedBox(height: 24),
                  _featuredSection(context, ref, l10n, catalogState, products),
                  const SizedBox(height: 24),
                  _recentOrdersSection(context, ref, l10n, ordersState, orders),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _catalogDiscovery(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    CatalogFilters filters,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatalogSearchField(
            controller: _searchController,
            onChanged: ref.read(catalogFiltersProvider.notifier).setQuery,
            onCleared: () {
              _searchController.clear();
              ref.read(catalogFiltersProvider.notifier).setQuery('');
            },
            onSubmitted: (_) => _openCatalog(context),
          ),
          const SizedBox(height: 12),
          CatalogFilterLabel(label: l10n.filterCategory),
          const SizedBox(height: 6),
          CatalogCategoryFilter(
            filters: filters,
            onToggle: (category) {
              ref
                  .read(catalogFiltersProvider.notifier)
                  .toggleCategory(category);
              _openCatalog(context);
            },
            onClear: () {
              ref.read(catalogFiltersProvider.notifier).clearCategory();
              _openCatalog(context);
            },
          ),
        ],
      ),
    );
  }

  void _openCatalog(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.go(RoutePaths.buyerCatalog);
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  /// Featured catalog, sorted so the products actually purchasable come
  /// first: an out-of-stock product has nothing to offer on a "buy" surface.
  Widget _featuredSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    BuyerCatalogState state,
    List<BuyerProduct> products,
  ) {
    final available = [
      for (final p in products)
        if (p.inStock) p,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.featuredCatalog,
          actionLabel: l10n.seeAll,
          onAction: () => context.go(RoutePaths.buyerCatalog),
        ),
        const SizedBox(height: 10),
        if (state.isLoading && products.isEmpty)
          const CardListSkeleton(itemCount: 3)
        else if (state.failure != null && products.isEmpty)
          FailureView(
            failure: state.failure!,
            compact: true,
            onRetry: () =>
                ref.read(buyerCatalogControllerProvider.notifier).refresh(),
          )
        else if (available.isEmpty)
          EmptyState(
            icon: Icons.storefront_outlined,
            title: l10n.catalogEmptyTitle,
            body: l10n.catalogEmptyBody,
            actionLabel: l10n.dashboardQuickExplore,
            actionIcon: Icons.storefront_rounded,
            onAction: () => context.go(RoutePaths.buyerCatalog),
          )
        else
          for (final product in available.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FeaturedProductCard(
                product: product,
                onTap: () => context.push(RoutePaths.buyerProduct(product.id)),
                onAdd: () => _addToCart(context, ref, product),
              ),
            ),
      ],
    );
  }

  /// Latest orders, most recent first.
  Widget _recentOrdersSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    BuyerOrdersState state,
    List<BuyerOrder> orders,
  ) {
    final recent = [...orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.recentOrders,
          actionLabel: l10n.seeAll,
          onAction: () => context.go(RoutePaths.buyerOrders),
        ),
        const SizedBox(height: 10),
        if (state.isLoading && orders.isEmpty)
          const CardListSkeleton(itemCount: 3)
        else if (state.failure != null && orders.isEmpty)
          FailureView(
            failure: state.failure!,
            compact: true,
            onRetry: () =>
                ref.read(buyerOrdersControllerProvider.notifier).refresh(),
          )
        else if (recent.isEmpty)
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: l10n.buyerOrdersEmptyTitle,
            body: l10n.buyerOrdersEmptyBody,
            actionLabel: l10n.dashboardQuickExplore,
            actionIcon: Icons.storefront_rounded,
            onAction: () => context.go(RoutePaths.buyerCatalog),
          )
        else
          for (final order in recent.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RecentOrderTile(
                order: order,
                onTap: () => context.push(RoutePaths.buyerOrder(order.id)),
              ),
            ),
      ],
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, BuyerProduct product) {
    ref.read(cartControllerProvider.notifier).add(product);
    showAddedToCart(context, product.name);
  }
}

/// Section title carrying the total number of orders behind it, plus the
/// shortcut to the full list.
///
/// [SectionHeader] has no slot for a figure, and the total is the one number a
/// buyer looks for before the three stage figures below it.
class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.title,
    required this.count,
    required this.countLabel,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final int count;
  final String countLabel;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: countLabel,
          child: Container(
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
        ),
        TextButton(
          onPressed: onAction,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(actionLabel),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

/// Orders overview: how many orders the buyer placed, and what stage they are
/// at. Each figure filters nothing by itself, it only opens the order list.
class _OrdersSummary extends StatelessWidget {
  const _OrdersSummary({required this.orders, required this.onOpenOrders});

  final List<BuyerOrder> orders;
  final VoidCallback onOpenOrders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // "Active" is what the orders list calls "En cours": an order still moving
    // towards the buyer, whatever step of the delivery it is on. The two
    // screens answer the same question and must not answer it differently.
    final activeCount = orders.where((o) => o.status.isOngoing).length;
    final inTransitCount = orders
        .where((o) => o.status == BuyerOrderStatus.inTransit)
        .length;
    final deliveredCount = orders
        .where((o) => o.status == BuyerOrderStatus.delivered)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryHeader(
          title: l10n.dashboardOverview,
          count: orders.length,
          countLabel: l10n.ordersPlacedStat,
          actionLabel: l10n.seeAll,
          onAction: onOpenOrders,
        ),
        const SizedBox(height: 10),
        StatGrid(
          values: ['$activeCount', '$inTransitCount', '$deliveredCount'],
          labels: [
            l10n.activeOrdersStat,
            l10n.statInTransit,
            l10n.statDelivered,
          ],
          icons: const [
            Icons.hourglass_top_rounded,
            Icons.local_shipping_rounded,
            Icons.check_circle_rounded,
          ],
          accents: const [true, false, false],
          onTap: [onOpenOrders, onOpenOrders, onOpenOrders],
        ),
      ],
    );
  }
}
