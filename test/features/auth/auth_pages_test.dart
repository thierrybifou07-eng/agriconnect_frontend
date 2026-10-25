import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/prefs_storage.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_page_controllers.dart';
import 'package:agri_connect/features/auth/presentation/pages/auth_pages.dart';

import '../../support/get_test_harness.dart';
import 'fake_auth_repository.dart';

void main() {
  setupGetTestHarness();

  testWidgets('login displays server field errors', (tester) async {
    final auth = _auth();
    auth.authState.value = Failure<void>(
      const ApiFailure(
        status: 400,
        code: null,
        message: 'Invalid input',
        fieldErrors: {'email': 'This address is invalid.'},
        kind: ApiFailureKind.client,
      ),
    );
    auth.fieldErrors['email'] = 'This address is invalid.';
    Get.put<AuthController>(auth);
    Get.put<LoginPageController>(LoginPageController(auth));

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This address is invalid.'), findsOneWidget);
  });

  testWidgets('register only offers public buyer and supplier roles', (
    tester,
  ) async {
    final auth = _auth();
    Get.put<AuthController>(auth);
    final prefs = PrefsStorage();
    Get.put<RegisterPageController>(RegisterPageController(auth, prefs));

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('I sell (supplier)'), findsOneWidget);
    expect(find.text('I buy (buyer)'), findsOneWidget);
    expect(find.textContaining('driver', findRichText: true), findsNothing);
  });

  testWidgets('splash exposes recovery actions when token storage fails', (
    tester,
  ) async {
    final auth = _auth(tokenStorage: _ThrowingTokenStorage());
    Get.put<AuthController>(auth);
    Get.put<SplashController>(SplashController(auth, PrefsStorage()));

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        getPages: [
          GetPage(
            name: AppRoutes.login,
            page: () => const Scaffold(body: Text('login-route')),
          ),
        ],
        home: const SplashPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Une erreur est survenue. Veuillez réessayer.'),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('login-route'), findsOneWidget);
  });
}

AuthController _auth({TokenStorage? tokenStorage}) => AuthController(
  tokenStorage: tokenStorage ?? InMemoryTokenStorage(),
  sessionEvents: SessionEvents(),
  repository: FakeAuthRepository(),
);

class _ThrowingTokenStorage implements TokenStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<TokenPair?> read() async => throw StateError('storage unavailable');

  @override
  Future<void> save({required String access, required String refresh}) async {}
}
