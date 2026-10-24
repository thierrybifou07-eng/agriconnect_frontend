import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/buyer/application/buyer_providers.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';

/// Immutable snapshot of the buyer catalog.
class BuyerCatalogState {
  const BuyerCatalogState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.products = const [],
  });

  final bool isLoading;
  final bool isRefreshing;
  final Failure? failure;
  final List<BuyerProduct> products;

  BuyerCatalogState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    List<BuyerProduct>? products,
  }) {
    return BuyerCatalogState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: failure ?? this.failure,
      products: products ?? this.products,
    );
  }
}

final buyerCatalogControllerProvider =
    NotifierProvider<BuyerCatalogController, BuyerCatalogState>(
      BuyerCatalogController.new,
    );

/// Loads and keeps the buyer catalog in sync.
class BuyerCatalogController extends Notifier<BuyerCatalogState> {
  @override
  BuyerCatalogState build() {
    Future<void>.microtask(_load);
    return const BuyerCatalogState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await _load();
    state = state.copyWith(isRefreshing: false);
  }

  Future<void> _load() async {
    final repository = ref.read(buyerRepositoryProvider);
    try {
      final products = await repository.fetchCatalog();
      state = BuyerCatalogState(
        products: products.where((p) => p.published).toList(),
      );
    } on Failure catch (failure) {
      state = BuyerCatalogState(failure: failure, products: state.products);
    } catch (_) {
      state = BuyerCatalogState(
        failure: const UnexpectedFailure(),
        products: state.products,
      );
    }
  }
}
