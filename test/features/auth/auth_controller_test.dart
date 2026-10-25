import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/auth/data/auth_api.dart';
import 'package:agri_connect/features/auth/data/auth_repository_impl.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

import '../../support/fake_http_adapter.dart';
import '../../support/get_test_harness.dart';
import 'fake_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupGetTestHarness();

  testWidgets(
    'signIn stores both tokens, sets the user and navigates by role',
    (tester) async {
      await _pumpRoutes(tester);
      final repository = FakeAuthRepository();
      final storage = InMemoryTokenStorage();
      final controller = _controller(repository, storage);

      final signIn = controller.signIn('test@example.test', 'Password123!');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(await signIn, isTrue);

      expect(controller.currentUser?.role, RoleCode.supplier);
      expect((await storage.read())?.access, 'test-access');
      expect((await storage.read())?.refresh, 'test-refresh');
    },
  );

  for (final status in [401, 403, 429]) {
    test('signIn retains API failure status $status', () async {
      final repository = FakeAuthRepository()..signInError = _failure(status);
      final controller = _controller(repository, InMemoryTokenStorage());

      expect(await controller.signIn('bad@example.test', 'wrong'), isFalse);
      expect(controller.authState.value, isA<Failure<void>>());
      expect(
        (controller.authState.value as Failure<void>).failure.status,
        status,
      );
    });
  }

  testWidgets(
    'signUp stores tokens and sends the successful user to their home',
    (tester) async {
      await _pumpRoutes(tester);
      final repository = FakeAuthRepository();
      final storage = InMemoryTokenStorage();
      final controller = _controller(repository, storage);

      final signUp = controller.signUp({
        'firstname': 'Test',
        'role': 'BUYER',
        'acceptTerms': true,
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(await signUp, isTrue);
      expect(repository.lastPayload?['acceptTerms'], isTrue);
      expect((await storage.read())?.refresh, 'test-refresh');
    },
  );

  test('signUp exposes 400 field errors and 409 conflict', () async {
    final validation = ApiFailure(
      status: 400,
      code: null,
      message: 'Données invalides',
      fieldErrors: const {'phone': 'Numéro invalide'},
      kind: ApiFailureKind.client,
    );
    final repository = FakeAuthRepository()..signUpError = validation;
    final controller = _controller(repository, InMemoryTokenStorage());

    expect(await controller.signUp({'acceptTerms': true}), isFalse);
    expect(controller.fieldErrors['phone'], 'Numéro invalide');

    repository.signUpError = _failure(409);
    expect(await controller.signUp({'acceptTerms': true}), isFalse);
    expect((controller.authState.value as Failure<void>).failure.status, 409);
  });

  test('restoreSession loads the user when stored tokens are valid', () async {
    final repository = FakeAuthRepository();
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'access', refresh: 'refresh');
    final controller = _controller(repository, storage);

    final user = await controller.restoreSession();

    expect(user, same(repository.user));
    expect(controller.currentUser, same(repository.user));
    expect(repository.meCalls, 1);
  });

  test('restoreSession clears tokens when none exist', () async {
    final repository = FakeAuthRepository();
    final storage = InMemoryTokenStorage();
    final controller = _controller(repository, storage);

    expect(await controller.restoreSession(), isNull);
    expect(repository.meCalls, 0);
    expect(await storage.read(), isNull);
  });

  test('restoreSession refreshes an expired access token once', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'auth/me',
        const FakeHttpResponse(statusCode: 401, data: {'error': 'Expired'}),
      )
      ..enqueue(
        'auth/refresh',
        const FakeHttpResponse(
          statusCode: 200,
          data: {'accessToken': 'access-new', 'refreshToken': 'refresh-new'},
        ),
      )
      ..enqueue(
        'auth/me',
        const FakeHttpResponse(
          statusCode: 200,
          data: {
            'id': 44,
            'firstname': 'Test',
            'lastname': 'Buyer',
            'email': 'buyer@example.test',
            'phone': '+237600000000',
            'role': {'code': 'BUYER', 'label': 'Acheteur'},
            'emailVerified': true,
            'profileVerificationStatus': 'VERIFIED',
          },
        ),
      );
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'access-old', refresh: 'refresh-old');
    final events = SessionEvents();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v2'))
      ..httpClientAdapter = adapter;
    final api = ApiClient(
      baseUrl: 'https://example.test/api/v2',
      tokenStorage: storage,
      sessionEvents: events,
      dio: dio,
      refreshDioFactory: (options) => Dio(options)..httpClientAdapter = adapter,
    );
    final repository = AuthRepositoryImpl(AuthApi(api));
    final controller = _controller(repository, storage, events: events);

    final user = await controller.restoreSession();

    expect(user?.role, RoleCode.buyer);
    expect(adapter.callCounts['auth/refresh'], 1);
    expect((await storage.read())?.access, 'access-new');
    await events.close();
  });

  testWidgets('signOut calls remote logout and always clears local tokens', (
    tester,
  ) async {
    await _pumpRoutes(tester);
    final repository = FakeAuthRepository();
    final storage = InMemoryTokenStorage();
    await storage.save(access: 'access', refresh: 'refresh');
    final controller = _controller(repository, storage);

    final signOut = controller.signOut();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await signOut;

    expect(repository.logoutCalls, 1);
    expect(await storage.read(), isNull);
    expect(controller.currentUser, isNull);
  });
}

Future<void> _pumpRoutes(WidgetTester tester) async {
  await tester.pumpWidget(
    GetMaterialApp(
      home: const Scaffold(),
      getPages: [
        GetPage(name: '/supplier', page: () => const Scaffold()),
        GetPage(name: '/buyer', page: () => const Scaffold()),
        GetPage(name: '/login', page: () => const Scaffold()),
      ],
    ),
  );
  await tester.pump();
}

AuthController _controller(
  AuthRepository repository,
  TokenStorage storage, {
  SessionEvents? events,
}) => AuthController(
  tokenStorage: storage,
  sessionEvents: events ?? SessionEvents(),
  repository: repository,
);

ApiFailure _failure(int status) => ApiFailure(
  status: status,
  code: null,
  message: 'Failure',
  fieldErrors: const {},
  kind: ApiFailureKind.client,
);
