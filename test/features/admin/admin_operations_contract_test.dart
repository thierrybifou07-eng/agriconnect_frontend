import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/admin/data/admin_operations_api.dart';
import 'package:agri_connect/features/admin/domain/admin_operations.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_operations_controller.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';
import '../../support/fake_http_adapter.dart';

Object? _fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync());

void main() {
  test('admin referential, agency and compensation fixtures parse', () {
    final refPage = Paginated<AdminOperationRecord>.fromJson(
      _fixture('admin_referential_page.json') as Map<String, dynamic>,
      AdminOperationRecord.fromJson,
    );
    final agency = AdminOperationRecord.fromJson(_fixture('agency.json'));
    final compensation = Paginated<AdminOperationRecord>.fromJson(
      _fixture('compensations_admin_page.json') as Map<String, dynamic>,
      AdminOperationRecord.fromJson,
    );
    final payouts = Paginated<AdminOperationRecord>.fromJson(
      _fixture('payouts_page.json') as Map<String, dynamic>,
      AdminOperationRecord.fromJson,
    );

    expect(refPage.items.single['code'], 'FRUITS');
    expect(agency['insuranceExpiresAt'], '2026-11-15T00:00:00.000Z');
    expect(
      compensation.items.single['supplier'],
      containsPair('farmName', 'Ferme Exemple'),
    );
    expect(payouts.total, 0);
  });

  test(
    'admin endpoints preserve pagination, filters and coverage request body',
    () async {
      final adapter = FakeHttpAdapter()
        ..enqueue(
          'admin/categories',
          FakeHttpResponse(
            statusCode: 200,
            data: _fixture('admin_referential_page.json'),
          ),
        )
        ..enqueue(
          'admin/units',
          const FakeHttpResponse(
            statusCode: 200,
            data: {'items': [], 'page': 1, 'limit': 20, 'total': 0},
          ),
        )
        ..enqueue(
          'admin/agencies/18/zones/4',
          const FakeHttpResponse(statusCode: 200, data: {}),
        )
        ..enqueue(
          'admin/payouts/12/pay',
          const FakeHttpResponse(statusCode: 200, data: {}),
        );
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v2/'))
        ..httpClientAdapter = adapter;
      final client = ApiClient(
        tokenStorage: InMemoryTokenStorage(),
        sessionEvents: SessionEvents(),
        dio: dio,
      );
      final api = AdminOperationsApi(client);

      final categories = await api.referentials(
        'categories',
        page: 1,
        limit: 20,
        active: true,
      );
      await api.referentials('units', page: 1, limit: 20, active: false);
      await api.saveAgencyZone(18, 4, {'baseFee': 150.25, 'perKmFee': 22.75});
      await api.payout(12, {
        'reference': 'BANK-2026-101',
        'payoutAccountId': 7,
      });

      expect(categories.items.single.id, 31);
      final categoriesRequest = adapter.requests[0];
      expect(categoriesRequest.uri.queryParameters['active'], 'true');
      expect(categoriesRequest.uri.queryParameters['page'], '1');
      final unitsRequest = adapter.requests[1];
      expect(unitsRequest.uri.queryParameters.containsKey('active'), isFalse);
      expect(adapter.requests[2].method, 'PUT');
      expect(adapter.requests[2].data, {'baseFee': 150.25, 'perKmFee': 22.75});
      expect(adapter.requests[3].method, 'PATCH');
      expect(adapter.requests[3].data, {
        'reference': 'BANK-2026-101',
        'payoutAccountId': 7,
      });
    },
  );

  test(
    'referential validation, coverage payload and cache invalidation',
    () async {
      final repository = _OperationsRepository();
      final references = _References();
      final controller = AdminOperationsController(
        repository: repository,
        references: references,
      );
      expect(
        validateAdminReferential('categories', {
          'code': 'fruit',
          'label': 'Fruit',
        }),
        'code',
      );
      expect(
        await controller.saveReferential(
          id: 31,
          values: {'code': 'FRUITS', 'label': 'Fruits'},
        ),
        isTrue,
      );
      expect(repository.savedReferentialId, 31);
      expect(references.invalidations, 1);
      expect(await controller.saveCoverage(18, 4, 150.25, 22.75), isTrue);
      expect(repository.coverageBody, {'baseFee': 150.25, 'perKmFee': 22.75});
      expect(await controller.payPayout(12, '  '), isFalse);
      expect(repository.payoutCalls, 0);
    },
  );

  test('publishing a legal draft reloads after HTTP 409', () async {
    final repository = _OperationsRepository()
      ..publishFailure = const ApiFailure(
        status: 409,
        code: 'INVALID_STATE_TRANSITION',
        message: 'Already published',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
    final controller = AdminOperationsController(
      repository: repository,
      references: _References(),
    );
    expect(
      await controller.createLegalVersion(
        'CGU',
        '2.0',
        'Conditions',
        'Texte français',
        '',
        '',
      ),
      isTrue,
    );
    expect(await controller.publishLegal(90), isFalse);
    expect(repository.publishCalls, 1);
    expect(repository.legalLoads, 1);
  });
}

class _OperationsRepository implements AdminOperationsRepository {
  int? savedReferentialId;
  Map<String, Object?>? coverageBody;
  int payoutCalls = 0;
  int publishCalls = 0;
  int legalLoads = 0;
  ApiFailure? publishFailure;

  @override
  Future<Paginated<AdminOperationRecord>> referentials(
    String kind, {
    required int page,
    required int limit,
    bool? active,
  }) async => const Paginated(items: [], page: 1, limit: 20, total: 0);

  @override
  Future<void> saveReferential(
    String kind,
    int? id,
    Map<String, Object?> body,
  ) async {
    savedReferentialId = id;
  }

  @override
  Future<Paginated<AdminOperationRecord>> agencies({
    required int page,
    required int limit,
  }) async => const Paginated(items: [], page: 1, limit: 20, total: 0);

  @override
  Future<void> saveAgency(int? id, Map<String, Object?> body) async {}

  @override
  Future<void> saveAgencyZone(
    int agencyId,
    int zoneId,
    Map<String, Object?> body,
  ) async {
    coverageBody = body;
  }

  @override
  Future<void> removeAgencyZone(int agencyId, int zoneId) async {}

  @override
  Future<List<AdminOperationRecord>> agencyDrivers(int agencyId) async => [];

  @override
  Future<Paginated<AdminOperationRecord>> moneyRecords(
    String kind, {
    required int page,
    required int limit,
    String? status,
  }) async => const Paginated(items: [], page: 1, limit: 20, total: 0);

  @override
  Future<void> payout(int id, Map<String, Object?> body) async {
    payoutCalls++;
  }

  @override
  Future<void> referralAction(
    int id,
    String action,
    Map<String, Object?> body,
  ) async {}

  @override
  Future<void> compensationAction(
    int id,
    String action,
    Map<String, Object?> body,
  ) async {}

  @override
  Future<List<AdminLegalDocument>> publishedLegal() async {
    legalLoads++;
    return const [];
  }

  @override
  Future<AdminLegalDocument> createLegalVersion(
    String code,
    Map<String, Object?> body,
  ) async => const AdminLegalDocument(
    id: 90,
    code: 'CGU',
    version: '2.0',
    status: 'DRAFT',
  );

  @override
  Future<void> publishLegalVersion(int id) async {
    publishCalls++;
    if (publishFailure != null) {
      throw ApiFailure(
        status: publishFailure!.status,
        code: publishFailure!.code,
        message: publishFailure!.message,
        fieldErrors: publishFailure!.fieldErrors,
        kind: publishFailure!.kind,
      );
    }
  }
}

class _References implements ReferenceRepository {
  int invalidations = 0;

  @override
  void invalidate() => invalidations++;

  @override
  Future<List<RefCategory>> categories({bool forceRefresh = false}) async => [];
  @override
  Future<List<RefUnit>> units({bool forceRefresh = false}) async => [];
  @override
  Future<List<RefProduct>> products({
    String? q,
    int? categoryId,
    bool forceRefresh = false,
  }) async => [];
  @override
  Future<List<RefZone>> zones({bool forceRefresh = false}) async => [];
  @override
  Future<List<RefHub>> hubs({int? zoneId, bool forceRefresh = false}) async =>
      [];
}
