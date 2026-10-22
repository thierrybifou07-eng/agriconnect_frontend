import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/supplier/application/supplier_products_controller.dart';
import 'package:agri_connect/features/supplier/application/product_filters_controller.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/product_card.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

/// Supplier product catalog with creation entry point, search and filtering.
class SupplierProductsPage extends ConsumerStatefulWidget {
  const SupplierProductsPage({super.key});

  @override
  ConsumerState<SupplierProductsPage> createState() =>
      _SupplierProductsPageState();
}

class _SupplierProductsPageState extends ConsumerState<SupplierProductsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  /// Room kept below the last card so the floating creation button never
  /// covers it: the button height, its margin and the page padding.
  static const double _fabClearance = 96;

  @override
  void initState() {
    super.initState();
    // The tab can be reopened while criteria are still active: the field must
    // start on the query that is really narrowing the list.
    _searchController.text = ref.read(productFiltersProvider).query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(productFiltersProvider.notifier).setQuery('');
  }

  /// Drops every criterion at once, and the text field that mirrors it.
  void _clearFilters() {
    _searchController.clear();
    ref.read(productFiltersProvider.notifier).clear();
    // With the criteria gone the whole catalog comes back: returning to the top
    // puts the search field, and the first products, straight in view.
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(supplierProductsControllerProvider);
    final products = ref.watch(filteredSupplierProductsProvider);
    final filters = ref.watch(productFiltersProvider);

    // A criterion can also change outside the field, through a reset or the
    // "all" chip: the field then has to follow, or it would keep advertising a
    // search that is no longer applied.
    ref.listen(productFiltersProvider, (previous, next) {
      if (next.query == _searchController.text) return;
      _searchController.value = TextEditingValue(
        text: next.query,
        selection: TextSelection.collapsed(offset: next.query.length),
      );
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.supplierProductNew),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addProduct),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(supplierProductsControllerProvider.notifier).refresh(),
        child: _buildContent(context, l10n, state, products, filters),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    SupplierProductsState state,
    List<Product> products,
    ProductFilters filters,
  ) {
    final header = _ProductsHeader(count: state.products.length);
    final isEmptyCatalog = state.products.isEmpty;
    final hasNoMatch = !isEmptyCatalog && products.isEmpty;

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.pagePadding,
        AppSizes.pagePadding,
        // The creation button floats over the list: the last card would end up
        // underneath it and stay partly untappable.
        isEmptyCatalog ? AppSizes.pagePadding : _fabClearance,
      ),
      children: [
        header,
        const SizedBox(height: 12),
        if (!isEmptyCatalog) ...[
          TextField(
            controller: _searchController,
            onChanged: (value) =>
                ref.read(productFiltersProvider.notifier).setQuery(value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.searchCatalog,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: filters.query.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.filterAll),
                  selected: filters.status == null,
                  onSelected: (_) => _clearFilters(),
                ),
                const SizedBox(width: 8),
                for (final status in ProductStatus.values) ...[
                  FilterChip(
                    label: Text(status.label(l10n)),
                    selected: filters.status == status,
                    onSelected: (_) => ref
                        .read(productFiltersProvider.notifier)
                        .toggleStatus(status),
                  ),
                  if (status != ProductStatus.values.last)
                    const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (state.isLoading && isEmptyCatalog)
          const CardListSkeleton(itemCount: 4)
        else if (state.failure != null && isEmptyCatalog)
          FailureView(
            failure: state.failure!,
            onRetry: () =>
                ref.read(supplierProductsControllerProvider.notifier).refresh(),
          )
        else if (isEmptyCatalog)
          EmptyState(
            icon: Icons.inventory_2_outlined,
            title: l10n.productsEmptyTitle,
            body: l10n.productsEmptyBody,
            actionLabel: l10n.addProduct,
            onAction: () => context.push(RoutePaths.supplierProductNew),
          )
        else if (hasNoMatch)
          EmptyState(
            icon: Icons.search_off_rounded,
            title: l10n.productsNoResultTitle,
            body: l10n.productsNoResultBody,
            actionLabel: filters.isActive ? l10n.ordersClearFilters : null,
            actionIcon: Icons.filter_alt_off_outlined,
            onAction: filters.isActive ? _clearFilters : null,
          )
        else ...[
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.resultsCount(products.length),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (filters.isActive)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                  label: Text(l10n.ordersClearFilters),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final product in products)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductCard(
                product: product,
                onTap: () =>
                    context.push(RoutePaths.supplierProduct(product.id)),
              ),
            ),
        ],
      ],
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({required this.count});

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
            l10n.sectionProducts,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
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
