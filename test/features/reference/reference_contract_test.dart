import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/reference/data/reference_api.dart';
import 'package:agri_connect/features/reference/data/reference_repository_impl.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';

import '../../support/fake_http_adapter.dart';

Map<String, dynamic> _zoneFixture() => jsonDecode(
  File('test/fixtures/api/reference_zones.json').readAsStringSync(),
) as Map<String, dynamic>;

void main() {
  test('reference zone fixture maps the real paginated item shape', () {
    final page = _zoneFixture();
    final zones = (page['items'] as List)
        .map(RefZone.fromJson)
        .toList(growable: false);

    expect(zones.map((zone) => zone.id), [2, 3]);
    expect(zones.first.displayName, 'Centre, Yaoundé');
    expect(page['page'], 1);
    expect(page['limit'], 100);
  });

  test('reference API fetchAll requests all pages with limit 100', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'reference/zones',
        FakeHttpResponse(
          statusCode: 200,
          data: {
            'items': [
              for (var id = 1; id <= 100; id++)
                {'id': id, 'name': 'Zone $id', 'city': null, 'region': null},
            ],
            'page': 1,
            'limit': 100,
            'total': 101,
          },
        ),
      )
      ..enqueue(
        'reference/zones',
        const FakeHttpResponse(
          statusCode: 200,
          data: {
            'items': [
              {'id': 101, 'name': 'Zone 101', 'city': null, 'region': null},
            ],
            'page': 2,
            'limit': 100,
            'total': 101,
          },
        ),
      );
    final client = ApiClient(
      baseUrl: 'https://example.test/api/v2',
      tokenStorage: InMemoryTokenStorage(),
      sessionEvents: SessionEvents(),
      dio: Dio(BaseOptions(baseUrl: 'https://example.test/api/v2'))
        ..httpClientAdapter = adapter,
    );

    final zones = await ReferenceApi(client).zones();

    expect(zones, hasLength(101));
    expect(adapter.callCounts['reference/zones'], 2);
    expect(adapter.requests.first.queryParameters['limit'], 100);
    expect(adapter.requests.last.queryParameters['page'], 2);
  });

  test('reference repository caches results until invalidated', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'reference/zones',
        FakeHttpResponse(statusCode: 200, data: _zoneFixture()),
      )
      ..enqueue(
        'reference/zones',
        FakeHttpResponse(statusCode: 200, data: _zoneFixture()),
      );
    final api = ReferenceApi(
      ApiClient(
        baseUrl: 'https://example.test/api/v2',
        tokenStorage: InMemoryTokenStorage(),
        sessionEvents: SessionEvents(),
        dio: Dio(BaseOptions(baseUrl: 'https://example.test/api/v2'))
          ..httpClientAdapter = adapter,
      ),
    );
    final repository = ReferenceRepositoryImpl(api);

    expect(await repository.zones(), hasLength(2));
    expect(await repository.zones(), hasLength(2));
    expect(adapter.callCounts['reference/zones'], 1);
    repository.invalidate();
    expect(await repository.zones(), hasLength(2));
    expect(adapter.callCounts['reference/zones'], 2);
  });
}
