import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/api_failure_events.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_repository.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_controllers.dart';
import '../auth/fake_auth_repository.dart';
import '../../support/fake_realtime_transport.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  late FakeStaffRepository repository;
  late StaffInboxController inbox;
  late StaffLotsController lots;
  late StaffListingsController listings;

  setUp(() {
    repository = FakeStaffRepository();
    final storage = InMemoryTokenStorage();
    final events = SessionEvents();
    final client = ApiClient(
      tokenStorage: storage,
      sessionEvents: events,
      failureEvents: ApiFailureEvents(),
      baseUrl: 'http://localhost/api/v2',
      dio: Dio(BaseOptions(baseUrl: 'http://localhost/api/v2')),
    );
    final socket = SocketService(
      authController: AuthController(
        tokenStorage: storage,
        sessionEvents: events,
        repository: FakeAuthRepository(),
      ),
      apiClient: client,
      tokenStorage: storage,
      transport: FakeTransport(),
    );
    inbox = StaffInboxController(repository: repository, socket: socket);
    lots = StaffLotsController(repository: repository);
    listings = StaffListingsController(repository: repository);
  });

  test('inbox filters are passed through to the repository', () async {
    await inbox.setFilter('escalated');
    await inbox.setStatus('OPEN');
    expect(repository.conversationQueries.last, {
      'status': 'OPEN',
      'escalated': true,
    });
    await inbox.setFilter('unassigned');
    expect(repository.conversationQueries.last['unassigned'], isTrue);
    await inbox.setFilter('mine');
    expect(repository.conversationQueries.last['mine'], isTrue);
  });

  test(
    'public and internal messages preserve the selected visibility',
    () async {
      await inbox.open(42);
      inbox.internalNote.value = false;
      expect(await inbox.send('Public reply'), isTrue);
      inbox.internalNote.value = true;
      expect(await inbox.send('Internal note'), isTrue);
      expect(repository.sentInternalFlags, [false, true]);
    },
  );

  test(
    'assign, escalate, and close actions call their matching operations',
    () async {
      await inbox.open(42);
      await inbox.assign();
      await inbox.escalate('Needs supervisor');
      await inbox.closeConversation();
      expect(repository.assignCalls, 1);
      expect(repository.escalationReasons, ['Needs supervisor']);
      expect(repository.closeCalls, 1);
    },
  );

  test('lot validation surfaces the NOT_VERIFIED conflict', () async {
    repository.validateFailure = _failure('NOT_VERIFIED');
    await lots.open(1);
    expect((await lots.validate())?.code, 'NOT_VERIFIED');
  });

  test('listing publication surfaces a lot availability conflict', () async {
    repository.publishFailure = _failure('LOT_NOT_AVAILABLE');
    expect(
      (await listings.changePublication(
        StaffListing.fromJson(fixture('staff_listing.json')),
      ))?.code,
      'LOT_NOT_AVAILABLE',
    );
  });
}

ApiFailure _failure(String code) => ApiFailure(
  status: 409,
  code: code,
  message: code,
  fieldErrors: const {},
  kind: ApiFailureKind.client,
);

class FakeStaffRepository implements StaffRepository {
  final List<Map<String, Object?>> conversationQueries = [];
  final List<bool> sentInternalFlags = [];
  final List<String> escalationReasons = [];
  int assignCalls = 0;
  int closeCalls = 0;
  ApiFailure? validateFailure;
  ApiFailure? publishFailure;

  @override
  Future<Paginated<StaffConversation>> conversations({
    int page = 1,
    int limit = 20,
    String? status,
    bool? unassigned,
    bool? mine,
    bool? escalated,
  }) async {
    final query = <String, Object?>{};
    if (status != null) query['status'] = status;
    if (unassigned != null) query['unassigned'] = unassigned;
    if (mine != null) query['mine'] = mine;
    if (escalated != null) query['escalated'] = escalated;
    conversationQueries.add(query);
    return Paginated(items: const [], page: page, limit: limit, total: 0);
  }

  @override
  Future<StaffConversation> conversation(int id) async =>
      StaffConversation.fromJson(
        fixture('staff_conversations_page.json')['items'][0],
      );

  @override
  Future<Paginated<StaffMessage>> messages(int id, int page, int limit) async =>
      Paginated(items: const [], page: page, limit: limit, total: 0);

  @override
  Future<StaffMessage> sendMessage(
    int id,
    String content,
    bool isInternal,
  ) async {
    sentInternalFlags.add(isInternal);
    return StaffMessage(
      id: sentInternalFlags.length,
      conversationId: id,
      senderType: 'AGENT',
      content: content,
      isInternal: isInternal,
      createdAt: DateTime.utc(2026),
    );
  }

  @override
  Future<void> assign(int id, {int? agentId}) async {
    assignCalls++;
  }

  @override
  Future<void> escalate(int id, String reason) async =>
      escalationReasons.add(reason);
  @override
  Future<void> closeConversation(int id) async {
    closeCalls++;
  }

  @override
  Future<Paginated<StaffLot>> lots({
    int page = 1,
    int limit = 20,
    String? status,
    int? supplierId,
    int? productId,
  }) async => Paginated(items: const [], page: page, limit: limit, total: 0);

  @override
  Future<StaffLot> lot(int id) async =>
      StaffLot.fromJson(fixture('staff_lot.json'));
  @override
  Future<void> validateLot(int id) async {
    if (validateFailure != null) throw validateFailure!;
  }

  @override
  Future<void> rejectLot(int id, String reason) async {}
  @override
  Future<void> returnLot(int id, String reason) async {}
  @override
  Future<void> qualityCheck(int id, String grade, String? notes) async {}
  @override
  Future<List<Map<String, Object?>>> qualityChecks(int id) async => const [];
  @override
  Future<Paginated<Map<String, Object?>>> stockMovements(
    int lotId, {
    int page = 1,
    int limit = 20,
  }) async => Paginated(items: const [], page: page, limit: limit, total: 0);

  @override
  Future<Paginated<StaffListing>> listings({
    int page = 1,
    int limit = 20,
    String? status,
    int? productId,
    int? supplierId,
  }) async => Paginated(items: const [], page: page, limit: limit, total: 0);
  @override
  Future<StaffListing> listing(int id) async =>
      StaffListing.fromJson(fixture('staff_listing.json'));
  @override
  Future<StaffListing> createListing(
    int lotId,
    String title,
    String? description,
    List<String> imagePaths,
  ) async => listing(0);
  @override
  Future<StaffListing> updateListing(
    int id,
    Map<String, Object?> fields,
  ) async => listing(id);
  @override
  Future<void> publishListing(int id) async {
    if (publishFailure != null) throw publishFailure!;
  }

  @override
  Future<void> unpublishListing(int id) async {}
}
