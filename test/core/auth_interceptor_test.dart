import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/auth_interceptor.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';

import '../support/fake_http_adapter.dart';
import '../support/in_memory_token_storage.dart';

class _Harness {
  _Harness(this.adapter, this.storage) {
    final dio = Dio()..httpClientAdapter = adapter;
    interceptor = AuthInterceptor(
      dio: dio,
      tokenStorage: storage,
      sessionEvents: events,
      refreshDioFactory: (options) =>
          Dio(options)..httpClientAdapter = adapter,
    );
    api = ApiClient(
      dio: dio,
      baseUrl: 'http://10.0.2.2:4000/api/v2',
      interceptors: [interceptor],
    );
    events.stream.listen(reasons.add);
  }

  final FakeHttpAdapter adapter;
  final TokenStorage storage;
  final SessionEvents events = SessionEvents();
  final List<SessionEndReason> reasons = [];
  late final AuthInterceptor interceptor;
  late final ApiClient api;
}

const _expired = FakeHttpResponse(
  statusCode: 401,
  data: {'error': 'Token invalide ou expiré', 'code': 'TOKEN_INVALID'},
);

void main() {
  test('three concurrent 401 share ONE refresh, store both tokens, replay once', () async {
    final adapter = FakeHttpAdapter();
    for (var i = 0; i < 3; i++) {
      adapter.enqueue('orders', _expired);
    }
    adapter.enqueue(
      'auth/refresh',
      const FakeHttpResponse(
        statusCode: 200,
        data: {'accessToken': 'access-new', 'refreshToken': 'refresh-new'},
      ),
    );
    for (var i = 0; i < 3; i++) {
      adapter.enqueue('orders', const FakeHttpResponse(statusCode: 200, data: {'ok': true}));
    }
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'access-old', refresh: 'refresh-old');
    final h = _Harness(adapter, storage);

    final results = await Future.wait([
      h.api.get('orders'),
      h.api.get('orders'),
      h.api.get('orders'),
    ]);

    expect(results, everyElement({'ok': true}));
    expect(adapter.callCounts['auth/refresh'], 1);
    expect(adapter.callCounts['orders'], 6);
    final refresh = adapter.requests.firstWhere((r) => r.path == 'auth/refresh');
    expect(refresh.data, {'refreshToken': 'refresh-old'});
    expect(refresh.headers.containsKey('Authorization'), isFalse);
    final stored = await storage.read();
    expect(stored?.access, 'access-new');
    expect(stored?.refresh, 'refresh-new');
    final replays = adapter.requests.where((r) => r.path == 'orders').skip(3);
    expect(replays.map((r) => r.headers['Authorization']), everyElement('Bearer access-new'));
    expect(h.reasons, isEmpty);
  });

  test('a refused refresh clears the tokens and ends the session as expired', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue('orders', _expired)
      ..enqueue(
        'auth/refresh',
        const FakeHttpResponse(statusCode: 401, data: {'error': 'Refresh token invalide ou expiré'}),
      );
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'a', refresh: 'r');
    final h = _Harness(adapter, storage);

    await expectLater(h.api.get('orders'), throwsA(isA<ApiFailure>()));
    await Future<void>.delayed(Duration.zero);

    expect(await storage.read(), isNull);
    expect(h.reasons, [SessionEndReason.expired]);
    expect(adapter.callCounts['orders'], 1);
  });

  test('a replayed request answering 401 again is not refreshed a second time', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue('orders', _expired)
      ..enqueue(
        'auth/refresh',
        const FakeHttpResponse(statusCode: 200, data: {'accessToken': 'a2', 'refreshToken': 'r2'}),
      )
      ..enqueue('orders', _expired);
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'a1', refresh: 'r1');
    final h = _Harness(adapter, storage);

    final failure = await h.api.get('orders').then<ApiFailure?>((_) => null, onError: (Object e) => e as ApiFailure);

    expect(failure?.status, 401);
    expect(adapter.callCounts['auth/refresh'], 1);
    expect(adapter.callCounts['orders'], 2);
  });

  test('ACCOUNT_SUSPENDED clears the tokens without trying to refresh', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'orders',
        const FakeHttpResponse(
          statusCode: 403,
          data: {'error': 'Ce compte a été suspendu', 'code': 'ACCOUNT_SUSPENDED'},
        ),
      );
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'a', refresh: 'r');
    final h = _Harness(adapter, storage);

    final failure = await h.api.get('orders').then<ApiFailure?>((_) => null, onError: (Object e) => e as ApiFailure);
    await Future<void>.delayed(Duration.zero);

    expect(failure?.isSuspended, isTrue);
    expect(await storage.read(), isNull);
    expect(h.reasons, [SessionEndReason.suspended]);
    expect(adapter.callCounts['auth/refresh'], isNull);
  });

  test('a network error during refresh keeps the session', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue('orders', _expired)
      ..enqueueError('auth/refresh', DioExceptionType.connectionError);
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'a', refresh: 'r');
    final h = _Harness(adapter, storage);

    await expectLater(h.api.get('orders'), throwsA(isA<ApiFailure>()));

    expect((await storage.read())?.refresh, 'r');
    expect(h.reasons, isEmpty);
  });

  test('public calls (auth: false) are neither signed nor refreshed', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue('auth/login', const FakeHttpResponse(statusCode: 401, data: {'error': 'Identifiants invalides'}));
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'a', refresh: 'r');
    final h = _Harness(adapter, storage);

    await expectLater(h.api.post('auth/login', auth: false), throwsA(isA<ApiFailure>()));

    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
    expect(adapter.callCounts['auth/refresh'], isNull);
    expect((await storage.read())?.access, 'a');
  });
}
