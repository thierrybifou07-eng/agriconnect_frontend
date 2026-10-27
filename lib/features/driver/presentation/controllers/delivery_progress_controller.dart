import 'dart:async';

import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_repository.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';

class DeliveryProgressController extends GetxController {
  DeliveryProgressController({
    required this.delivery,
    required this.repository,
    required this.reloadDelivery,
    required this.refreshLists,
    required this.socketService,
  }) : state = Rx<UiState<DriverDelivery>>(Success(delivery));

  final DriverDelivery delivery;
  final DriverRepository repository;
  final Future<DriverDelivery?> Function(int id) reloadDelivery;
  final Future<void> Function() refreshLists;
  final SocketService socketService;
  final Rx<UiState<DriverDelivery>> state;
  final RxBool submitting = false.obs;
  final Rxn<ApiFailure> lastFailure = Rxn<ApiFailure>();
  StreamSubscription<Map<String, dynamic>>? _statusSubscription;

  DriverDelivery get current => switch (state.value) {
    Success<DriverDelivery>(:final data) => data,
    _ => delivery,
  };

  @override
  void onInit() {
    super.onInit();
    _statusSubscription = socketService.deliveryStatus.listen((payload) {
      final id = payload['id'] is int
          ? payload['id'] as int
          : payload['deliveryId'] is int
          ? payload['deliveryId'] as int
          : null;
      if (id == current.id) unawaited(reload());
    });
  }

  Future<void> reload() async {
    try {
      final refreshed = await reloadDelivery(current.id);
      if (refreshed != null) state.value = Success(refreshed);
      lastFailure.value = null;
    } on ApiFailure catch (failure) {
      lastFailure.value = failure;
    }
  }

  Future<ApiFailure?> advance() async {
    final next = current.status.driverNextStatus;
    if (next == null || submitting.value) return null;
    return _update(next);
  }

  Future<ApiFailure?> fail(String reason) async {
    final normalized = reason.trim();
    if (submitting.value) return null;
    if (normalized.isEmpty || normalized.length > 500) {
      return const ApiFailure(
        status: 400,
        code: 'INVALID_FAILURE_REASON',
        message:
            'A delivery failure reason is required (maximum 500 characters)',
        fieldErrors: {'failureReason': 'Required, maximum 500 characters'},
        kind: ApiFailureKind.client,
      );
    }
    if (current.status.canFail == false) return null;
    return _update(DeliveryStatus.failed, failureReason: normalized);
  }

  Future<ApiFailure?> _update(
    DeliveryStatus next, {
    String? failureReason,
  }) async {
    if (!_isAllowed(current.status, next)) {
      return const ApiFailure(
        status: 409,
        code: 'INVALID_STATE_TRANSITION',
        message: 'Invalid delivery status transition',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
    }
    submitting.value = true;
    lastFailure.value = null;
    try {
      state.value = Success(
        await repository.updateStatus(
          current.id,
          status: next,
          failureReason: failureReason,
        ),
      );
      await refreshLists();
      return null;
    } on ApiFailure catch (failure) {
      lastFailure.value = failure;
      if (failure.isStateConflict) {
        await reload();
      }
      return failure;
    } finally {
      submitting.value = false;
    }
  }

  static bool _isAllowed(DeliveryStatus from, DeliveryStatus to) =>
      from.driverNextStatus == to ||
      (from.canFail && to == DeliveryStatus.failed);

  @override
  void onClose() {
    unawaited(_statusSubscription?.cancel());
    super.onClose();
  }
}
