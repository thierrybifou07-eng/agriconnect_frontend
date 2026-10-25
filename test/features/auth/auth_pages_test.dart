import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/prefs_storage.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
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
}

AuthController _auth() => AuthController(
  tokenStorage: InMemoryTokenStorage(),
  sessionEvents: SessionEvents(),
  repository: FakeAuthRepository(),
);
