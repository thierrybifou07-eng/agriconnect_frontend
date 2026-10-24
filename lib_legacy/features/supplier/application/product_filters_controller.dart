import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/supplier/application/supplier_products_controller.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';

/// Active search and filter criteria of the supplier product page.
///
/// Mirrors the buyer catalog filters so both catalogs behave the same way.
class ProductFilters {
  const ProductFilters({this.query = '', this.status});

  final String query;
  final ProductStatus? status;

  bool get isActive => query.trim().isNotEmpty || status != null;

  ProductFilters copyWith({
    String? query,
    ProductStatus? status,
    bool clearStatus = false,
  }) {
    return ProductFilters(
      query: query ?? this.query,
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  List<Product> apply(List<Product> products) {
    final term = query.trim().toLowerCase();
    return [
      for (final product in products)
        if ((status == null || product.status == status) &&
            (term.isEmpty ||
                product.name.toLowerCase().contains(term) ||
                product.description.toLowerCase().contains(term)))
          product,
    ];
  }
}

final productFiltersProvider =
    NotifierProvider<ProductFiltersController, ProductFilters>(
      ProductFiltersController.new,
    );

/// Owns the product search/filter criteria.
class ProductFiltersController extends Notifier<ProductFilters> {
  @override
  ProductFilters build() => const ProductFilters();

  void setQuery(String value) => state = state.copyWith(query: value);

  void toggleStatus(ProductStatus status) {
    state = state.copyWith(status: status, clearStatus: state.status == status);
  }

  void clear() => state = const ProductFilters();
}

/// Products matching the current filters.
final filteredSupplierProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(supplierProductsControllerProvider).products;
  final filters = ref.watch(productFiltersProvider);
  return filters.apply(products);
});
