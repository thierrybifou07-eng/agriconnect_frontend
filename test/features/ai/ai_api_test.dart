import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/ai/data/ai_api.dart';
import '../../support/fake_http_adapter.dart';

dynamic fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync());

void main() {
  test('approve sends the editedContent body exactly', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'staff/ai/suggestions/31/approve',
        FakeHttpResponse(
          statusCode: 200,
          data: fixture('ai_suggestion_ready.json'),
        ),
      );
    final api = AiApi(_client(adapter));

    await api.approve(31, editedContent: 'Texte relu et corrigé.');

    expect(adapter.requests.single.data, {
      'editedContent': 'Texte relu et corrigé.',
    });
  });

  test('reject trims an optional reason and omits an empty reason', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'staff/ai/suggestions/31/reject',
        FakeHttpResponse(
          statusCode: 200,
          data: fixture('ai_suggestion_ready.json'),
        ),
      )
      ..enqueue(
        'staff/ai/suggestions/32/reject',
        FakeHttpResponse(
          statusCode: 200,
          data: fixture('ai_suggestion_ready.json'),
        ),
      );
    final api = AiApi(_client(adapter));

    await api.reject(31, reason: '  Hors sujet  ');
    await api.reject(32, reason: '  ');

    expect(adapter.requests[0].data, {'reason': 'Hors sujet'});
    expect(adapter.requests[1].data, isEmpty);
  });

  test(
    'suggestion filters are sent using the documented query names',
    () async {
      final adapter = FakeHttpAdapter()
        ..enqueue(
          'staff/ai/suggestions',
          const FakeHttpResponse(
            statusCode: 200,
            data: {'items': [], 'page': 2, 'limit': 20, 'total': 0},
          ),
        );
      final api = AiApi(_client(adapter));

      await api.suggestions(
        page: 2,
        limit: 20,
        status: 'PENDING',
        kind: 'REPLY',
        conversationId: 18,
      );

      expect(adapter.requests.single.queryParameters, {
        'page': 2,
        'limit': 20,
        'status': 'PENDING',
        'kind': 'REPLY',
        'conversationId': 18,
      });
    },
  );
}

ApiClient _client(FakeHttpAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test/api/v2'))
    ..httpClientAdapter = adapter;
  return ApiClient(
    tokenStorage: InMemoryTokenStorage(),
    sessionEvents: SessionEvents(),
    baseUrl: 'http://example.test/api/v2',
    dio: dio,
  );
}
