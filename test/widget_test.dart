import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/app/router/app_router.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/media/photo_picker.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/buyer/application/buyer_providers.dart';
import 'package:agri_connect/features/supplier/application/supplier_providers.dart';
import 'package:agri_connect/features/super_admin/application/super_admin_providers.dart';

import 'support/fakes.dart';

const _welcomeOnboardingKey = 'welcome_onboarding_completed_v1';
const _welcomeLanguageKey = 'welcome_language_code_v1';
const _welcomeRoleKey = 'welcome_selected_role_v1';
const _tokenKey = 'auth_token_v1';
const _tokenExpiryKey = 'auth_token_expires_at_v1';

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supplierRepositoryProvider.overrideWithValue(FakeSupplierRepository()),
        buyerRepositoryProvider.overrideWithValue(FakeBuyerRepository()),
        // The demo repository answers after a delay; a session test ends before
        // that delay is over, which leaves a live timer behind the widget tree.
        superAdminRepositoryProvider.overrideWithValue(
          FakeSuperAdminRepository(),
        ),
        photoPickerProvider.overrideWithValue(FakePhotoPicker()),
      ],
      child: const AgriConnectApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
}

Future<ProviderContainer> _pumpUnassignedWelcome(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    _welcomeOnboardingKey: true,
    _welcomeLanguageKey: 'fr',
  });
  final container = ProviderContainer(
    overrides: [
      supplierRepositoryProvider.overrideWithValue(FakeSupplierRepository()),
      buyerRepositoryProvider.overrideWithValue(FakeBuyerRepository()),
      superAdminRepositoryProvider.overrideWithValue(
        FakeSuperAdminRepository(),
      ),
      photoPickerProvider.overrideWithValue(FakePhotoPicker()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const AgriConnectApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
  return container;
}

Map<String, Object> _welcomePreferences({
  bool onboarding = true,
  String? language = 'fr',
  UserRole? role,
}) {
  return {
    _welcomeOnboardingKey: onboarding,
    _welcomeLanguageKey: ?language,
    _welcomeRoleKey: ?role?.name,
  };
}

Future<void> _settleNavigation(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();
}

void main() {
  testWidgets('a new user without a stored session lands on onboarding', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await _pumpApp(tester);

    expect(find.text('Passer'), findsOneWidget);
    expect(find.text('Un marché agricole connecté'), findsOneWidget);
    expect(find.text('Se connecter'), findsNothing);
  });

  testWidgets('a completed profile with no session lands on the login page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(
      _welcomePreferences(role: UserRole.supplier),
    );

    await _pumpApp(tester);

    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Fournisseur'), findsWidgets);
  });

  for (final account in [
    (
      role: UserRole.agent,
      email: 'agent@agriconnect.app',
      expectedHome: '/agent/home',
    ),
    (
      role: UserRole.admin,
      email: 'admin@agriconnect.app',
      expectedHome: '/admin/home',
    ),
    (
      role: UserRole.root,
      email: 'root@agriconnect.app',
      expectedHome: '/root/home',
    ),
  ]) {
    testWidgets(
      'can sign in as ${account.role.name} from role selection and stays guarded',
      (tester) async {
        final container = await _pumpUnassignedWelcome(tester);
        expect(find.text('Quel est votre profil ?'), findsOneWidget);
        expect(find.text('Comptes de démonstration'), findsNothing);

        await tester.tap(find.text('Se connecter'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.text('Comptes de démonstration'), findsOneWidget);
        expect(container.read(routerProvider).state.matchedLocation, '/login');

        final preferences = await SharedPreferences.getInstance();
        expect(preferences.getString(_welcomeRoleKey), isNull);

        await tester.ensureVisible(find.text(account.email));
        await tester.tap(find.text(account.email));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pump(const Duration(milliseconds: 400));

        final router = container.read(routerProvider);
        expect(router.state.matchedLocation, account.expectedHome);

        router.go(RoutePaths.buyerHome);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(router.state.matchedLocation, account.expectedHome);
      },
    );
  }

  testWidgets('changing the role leaves login, re-picks a role and returns', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(
      _welcomePreferences(role: UserRole.supplier),
    );

    await _pumpApp(tester);
    expect(find.text('Changer de rôle'), findsOneWidget);

    await tester.tap(find.text('Changer de rôle'));
    await _settleNavigation(tester);

    expect(find.text('Quel est votre profil ?'), findsOneWidget);
    expect(find.text('Comptes de démonstration'), findsNothing);

    await tester.tap(find.text("J'achète des produits locaux"));
    await _settleNavigation(tester);

    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Acheteur'), findsWidgets);
  });

  testWidgets('restores a stored session and lands on the role dashboard', (
    tester,
  ) async {
    final user = AuthUser(
      id: '1',
      fullName: 'Alassane Traoré',
      email: 'supplier@agriconnect.app',
      role: UserRole.supplier,
    );
    SharedPreferences.setMockInitialValues({
      'auth_user_v1': jsonEncode(user.toJson()),
    });

    await _pumpApp(tester);

    expect(find.text('Bonjour, Alassane'), findsOneWidget);
    expect(find.text('Fournisseur'), findsWidgets);
    expect(find.text('Mes produits'), findsWidgets);
  });

  testWidgets('a stored session redirects to its own role workspace', (
    tester,
  ) async {
    final user = AuthUser(
      id: '2',
      fullName: 'Binta Cissé',
      email: 'root@agriconnect.app',
      role: UserRole.root,
    );
    SharedPreferences.setMockInitialValues({
      'auth_user_v1': jsonEncode(user.toJson()),
    });

    await _pumpApp(tester);

    expect(find.text('Bonjour, Binta'), findsOneWidget);
    expect(find.text('Root'), findsWidgets);
  });

  testWidgets('completing the onboarding leads to the language selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpApp(tester);

    await tester.tap(find.text('Passer'));
    await _settleNavigation(tester);

    expect(find.text('Choisissez votre langue'), findsOneWidget);
  });

  testWidgets('choosing a language leads to the role selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(_welcomePreferences(language: null));
    await _pumpApp(tester);
    expect(find.text('Choisissez votre langue'), findsOneWidget);

    await tester.tap(find.text('Français'));
    await _settleNavigation(tester);

    expect(find.text('Quel est votre profil ?'), findsOneWidget);
  });

  testWidgets('choosing a role leads to the login page', (tester) async {
    SharedPreferences.setMockInitialValues(_welcomePreferences(role: null));
    await _pumpApp(tester);
    expect(find.text('Quel est votre profil ?'), findsOneWidget);

    await tester.tap(find.text('Fournisseur'));
    await _settleNavigation(tester);

    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Profil sélectionné'), findsOneWidget);
  });

  testWidgets('signs in with a demo account and reaches the role dashboard', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(
      _welcomePreferences(role: UserRole.supplier),
    );
    await _pumpApp(tester);
    expect(find.text('Se connecter'), findsOneWidget);

    await tester.ensureVisible(find.text('supplier@agriconnect.app'));
    await tester.tap(find.text('supplier@agriconnect.app'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Bonjour, Alassane'), findsOneWidget);
  });

  testWidgets('registers a new account and lands on the role dashboard', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(
      _welcomePreferences(role: UserRole.supplier),
    );
    await _pumpApp(tester);
    expect(find.text('Se connecter'), findsOneWidget);

    await tester.ensureVisible(find.text('Créer un compte'));
    await tester.tap(find.text('Créer un compte'));
    await _settleNavigation(tester);
    expect(find.text('Créer votre compte'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Kouadio Yao');
    await tester.enterText(fields.at(1), 'kouadio@agriconnect.app');
    await tester.enterText(fields.at(2), 'demo1234');
    await tester.enterText(fields.at(3), 'demo1234');

    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.tap(find.text('Créer mon compte'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Bonjour, Kouadio'), findsOneWidget);
    expect(find.text('Fournisseur'), findsWidgets);
  });

  testWidgets('rejects a demo account whose role does not match the profile', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(
      _welcomePreferences(role: UserRole.supplier),
    );
    await _pumpApp(tester);
    expect(find.text('Se connecter'), findsOneWidget);

    await tester.ensureVisible(find.text('buyer@agriconnect.app'));
    await tester.tap(find.text('buyer@agriconnect.app'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text("Cette adresse e-mail n'est pas associée au rôle sélectionné."),
      findsOneWidget,
    );
    expect(find.text('Bonjour, Marie'), findsNothing);
  });

  testWidgets('an expired stored session is cleared and sent back to login', (
    tester,
  ) async {
    final user = AuthUser(
      id: '3',
      fullName: 'Ibrahim Cissé',
      email: 'driver@agriconnect.app',
      role: UserRole.driver,
    );
    SharedPreferences.setMockInitialValues({
      ..._welcomePreferences(role: UserRole.driver),
      'auth_user_v1': jsonEncode(user.toJson()),
      _tokenKey: 'demo_driver@agriconnect.app_1',
      _tokenExpiryKey: DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    });

    await _pumpApp(tester);

    expect(find.text('Se connecter'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_user_v1'), isNull);
    expect(prefs.getString(_tokenKey), isNull);
  });

  testWidgets('register form validates name, email and password length', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(
      _welcomePreferences(role: UserRole.supplier),
    );
    await _pumpApp(tester);

    await tester.ensureVisible(find.text('Créer un compte'));
    await tester.tap(find.text('Créer un compte'));
    await _settleNavigation(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'A');
    await tester.enterText(fields.at(1), 'mauvais-email');
    await tester.enterText(fields.at(2), 'abc123');
    await tester.enterText(fields.at(3), 'abc123');

    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.tap(find.text('Créer mon compte'));
    await tester.pump();

    expect(
      find.text('Le nom doit contenir au moins 2 caractères.'),
      findsOneWidget,
    );
    expect(find.text('Adresse e-mail invalide.'), findsOneWidget);
    expect(
      find.text('Le mot de passe doit contenir au moins 8 caractères.'),
      findsOneWidget,
    );
  });
}
