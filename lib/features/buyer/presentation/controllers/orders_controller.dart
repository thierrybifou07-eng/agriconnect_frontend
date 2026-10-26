import 'dart:async';

import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/ui/paginated_controller.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/domain/buyer_repository.dart';
import 'package:agri_connect/shared/domain/order_status.dart';

class BuyerOrdersController extends PaginatedController<BuyerOrder> {
  BuyerOrdersController({required this.repository, required this.socketService})
    : super(limit: 100);

  final OrdersRepository repository;
  final SocketService socketService;
  final RxInt quotedCount = 0.obs;
  final Rx<UiState<int>> quotedCountState = Rx<UiState<int>>(const Idle());
  StreamSubscription<Map<String, dynamic>>? _deliverySubscription;

  @override
  void onInit() {
    super.onInit();
    _deliverySubscription = socketService.deliveryStatus.listen((_) {
      final current = state.value;
      if (current is Success<List<BuyerOrder>> &&
          current.data.any(
            (order) => order.status == OrderStatus.outForDelivery,
          )) {
        unawaited(loadFirst());
      }
    });
    unawaited(loadFirst());
  }

  @override
  Future<Paginated<BuyerOrder>> fetch(int page, int limit) =>
      repository.orders(page: page, limit: limit);

  @override
  Future<void> loadFirst() async {
    await super.loadFirst();
    final current = state.value;
    if (current is Success<List<BuyerOrder>>) {
      unawaited(_loadQuotedCount());
    }
  }

  Future<void> _loadQuotedCount() async {
    quotedCountState.value = const Loading();
    try {
      var page = await repository.orders(page: 1, limit: 100);
      var count = page.items
          .where((order) => order.status == OrderStatus.quoted)
          .length;
      var nextPage = 2;
      while (page.hasMore) {
        page = await repository.orders(page: nextPage++, limit: 100);
        count += page.items
            .where((order) => order.status == OrderStatus.quoted)
            .length;
      }
      quotedCount.value = count;
      quotedCountState.value = Success(count);
    } on ApiFailure catch (failure) {
      quotedCountState.value = Failure(failure);
    }
  }

  Future<void> refreshFromDetail() async {
    await loadFirst();
  }

  @override
  void onClose() {
    unawaited(_deliverySubscription?.cancel());
    super.onClose();
  }
}

class BuyerOrderDetailController extends GetxController {
  BuyerOrderDetailController({
    required this.id,
    required this.repository,
    required this.refreshOrders,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final int id;
  final OrdersRepository repository;
  final Future<void> Function() refreshOrders;
  final DateTime Function() _clock;
  final Rx<UiState<BuyerOrder>> state = Rx<UiState<BuyerOrder>>(const Idle());
  final RxString countdown = ''.obs;
  final RxBool expired = false.obs;
  final RxBool submitting = false.obs;
  Timer? _timer;
  bool _expirationReloadStarted = false;

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    state.value = const Loading();
    try {
      state.value = Success(await repository.order(id));
      _updateCountdown();
      _timer ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) => _updateCountdown(),
      );
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }

  Future<ApiFailure?> confirm() async {
    final order = _currentOrder;
    if (order == null || submitting.value) return null;
    submitting.value = true;
    try {
      state.value = Success(await repository.confirm(id));
      await refreshOrders();
      return null;
    } on ApiFailure catch (failure) {
      if (failure.isStateConflict) await load();
      return failure;
    } finally {
      submitting.value = false;
    }
  }

  Future<ApiFailure?> cancel({String? reason}) async {
    final order = _currentOrder;
    if (order == null || submitting.value) return null;
    submitting.value = true;
    try {
      state.value = Success(await repository.cancel(id, reason: reason));
      await refreshOrders();
      return null;
    } on ApiFailure catch (failure) {
      if (failure.isStateConflict) await load();
      return failure;
    } finally {
      submitting.value = false;
    }
  }

  BuyerOrder? get _currentOrder {
    final current = state.value;
    return current is Success<BuyerOrder> ? current.data : null;
  }

  void refreshCountdown() => _updateCountdown();

  void _updateCountdown() {
    final reservedUntil = _currentOrder?.reservedUntil;
    if (reservedUntil == null) return;
    final remaining = reservedUntil.difference(_clock());
    if (remaining.isNegative || remaining.inSeconds == 0) {
      countdown.value = '00:00';
      expired.value = true;
      if (!_expirationReloadStarted) {
        _expirationReloadStarted = true;
        unawaited(load());
      }
      return;
    }
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    countdown.value = hours > 0
        ? '${hours}h ${minutes.toString().padLeft(2, '0')}'
        : '${minutes}m ${(remaining.inSeconds % 60).toString().padLeft(2, '0')}s';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
