import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/app/router/redirect_policy.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/features/admin/application/admin_providers.dart';
import 'package:agri_connect/features/auth/application/auth_state.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/buyer/application/buyer_providers.dart';
import 'package:agri_connect/features/driver/application/driver_providers.dart';
import 'package:agri_connect/features/onboarding/application/welcome_state.dart';
import 'package:agri_connect/features/supplier/application/supplier_providers.dart';
import 'package:agri_connect/features/super_admin/application/super_admin_providers.dart';

import 'support/fakes.dart';

const _welcomeKeys = {
  'welcome_onboarding_completed_v1': true,
  'welcome_language_code_v1': 'fr',
  'welcome_selected_role_v1': 'supplier',
};

AuthUser _user(UserRole role) => AuthUser(
  id: 'u1',
  fullName: 'Awa Diallo',
  email: '${role.name}@agriconnect.app',
  role: role,
);

WelcomeState _welcome({UserRole? role = UserRole.supplier}) => WelcomeState(
  onboardingCompleted: true,
  languageCode: 'fr',
  selectedRole: role,
);

/// Number of redirect hops before [RedirectPolicy] settles on a location,
/// bounded so a loop reports as `cap` instead of hanging the test.
int _stepsToSettle(RedirectPolicy policy, String location, {int cap = 8}) {
  var current = location;
  var steps = 0;
  while (steps < cap) {
    final next = policy.resolve(current);
    if (next == null) return steps;
    current = next;
    ++steps;
  }
  return cap;
}

/// Convenience that builds the two sessions most used by the unit tests.
RedirectPolicy _policy(AuthState auth, {WelcomeState? welcome}) =>
    RedirectPolicy(auth: auth, welcome: welcome ?? _welcome());

