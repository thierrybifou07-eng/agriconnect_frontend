import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/buyer/application/buyer_orders_controller.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';

/// Status criterion of the buyer orders page.
///
/// Kept apart from [BuyerOrdersState] so reloading the orders never discards
/// the filter the buyer is working with.
class BuyerOrderFilters {
  const BuyerOrderFilters({this.status});

  /// `null` means "every status".
  final BuyerOrderStatus? status;

  BuyerOrderFilters copyWith({
    BuyerOrderStatus? status,
    bool clearStatus = false,
  }) {
    return BuyerOrderFilters(
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  /// Keeps the orders matching the selected status.
  List<BuyerOrder> apply(List<BuyerOrder> orders) {
    if (status == null) return orders;
    return [
      for (final order in orders)
        if (order.status == status) order,
    ];
  }
}

final buyerOrderFiltersProvider =
    NotifierProvider<BuyerOrderFiltersController, BuyerOrderFilters>(
      BuyerOrderFiltersController.new,
    );

/// Owns the status criterion of the orders list.
class BuyerOrderFiltersController extends Notifier<BuyerOrderFilters> {
  @override
  BuyerOrderFilters build() => const BuyerOrderFilters();

  /// Selecting the active status again releases the filter.
  void toggleStatus(BuyerOrderStatus status) {
    state = state.copyWith(status: status, clearStatus: state.status == status);
  }

  void clearStatus() => state = state.copyWith(clearStatus: true);
}

/// Orders matching the current filter, most recent first.
///
/// Sorting lives here rather than in the repository: the demo repository
/// returns its list in insertion order, which stops being chronological as soon
/// as an order is placed between two seeded ones.
final filteredBuyerOrdersProvider = Provider<List<BuyerOrder>>((ref) {
  final orders = ref.watch(buyerOrdersControllerProvider).orders;
  final filtered = ref.watch(buyerOrderFiltersProvider).apply(orders);
  return [...filtered]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// How many orders sit in each status, computed on the full list so the filter
/// chips keep their counts and never disappear while a filter is active.
class BuyerOrdersSummary {
  const BuyerOrdersSummary(this.counts);

  final Map<BuyerOrderStatus, int> counts;

  int get total => counts.values.fold(0, (sum, count) => sum + count);

  int countOf(BuyerOrderStatus status) => counts[status] ?? 0;

  /// Statuses actually present in the loaded orders, in progression order and
  /// then the closed ones.
  ///
  /// An empty or partial backend must not offer a filter that leads nowhere.
  List<BuyerOrderStatus> get availableStatuses => [
    for (final status in buyerOrderTrackingSteps)
      if (countOf(status) > 0) status,
    if (countOf(BuyerOrderStatus.cancelled) > 0) BuyerOrderStatus.cancelled,
  ];
}

final buyerOrdersSummaryProvider = Provider<BuyerOrdersSummary>((ref) {
  final orders = ref.watch(buyerOrdersControllerProvider).orders;
  final counts = <BuyerOrderStatus, int>{};
  for (final order in orders) {
    counts.update(order.status, (count) => count + 1, ifAbsent: () => 1);
  }
  return BuyerOrdersSummary(counts);
});
