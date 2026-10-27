import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/presentation/controllers/delivery_progress_controller.dart';
import 'package:agri_connect/features/driver/presentation/controllers/driver_controller.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';
import '../../support/fake_realtime_transport.dart';
import '../../support/get_test_harness.dart';
import '../auth/fake_auth_repository.dart';
import 'fake_driver_repository.dart';

void main() {
  setupGetTestHarness();

  test('accept success refreshes the available and assigned lists', () async {
    final repository = FakeDriverRepository(delivery: _delivery());
    final controller = DriverController(
      repository: repository,
      socketService: _StubSocketService(),
    );

    expect(await controller.accept(37), isNull);
    expect(repository.accepts, 1);
    expect(repository.availableRequests, isNotEmpty);
    expect(repository.mineRequests, isNotEmpty);
    controller.onClose();
  });

  test(
    'accept reports active-course conflict and refreshes the pool',
    () async {
      final repository = FakeDriverRepository(delivery: _delivery())
        ..acceptFailure = _failure('DELIVERY_ALREADY_ACTIVE', status: 409);
      final controller = DriverController(
        repository: repository,
        socketService: _StubSocketService(),
      );

      expect((await controller.accept(37))?.code, 'DELIVERY_ALREADY_ACTIVE');
      expect(repository.availableRequests, isNotEmpty);
      expect(repository.mineRequests, isNotEmpty);
      controller.onClose();
    },
  );

  test('accept refreshes after a taken 409 or 404', () async {
    for (final failure in [
      _failure('DELIVERY_ALREADY_TAKEN', status: 409),
      _failure(null, status: 404),
    ]) {
      final repository = FakeDriverRepository(delivery: _delivery())
        ..acceptFailure = failure;
      final controller = DriverController(
        repository: repository,
        socketService: _StubSocketService(),
      );

      expect(await controller.accept(37), same(failure));
      expect(repository.availableRequests, isNotEmpty);
      controller.onClose();
    }
  });

  test(
    'progress accepts only next transitions and requires failure reason',
    () async {
      final repository = FakeDriverRepository(
        delivery: _delivery(status: DeliveryStatus.accepted),
      );
      final progress = DeliveryProgressController(
        delivery: _delivery(status: DeliveryStatus.accepted),
        repository: repository,
        reloadDelivery: (_) async => null,
        refreshLists: () async {},
        socketService: _StubSocketService(),
      );

      expect(await progress.fail('  '), isNotNull);
      expect(repository.updates, isEmpty);
      expect(await progress.advance(), isNull);
      expect(repository.updates.single.$2, DeliveryStatus.pickedUp);
      expect(await progress.advance(), isNull);
      expect(repository.updates.last.$2, DeliveryStatus.inTransit);
      expect(await progress.advance(), isNull);
      expect(repository.updates.last.$2, DeliveryStatus.delivered);
      expect(await progress.advance(), isNull);
      expect(repository.updates, hasLength(3));
      progress.onClose();
    },
  );

  test('failure transition submits a trimmed required reason', () async {
    final repository = FakeDriverRepository(
      delivery: _delivery(status: DeliveryStatus.pickedUp),
    );
    final progress = DeliveryProgressController(
      delivery: _delivery(status: DeliveryStatus.pickedUp),
      repository: repository,
      reloadDelivery: (_) async => null,
      refreshLists: () async {},
      socketService: _StubSocketService(),
    );

    expect(await progress.fail('Road closed'), isNull);
    expect(repository.updates.single.$2, DeliveryStatus.failed);
    expect(repository.updates.single.$3, 'Road closed');
    progress.onClose();
  });

  test(
    'socket events refresh only the driver delivery lists they concern',
    () async {
      final transport = FakeTransport();
      final tokens = InMemoryTokenStorage();
      await tokens.save(access: 'access', refresh: 'refresh');
      final sessionEvents = SessionEvents();
      final authRepository = FakeAuthRepository();
      final auth = Get.put(
        AuthController(
          tokenStorage: tokens,
          sessionEvents: sessionEvents,
          repository: authRepository,
        ),
      );
      auth.setUser(authRepository.user);
      final api = ApiClient(
        tokenStorage: tokens,
        sessionEvents: sessionEvents,
        baseUrl: 'https://example.test/api/v2',
        refreshDioFactory: Dio.new,
      );
      final socket = Get.put(
        SocketService(
          authController: auth,
          apiClient: api,
          tokenStorage: tokens,
          transport: transport,
        ),
      );
      final repository = FakeDriverRepository(
        delivery: _delivery(status: DeliveryStatus.accepted),
      );
      final controller = DriverController(
        repository: repository,
        socketService: socket,
      )..onInit();

      await _until(() => repository.availableRequests.isNotEmpty);
      final availableCalls = repository.availableRequests.length;
      transport.fire('delivery:available', {'id': 99});
      await _until(() => repository.availableRequests.length > availableCalls);

      final mineCalls = repository.mineRequests.length;
      transport.fire('delivery:status', {'id': 37});
      await _until(() => repository.mineRequests.length > mineCalls);

      controller.onClose();
      socket.onClose();
      auth.onClose();
    },
  );
}

DriverDelivery _delivery({DeliveryStatus status = DeliveryStatus.pending}) =>
    DriverDelivery(
      id: 37,
      status: status,
      pickupAddress: 'Pickup',
      pickupLatitude: 3.8,
      pickupLongitude: 11.5,
      dropoffAddress: 'Dropoff',
      dropoffLatitude: 3.9,
      dropoffLongitude: 11.6,
      distanceKm: 4.8,
      buyer: null,
      items: const [],
    );

ApiFailure _failure(String? code, {required int status}) => ApiFailure(
  status: status,
  code: code,
  message: 'Failure',
  fieldErrors: const {},
  kind: ApiFailureKind.client,
);

Future<void> _until(bool Function() condition) async {
  for (var i = 0; i < 50 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  expect(condition(), isTrue);
}

class _StubSocketService implements SocketService {
  @override
  Stream<Map<String, dynamic>> get deliveryAvailable =>
      const Stream<Map<String, dynamic>>.empty();

  @override
  Stream<Map<String, dynamic>> get deliveryStatus =>
      const Stream<Map<String, dynamic>>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
