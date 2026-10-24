import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/app/router/app_router.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/auth/data/demo_auth_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/buyer/application/buyer_providers.dart';
import 'package:agri_connect/features/supplier/application/supplier_providers.dart';
import 'package:agri_connect/features/super_admin/application/super_admin_providers.dart';

import 'support/fakes.dart';

const _allCapabilities = {
  UserCapability.buyerSupport,
  UserCapability.stockValidation,
  UserCapability.orderProcessing,
  UserCapability.paymentFollowup,
};

void main() {
  group('UserCapability', () {
    test('round-trips through the documented API keys', () {
      for (final capability in UserCapability.values) {
        expect(UserCapability.fromKey(capability.key), capability);
      }
      expect(UserCapability.fromKey('UNKNOWN'), isNull);
    });
  });

  group('role capability bundles', () {
    test('staff roles bundle every platform capability', () {
      for (final role in const [
        UserRole.agent,
        UserRole.admin,
        UserRole.root,
      ]) {
        expect(role.capabilities, _allCapabilities, reason: role.name);
      }
    });

    test('marketplace roles start with no capability', () {
      for (final role in const [
        UserRole.buyer,
        UserRole.supplier,
        UserRole.driver,
      ]) {
        expect(role.capabilities, isEmpty, reason: role.name);
      }
    });
  });

  group('AuthUser capabilities', () {
    test('defaults to the role bundle when none is given', () {
      final agentUser = AuthUser(
        id: '1',
        fullName: 'Awa Diallo',
        email: 'agent@agriconnect.app',
        role: UserRole.agent,
      );
      expect(agentUser.capabilities, _allCapabilities);

      final supplierUser = AuthUser(
        id: '2',
        fullName: 'Alassane Traoré',
        email: 'supplier@agriconnect.app',
        role: UserRole.supplier,
      );
      expect(supplierUser.capabilities, isEmpty);
    });

    test('persists an explicit capability list in the session json', () {
      final user = AuthUser(
        id: '1',
        fullName: 'Awa Diallo',
        email: 'agent@agriconnect.app',
        role: UserRole.agent,
        capabilities: const {
          UserCapability.buyerSupport,
          UserCapability.paymentFollowup,
        },
      );

      final restored = AuthUser.fromJson(user.toJson());

      expect(restored.capabilities, {
        UserCapability.buyerSupport,
        UserCapability.paymentFollowup,
      });
      expect(restored.role, UserRole.agent);
    });

    test('restores a stored legacy farmer session as a supplier', () {
      final json = <String, Object?>{
        'id': 'legacy_1',
        'fullName': 'Alassane Traoré',
        'email': 'supplier@agriconnect.app',
        'role': 'farmer',
      };

      final restored = AuthUser.fromJson(json);

      expect(restored.role, UserRole.supplier);
    });
  });

  group('AuthCapabilityGuardX', () {
    final rootUser = AuthUser(
      id: '1',
      fullName: 'Binta Cissé',
      email: 'root@agriconnect.app',
      role: UserRole.root,
    );
    final supplierUser = AuthUser(
      id: '2',
      fullName: 'Alassane Traoré',
      email: 'supplier@agriconnect.app',
      role: UserRole.supplier,
    );

    test('hasCapability and hasAllCapabilities follow the session', () {
      expect(rootUser.hasCapability(UserCapability.orderProcessing), isTrue);
      expect(rootUser.hasAllCapabilities(_allCapabilities), isTrue);
      expect(
        supplierUser.hasCapability(UserCapability.orderProcessing),
        isFalse,
      );
      expect(supplierUser.hasAnyCapability(_allCapabilities), isFalse);
    });

    test('requireCapability throws AccessDeniedFailure when the session lacks '
        'the capability', () {
      expect(
        () => supplierUser.requireCapability(UserCapability.buyerSupport),
        throwsA(
          isA<AccessDeniedFailure>()
              .having((f) => f.code, 'code', 'access_denied')
              .having((f) => f.details, 'details', 'BUYER_SUPPORT'),
        ),
      );
      expect(
        () => rootUser.requireCapability(UserCapability.paymentFollowup),
        returnsNormally,
      );
    });
  });

  group('DemoAuthRepository', () {
    test('seeds one account per role', () {
      expect(
        DemoAuthRepository.accounts.map((account) => account.role).toSet(),
        {
          UserRole.buyer,
          UserRole.supplier,
          UserRole.driver,
          UserRole.agent,
          UserRole.admin,
          UserRole.root,
        },
      );
    });

    test('rejects self-registration on a staff role', () async {
      final repository = DemoAuthRepository();
      await expectLater(
        repository.register(
          const RegisterRequest(
            fullName: 'Awa Diallo',
            email: 'awa.diallo@agriconnect.app',
            password: 'demo1234',
            role: UserRole.agent,
          ),
        ),
        throwsA(
          isA<AuthFailure>().having((f) => f.code, 'code', 'role_not_allowed'),
        ),
      );
    });
  });

  group('V2 role workspaces', () {
    Future<ProviderContainer> pumpSignedIn(
      WidgetTester tester, {
      required UserRole role,
      String roleKey = '',
    }) async {
      SharedPreferences.setMockInitialValues({
        'welcome_onboarding_completed_v1': true,
        'welcome_language_code_v1': 'fr',
        'welcome_selected_role_v1': roleKey.isEmpty ? role.key : roleKey,
        'auth_user_v1': jsonEncode(
          AuthUser(
            id: 'u1',
            fullName: 'Awa Traoré',
            email: 'awa@agriconnect.app',
            role: role,
          ).toJson(),
        ),
      });
      final container = ProviderContainer(
        overrides: [
          supplierRepositoryProvider.overrideWithValue(
            FakeSupplierRepository(),
          ),
          buyerRepositoryProvider.overrideWithValue(FakeBuyerRepository()),
          superAdminRepositoryProvider.overrideWithValue(
            FakeSuperAdminRepository(),
          ),
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
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      return container;
    }

    testWidgets('an agent session is bounced away from another workspace', (
      tester,
    ) async {
      final container = await pumpSignedIn(tester, role: UserRole.supplier);

      container.read(routerProvider).go('/buyer/orders');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        container.read(routerProvider).state.matchedLocation,
        '/supplier/home',
      );
    });

    testWidgets('signing in with the agent demo account reaches the agent '
        'workspace', (tester) async {
      SharedPreferences.setMockInitialValues({
        'welcome_onboarding_completed_v1': true,
        'welcome_language_code_v1': 'fr',
        'welcome_selected_role_v1': UserRole.supplier.key,
      });
      await tester.pumpWidget(const ProviderScope(child: AgriConnectApp()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();

      await tester.ensureVisible(find.text('agent@agriconnect.app'));
      await tester.tap(find.text('agent@agriconnect.app'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();

      // The agent workspace is a real dashboard, not the old placeholder: the
      // demo account holds every capability, so all four operational sections
      // are offered next to the dashboard and the profile.
      expect(find.text('Bonjour, Awa'), findsOneWidget);
      expect(find.text('Section en construction'), findsNothing);
      expect(find.text('Bientôt disponible'), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('roleShellSidebar')),
          matching: find.byType(ListTile),
        ),
        findsNWidgets(6),
      );

      // Let the demo repository's section reads settle so no timer outlives the
      // test.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('the root profile lists the platform permissions', (
      tester,
    ) async {
      await pumpSignedIn(tester, role: UserRole.root, roleKey: 'superAdmin');

      await tester.tap(
        find
            .descendant(
              of: find.byKey(const ValueKey('roleShellSidebar')),
              matching: find.byType(ListTile),
            )
            .at(4),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 100));

      // The permission chips sit below the first screen of the profile.
      await tester.drag(find.byType(ListView).last, const Offset(0, -600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Permissions'), findsOneWidget);
      expect(find.text('Support acheteurs'), findsOneWidget);
      expect(find.text('Validation des stocks'), findsOneWidget);
      expect(find.text('Traitement des commandes'), findsOneWidget);
      expect(find.text('Suivi des paiements'), findsOneWidget);
    });
  });
}
