import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';
import 'package:agri_connect/features/staff/data/staff_workflow_api.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_repository.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_repository.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_quote_controller.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_workflow_controllers.dart';
import 'package:agri_connect/shared/domain/order_status.dart';

import '../../support/fake_http_adapter.dart';
import '../../support/get_test_harness.dart';

Object? fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync());

void main() {
  setupGetTestHarness();

  test(
    'manual status transition truth table never permits manual delivery',
    () {
      expect(StaffOrdersController.manualTransitions[OrderStatus.quoted], {
        OrderStatus.confirmed,
        OrderStatus.cancelled,
      });
      expect(StaffOrdersController.manualTransitions[OrderStatus.confirmed], {
        OrderStatus.preparing,
        OrderStatus.cancelled,
      });
      expect(StaffOrdersController.manualTransitions[OrderStatus.preparing], {
        OrderStatus.readyForPickup,
        OrderStatus.cancelled,
      });
      expect(
        StaffOrdersController.manualTransitions[OrderStatus.readyForPickup],
        {OrderStatus.completed},
      );
      expect(
        StaffOrdersController.manualTransitions[OrderStatus.outForDelivery],
        {OrderStatus.completed},
      );
      for (final status in OrderStatus.values) {
        expect(
          StaffOrdersController.canTransition(
            status,
            OrderStatus.outForDelivery,
          ),
          isFalse,
        );
      }
    },
  );

  test('quote body distinguishes hub pickup from agency delivery', () {
    final repository = _WorkflowRepository();
    final orders = _ordersController(repository);
    final quote = StaffQuoteController(
      buyerId: 12,
      conversationId: 44,
      ordersController: orders,
      referenceRepository: _NoopReferenceRepository(),
    );
    final line = QuoteLineDraft()
      ..listing.value = _activeListing()
      ..quantity.text = '1.5';
    quote.lines.add(line);
    quote.pickupHub.value = const RefHub(
      id: 8,
      name: 'Centre',
      zoneId: 2,
      acceptsDropoff: false,
      acceptsPickup: true,
    );
    final pickupBody = quote.buildBody()!;
    expect(pickupBody['buyerId'], 12);
    expect(pickupBody['conversationId'], 44);
    expect(pickupBody['deliveryMode'], 'HUB_PICKUP');
    expect(pickupBody['pickupHubId'], 8);
    expect(pickupBody.containsKey('delivery'), isFalse);
    expect(pickupBody.containsKey('force'), isFalse);
    expect(pickupBody['items'], [
      {'listingId': 51, 'quantity': 1.5},
    ]);

    quote.deliveryMode.value = 'AGENCY_DELIVERY';
    quote.zone.value = const RefZone(id: 3, name: 'Centre');
    quote.address.text = 'Marché central';
    quote.latitude.text = '3.87';
    quote.longitude.text = '11.53';
    final agencyBody = quote.buildBody()!;
    expect(agencyBody.containsKey('pickupHubId'), isFalse);
    expect(agencyBody['deliveryMode'], 'AGENCY_DELIVERY');
    expect(agencyBody['delivery'], {
      'zoneId': 3,
      'address': 'Marché central',
      'latitude': 3.87,
      'longitude': 11.53,
    });
    quote.onClose();
  });

  test('payment retries retain network key and success clears it', () async {
    final repository = _WorkflowRepository()
      ..paymentFailure = const ApiFailure(
        status: null,
        code: null,
        message: 'offline',
        fieldErrors: {},
        kind: ApiFailureKind.network,
      );
    final controller = _ordersController(repository);
    final firstKey = controller.paymentIdempotencyKey;

    expect(
      (await controller.recordPayment(73, amount: 10, method: 'CASH'))?.kind,
      ApiFailureKind.network,
    );
    expect(controller.paymentIdempotencyKey, firstKey);

    repository.paymentFailure = null;
    expect(
      await controller.recordPayment(73, amount: 10, method: 'CASH'),
      isNull,
    );
    expect(repository.paymentKeys, [firstKey, firstKey]);
    expect(controller.paymentIdempotencyKey, isNot(firstKey));
  });

  test('agent cannot see refund; admin can; AI payment access is disabled', () {
    final repository = _WorkflowRepository();
    final agent = StaffOrdersController(
      repository: repository,
      staffRepository: _NoopStaffRepository(),
      referenceRepository: _NoopReferenceRepository(),
      user: _agentUser(),
    );
    final aiAgent = StaffOrdersController(
      repository: repository,
      staffRepository: _NoopStaffRepository(),
      referenceRepository: _NoopReferenceRepository(),
      user: _agentUser(kind: 'AI'),
    );
    final admin = StaffOrdersController(
      repository: repository,
      staffRepository: _NoopStaffRepository(),
      referenceRepository: _NoopReferenceRepository(),
      user: const AuthUser(role: RoleCode.admin),
    );

    expect(agent.canRefund, isFalse);
    expect(aiAgent.canFollowPayments, isFalse);
    expect(admin.canRefund, isTrue);
  });

  test('REJECT without note is stopped before calling API', () async {
    final repository = _WorkflowRepository();
    final controller = StaffVerificationsController(repository: repository);
    final failure = await controller.decide(decision: 'REJECT');
    expect(failure?.code, 'INVALID_DECISION_NOTE');
    expect(repository.decisionCalls, 0);
  });

  test(
    'private verification bytes request uses authenticated ApiClient',
    () async {
      final adapter = FakeHttpAdapter()
        ..enqueue(
          'admin/files/private-token',
          const FakeHttpResponse(statusCode: 200, data: {'file': 'bytes'}),
        );
      final storage = InMemoryTokenStorage();
      await storage.save(
        access: 'reviewer-access',
        refresh: 'reviewer-refresh',
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v2'))
        ..httpClientAdapter = adapter;
      final client = ApiClient(
        baseUrl: 'https://example.test/api/v2',
        tokenStorage: storage,
        sessionEvents: SessionEvents(),
        dio: dio,
        refreshDioFactory: (options) =>
            Dio(options)..httpClientAdapter = adapter,
      );

      await StaffWorkflowApi(client)
          .verificationBytes('admin/files/private-token');

      expect(adapter.requests.single.headers['Authorization'], isNotNull);
      expect(adapter.requests.single.path, 'admin/files/private-token');
    },
  );
}

StaffOrdersController _ordersController(_WorkflowRepository repository) =>
    StaffOrdersController(
      repository: repository,
      staffRepository: _NoopStaffRepository(),
      referenceRepository: _NoopReferenceRepository(),
      user: const AuthUser(role: RoleCode.admin),
    );

StaffListing _activeListing() => StaffListing.fromJson({
  ...(fixture('staff_listing.json')! as Map<String, Object?>),
  'status': 'ACTIVE',
});

AuthUser _agentUser({String? kind}) => AuthUser(
  role: RoleCode.agent,
  agent: AgentInfo(
    kind: kind,
    capabilities: {
      AgentCapability.orderProcessing,
      AgentCapability.paymentFollowup,
    },
  ),
);

class _WorkflowRepository implements StaffWorkflowRepository {
  ApiFailure? paymentFailure;
  final paymentKeys = <String>[];
  int decisionCalls = 0;

  @override
  Future<Paginated<StaffOrder>> orders({int page = 1, int limit = 20}) async =>
      Paginated(items: const [], page: page, limit: limit, total: 0);

  @override
  Future<StaffOrder> order(int id) async =>
      StaffOrder.fromJson(fixture('staff_order.json'));

  @override
  Future<List<StaffPayment>> payments(int orderId) async => const [];

  @override
  Future<Paginated<StaffDelivery>> deliveries({
    int page = 1,
    int limit = 20,
    String? status,
    int? orderId,
  }) async => Paginated(items: const [], page: page, limit: limit, total: 0);

  @override
  Future<void> recordPayment(
    int orderId,
    Map<String, Object?> body,
    String idempotencyKey,
  ) async {
    paymentKeys.add(idempotencyKey);
    if (paymentFailure != null) throw paymentFailure!;
  }

  @override
  Future<void> decideVerification(
    int id, {
    required String decision,
    String? note,
  }) async {
    decisionCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopStaffRepository implements StaffRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopReferenceRepository implements ReferenceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
