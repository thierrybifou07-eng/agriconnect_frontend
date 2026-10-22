import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/buyer/application/buyer_providers.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';

/// Immutable snapshot of the buyer orders.
class BuyerOrdersState {
  const BuyerOrdersState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.orders = const [],
  });

  final bool isLoading;
  final bool isRefreshing;
  final Failure? failure;
  final List<BuyerOrder> orders;

  BuyerOrdersState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    List<BuyerOrder>? orders,
    bool clearFailure = false,
  }) {
    return BuyerOrdersState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      // A load failure is dropped only on request: without the flag, the last
      // error would outlive the data that replaced it.
      failure: clearFailure ? null : (failure ?? this.failure),
      orders: orders ?? this.orders,
    );
  }
}

final buyerOrdersControllerProvider =
    NotifierProvider<BuyerOrdersController, BuyerOrdersState>(
      BuyerOrdersController.new,
    );

/// Loads the orders placed by the current buyer.
class BuyerOrdersController extends Notifier<BuyerOrdersState> {
  @override
  BuyerOrdersState build() {
    Future<void>.microtask(_load);
    return const BuyerOrdersState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await _load();
    state = state.copyWith(isRefreshing: false);
  }

  Future<void> _load() async {
    final repository = ref.read(buyerRepositoryProvider);
    try {
      final orders = await repository.fetchOrders();
      state = BuyerOrdersState(orders: orders);
    } on Failure catch (failure) {
      state = BuyerOrdersState(failure: failure, orders: state.orders);
    } catch (_) {
      state = BuyerOrdersState(
        failure: const UnexpectedFailure(),
        orders: state.orders,
      );
    }
  }

  /// Inserts or replaces [order] after a successful placement.
  void upsert(BuyerOrder order) {
    final orders = state.orders;
    final index = orders.indexWhere((o) => o.id == order.id);
    // The order just placed is proof the list is not empty, so a load error
    // from before is no longer what the screen is about to show.
    state = index >= 0
        ? state.copyWith(
            clearFailure: true,
            orders: [
              for (var i = 0; i < orders.length; i++)
                if (i == index) order else orders[i],
            ],
          )
        : state.copyWith(clearFailure: true, orders: [order, ...orders]);
  }
}
