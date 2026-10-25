import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/api_failure_events.dart';
import 'package:agri_connect/core/network/profile_verification_failure_handler.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/profile_verification_status.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/shared/widgets/verification_banner.dart';

import '../../support/get_test_harness.dart';
import '../auth/fake_auth_repository.dart';

void main() {
  setupGetTestHarness();

  testWidgets('verification banner reflects status and excludes staff', (
    tester,
  ) async {
    final auth = _auth();
    Get.put<AuthController>(auth);
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: VerificationBanner()),
      ),
    );

    auth.setUser(
      const AuthUser(
        role: RoleCode.supplier,
        profileVerificationStatus: ProfileVerificationStatus.unverified,
      ),
    );
    await tester.pump();
    expect(find.text('Vérifiez votre profil pour commencer.'), findsOneWidget);

    auth.setUser(
      const AuthUser(
        role: RoleCode.buyer,
        profileVerificationStatus: ProfileVerificationStatus.pending,
      ),
    );
    await tester.pump();
    expect(find.text("Votre profil est en cours d'examen."), findsOneWidget);

    auth.setUser(
      const AuthUser(
        role: RoleCode.supplier,
        profileVerificationStatus: ProfileVerificationStatus.rejected,
      ),
    );
    await tester.pump();
    expect(
      find.text('Votre profil a été refusé. Déposez un nouveau document.'),
      findsOneWidget,
    );

    auth.setUser(
      const AuthUser(
        role: RoleCode.supplier,
        profileVerificationStatus: ProfileVerificationStatus.verified,
      ),
    );
    await tester.pump();
    expect(find.byType(VerificationBanner), findsOneWidget);
    expect(find.text('Votre profil est en cours d’examen.'), findsNothing);

    auth.setUser(const AuthUser(role: RoleCode.driver));
    await tester.pump();
    expect(find.text('Vérifiez votre profil pour commencer.'), findsNothing);
  });

  testWidgets('profile-not-verified API failure opens the document dialog', (
    tester,
  ) async {
    final events = ApiFailureEvents();
    Get.put<ProfileVerificationFailureHandler>(
      ProfileVerificationFailureHandler(events),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        getPages: [
          GetPage(
            name: AppRoutes.documents,
            page: () => const Scaffold(body: Text('documents-route')),
          ),
        ],
        home: const Scaffold(body: Text('home-route')),
      ),
    );

    events.emit(
      const ApiFailure(
        status: 403,
        code: 'PROFILE_NOT_VERIFIED',
        message: 'Profile verification required',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profil non vérifié'), findsOneWidget);
    expect(
      find.text('Vérifiez votre profil pour accéder à cette fonctionnalité.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Voir les documents'));
    await tester.pumpAndSettle();
    expect(find.text('documents-route'), findsOneWidget);
  });
}

AuthController _auth() => AuthController(
  tokenStorage: InMemoryTokenStorage(),
  sessionEvents: SessionEvents(),
  repository: FakeAuthRepository(),
);
