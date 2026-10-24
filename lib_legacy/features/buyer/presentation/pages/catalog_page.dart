import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/buyer/application/buyer_cart_controller.dart';
import 'package:agri_connect/features/buyer/application/buyer_catalog_controller.dart';
import 'package:agri_connect/features/buyer/application/catalog_filters_controller.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';
import 'package:agri_connect/features/buyer/presentation/cart_feedback.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_filter_bar.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_filter_chip.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_product_card.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_search_field.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

/// Width beyond which the catalog stops stretching: a marketplace browsed on a
/// desktop window gains columns, but each tile keeps a readable size.
const double _maxContentWidth = 1000;

/// Marketplace catalog with search and category/location filtering.
///
/// Search and filters run on the products already held by the catalog
/// controller, so refining the list never reloads anything. The page is a
/// single scrollable so a pull to refresh reaches the top of the screen.
class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
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
    final state = ref.watch(buyerCatalogControllerProvider);
    final products = ref.watch(filteredCatalogProvider);
    final filters = ref.watch(catalogFiltersProvider);
    ref.listen<CatalogFilters>(catalogFiltersProvider, (previous, next) {
      if (_searchController.text == next.query) return;
      _searchController.value = TextEditingValue(
        text: next.query,
        selection: TextSelection.collapsed(offset: next.query.length),
      );
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(buyerCatalogControllerProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // The grid answers to the room it is given: two columns on a phone,
            // more as the window grows, and a single block of content on a
            // wide screen. The width is measured inside the page padding and
            // below the cap, which is the width the tiles really get.
            final width = constraints.maxWidth - AppSizes.pagePadding * 2;
            final contentWidth = width < _maxContentWidth
                ? width
                : _maxContentWidth;
            final columns = _columnsFor(contentWidth);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CatalogHeader(
                          // Unknown while the first load is in flight: a header
                          // claiming "0" over a skeleton would be a figure
                          // nobody can trust.
                          count: state.products.isEmpty && state.isLoading
                              ? null
                              : state.products.length,
                          filtersActive: filters.isActive,
                          onResetFilters: () =>
                              ref.read(catalogFiltersProvider.notifier).clear(),
                        ),
                        const SizedBox(height: 14),
                        CatalogSearchField(
                          controller: _searchController,
                          onChanged: (value) => ref
                              .read(catalogFiltersProvider.notifier)
                              .setQuery(value),
                          onCleared: () {
                            _searchController.clear();
                            ref
                                .read(catalogFiltersProvider.notifier)
                                .setQuery('');
                          },
                        ),
                        const SizedBox(height: 16),
                        CatalogFilterLabel(label: l10n.filterCategory),
                        const SizedBox(height: 8),
                        CatalogCategoryFilter(
                          filters: filters,
                          onToggle: (category) => ref
                              .read(catalogFiltersProvider.notifier)
                              .toggleCategory(category),
                          onClear: () => ref
                              .read(catalogFiltersProvider.notifier)
                              .clearCategory(),
                        ),
                        const SizedBox(height: 14),
                        CatalogFilterLabel(label: l10n.filterLocation),
                        const SizedBox(height: 8),
                        CatalogLocationFilter(
                          filters: filters,
                          onSelect: (location) => ref
                              .read(catalogFiltersProvider.notifier)
                              .selectLocation(location),
                        ),
                        const SizedBox(height: 18),
                        _catalogBody(
                          context,
                          l10n,
                          state,
                          products,
                          filters,
                          columns: columns,
                          contentWidth: contentWidth,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Columns of the product grid for a given content width.
  ///
  /// Kept next to the page so the real grid and its skeleton are built from the
  /// same numbers.
  static int _columnsFor(double width) {
    if (width >= 960) return 4;
    if (width >= 640) return 3;
    return 2;
  }

  Widget _catalogBody(
    BuildContext context,
    AppLocalizations l10n,
    BuyerCatalogState state,
    List<BuyerProduct> products,
    CatalogFilters filters, {
    required int columns,
    required double contentWidth,
  }) {
    // Nothing has ever been loaded: the grid is still on its way.
    if (state.isLoading && state.products.isEmpty) {
      return GridSkeleton(itemCount: columns * 2, crossAxisCount: columns);
    }

    // The first load failed and there is nothing to show behind it.
    if (state.failure != null && state.products.isEmpty) {
      return FailureView(
        failure: state.failure!,
        onRetry: () =>
            ref.read(buyerCatalogControllerProvider.notifier).refresh(),
      );
    }

    if (products.isEmpty) {
      // An empty catalog and a search that matched nothing are different
      // situations, so they do not share the same message.
      final noResult = state.products.isNotEmpty || filters.isActive;
      return EmptyState(
        icon: noResult ? Icons.search_off_rounded : Icons.storefront_outlined,
        title: noResult ? l10n.catalogNoResultsTitle : l10n.catalogEmptyTitle,
        body: noResult ? l10n.catalogNoResultsBody : l10n.catalogEmptyBody,
        actionLabel: noResult ? l10n.catalogFiltersReset : l10n.retry,
        actionIcon: noResult
            ? Icons.filter_alt_off_rounded
            : Icons.refresh_rounded,
        onAction: noResult
            ? () {
                _searchController.clear();
                ref.read(catalogFiltersProvider.notifier).clear();
              }
            : () => ref.read(buyerCatalogControllerProvider.notifier).refresh(),
      );
    }

    // The tile height comes from the card itself, so the grid can never hand
    // it a box its content does not fit into.
    final metrics = CatalogCardMetrics.of(context);
    final tileWidth = (contentWidth - (columns - 1) * 10) / columns;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.resultsCount(products.length),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: metrics.cardHeight(tileWidth),
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return CatalogProductCard(
              product: product,
              onTap: () => context.push(RoutePaths.buyerProduct(product.id)),
              onAdd: () => _addToCart(context, product),
            );
          },
        ),
      ],
    );
  }

  void _addToCart(BuildContext context, BuyerProduct product) {
    ref.read(cartControllerProvider.notifier).add(product);
    showAddedToCart(context, product.name);
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({
    required this.count,
    required this.filtersActive,
    required this.onResetFilters,
  });

  /// Products in the catalog, or `null` while the first load is in flight.
  final int? count;
  final bool filtersActive;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final total = count;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.sectionCatalog,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (filtersActive) ...[
              // Flexible, so the row never overflows on a narrow screen: the
              // label gives up characters rather than pushing the badge out.
              Flexible(
                child: TextButton.icon(
                  onPressed: onResetFilters,
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                  label: Text(
                    l10n.catalogFiltersReset,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // The badge counts the whole catalog, filters excluded, so it is
            // the one figure that stays put while the buyer narrows the list.
            if (total != null)
              Semantics(
                label: l10n.catalogTotalProducts(total),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
        ),
        const SizedBox(height: 4),
        Text(
          l10n.catalogSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
