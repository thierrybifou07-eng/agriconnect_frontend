import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/driver/application/driver_providers.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';

/// Immutable snapshot of the driver trips.
class DriverTripsState {
  const DriverTripsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.trips = const [],
  });

  final bool isLoading;
  final bool isRefreshing;
  final Failure? failure;
  final List<DeliveryTrip> trips;

  DriverTripsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    List<DeliveryTrip>? trips,
    bool clearFailure = false,
  }) {
    return DriverTripsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      // A failure is dropped only when the caller says so: a copy that simply
      // omitted it must not make a failed load look like it never happened.
      failure: clearFailure ? null : (failure ?? this.failure),
      trips: trips ?? this.trips,
    );
  }
}

final driverTripsControllerProvider =
    NotifierProvider<DriverTripsController, DriverTripsState>(
      DriverTripsController.new,
    );

/// Loads the driver trips.
class DriverTripsController extends Notifier<DriverTripsState> {
  @override
  DriverTripsState build() {
    Future<void>.microtask(_load);
    return const DriverTripsState(isLoading: true);
  }

  /// Reloads the trips on pull-to-refresh and on retry after a failure.
  ///
  /// Refreshes rather than loads: the trips already on screen stay there under
  /// the pull indicator instead of being replaced by a skeleton.
  Future<void> refresh() async {
    if (state.isLoading || state.isRefreshing) return;
    state = state.copyWith(
      isLoading: state.trips.isEmpty,
      isRefreshing: true,
      clearFailure: true,
    );
    await _load();
  }

  Future<void> _load() async {
    final repository = ref.read(driverRepositoryProvider);
    try {
      final trips = await repository.fetchTrips();
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        trips: trips,
        clearFailure: true,
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
}
