import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/supplier/application/supplier_providers.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';

/// Sentinel telling [SupplierProductsState.copyWith] to keep the current value.
const Object _keep = Object();

/// Immutable snapshot of the supplier product list.
class SupplierProductsState {
  const SupplierProductsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.products = const [],
  });

  final bool isLoading;
  final bool isRefreshing;
  final Failure? failure;
  final List<Product> products;

  SupplierProductsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Object? failure = _keep,
    List<Product>? products,
  }) {
    return SupplierProductsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: identical(failure, _keep) ? this.failure : failure as Failure?,
      products: products ?? this.products,
    );
  }
}

final supplierProductsControllerProvider =
    NotifierProvider<SupplierProductsController, SupplierProductsState>(
      SupplierProductsController.new,
    );

/// Loads and keeps the supplier product catalog in sync.
class SupplierProductsController extends Notifier<SupplierProductsState> {
  @override
  SupplierProductsState build() {
    Future<void>.microtask(_load);
    return const SupplierProductsState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await _load();
    state = state.copyWith(isRefreshing: false);
  }

  Future<void> _load() async {
    final repository = ref.read(supplierRepositoryProvider);
    try {
      final products = await repository.fetchProducts();
      state = SupplierProductsState(products: products);
    } on Failure catch (failure) {
      state = SupplierProductsState(failure: failure, products: state.products);
    } catch (_) {
      state = SupplierProductsState(
        failure: const UnexpectedFailure(),
        products: state.products,
      );
    }
  }

  /// Inserts or replaces [product] after a successful save.
  void upsert(Product product) {
    final products = state.products;
    final index = products.indexWhere((p) => p.id == product.id);
    state = index >= 0
        ? state.copyWith(
            products: [
              for (var i = 0; i < products.length; i++)
                if (i == index) product else products[i],
            ],
          )
        : state.copyWith(products: [product, ...products]);
  }
}