void main() {
  group('RedirectPolicy — landing (AuthGuard + SessionGuard)', () {
    test('session restore keeps the splash and funnels everything to it', () {
      final policy = _policy(const AuthState.initial());
      expect(policy.resolve(RoutePaths.splash), isNull);
      expect(policy.resolve(RoutePaths.login), RoutePaths.splash);
      expect(policy.resolve('/supplier/home'), RoutePaths.splash);
    });

    test('anonymous sessions stay confined to the public shell', () {
      final policy = _policy(const AuthState.unauthenticated());
      expect(policy.resolve(RoutePaths.login), isNull);
      expect(policy.resolve(RoutePaths.register), isNull);
      expect(policy.resolve('/supplier/home'), RoutePaths.login);
      expect(policy.resolve('/buyer/catalog'), RoutePaths.login);
      expect(policy.resolve('/bogus'), RoutePaths.login);
    });

    test('welcome loading parks anonymous navigation on the splash', () {
      final policy = RedirectPolicy(
        auth: const AuthState.unauthenticated(),
        welcome: const WelcomeState(isLoading: true),
      );
      expect(policy.resolve(RoutePaths.splash), isNull);
      expect(policy.resolve('/supplier/home'), RoutePaths.splash);
    });

    test('an incomplete welcome journey stays in the welcome shell', () {
      final incomplete = _policy(
        const AuthState.unauthenticated(),
        welcome: const WelcomeState(),
      );
      expect(incomplete.resolve('/supplier/home'), RoutePaths.onboarding);
      expect(incomplete.resolve(RoutePaths.onboarding), isNull);

      final noLanguage = _policy(
        const AuthState.unauthenticated(),
        welcome: const WelcomeState(onboardingCompleted: true),
      );
      expect(noLanguage.resolve('/supplier/home'), RoutePaths.language);

      final noRole = _policy(
        const AuthState.unauthenticated(),
        welcome: const WelcomeState(
          onboardingCompleted: true,
          languageCode: 'fr',
        ),
      );
      expect(noRole.resolve(RoutePaths.login), isNull);
      expect(noRole.resolve(RoutePaths.register), RoutePaths.role);
      expect(noRole.resolve('/supplier/home'), RoutePaths.role);
    });

    test('an expired session is sent back to sign-in from anywhere', () {
      final expired = AuthState.authenticated(
        _user(UserRole.supplier),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      final policy = _policy(expired);
      expect(policy.resolve('/supplier/home'), RoutePaths.login);
      // Once on the login the policy settles: anything else would loop between
      // "expired" and "login".
      expect(policy.resolve(RoutePaths.login), isNull);
    });
  });

  group('RedirectPolicy — RoleGuard keeps each role in its own workspace', () {
    for (final role in UserRole.values) {
      final policy = _policy(AuthState.authenticated(_user(role)));

      test('$role owns its workspace', () {
        expect(policy.resolve(role.homePath), isNull, reason: '$role home');
        expect(
          policy.resolve('${role.routePrefix}/orders'),
          isNull,
          reason: '$role sub-route',
        );
        expect(
          policy.resolve('${role.routePrefix}/does-not-exist'),
          isNull,
          reason: 'an unknown $role sub-route stays under its guard',
        );
      });

      test('$role is bounced from every other workspace and public route', () {
        for (final other in UserRole.values.where((r) => r != role)) {
          expect(
            policy.resolve(other.homePath),
            role.homePath,
            reason: '$role must not see ${other.name}',
          );
        }
        expect(policy.resolve(RoutePaths.login), role.homePath);
        expect(policy.resolve(RoutePaths.onboarding), role.homePath);
        expect(policy.resolve('/bogus'), role.homePath);
      });
    }
  });

  group('RedirectPolicy — every combination settles (no redirect loop)', () {
    test('unauthenticated journeys settle within one hop', () {
      final policy = _policy(const AuthState.unauthenticated());
      for (final location in [
        RoutePaths.splash,
        RoutePaths.onboarding,
        RoutePaths.language,
        RoutePaths.role,
        RoutePaths.login,
        RoutePaths.register,
        '/supplier/home',
        '/buyer/catalog',
        '/bogus',
      ]) {
        expect(
          _stepsToSettle(policy, location),
          lessThan(3),
          reason: 'unauthenticated $location',
        );
      }
    });

    test('authenticated role journeys settle back home within a hop', () {
      for (final role in UserRole.values) {
        final policy = _policy(AuthState.authenticated(_user(role)));
        for (final start in [
          ...UserRole.values.map((r) => r.homePath),
          RoutePaths.login,
          RoutePaths.onboarding,
          '/bogus',
        ]) {
          expect(
            _stepsToSettle(policy, start),
            lessThan(3),
            reason: '$role at $start',
          );
        }
      }
    });

    test('expired and loading states settle', () {
      final expired = _policy(
        AuthState.authenticated(
          _user(UserRole.supplier),
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      );
      expect(_stepsToSettle(expired, '/supplier/home'), lessThan(3));

      final loading = RedirectPolicy(
        auth: const AuthState.unauthenticated(),
        welcome: const WelcomeState(isLoading: true),
      );
      expect(_stepsToSettle(loading, '/supplier/home'), lessThan(3));
    });
  });

  group(
    'AuthUser — demo capabilities never replace a stored authorization',
    () {
      test('the role bundle is a constructor fallback for fresh accounts', () {
        expect(_user(UserRole.admin).capabilities, isNotEmpty);
        expect(_user(UserRole.supplier).capabilities, isEmpty);
      });

      test(
        'a staff account restored without a capability list stays empty',
        () {
          final restored = AuthUser.fromJson(const {
            'id': 'a1',
            'fullName': 'Awa Traore',
            'email': 'awa@agriconnect.app',
            'role': 'admin',
          });
          expect(restored.role, UserRole.admin);
          expect(restored.capabilities, isEmpty);
        },
      );

      test('an explicit persisted list is restored verbatim', () {
        final user = AuthUser(
          id: 'a1',
          fullName: 'Awa Traore',
          email: 'awa@agriconnect.app',
          role: UserRole.agent,
          capabilities: const {UserCapability.stockValidation},
        );
        final restored = AuthUser.fromJson(user.toJson());
        expect(restored.capabilities, {UserCapability.stockValidation});
      });
    },
  );

  group('Router wiring', () {
    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supplierRepositoryProvider.overrideWithValue(
              FakeSupplierRepository(),
            ),
            buyerRepositoryProvider.overrideWithValue(FakeBuyerRepository()),
            driverRepositoryProvider.overrideWithValue(FakeDriverRepository()),
            superAdminRepositoryProvider.overrideWithValue(
              FakeSuperAdminRepository(),
            ),
            adminRepositoryProvider.overrideWithValue(FakeAdminRepository()),
          ],
          child: const AgriConnectApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();
    }

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
    }

    for (final role in UserRole.values) {
      testWidgets('a ${role.name} session lands home and bounces from the '
          'other workspaces', (tester) async {
        SharedPreferences.setMockInitialValues({
          'auth_user_v1': jsonEncode(_user(role).toJson()),
        });
        await pumpApp(tester);

        final context = tester.element(find.byType(Scaffold).first);
        final router = GoRouter.of(context);
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          role.homePath,
          reason: '$role lands at home',
        );

        for (final other in UserRole.values.where((r) => r != role)) {
          router.go(other.homePath);
          await settle(tester);
          expect(
            router.routerDelegate.currentConfiguration.uri.path,
            role.homePath,
            reason: '$role vs ${other.name}',
          );
        }

        router.go('/bogus');
        await settle(tester);
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          role.homePath,
          reason: '$role vs unknown /bogus',
        );
      });
    }

    testWidgets('an unknown address under a role prefix shows the not-found '
        'page and its way home works', (tester) async {
      SharedPreferences.setMockInitialValues({
        'auth_user_v1': jsonEncode(_user(UserRole.supplier).toJson()),
      });
      await pumpApp(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/supplier/bogus');
      await settle(tester);

      expect(find.text('Page introuvable'), findsOneWidget);
      expect(find.text("L'adresse demandée n'existe pas."), findsOneWidget);

      await tester.tap(find.text("Retour à l'accueil"));
      await settle(tester);

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        UserRole.supplier.homePath,
      );
      expect(find.text('Page introuvable'), findsNothing);
    });

    testWidgets('the moderation queue is gated by the stockValidation '
        'capability', (tester) async {
      final restricted = AuthUser(
        id: 'a1',
        fullName: 'Awa Traore',
        email: 'awa@agriconnect.app',
        role: UserRole.admin,
        capabilities: const {UserCapability.orderProcessing},
      );
      SharedPreferences.setMockInitialValues({
        'auth_user_v1': jsonEncode(restricted.toJson()),
      });
      await pumpApp(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/admin/products');
      await settle(tester);

      // The moderation menu is the only popup on this screen, so a session
      // without the stockValidation capability must render none at all.
      expect(find.byType(PopupMenuButton), findsNothing);
      expect(
        find.byKey(const ValueKey('admin.products.menu.p1')),
        findsNothing,
      );
    });

    testWidgets('the moderation queue offers its decisions to an admin with '
        'the stockValidation capability', (tester) async {
      SharedPreferences.setMockInitialValues({
        ..._welcomeKeys,
        'auth_user_v1': jsonEncode(_user(UserRole.admin).toJson()),
      });
      await pumpApp(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/admin/products');
      await settle(tester);

      final menu = find.byKey(const ValueKey('admin.products.menu.p1'));
      await tester.ensureVisible(menu);
      await settle(tester);
      expect(menu, findsOneWidget);
    });
  });
}
