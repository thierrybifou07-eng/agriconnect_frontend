import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import '../support/fake_http_adapter.dart';

void main() {
  test('three concurrent 401 responses share one refresh and replay', () async {
    final adapter = FakeHttpAdapter();
    for (var index = 0; index < 3; index++) {
      adapter.enqueue(
        'private/resource',
        const FakeHttpResponse(statusCode: 401, data: {'error': 'Expired'}),
      );
    }
    adapter.enqueue(
      'auth/refresh',
      const FakeHttpResponse(
        statusCode: 200,
        data: {'accessToken': 'access-new', 'refreshToken': 'refresh-new'},
      ),
    );
    for (var index = 0; index < 3; index++) {
      adapter.enqueue(
        'private/resource',
        const FakeHttpResponse(statusCode: 200, data: {'ok': true}),
      );
    }
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'access-old', refresh: 'refresh-old');
    final api = _client(adapter, storage);

    final responses = await Future.wait([
      api.get('private/resource'),
      api.get('private/resource'),
      api.get('private/resource'),
    ]);

    expect(responses, everyElement({'ok': true}));
    expect(adapter.callCounts['auth/refresh'], 1);
    expect(adapter.callCounts['private/resource'], 6);
    expect(
      adapter.requests
          .where((request) => request.path == 'private/resource')
          .map((request) => request.headers['Authorization'])
          .toList(),
      [
        'Bearer access-old',
        'Bearer access-old',
        'Bearer access-old',
        'Bearer access-new',
        'Bearer access-new',
        'Bearer access-new',
      ],
    );
    expect((await storage.read())?.refresh, 'refresh-new');
  });

  test(
    'failed refresh clears tokens, emits expired, and is not retried',
    () async {
      final adapter = FakeHttpAdapter()
        ..enqueue(
          'private/resource',
          const FakeHttpResponse(statusCode: 401, data: {'error': 'Expired'}),
        )
        ..enqueue(
          'auth/refresh',
          const FakeHttpResponse(
            statusCode: 401,
            data: {'error': 'Invalid token'},
          ),
        );
      final storage = InMemoryTokenStorage();
      await storage.save(access: 'access-old', refresh: 'refresh-old');
      final events = SessionEvents();
      final reasons = <SessionEndReason>[];
      final subscription = events.stream.listen(
        (event) => reasons.add(event.reason),
      );
      final api = _client(adapter, storage, events: events);

      await expectLater(
        api.get('private/resource'),
        throwsA(isA<ApiFailure>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(await storage.read(), isNull);
      expect(reasons, [SessionEndReason.expired]);
      expect(adapter.callCounts['private/resource'], 1);
      expect(adapter.callCounts['auth/refresh'], 1);
      await subscription.cancel();
      await events.close();
    },
  );

  test(
    'a request without a refresh token is rejected without looping',
    () async {
      final adapter = FakeHttpAdapter()
        ..enqueue(
          'private/resource',
          const FakeHttpResponse(statusCode: 401, data: {'error': 'Expired'}),
        );
      final events = SessionEvents();
      final reasons = <SessionEndReason>[];
      final subscription = events.stream.listen(
        (event) => reasons.add(event.reason),
      );
      final api = _client(adapter, InMemoryTokenStorage(), events: events);

      await expectLater(
        api.get('private/resource'),
        throwsA(isA<ApiFailure>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(adapter.callCounts['auth/refresh'], isNull);
      expect(reasons, [SessionEndReason.expired]);
      await subscription.cancel();
      await events.close();
    },
  );

  test('a suspended response clears tokens and emits suspended', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'private/resource',
        const FakeHttpResponse(
          statusCode: 403,
          data: {
            'error': 'Votre compte est suspendu.',
            'code': 'ACCOUNT_SUSPENDED',
          },
        ),
      );
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'access-old', refresh: 'refresh-old');
    final events = SessionEvents();
    final reasons = <SessionEndReason>[];
    final subscription = events.stream.listen(
      (event) => reasons.add(event.reason),
    );
    final api = _client(adapter, storage, events: events);

    await expectLater(api.get('private/resource'), throwsA(isA<ApiFailure>()));
    await Future<void>.delayed(Duration.zero);

    expect(await storage.read(), isNull);
    expect(reasons, [SessionEndReason.suspended]);
    expect(adapter.callCounts['auth/refresh'], isNull);
    await subscription.cancel();
    await events.close();
  });

  test('auth false omits the authorization header', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'auth/login',
        const FakeHttpResponse(statusCode: 200, data: {'ok': true}),
      );
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'access-old', refresh: 'refresh-old');
    final api = _client(adapter, storage);

    await api.post('auth/login', auth: false);

    expect(
      adapter.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
    expect(adapter.requests.single.uri.path, '/api/v2/auth/login');
  });
}

ApiClient _client(
  FakeHttpAdapter adapter,
  TokenStorage storage, {
  SessionEvents? events,
}) {
  final sessionEvents = events ?? SessionEvents();
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v2'))
    ..httpClientAdapter = adapter;
  return ApiClient(
    baseUrl: 'https://example.test/api/v2',
    tokenStorage: storage,
    sessionEvents: sessionEvents,
    dio: dio,
    refreshDioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
  );
}
