import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/theme/app_theme.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/storage/session_storage.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/auth/presentation/widgets/role_profile_page.dart';

const _userKey = 'auth_user_v1';
const _tokenKey = 'auth_token_v1';

AuthUser _user(UserRole role) => AuthUser(
  id: 'user-1',
  fullName: 'Awa Diallo',
  email: 'awa@example.com',
  role: role,
  capabilities: const {UserCapability.buyerSupport},
);

class _ToggleWriteFailureStorage implements SessionStorage {
  final LocalSessionStorage _delegate = const LocalSessionStorage();
  bool failWrites = true;

  @override
  Future<void> clear() => _delegate.clear();

  @override
  Future<DateTime?> readExpiryAt() => _delegate.readExpiryAt();

  @override
  Future<String?> readToken() => _delegate.readToken();

  @override
  Future<String?> readUserJson() => _delegate.readUserJson();

  @override
  Future<void> writeExpiryAt(DateTime? value) => _delegate.writeExpiryAt(value);

  @override
  Future<void> writeToken(String value) => _delegate.writeToken(value);

  @override
  Future<void> writeUserJson(String value) async {
    if (failWrites) throw const CacheFailure();
    await _delegate.writeUserJson(value);
  }
}

Future<ProviderContainer> _pumpProfile(
  WidgetTester tester, {
  UserRole role = UserRole.buyer,
  Locale locale = const Locale('fr'),
  _ToggleWriteFailureStorage? storage,
}) async {
  SharedPreferences.setMockInitialValues({
    _userKey: jsonEncode(_user(role).toJson()),
    _tokenKey: 'token-1',
  });
  final container = ProviderContainer(
    overrides: [
      if (storage != null) sessionStorageProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: const Scaffold(body: RoleProfilePage()),
      ),
    ),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows read-only account fields and profile capabilities', (
    tester,
  ) async {
    await _pumpProfile(tester, role: UserRole.root);

    expect(find.text('Awa Diallo'), findsOneWidget);
    expect(find.text('awa@example.com'), findsOneWidget);
    expect(find.text('Root'), findsNWidgets(2));
    expect(find.text('Support acheteurs'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('cancel confirms before discarding the edited name', (
    tester,
  ) async {
    await _pumpProfile(tester);

    await tester.tap(find.text('Modifier le profil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Awa Traoré');
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.text('Abandonner les modifications ?'), findsOneWidget);
    await tester.tap(find.text('Continuer la modification'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Awa Traoré'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abandonner').last);
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Awa Diallo'), findsOneWidget);
  });

  testWidgets('validates required and too-short names without saving', (
    tester,
  ) async {
    final container = await _pumpProfile(tester);

    await tester.tap(find.text('Modifier le profil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();
    expect(find.text('Veuillez saisir votre nom complet.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'A');
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();
    expect(
      find.text('Le nom doit contenir au moins 2 caractères.'),
      findsOneWidget,
    );
    expect(container.read(authControllerProvider).user?.fullName, 'Awa Diallo');
  });

  testWidgets('saves the name locally and preserves role and capabilities', (
    tester,
  ) async {
    final container = await _pumpProfile(tester, role: UserRole.root);

    await tester.tap(find.text('Modifier le profil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Awa Traoré');
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();

    final updated = container.read(authControllerProvider).user!;
    expect(updated.fullName, 'Awa Traoré');
    expect(updated.id, 'user-1');
    expect(updated.email, 'awa@example.com');
    expect(updated.role, UserRole.root);
    expect(updated.capabilities, {UserCapability.buyerSupport});
    expect(find.text('Profil mis à jour sur cet appareil.'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    final persisted = AuthUser.fromJson(
      (jsonDecode(preferences.getString(_userKey)!) as Map)
          .cast<String, Object?>(),
    );
    expect(persisted.fullName, 'Awa Traoré');
    expect(persisted.role, UserRole.root);
    expect(persisted.capabilities, {UserCapability.buyerSupport});
    expect(preferences.getString(_tokenKey), 'token-1');
  });

  testWidgets(
    'storage failure keeps the draft and permits a successful retry',
    (tester) async {
      final storage = _ToggleWriteFailureStorage();
      final container = await _pumpProfile(tester, storage: storage);

      await tester.tap(find.text('Modifier le profil'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Awa Traoré');
      await tester.tap(find.text('Enregistrer les modifications'));
      await tester.pumpAndSettle();

      expect(
        find.text("Impossible d'accéder au stockage local."),
        findsOneWidget,
      );
      expect(find.text('Awa Traoré'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(
        container.read(authControllerProvider).user?.fullName,
        'Awa Diallo',
      );

      storage.failWrites = false;
      await tester.tap(find.text('Enregistrer les modifications'));
      await tester.pumpAndSettle();
      expect(
        container.read(authControllerProvider).user?.fullName,
        'Awa Traoré',
      );
      expect(find.byType(TextFormField), findsNothing);
    },
  );

  for (final role in UserRole.values) {
    testWidgets('the shared editable profile serves ${role.name}', (
      tester,
    ) async {
      await _pumpProfile(tester, role: role);
      final localizations = AppLocalizations.of(
        tester.element(find.byType(RoleProfilePage)),
      );
      expect(find.text(role.label(localizations)), findsNWidgets(2));
      expect(find.text('Modifier le profil'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('profile form fits phone, tablet and desktop with large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await _pumpProfile(tester);
    await tester.tap(find.text('Modifier le profil'));
    await tester.pumpAndSettle();

    for (final size in [
      const Size(320, 640),
      const Size(360, 720),
      const Size(412, 840),
      const Size(600, 900),
      const Size(720, 900),
      const Size(1024, 900),
      const Size(1280, 900),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'layout at $size');
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Enregistrer les modifications'), findsOneWidget);
    }
  });

  testWidgets('profile editor uses English strings', (tester) async {
    await _pumpProfile(tester, locale: const Locale('en'));

    expect(find.text('Edit profile'), findsOneWidget);
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    expect(find.text('Edit your profile'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
