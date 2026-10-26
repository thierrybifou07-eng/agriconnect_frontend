import 'dart:async';

import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';

class SupplierLotsController extends GetxController {
  SupplierLotsController(this.repository);

  final SupplierRepository repository;
  final RxnString statusFilter = RxnString();
  final Rx<UiState<List<SupplierLot>>> state = Rx<UiState<List<SupplierLot>>>(
    const Idle(),
  );
  final Rx<UiState<Map<String, int>>> counts = Rx<UiState<Map<String, int>>>(
    const Idle(),
  );
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  int _generation = 0;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadCounts());
    unawaited(loadFirst());
  }

  Future<void> loadCounts() async {
    counts.value = const Loading();
    try {
      final statuses = [
        'PENDING_VALIDATION',
        'AVAILABLE',
        'FULLY_RESERVED',
        'SOLD_OUT',
      ];
      final pages = await Future.wait(
        statuses.map(
          (value) => repository.lots(status: value, page: 1, limit: 1),
        ),
      );
      counts.value = Success({
        for (var index = 0; index < statuses.length; index++)
          statuses[index]: pages[index].total,
      });
    } on ApiFailure catch (failure) {
      counts.value = Failure(failure);
    }
  }

  Future<void> loadFirst() async {
    if (_loading) return;
    _loading = true;
    final generation = ++_generation;
    state.value = const Loading();
    try {
      final result = await repository.lots(
        status: statusFilter.value,
        page: 1,
        limit: 20,
      );
      if (generation != _generation) return;
      _page = result.page;
      _hasMore = result.hasMore;
      state.value = Success(List.unmodifiable(result.items));
    } on ApiFailure catch (failure) {
      if (generation == _generation) state.value = Failure(failure);
    } finally {
      _loading = false;
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (_loading || !_hasMore || current is! Success<List<SupplierLot>>) {
      return;
    }
    _loading = true;
    final generation = _generation;
    try {
      final result = await repository.lots(
        status: statusFilter.value,
        page: _page + 1,
        limit: 20,
      );
      if (generation != _generation) return;
      _page = result.page;
      _hasMore = result.hasMore;
      state.value = Success(
        List.unmodifiable([...current.data, ...result.items]),
      );
    } on ApiFailure catch (failure) {
      if (generation == _generation) state.value = Failure(failure);
    } finally {
      _loading = false;
    }
  }

  void filterBy(String? value) {
    if (statusFilter.value == value) return;
    statusFilter.value = value;
    unawaited(loadFirst());
  }
}

class SupplierLotDetailController extends GetxController {
  SupplierLotDetailController({required this.repository, required this.id});

  final SupplierRepository repository;
  final int id;
  final Rx<UiState<SupplierLot>> state = Rx<UiState<SupplierLot>>(const Idle());
  final RxBool busy = false.obs;
  final Rxn<ApiFailure> actionFailure = Rxn<ApiFailure>();

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    state.value = const Loading();
    try {
      state.value = Success(await repository.lot(id));
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }

  Future<bool> updateLot(Map<String, Object?> fields) async {
    busy.value = true;
    actionFailure.value = null;
    try {
      state.value = Success(await repository.updateLot(id, fields));
      return true;
    } on ApiFailure catch (failure) {
      actionFailure.value = failure;
      if (failure.isStateConflict) unawaited(load());
      return false;
    } finally {
      busy.value = false;
    }
  }

  Future<bool> delete() async {
    busy.value = true;
    actionFailure.value = null;
    try {
      await repository.deleteLot(id);
      return true;
    } on ApiFailure catch (failure) {
      actionFailure.value = failure;
      if (failure.isStateConflict) unawaited(load());
      return false;
    } finally {
      busy.value = false;
    }
  }

  Future<bool> withdraw(String reason) async {
    busy.value = true;
    actionFailure.value = null;
    try {
      state.value = Success(await repository.withdrawLot(id, reason));
      return true;
    } on ApiFailure catch (failure) {
      actionFailure.value = failure;
      if (failure.isStateConflict) unawaited(load());
      return false;
    } finally {
      busy.value = false;
    }
  }
}

class SupplierRevenueController<T> extends GetxController {
  SupplierRevenueController({required this.fetch, this.limit = 20});

  final Future<Paginated<T>> Function(int page, int limit) fetch;
  final int limit;
  final Rx<UiState<List<T>>> state = Rx<UiState<List<T>>>(const Idle());
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadFirst());
  }

  Future<void> loadFirst() async {
    if (_loading) return;
    _loading = true;
    state.value = const Loading();
    try {
      final result = await fetch(1, limit);
      _page = result.page;
      _hasMore = result.hasMore;
      state.value = Success(List.unmodifiable(result.items));
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    } finally {
      _loading = false;
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (_loading || !_hasMore || current is! Success<List<T>>) return;
    _loading = true;
    try {
      final result = await fetch(_page + 1, limit);
      _page = result.page;
      _hasMore = result.hasMore;
      state.value = Success(
        List.unmodifiable([...current.data, ...result.items]),
      );
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    } finally {
      _loading = false;
    }
  }
}
