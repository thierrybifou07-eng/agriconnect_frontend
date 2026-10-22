import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/buyer/application/buyer_catalog_controller.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';

/// Active search and filter criteria of the catalog page.
class CatalogFilters {
  const CatalogFilters({this.query = '', this.category, this.location});

  final String query;
  final CatalogCategory? category;
  final String? location;

  bool get isActive =>
      query.trim().isNotEmpty || category != null || location != null;

  CatalogFilters copyWith({
    String? query,
    CatalogCategory? category,
    String? location,
    bool clearCategory = false,
    bool clearLocation = false,
  }) {
    return CatalogFilters(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      location: clearLocation ? null : (location ?? this.location),
    );
  }

  List<BuyerProduct> apply(List<BuyerProduct> products) {
    final term = query.trim().toLowerCase();
    return [
      for (final product in products)
        if ((category == null || product.category == category) &&
            (location == null || product.location == location) &&
            (term.isEmpty ||
                product.name.toLowerCase().contains(term) ||
                product.sellerName.toLowerCase().contains(term) ||
                product.description.toLowerCase().contains(term)))
          product,
    ];
  }
}

final catalogFiltersProvider =
    NotifierProvider<CatalogFiltersController, CatalogFilters>(
      CatalogFiltersController.new,
    );

/// Owns the catalog search/filter criteria.
class CatalogFiltersController extends Notifier<CatalogFilters> {
  @override
  CatalogFilters build() => const CatalogFilters();

  void setQuery(String value) => state = state.copyWith(query: value);

  void toggleCategory(CatalogCategory category) {
    state = state.copyWith(
      category: category,
      clearCategory: state.category == category,
    );
  }

  /// Releases the family filter only, leaving the search and the location
  /// untouched, as the "all" chip of the category row does.
  void clearCategory() => state = state.copyWith(clearCategory: true);

  void selectLocation(String? location) {
    state = state.copyWith(location: location, clearLocation: location == null);
  }

  void clear() => state = const CatalogFilters();
}

/// Products matching the current filters.
final filteredCatalogProvider = Provider<List<BuyerProduct>>((ref) {
  final products = ref.watch(buyerCatalogControllerProvider).products;
  final filters = ref.watch(catalogFiltersProvider);
  return filters.apply(products);
});
