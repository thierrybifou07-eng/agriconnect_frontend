import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/features/admin/presentation/admin_analytics_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_deliveries_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_orders_page.dart';
import 'package:agri_connect/features/agent/presentation/pages/agent_payments_page.dart';
import 'package:agri_connect/features/agent/presentation/pages/agent_stock_page.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/auth/presentation/widgets/role_profile_page.dart';

const _allAgentCapabilities = {
  UserCapability.buyerSupport,
  UserCapability.stockValidation,
  UserCapability.orderProcessing,
  UserCapability.paymentFollowup,
};

const _limitedAgentCapabilities = {
  UserCapability.buyerSupport,
  UserCapability.stockValidation,
  UserCapability.paymentFollowup,
};

const _phoneWidths = [320.0, 360.0, 390.0, 412.0];

void _useSize(WidgetTester tester, double width, {double textScale = 1}) {
  const dpr = 2.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = Size(width, 800) * dpr;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

Future<void> _pumpRole(
  WidgetTester tester,
  UserRole role, {
  Set<UserCapability> capabilities = const {},
  String language = 'fr',
}) async {
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': language,
    'welcome_selected_role_v1': role.key,
    'supplier_welcome_seen_v1': true,
    'buyer_welcome_seen_v1': true,
    'auth_user_v1': jsonEncode(
      AuthUser(
        id: 'u1',
        fullName: 'Awa Traoré',
        email: 'awa@agriconnect.app',
        role: role,
        capabilities: capabilities,
      ).toJson(),
    ),
  });
  await tester.pumpWidget(const ProviderScope(child: AgriConnectApp()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

Finder _destinations() => find.descendant(
  of: find.byType(NavigationBar),
  matching: find.byType(NavigationDestination),
);

Finder _sidebarItems() => find.descendant(
  of: find.byKey(const ValueKey('roleShellSidebar')),
  matching: find.byType(ListTile),
);

Finder _more() => find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text('Plus'),
);

Finder _navLabel(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Future<void> _openMore(WidgetTester tester) async {
  await tester.tap(_destinations().last);
  await _settle(tester);
}

void _expectNavigationTargetsReachable(WidgetTester tester) {
  for (final element in _destinations().evaluate()) {
    final box = element.renderObject! as RenderBox;
    expect(box.size.width, greaterThanOrEqualTo(48));
    expect(box.size.height, greaterThanOrEqualTo(48));
  }
}

void main() {
  for (final width in _phoneWidths) {
    testWidgets(
      'Agent keeps primary destinations usable at ${width.toInt()}dp',
      (tester) async {
        _useSize(tester, width);
        await _pumpRole(
          tester,
          UserRole.agent,
          capabilities: _allAgentCapabilities,
        );

        expect(_destinations(), findsNWidgets(4));
        expect(_more(), findsOneWidget);
        expect(_navLabel('Accueil'), findsOneWidget);
        expect(_navLabel('Support'), findsOneWidget);
        expect(_navLabel('Commandes'), findsOneWidget);
        expect(_navLabel('Traitement des commandes'), findsNothing);
        expect(_navLabel('Validation du stock'), findsNothing);
        _expectNavigationTargetsReachable(tester);
        expect(tester.takeException(), isNull);

        for (var index = 0; index < 3; index++) {
          await tester.tap(_destinations().at(index));
          await _settle(tester);
          expect(
            tester
                .widget<NavigationBar>(find.byType(NavigationBar))
                .selectedIndex,
            index,
          );
        }

        await _openMore(tester);
        final items = find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(ListTile),
        );
        expect(items, findsNWidgets(3));
        expect(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.text('Validation du stock'),
          ),
          findsOneWidget,
        );
        expect(find.text('Suivi des paiements'), findsOneWidget);
        expect(find.text('Profil'), findsOneWidget);
        var firstSecondary = true;
        for (final (label, pageType) in [
          ('Validation du stock', AgentStockPage),
          ('Suivi des paiements', AgentPaymentsPage),
          ('Profil', RoleProfilePage),
        ]) {
          if (!firstSecondary) await _openMore(tester);
          firstSecondary = false;
          await tester.tap(
            find.descendant(
              of: find.byType(BottomSheet),
              matching: find.text(label),
            ),
          );
          await _settle(tester);
          expect(find.byType(pageType), findsOneWidget);
          expect(
            tester
                .widget<NavigationBar>(find.byType(NavigationBar))
                .selectedIndex,
            3,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Agent Plus only contains destinations allowed by capabilities', (
    tester,
  ) async {
    _useSize(tester, 360);
    await _pumpRole(
      tester,
      UserRole.agent,
      capabilities: _limitedAgentCapabilities,
    );

    expect(_destinations(), findsNWidgets(3));
    expect(_navLabel('Support'), findsOneWidget);
    expect(_navLabel('Validation du stock'), findsNothing);
    expect(_navLabel('Traitement des commandes'), findsNothing);

    await _openMore(tester);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(ListTile),
      ),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Traitement des commandes'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Validation du stock'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Suivi des paiements'),
      ),
      findsOneWidget,
    );
  });

  for (final width in _phoneWidths) {
    testWidgets('Admin More remains reachable at ${width.toInt()}dp', (
      tester,
    ) async {
      _useSize(tester, width);
      await _pumpRole(tester, UserRole.admin);

      expect(_destinations(), findsNWidgets(4));
      _expectNavigationTargetsReachable(tester);
      await _openMore(tester);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(ListTile),
        ),
        findsNWidgets(4),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Admin secondary routes open and select Plus on narrow screens', (
    tester,
  ) async {
    _useSize(tester, 390);
    await _pumpRole(tester, UserRole.admin);
    for (final (label, pageType) in [
      ('Commandes', AdminOrdersPage),
      ('Livraisons', AdminDeliveriesPage),
      ('Statistiques', AdminAnalyticsPage),
      ('Profil', RoleProfilePage),
    ]) {
      await _openMore(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text(label),
        ),
      );
      await _settle(tester);
      expect(find.byType(pageType), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        3,
      );
    }
    expect(tester.takeException(), isNull);
  });

  for (final width in [768.0, 1024.0, 1280.0]) {
    testWidgets(
      'Admin shows all seven sections in its sidebar at ${width.toInt()}dp',
      (tester) async {
        _useSize(tester, width);
        await _pumpRole(tester, UserRole.admin);

        expect(_sidebarItems(), findsNWidgets(7));
        expect(find.byType(NavigationBar), findsNothing);
        for (var index = 0; index < 7; index++) {
          await tester.tap(_sidebarItems().at(index));
          await _settle(tester);
          expect(
            tester.widget<ListTile>(_sidebarItems().at(index)).selected,
            isTrue,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final role in [UserRole.agent, UserRole.root]) {
    for (final width in [768.0, 1024.0, 1280.0]) {
      testWidgets(
        '${role.name} preserves every authorized sidebar destination at ${width.toInt()}dp',
        (tester) async {
          _useSize(tester, width);
          await _pumpRole(
            tester,
            role,
            capabilities: role == UserRole.agent ? _allAgentCapabilities : {},
          );

          final expectedCount = role == UserRole.agent ? 6 : 5;
          expect(_sidebarItems(), findsNWidgets(expectedCount));
          expect(find.byType(NavigationBar), findsNothing);
          if (role == UserRole.agent) {
            expect(find.text('OPÉRATIONS'), findsOneWidget);
            expect(find.text('ASSISTANCE'), findsOneWidget);
            expect(find.text('SUIVI'), findsOneWidget);
            final sidebarTexts = find.descendant(
              of: find.byKey(const ValueKey('roleShellSidebar')),
              matching: find.text('Validation du stock', skipOffstage: false),
            );
            expect(sidebarTexts, findsOneWidget);
          }
          for (var index = 0; index < expectedCount; index++) {
            await tester.tap(_sidebarItems().at(index));
            await _settle(tester);
            expect(
              tester.widget<ListTile>(_sidebarItems().at(index)).selected,
              isTrue,
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Agent navigation labels and sidebar groups are localized', (
    tester,
  ) async {
    _useSize(tester, 390);
    await _pumpRole(
      tester,
      UserRole.agent,
      capabilities: _allAgentCapabilities,
      language: 'en',
    );

    expect(_navLabel('Home'), findsOneWidget);
    expect(_navLabel('Support'), findsOneWidget);
    expect(_navLabel('Orders'), findsOneWidget);

    tester.view.physicalSize = const Size(1536, 1600);
    await tester.pump();
    expect(find.text('OPERATIONS'), findsOneWidget);
    expect(find.text('SUPPORT'), findsOneWidget);
    expect(find.text('FOLLOW-UP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Root keeps its primary spaces in compact navigation', (
    tester,
  ) async {
    _useSize(tester, 320);
    await _pumpRole(tester, UserRole.root);

    expect(_destinations(), findsNWidgets(4));
    expect(_navLabel('Accueil'), findsOneWidget);
    expect(_navLabel('Utilisateurs'), findsOneWidget);
    expect(_navLabel('Plateforme'), findsOneWidget);
    await _openMore(tester);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Statistiques'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Profil'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text uses compact Agent navigation without overflow', (
    tester,
  ) async {
    _useSize(tester, 430, textScale: 1.6);
    await _pumpRole(
      tester,
      UserRole.agent,
      capabilities: _allAgentCapabilities,
    );

    expect(_destinations(), findsNWidgets(4));
    _expectNavigationTargetsReachable(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text uses compact Admin navigation without overflow', (
    tester,
  ) async {
    _useSize(tester, 720, textScale: 1.6);
    await _pumpRole(tester, UserRole.admin);

    expect(_destinations(), findsNWidgets(4));
    _expectNavigationTargetsReachable(tester);
    expect(tester.takeException(), isNull);
  });

  // The dashboard section is the way back to the home screen of the signed-in
  // role: the navigation names it "Accueil" / "Home", while the section keeps
  // its own title for the pages that describe it.
  for (final role in UserRole.values) {
    testWidgets('${role.key} names its home destination "Accueil" in French', (
      tester,
    ) async {
      _useSize(tester, 390);
      await _pumpRole(tester, role, capabilities: _allAgentCapabilities);

      expect(_navLabel('Accueil'), findsOneWidget);
      expect(_navLabel('Tableau de bord'), findsNothing);
      expect(find.text('Tableau de bord'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('${role.key} names its home destination "Home" in English', (
      tester,
    ) async {
      _useSize(tester, 390);
      await _pumpRole(
        tester,
        role,
        capabilities: _allAgentCapabilities,
        language: 'en',
      );

      expect(_navLabel('Home'), findsOneWidget);
      expect(_navLabel('Dashboard'), findsNothing);
      expect(find.text('Dashboard'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final role in [UserRole.agent, UserRole.admin, UserRole.root]) {
    testWidgets('${role.key} names its sidebar home entry "Accueil"', (
      tester,
    ) async {
      _useSize(tester, 390);
      await _pumpRole(tester, role, capabilities: _allAgentCapabilities);
      tester.view.physicalSize = const Size(1536, 1600);
      await tester.pump();
      await _settle(tester);

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('roleShellSidebar')),
          matching: find.text('Accueil'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
