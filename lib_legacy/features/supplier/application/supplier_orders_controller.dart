import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/supplier/application/supplier_providers.dart';
import 'package:agri_connect/features/supplier/domain/supplier_order.dart';

/// Sentinel telling [SupplierOrdersState.copyWith] to keep the current value.
///
/// Without it, passing `null` for a nullable field would be indistinguishable
/// from omitting it, and the field could never be cleared.
const Object _keep = Object();

/// Immutable snapshot of the supplier received orders.
class SupplierOrdersState {
  const SupplierOrdersState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.orders = const [],
    this.confirmingIds = const {},
    this.confirmFailure,
    this.failedConfirmId,
  });

  final bool isLoading;
  final bool isRefreshing;

  /// Initial load failure (retryable through [SupplierOrdersController.refresh]).
  final Failure? failure;

  final List<SupplierOrder> orders;

  /// Orders currently being confirmed; guards against double submissions.
  final Set<String> confirmingIds;

  /// Last confirmation attempt failure, surfaced once to the UI.
  final Failure? confirmFailure;

  /// Order that failed to confirm, so the UI can offer a manual retry.
  final String? failedConfirmId;

  bool isConfirming(String orderId) => confirmingIds.contains(orderId);

  SupplierOrdersState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Object? failure = _keep,
    List<SupplierOrder>? orders,
    Set<String>? confirmingIds,
    Object? confirmFailure = _keep,
    Object? failedConfirmId = _keep,
  }) {
    return SupplierOrdersState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: identical(failure, _keep) ? this.failure : failure as Failure?,
      orders: orders ?? this.orders,
      confirmingIds: confirmingIds ?? this.confirmingIds,
      confirmFailure: identical(confirmFailure, _keep)
          ? this.confirmFailure
          : confirmFailure as Failure?,
      failedConfirmId: identical(failedConfirmId, _keep)
          ? this.failedConfirmId
          : failedConfirmId as String?,
    );
  }
}

final supplierOrdersControllerProvider =
    NotifierProvider<SupplierOrdersController, SupplierOrdersState>(
      SupplierOrdersController.new,
    );

/// Loads the supplier received orders and handles order confirmation.
class SupplierOrdersController extends Notifier<SupplierOrdersState> {
  @override
  SupplierOrdersState build() {
    Future<void>.microtask(_load);
    return const SupplierOrdersState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await _load();
  }

  Future<void> _load() async {
    final repository = ref.read(supplierRepositoryProvider);
    try {
      final orders = await repository.fetchOrders();
      state = SupplierOrdersState(orders: orders);
    } on Failure catch (failure) {
      state = SupplierOrdersState(
        failure: failure,
        confirmFailure: state.confirmFailure,
        orders: state.orders,
        confirmingIds: state.confirmingIds,
        failedConfirmId: state.failedConfirmId,
      );
    } catch (_) {
      state = SupplierOrdersState(
        failure: const UnexpectedFailure(),
        confirmFailure: state.confirmFailure,
        orders: state.orders,
        confirmingIds: state.confirmingIds,
        failedConfirmId: state.failedConfirmId,
      );
    }
  }

  /// Confirms [orderId] and returns whether it succeeded.
  ///
  /// On failure nothing is automatically retried and the real status is left
  /// untouched: the UI offers to re-read it before a new attempt.
  Future<bool> confirm(String orderId) async {
    if (state.confirmingIds.contains(orderId)) return false;
    state = state.copyWith(
      confirmingIds: {...state.confirmingIds, orderId},
      confirmFailure: null,
      failedConfirmId: null,
      failure: null,
    );

    try {
      final updated = await ref
          .read(supplierRepositoryProvider)
          .confirmOrder(orderId);
      final orders = [
        for (final order in state.orders)
          if (order.id == orderId) updated else order,
      ];
      state = state.copyWith(
        orders: orders,
        confirmingIds: {...state.confirmingIds}..remove(orderId),
      );
      return true;
    } on Failure catch (failure) {
      state = state.copyWith(
        confirmingIds: {...state.confirmingIds}..remove(orderId),
        confirmFailure: failure,
        failedConfirmId: orderId,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        confirmingIds: {...state.confirmingIds}..remove(orderId),
        confirmFailure: const UnexpectedFailure(),
        failedConfirmId: orderId,
      );
      return false;
    }
  }
}
