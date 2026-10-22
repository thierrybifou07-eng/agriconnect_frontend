import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/supplier/application/supplier_orders_controller.dart';
import 'package:agri_connect/features/supplier/domain/supplier_order.dart';

/// Active search and status filter of the supplier orders page.
///
/// Kept apart from [SupplierOrdersState] so reloading the orders never discards
/// the criteria the supplier is working with.
class OrderFilters {
  const OrderFilters({this.query = '', this.status});

  final String query;

  /// `null` means "every status".
  final OrderStatus? status;

  bool get isActive => query.trim().isNotEmpty || status != null;

  OrderFilters copyWith({
    String? query,
    OrderStatus? status,
    bool clearStatus = false,
  }) {
    return OrderFilters(
      query: query ?? this.query,
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  /// Keeps the orders matching the search term and the selected status.
  ///
  /// The term is matched against the reference, the buyer and the ordered
  /// products: the three things a supplier actually looks for.
  List<SupplierOrder> apply(List<SupplierOrder> orders) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty && status == null) return orders;

    return [
      for (final order in orders)
        if ((status == null || order.status == status) && _matches(order, term))
          order,
    ];
  }

  bool _matches(SupplierOrder order, String term) {
    if (order.id.toLowerCase().contains(term)) return true;
    if (order.buyerName.toLowerCase().contains(term)) return true;
    if (order.buyerEmail.toLowerCase().contains(term)) return true;
    return order.items.any(
      (item) => item.productName.toLowerCase().contains(term),
    );
  }
}

final orderFiltersProvider =
    NotifierProvider<OrderFiltersController, OrderFilters>(
      OrderFiltersController.new,
    );

/// Owns the orders search/filter criteria.
class OrderFiltersController extends Notifier<OrderFilters> {
  @override
  OrderFilters build() => const OrderFilters();

  void setQuery(String value) => state = state.copyWith(query: value);

  void toggleStatus(OrderStatus status) {
    state = state.copyWith(status: status, clearStatus: state.status == status);
  }

  /// Drops the status criterion and keeps the search term.
  void clearStatus() => state = state.copyWith(clearStatus: true);

  void clear() => state = const OrderFilters();
}

/// Orders matching the current filters, sorted from the most recent.
final filteredSupplierOrdersProvider = Provider<List<SupplierOrder>>((ref) {
  final orders = ref.watch(supplierOrdersControllerProvider).orders;
  final filters = ref.watch(orderFiltersProvider);
  final filtered = filters.apply(orders);
  return [...filtered]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// Aggregated figures of the received orders, always computed on the full list
/// so the supplier keeps an overview of everything while filtering.
class OrderSummary {
  const OrderSummary({
    this.total = 0,
    this.pending = 0,
    this.confirmed = 0,
    this.cancelled = 0,
    this.pendingAmount = 0,
    this.confirmedAmount = 0,
  });

  final int total;
  final int pending;
  final int confirmed;
  final int cancelled;

  /// Amount still waiting for a confirmation.
  final int pendingAmount;

  /// Amount of the confirmed orders, the only figure the supplier has earned.
  final int confirmedAmount;

  int countOf(OrderStatus? status) => switch (status) {
    null => total,
    OrderStatus.pending => pending,
    OrderStatus.confirmed => confirmed,
    OrderStatus.cancelled => cancelled,
  };
}

final supplierOrdersSummaryProvider = Provider<OrderSummary>((ref) {
  final orders = ref.watch(supplierOrdersControllerProvider).orders;
  var pending = 0;
  var confirmed = 0;
  var cancelled = 0;
  var pendingAmount = 0;
  var confirmedAmount = 0;

  for (final order in orders) {
    switch (order.status) {
      case OrderStatus.pending:
        pending++;
        pendingAmount += order.totalAmount;
      case OrderStatus.confirmed:
        confirmed++;
        confirmedAmount += order.totalAmount;
      case OrderStatus.cancelled:
        cancelled++;
    }
  }

  return OrderSummary(
    total: orders.length,
    pending: pending,
    confirmed: confirmed,
    cancelled: cancelled,
    pendingAmount: pendingAmount,
    confirmedAmount: confirmedAmount,
  );
});
