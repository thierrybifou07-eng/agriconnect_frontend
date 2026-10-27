import 'dart:async';

import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_repository.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';

class DriverController extends GetxController {
  DriverController({
    required this.repository,
    required this.socketService,
    this.limit = 20,
  }) {
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100');
    }
  }

  final DriverRepository repository;
  final SocketService socketService;
  final int limit;

  final Rx<UiState<List<DriverDelivery>>> availableState =
      Rx<UiState<List<DriverDelivery>>>(const Idle());
  final Rx<UiState<List<DriverDelivery>>> mineState =
      Rx<UiState<List<DriverDelivery>>>(const Idle());
  final Rxn<DeliveryStatus> statusFilter = Rxn<DeliveryStatus>();
  final RxSet<int> acceptingIds = <int>{}.obs;
  final RxInt selectedTab = 0.obs;

  void selectTab(int index) => selectedTab.value = index;

  int _availablePage = 0;
  int _minePage = 0;
  int _availableGeneration = 0;
  int _mineGeneration = 0;
  bool _availableHasMore = true;
  bool _mineHasMore = true;
  bool _loadingAvailable = false;
  bool _loadingMine = false;
  StreamSubscription<Map<String, dynamic>>? _availableSubscription;
  StreamSubscription<Map<String, dynamic>>? _statusSubscription;

  List<DriverDelivery> get availableDeliveries =>
      switch (availableState.value) {
        Success<List<DriverDelivery>>(:final data) => data,
        _ => const [],
      };
  List<DriverDelivery> get myDeliveries => switch (mineState.value) {
    Success<List<DriverDelivery>>(:final data) => data,
    _ => const [],
  };
  DriverDelivery? get activeDelivery {
    for (final delivery in myDeliveries) {
      if (delivery.status.isActive) return delivery;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _availableSubscription = socketService.deliveryAvailable.listen((_) {
      unawaited(loadAvailable());
    });
    _statusSubscription = socketService.deliveryStatus.listen(
      _onDeliveryStatus,
    );
    unawaited(refreshAll());
  }

  Future<void> refreshAll() => Future.wait([loadAvailable(), loadMine()]);

  Future<void> loadAvailable() async {
    if (_loadingAvailable) return;
    final generation = ++_availableGeneration;
    _loadingAvailable = true;
    availableState.value = const Loading();
    _availablePage = 0;
    _availableHasMore = true;
    try {
      final page = await repository.available(page: 1, limit: limit);
      if (generation != _availableGeneration) return;
      _availablePage = page.page;
      _availableHasMore = page.hasMore;
      availableState.value = Success(List.unmodifiable(page.items));
    } on ApiFailure catch (failure) {
      if (generation == _availableGeneration) {
        availableState.value = Failure(failure);
      }
    } finally {
      _loadingAvailable = false;
    }
  }

  Future<void> loadMoreAvailable() async {
    final current = availableState.value;
    if (_loadingAvailable ||
        !_availableHasMore ||
        current is! Success<List<DriverDelivery>>) {
      return;
    }
    _loadingAvailable = true;
    final generation = _availableGeneration;
    try {
      final page = await repository.available(
        page: _availablePage + 1,
        limit: limit,
      );
      if (generation != _availableGeneration) return;
      _availablePage = page.page;
      _availableHasMore = page.hasMore;
      availableState.value = Success(
        List.unmodifiable([...current.data, ...page.items]),
      );
    } on ApiFailure catch (failure) {
      if (generation == _availableGeneration) {
        availableState.value = Failure(failure);
      }
    } finally {
      _loadingAvailable = false;
    }
  }

  Future<void> loadMine() async {
    if (_loadingMine) return;
    final generation = ++_mineGeneration;
    _loadingMine = true;
    mineState.value = const Loading();
    _minePage = 0;
    _mineHasMore = true;
    try {
      final page = await repository.mine(
        status: statusFilter.value,
        page: 1,
        limit: limit,
      );
      if (generation != _mineGeneration) return;
      _minePage = page.page;
      _mineHasMore = page.hasMore;
      mineState.value = Success(List.unmodifiable(page.items));
    } on ApiFailure catch (failure) {
      if (generation == _mineGeneration) mineState.value = Failure(failure);
    } finally {
      _loadingMine = false;
    }
  }

  Future<void> loadMoreMine() async {
    final current = mineState.value;
    if (_loadingMine ||
        !_mineHasMore ||
        current is! Success<List<DriverDelivery>>) {
      return;
    }
    _loadingMine = true;
    final generation = _mineGeneration;
    try {
      final page = await repository.mine(
        status: statusFilter.value,
        page: _minePage + 1,
        limit: limit,
      );
      if (generation != _mineGeneration) return;
      _minePage = page.page;
      _mineHasMore = page.hasMore;
      mineState.value = Success(
        List.unmodifiable([...current.data, ...page.items]),
      );
    } on ApiFailure catch (failure) {
      if (generation == _mineGeneration) mineState.value = Failure(failure);
    } finally {
      _loadingMine = false;
    }
  }

  Future<void> setStatusFilter(DeliveryStatus? status) async {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    await loadMine();
  }

  Future<ApiFailure?> accept(int id) async {
    if (acceptingIds.contains(id)) return null;
    acceptingIds.add(id);
    try {
      await repository.accept(id);
      await refreshAll();
      return null;
    } on ApiFailure catch (failure) {
      if (failure.code == 'DELIVERY_ALREADY_ACTIVE' ||
          failure.code == 'DELIVERY_ALREADY_TAKEN' ||
          failure.status == 404) {
        await refreshAll();
      }
      return failure;
    } finally {
      acceptingIds.remove(id);
    }
  }

  Future<DriverDelivery?> reloadDelivery(int id) async {
    var page = await repository.mine(page: 1, limit: 100);
    while (true) {
      for (final item in page.items) {
        if (item.id == id) return item;
      }
      if (!page.hasMore) break;
      page = await repository.mine(page: page.page + 1, limit: 100);
    }
    page = await repository.available(page: 1, limit: 100);
    while (true) {
      for (final item in page.items) {
        if (item.id == id) return item;
      }
      if (!page.hasMore) break;
      page = await repository.available(page: page.page + 1, limit: 100);
    }
    await refreshAll();
    return null;
  }

  void _onDeliveryStatus(Map<String, dynamic> payload) {
    final id = payload['id'] is int
        ? payload['id'] as int
        : payload['deliveryId'] is int
        ? payload['deliveryId'] as int
        : null;
    if (id == null) return;
    final isMine = myDeliveries.any((delivery) => delivery.id == id);
    final isAvailable = availableDeliveries.any(
      (delivery) => delivery.id == id,
    );
    if (isMine || isAvailable) unawaited(refreshAll());
  }

  @override
  void onClose() {
    unawaited(_availableSubscription?.cancel());
    unawaited(_statusSubscription?.cancel());
    super.onClose();
  }
}
