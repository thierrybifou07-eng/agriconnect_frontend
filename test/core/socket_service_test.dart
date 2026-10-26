import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/fake_auth_repository.dart';
import '../support/fake_http_adapter.dart';
import '../support/fake_realtime_transport.dart';
import '../support/get_test_harness.dart';

void main() {
  setupGetTestHarness();

  test('connects after login and disconnects after logout', () async {
    final setup = await _createSocket();
    expect(setup.transport.tokens, isEmpty);

    setup.auth.setUser(FakeAuthRepository().user);
    await _until(() => setup.transport.tokens.length == 1);
    expect(setup.transport.tokens.single, 'access-old');
    expect(setup.socket.connected.value, isTrue);

    setup.auth.setUser(null);
    expect(setup.transport.connected, isFalse);
    expect(setup.socket.connected.value, isFalse);
  });

  test(
    'refreshes an expired handshake token once and reconnects with the new token',
    () async {
      final refreshAdapter = FakeHttpAdapter()
        ..enqueue(
          'auth/refresh',
          const FakeHttpResponse(
            statusCode: 200,
            data: {'accessToken': 'access-new', 'refreshToken': 'refresh-new'},
          ),
        );
      final setup = await _createSocket(refreshAdapter: refreshAdapter);
      setup.auth.setUser(FakeAuthRepository().user);
      await _until(() => setup.transport.tokens.length == 1);

      setup.transport.fire('connect_error', 'expired');
      await _until(() => setup.transport.tokens.contains('access-new'));

      expect(refreshAdapter.callCounts['auth/refresh'], 1);
      expect((await setup.storage.read())?.access, 'access-new');
    },
  );

  test('rejoins active conversation rooms after reconnect', () async {
    final setup = await _createSocket();
    setup.auth.setUser(FakeAuthRepository().user);
    await _until(() => setup.socket.connected.value);

    expect(await setup.socket.joinConversation(75), isTrue);
    setup.transport.fire('disconnect');
    await setup.transport.connect('access-reconnected');
    await _until(
      () =>
          setup.transport.emitted
              .where((entry) => entry.$1 == 'join_conversation')
              .length >=
          2,
    );
    expect(setup.socket.isConversationOpen(75), isTrue);
  });

  testWidgets('session_revoked forces local sign-out', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        getPages: [
          GetPage(name: AppRoutes.login, page: () => const Scaffold()),
        ],
        home: const Scaffold(body: Text('App')),
      ),
    );
    final setup = await _createSocket();
    setup.auth.setUser(FakeAuthRepository().user);
    await tester.pump();
    await tester.pump();
    expect(setup.transport.connected, isTrue);

    setup.transport.fire('session_revoked', {'reason': 'revoked'});
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(setup.auth.user.value, isNull);
  });
}

Future<_SocketSetup> _createSocket({FakeHttpAdapter? refreshAdapter}) async {
  final storage = InMemoryTokenStorage();
  await storage.save(access: 'access-old', refresh: 'refresh-old');
  final events = SessionEvents();
  final repository = FakeAuthRepository();
  final auth = Get.put(
    AuthController(
      tokenStorage: storage,
      sessionEvents: events,
      repository: repository,
    ),
  );
  final transport = FakeTransport();
  final api = ApiClient(
    tokenStorage: storage,
    sessionEvents: events,
    baseUrl: 'https://example.test/api/v2',
    refreshDioFactory: refreshAdapter == null
        ? null
        : (options) => Dio(options)..httpClientAdapter = refreshAdapter,
  );
  final socket = Get.put(
    SocketService(
      authController: auth,
      apiClient: api,
      tokenStorage: storage,
      transport: transport,
    ),
  );
  return _SocketSetup(auth, socket, transport, storage);
}

Future<void> _until(bool Function() condition) async {
  for (var attempt = 0; attempt < 50 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  expect(condition(), isTrue);
}

class _SocketSetup {
  const _SocketSetup(this.auth, this.socket, this.transport, this.storage);

  final AuthController auth;
  final SocketService socket;
  final FakeTransport transport;
  final InMemoryTokenStorage storage;
}
