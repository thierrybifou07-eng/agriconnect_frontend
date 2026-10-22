import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/admin/application/admin_providers.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/presentation/admin_orders_page.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_order_tile.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

import 'support/fakes.dart';

/// The admin orders workspace: the section is reachable from the shell, the
/// list searches and filters over the fields the repository actually holds, the
/// detail reports every field the model carries, and three honest states —
/// loading, failure and "this order no longer exists" — each have a way
/// forward. Order status changes are deliberately not offered, so nothing here
/// pretends a mutation ran.

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  String language = 'fr',
  Size size = const Size(800, 1600),
  double textScale = 1.0,
}) {
  const dpr = 1.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = size * dpr;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  return tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: page,
    ),
  );
}

/// Signs an administrator in and mounts the whole app, so the shell — and its
/// routing into the orders section — is exercised, not just the page.
Future<FakeAdminRepository> _pumpAdmin(
  WidgetTester tester, {
  FakeAdminRepository? repo,
  String language = 'fr',
  Size size = const Size(412, 915),
}) async {
  final repository = repo ?? FakeAdminRepository();
  const dpr = 3.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = size * dpr;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': language,
    'welcome_selected_role_v1': 'admin',
    'auth_user_v1': jsonEncode(
      AuthUser(
        id: 'a1',
        fullName: 'Awa Traore',
        email: 'awa@agriconnect.app',
        role: UserRole.admin,
      ).toJson(),
    ),
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [adminRepositoryProvider.overrideWithValue(repository)],
      child: const AgriConnectApp(),
    ),
  );
  await tester.pump();
  await _settle(tester);
  return repository;
}

Future<void> _openFirstOrder(WidgetTester tester) async {
  await tester.tap(find.text('CMD-1001'));
  await _settle(tester);
}

/// The pushed detail route. The list route underneath stays in the tree (the
/// Overlay keeps it, and it is not an `Offstage`), so detail assertions are
/// scoped to this subtree to avoid matching the list behind it.
final Finder _detail = find.byKey(const ValueKey('adminOrderDetail'));

/// Removes the spaces a number pattern inserts, so an amount matches whatever
/// grouping the current locale uses.
String _moneyText(int amount, {String locale = 'fr'}) =>
    '${NumberFormat.decimalPattern(locale).format(amount)} FCFA';

