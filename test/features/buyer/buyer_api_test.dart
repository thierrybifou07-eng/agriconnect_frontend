import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/buyer/data/catalog_api.dart';
import 'package:agri_connect/features/chat/data/chat_api.dart';
import '../../support/fake_http_adapter.dart';

void main() {
  test('catalog sends only documented filters and never productId', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'catalog/listings',
        const FakeHttpResponse(
          statusCode: 200,
          data: {'items': [], 'page': 1, 'limit': 20, 'total': 0},
        ),
      );
    final api = CatalogApi(_client(adapter));

    await api.listings(
      categoryId: 8,
      zoneId: 5,
      query: 'maïs',
      sort: 'expiry',
      page: 1,
      limit: 20,
    );

    expect(adapter.requests.single.queryParameters, {
      'page': 1,
      'limit': 20,
      'categoryId': 8,
      'zoneId': 5,
      'q': 'maïs',
      'sort': 'expiry',
    });
    expect(
      adapter.requests.single.queryParameters.containsKey('productId'),
      isFalse,
    );
  });

  test('categories reads the backend value and Count wrapper', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'catalog/categories',
        const FakeHttpResponse(
          statusCode: 200,
          data: {
            'value': [
              {'id': 4, 'code': 'CEREALS', 'label': 'Céréales'},
            ],
            'Count': 1,
          },
        ),
      );
    final api = CatalogApi(_client(adapter));

    final categories = await api.categories();

    expect(categories.single.id, 4);
    expect(categories.single.label, 'Céréales');
  });

  test(
    'quote request opens buyer conversation with listingId and content',
    () async {
      final adapter = FakeHttpAdapter()
        ..enqueue(
          'conversations',
          const FakeHttpResponse(
            statusCode: 201,
            data: {
              'id': 55,
              'type': 'BUYER_SUPPORT',
              'status': 'OPEN',
              'subject': null,
              'listingId': 1,
              'escalatedAt': null,
              'lastMessageAt': '2026-12-20T10:00:00.000Z',
              'createdAt': '2026-12-20T10:00:00.000Z',
            },
          ),
        );
      final api = ChatApi(_client(adapter));

      await api.openConversation(
        listingId: 1,
        content: 'Bonjour, je souhaite 10 kg de « Riz local » (ANN-1).',
      );

      expect(adapter.requests.single.data, {
        'listingId': 1,
        'content': 'Bonjour, je souhaite 10 kg de « Riz local » (ANN-1).',
      });
    },
  );

  test('quote request preserves a listing-not-found response', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'conversations',
        const FakeHttpResponse(
          statusCode: 404,
          data: {'error': 'Listing not found', 'code': 'NOT_FOUND'},
        ),
      );
    final api = ChatApi(_client(adapter));

    await expectLater(
      api.openConversation(listingId: 404, content: 'Quote request'),
      throwsA(
        isA<ApiFailure>().having((failure) => failure.status, 'status', 404),
      ),
    );
  });
}

ApiClient _client(FakeHttpAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v2'))
    ..httpClientAdapter = adapter;
  return ApiClient(
    baseUrl: 'https://example.test/api/v2',
    tokenStorage: InMemoryTokenStorage(),
    sessionEvents: SessionEvents(),
    dio: dio,
    refreshDioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
  );
}
