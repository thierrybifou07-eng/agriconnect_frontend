import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/driver/application/driver_providers.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';

/// Immutable snapshot of the driver deliveries.
class DriverDeliveriesState {
  const DriverDeliveriesState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.deliveries = const [],
    this.updatingIds = const {},
    this.actionFailure,
    this.failedDeliveryId,
  });

  final bool isLoading;
  final bool isRefreshing;

  /// Initial load failure (retryable through [DriverDeliveriesController.refresh]).
  final Failure? failure;

  final List<DriverDelivery> deliveries;

  /// Deliveries currently being updated; guards against double submissions.
  final Set<String> updatingIds;

  /// Last status-update failure, surfaced once to the UI.
  final Failure? actionFailure;

  /// Delivery that failed to update, so the UI can offer a manual retry.
  final String? failedDeliveryId;

  bool isUpdating(String deliveryId) => updatingIds.contains(deliveryId);

  DriverDeliveriesState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    List<DriverDelivery>? deliveries,
    Set<String>? updatingIds,
    Failure? actionFailure,
    String? failedDeliveryId,
    bool clearFailure = false,
    bool clearActionFailure = false,
  }) {
    return DriverDeliveriesState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      // A failure is dropped only when the caller says so: a copy that simply
      // omitted it must not make a failed load or action look like it never
      // happened.
      failure: clearFailure ? null : (failure ?? this.failure),
      deliveries: deliveries ?? this.deliveries,
      updatingIds: updatingIds ?? this.updatingIds,
      actionFailure: clearActionFailure
          ? null
          : (actionFailure ?? this.actionFailure),
      failedDeliveryId: clearActionFailure
          ? null
          : (failedDeliveryId ?? this.failedDeliveryId),
    );
  }
}

final driverDeliveriesControllerProvider =
    NotifierProvider<DriverDeliveriesController, DriverDeliveriesState>(
      DriverDeliveriesController.new,
    );

/// Loads the driver deliveries and handles status transitions.
class DriverDeliveriesController extends Notifier<DriverDeliveriesState> {
  @override
  DriverDeliveriesState build() {
    Future<void>.microtask(_load);
    return const DriverDeliveriesState(isLoading: true);
  }

  /// Reloads the deliveries on pull-to-refresh and on retry after a failure.
  ///
  /// Refreshes rather than loads: the deliveries already on screen stay there
  /// under the pull indicator instead of being replaced by a skeleton.
  Future<void> refresh() async {
    if (state.isLoading || state.isRefreshing) return;
    // Nothing on screen yet (a retry after a failure) means a load the user can
    // see as a skeleton; deliveries already there only get the pull indicator,
    // so the list never blanks out under the finger.
    state = state.copyWith(
      isLoading: state.deliveries.isEmpty,
      isRefreshing: true,
      clearFailure: true,
    );
    await _load();
  }

  Future<void> _load() async {
    final repository = ref.read(driverRepositoryProvider);
    try {
      final deliveries = await repository.fetchDeliveries();
      // A fresh load is the real status of the world: it supersedes both a
      // previous load failure and an action whose outcome was never confirmed.
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        deliveries: deliveries,
        clearFailure: true,
        clearActionFailure: true,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        failure: failure,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        failure: const UnexpectedFailure(),
      );
    }
  }

  /// Moves [deliveryId] to [status] and returns whether it succeeded.
  ///
  /// Mirror of the farmer confirmation flow: on failure nothing is
  /// automatically retried and the real status is left untouched.
  Future<bool> updateStatus(
    String deliveryId,
    DriverDeliveryStatus status,
  ) async {
    if (state.updatingIds.contains(deliveryId)) return false;
    state = state.copyWith(
      updatingIds: {...state.updatingIds, deliveryId},
      clearActionFailure: true,
      clearFailure: true,
    );

    try {
      final updated = await ref
          .read(driverRepositoryProvider)
          .updateDeliveryStatus(deliveryId, status);
      final deliveries = [
        for (final delivery in state.deliveries)
          if (delivery.id == deliveryId) updated else delivery,
      ];
      state = state.copyWith(
        deliveries: deliveries,
        updatingIds: {...state.updatingIds}..remove(deliveryId),
      );
      return true;
    } on Failure catch (failure) {
      state = state.copyWith(
        updatingIds: {...state.updatingIds}..remove(deliveryId),
        actionFailure: failure,
        failedDeliveryId: deliveryId,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        updatingIds: {...state.updatingIds}..remove(deliveryId),
        actionFailure: const UnexpectedFailure(),
        failedDeliveryId: deliveryId,
      );
      return false;
    }
  }
}