void main() {
  group('the orders section is wired into the shell', () {
    testWidgets('an administrator opens it from the compact More menu', (
      tester,
    ) async {
      await _pumpAdmin(tester);

      final moreTab = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Plus'),
      );
      expect(moreTab, findsOneWidget);

      await tester.tap(moreTab);
      await _settle(tester);

      final ordersEntry = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Commandes'),
      );
      expect(ordersEntry, findsOneWidget);
      await tester.tap(ordersEntry);
      await _settle(tester);

      expect(find.byType(AdminOrdersPage), findsOneWidget);
      expect(find.text('Rechercher une commande…'), findsOneWidget);
      // The section routed to the real page, not the under-construction stub.
      expect(find.text('Section en construction'), findsNothing);
    });
  });

  group('the orders list reads the repository', () {
    testWidgets('it lists every seeded order', (tester) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: FakeAdminRepository()),
      );
      await _settle(tester);

      expect(find.text('CMD-1001'), findsOneWidget);
      expect(find.text('CMD-1005'), findsOneWidget);
      expect(find.textContaining('Fatoumata Keita'), findsWidgets);
    });

    testWidgets('the search narrows the list', (tester) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: FakeAdminRepository()),
      );
      await _settle(tester);

      await tester.enterText(find.byType(TextField), 'CMD-1004');
      await _settle(tester);

      // The field itself holds the query, so match the tile, not any Text.
      expect(
        find.descendant(
          of: find.byType(AdminOrderTile),
          matching: find.text('CMD-1004'),
        ),
        findsOneWidget,
      );
      expect(find.text('CMD-1001'), findsNothing);
    });

    testWidgets('a status filter narrows the list', (tester) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: FakeAdminRepository()),
      );
      await _settle(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Annulée'));
      await _settle(tester);

      expect(find.text('CMD-1005'), findsOneWidget);
      expect(find.text('CMD-1001'), findsNothing);
    });
  });

  group('the order detail reports what the model holds', () {
    testWidgets('it shows the order number, parties, items and amount', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: FakeAdminRepository()),
      );
      await _settle(tester);
      await _openFirstOrder(tester);

      expect(
        find.widgetWithText(AppBar, 'Détail de la commande'),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _detail, matching: find.text('CMD-1001')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _detail, matching: find.text('Fatoumata Keita')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _detail, matching: find.text('Awa Traore')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _detail, matching: find.text('Tomates de saison')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _detail, matching: find.text('Riz local')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _detail, matching: find.text(_moneyText(45000))),
        findsOneWidget,
      );
      // The buyer and seller are tieable back to their accounts.
      expect(
        find.descendant(
          of: _detail,
          matching: find.textContaining('Compte u3'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a status change is not offered, and says why', (tester) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: FakeAdminRepository()),
      );
      await _settle(tester);
      await _openFirstOrder(tester);

      expect(
        find.descendant(
          of: _detail,
          matching: find.text('Changement de statut indisponible'),
        ),
        findsOneWidget,
      );
      // No control lets an administrator jump an undefined workflow.
      expect(
        find.descendant(
          of: _detail,
          matching: find.widgetWithText(FilledButton, 'Confirmer'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: _detail, matching: find.byType(ChoiceChip)),
        findsNothing,
      );
    });

    testWidgets('an order with no delivery link shows no delivery row', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: FakeAdminRepository()),
      );
      await _settle(tester);
      await _openFirstOrder(tester);

      // The seeded order carries no deliveryId, so nothing invents a link.
      expect(
        find.descendant(of: _detail, matching: find.text('Livraison liée')),
        findsNothing,
      );
    });

    testWidgets('an order that carries a delivery id shows the link', (
      tester,
    ) async {
      final repository = FakeAdminRepository(
        orders: [
          AdminOrder(
            id: 'o9',
            orderNumber: 'CMD-2009',
            status: AdminOrderStatus.inTransit,
            buyerId: 'u3',
            buyerName: 'Fatoumata Keita',
            sellerId: 'u1',
            sellerName: 'Awa Traore',
            amount: 12000,
            itemCount: 1,
            placedAt: DateTime(2026, 9, 8),
            deliveryId: 'd9',
            deliveryStatus: 'inTransit',
          ),
        ],
      );
      await _pumpPage(tester, AdminOrdersPage(repository: repository));
      await _settle(tester);

      await tester.tap(find.text('CMD-2009'));
      await _settle(tester);

      expect(
        find.descendant(of: _detail, matching: find.text('Livraison liée')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _detail, matching: find.textContaining('d9')),
        findsOneWidget,
      );
    });
  });

  group('the orders workspace tells its states apart', () {
    testWidgets('a pending load shows a skeleton, not a spinner', (
      tester,
    ) async {
      final repository = FakeAdminRepository(ordersGate: Completer<void>());
      await _pumpPage(tester, AdminOrdersPage(repository: repository));
      await tester.pump();

      expect(find.byType(CardListSkeleton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      repository.ordersGate!.complete();
      await _settle(tester);
      expect(find.byType(CardListSkeleton), findsNothing);
      expect(find.text('CMD-1001'), findsOneWidget);
    });

    testWidgets('a failed load can be retried', (tester) async {
      final repository = FakeAdminRepository(
        ordersThrows: const ServerFailure('boom'),
      );
      await _pumpPage(tester, AdminOrdersPage(repository: repository));
      await _settle(tester);

      expect(find.byKey(const ValueKey('admin.error.orders')), findsOneWidget);

      repository.ordersThrows = null;
      await tester.tap(find.byKey(const ValueKey('admin.retry.orders')));
      await _settle(tester);

      expect(find.byKey(const ValueKey('admin.error.orders')), findsNothing);
      expect(find.text('CMD-1001'), findsOneWidget);
    });

    testWidgets('an empty order book says so', (tester) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: FakeAdminRepository(orders: [])),
      );
      await _settle(tester);

      expect(find.text('Aucune commande'), findsOneWidget);
      expect(
        find.text('Les commandes enregistrées apparaîtront ici.'),
        findsOneWidget,
      );
    });

    testWidgets('an unknown order offers a way out, not an endless spinner', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: _VanishingAdminRepository()),
      );
      await _settle(tester);
      await _openFirstOrder(tester);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Commande introuvable.'), findsOneWidget);

      await tester.tap(find.text('Retour'));
      await tester.pumpAndSettle();
      expect(find.text('CMD-1001'), findsOneWidget);
      expect(find.byType(EmptyState), findsNothing);
    });

    testWidgets('a failing detail load shows the error card without throwing', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: _FailingDetailRepository()),
      );
      await _settle(tester);
      await _openFirstOrder(tester);

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('admin.error.orderDetail')),
        findsOneWidget,
      );
    });
  });

  group('the orders workspace speaks the reader\'s language', () {
    testWidgets('in French', (tester) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: FakeAdminRepository()),
      );
      await _settle(tester);

      expect(find.text('Rechercher une commande…'), findsOneWidget);
      expect(find.text('Tous'), findsOneWidget);
    });

    testWidgets('in English', (tester) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: FakeAdminRepository()),
        language: 'en',
      );
      await _settle(tester);

      expect(find.text('Search an order…'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('No orders'), findsNothing);
    });

    testWidgets('the detail is titled in English too', (tester) async {
      await _pumpPage(
        tester,
        AdminOrdersPage(repository: FakeAdminRepository()),
        language: 'en',
      );
      await _settle(tester);
      await _openFirstOrder(tester);

      expect(find.widgetWithText(AppBar, 'Order detail'), findsOneWidget);
      expect(find.text('Status change unavailable'), findsOneWidget);
    });
  });

  group('the orders workspace holds at the sizes it has to survive', () {
    for (final size in [const Size(320, 640), const Size(1200, 900)]) {
      for (final scale in [1.0, 1.5]) {
        testWidgets('list and detail lay out on $size at ${scale}x text', (
          tester,
        ) async {
          await _pumpPage(
            tester,
            AdminOrdersPage(repository: FakeAdminRepository()),
            size: size,
            textScale: scale,
          );
          await _settle(tester);
          await _openFirstOrder(tester);

          expect(tester.takeException(), isNull);
          expect(
            find.widgetWithText(AppBar, 'Détail de la commande'),
            findsOneWidget,
          );
        });
      }
    }
  });
}

/// Lists an order it will not hand back by id: the detail has to tell a
/// finished, empty lookup from one still running.
class _VanishingAdminRepository extends FakeAdminRepository {
  @override
  Future<AdminOrder?> fetchOrderById(String orderId) async => null;
}

/// Lists an order whose detail read fails, so the detail's error card is
/// observable without a backend.
class _FailingDetailRepository extends FakeAdminRepository {
  @override
  Future<AdminOrder?> fetchOrderById(String orderId) async =>
      throw const ServerFailure('boom');
}
