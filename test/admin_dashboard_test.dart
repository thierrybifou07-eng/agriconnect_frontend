import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/admin/application/admin_providers.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/presentation/admin_deliveries_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_orders_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_products_page.dart';
import 'package:agri_connect/features/admin/presentation/admin_users_page.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_dashboard_skeleton.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/shared/widgets/quick_action_grid.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';

import 'support/fakes.dart';

/// Widths a dashboard actually meets: the narrowest phone still sold, the
/// common ones, and a tablet-sized window.
const List<Size> _widths = [
  Size(320, 640),
  Size(360, 800),
  Size(412, 915),
  Size(430, 932),
  Size(1280, 800),
];

/// Overflow below this many pixels is rounding, not a layout a reader can see.
const double _subPixelOverflow = 0.01;

/// Revenue the fake repository can legitimately report: every seeded order but
/// the cancelled one.
const int _seedRevenue = 156600;

void _useSize(WidgetTester tester, Size logical, {double textScale = 1.0}) {
  const dpr = 3.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = logical * dpr;
  tester.view.padding = FakeViewPadding(top: 24 * dpr, bottom: 34 * dpr);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.view.resetPadding();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

Future<FakeAdminRepository> _pumpAdmin(
  WidgetTester tester, {
  FakeAdminRepository? repo,
  String language = 'fr',
}) async {
  final repository = repo ?? FakeAdminRepository();
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
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
  return repository;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

ScrollableState _mainScrollable(WidgetTester tester) =>
    tester.state<ScrollableState>(
      find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
    );

/// Scrolls the page until [target] is built and visible.
///
/// Two different problems, two different tools. A `ListView` only builds the
/// children near the viewport, so a section the reader would simply scroll to
/// does not exist yet and has to be brought into existence first. Once it is
/// mounted it can still sit below the fold, and mounting is not the same as
/// being reachable by a finger: [WidgetTester.ensureVisible] is what puts it
/// inside the viewport.
Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      target,
      220,
      scrollable: _scrollable(tester),
    );
  }
  await tester.ensureVisible(target);
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await _settle(tester);
}

Finder _scrollable(WidgetTester tester) => find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);

Future<void> _scrollToTop(WidgetTester tester) async {
  _mainScrollable(tester).position.jumpTo(0);
  await _settle(tester);
}

/// Removes every space a number pattern may insert, including the narrow and
/// non-breaking ones Dart's regex `\s` does not cover, so a figure can be
/// matched without knowing how the current locale writes it.
String _compact(String value) =>
    value.replaceAll(RegExp('[ \u00A0\u202F\u2009]'), '');

/// Finds a money label whatever separator the current locale inserts.
Finder _money(int amount) {
  final needle = '${amount}FCFA';
  return find.byWidgetPredicate(
    (w) => w is Text && _compact(w.data ?? '') == needle,
    description: 'money label $needle',
  );
}

Finder _key(String name) => find.byKey(ValueKey(name));

/// The figure of one tile, addressed by its key rather than by its value: two
/// tiles can legitimately hold the same number.
Finder _figureValue(String id, String value) =>
    find.descendant(of: _key('admin.figure.$id'), matching: find.text(value));

Finder _shortcut(String label) => find.descendant(
  of: find.byType(QuickActionGrid),
  matching: find.text(label),
);

/// Scrolls the page to its end and fails on any painted overflow.
Future<void> _expectNoRenderError(WidgetTester tester, String where) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final context = details.informationCollector?.call().join('\n') ?? '';
    final message = details.exceptionAsString();
    final overflow = RegExp(
      r'overflowed by ([\d.]+) pixels',
    ).firstMatch(message);
    if (overflow != null &&
        double.parse(overflow.group(1)!) < _subPixelOverflow) {
      return;
    }
    errors.add('$message\n$context');
  };

  try {
    for (var pass = 0; pass < 3; pass++) {
      var moved = false;
      final position = _mainScrollable(tester).position;
      final step = (position.viewportDimension / 2).clamp(80.0, 240.0);
      for (var i = 0; i < 60; i++) {
        if (!position.hasContentDimensions) break;
        if (position.pixels >= position.maxScrollExtent - 0.5) break;
        position.jumpTo(
          (position.pixels + step).clamp(0.0, position.maxScrollExtent),
        );
        moved = true;
        await _settle(tester);
      }
      if (!moved) break;
    }
    await _settle(tester);
    expect(errors, isEmpty, reason: 'render error on $where');
  } finally {
    FlutterError.onError = previous;
  }
}

void main() {
  testWidgets('the dashboard shows the figures the repository returns', (
    tester,
  ) async {
    await _pumpAdmin(tester);
    await _settle(tester);

    // Six accounts, four products, five orders, four deliveries, and a revenue
    // adding up to the seeded orders minus the cancelled one. Every number here
    // comes from the fake repository, so a dashboard that invented a trend or a
    // growth rate would have nothing to match.
    expect(_figureValue('users', '6'), findsOneWidget);
    expect(_figureValue('products', '4'), findsOneWidget);
    expect(_figureValue('orders', '5'), findsOneWidget);
    expect(_figureValue('deliveries', '4'), findsOneWidget);
    expect(
      find.descendant(
        of: _key('admin.figure.revenue'),
        matching: _money(_seedRevenue),
      ),
      findsOneWidget,
    );

    // The backlog counts the moderation and confirmation counters.
    expect(_key('attention.users'), findsOneWidget);
    expect(_key('attention.products'), findsOneWidget);
    expect(_key('attention.orders'), findsOneWidget);
    expect(_key('attention.deliveries'), findsOneWidget);

    // The two lists are the repository's own.
    await _scrollTo(tester, find.text('Ananas'));
    expect(find.text('Ananas'), findsOneWidget);
    await _scrollTo(tester, find.text('CMD-1001'));
    expect(find.text('CMD-1001'), findsOneWidget);
    expect(_key('admin.distribution.orders'), findsOneWidget);
    expect(_key('admin.distribution.deliveries'), findsOneWidget);
    expect(_key('admin.distribution.users'), findsOneWidget);
  });

  testWidgets('a skeleton holds the layout until the figures are known', (
    tester,
  ) async {
    final gate = Completer<void>();
    await _pumpAdmin(tester, repo: FakeAdminRepository(statsGate: gate));

    // Deliberately not pumpAndSettle: the skeleton breathes forever, so the
    // tree never reaches a quiet frame while it is on screen.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AdminDashboardSkeleton), findsOneWidget);
    expect(_figureValue('users', '6'), findsNothing);

    gate.complete();
    await _settle(tester);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AdminDashboardSkeleton), findsNothing);
    expect(_figureValue('users', '6'), findsOneWidget);
  });

  testWidgets('a failed section says so and can be retried', (tester) async {
    final repo = FakeAdminRepository();
    repo.setStatsThrows(const ServerFailure('stats_unavailable'));
    await _pumpAdmin(tester, repo: repo);
    await _settle(tester);

    expect(_key('admin.error.overview'), findsOneWidget);
    expect(_figureValue('users', '6'), findsNothing);

    repo.setStatsThrows(null);
    await tester.tap(_key('admin.retry.overview'));
    await _settle(tester);

    expect(_key('admin.error.overview'), findsNothing);
    expect(_figureValue('users', '6'), findsOneWidget);
    expect(repo.fetchStatsCalls, 2);
  });

  testWidgets('one failing list degrades alone, not the whole dashboard', (
    tester,
  ) async {
    await _pumpAdmin(
      tester,
      repo: FakeAdminRepository(ordersThrows: const NetworkFailure()),
    );
    await _settle(tester);

    await _scrollTo(tester, _key('admin.error.recentOrders'));
    // The orders section reports the failure...
    expect(_key('admin.error.recentOrders'), findsOneWidget);

    // ...while the figures, which come from another call, stay readable.
    await _scrollToTop(tester);
    expect(_figureValue('users', '6'), findsOneWidget);
    expect(_key('attention.users'), findsOneWidget);
  });

  testWidgets('refresh re-reads the repository instead of replaying it', (
    tester,
  ) async {
    final repo = await _pumpAdmin(tester);
    await _settle(tester);
    await _scrollTo(tester, find.text('CMD-1005'));
    expect(find.text('CMD-1005'), findsOneWidget);

    repo.setOrders([
      AdminOrder(
        id: 'o9',
        orderNumber: 'CMD-2009',
        status: AdminOrderStatus.confirmed,
        buyerId: 'u3',
        buyerName: 'Fatoumata Keita',
        sellerId: 'u1',
        sellerName: 'Awa Traore',
        amount: 99000,
        itemCount: 4,
        placedAt: DateTime(2026, 9, 12),
      ),
    ]);

    await _scrollToTop(tester);
    await tester.tap(_key('admin.refresh'));
    await _settle(tester);

    expect(repo.fetchOrdersCalls, greaterThanOrEqualTo(2));
    await _scrollTo(tester, find.text('CMD-2009'));
    expect(find.text('CMD-2009'), findsOneWidget);
    expect(find.text('CMD-1005'), findsNothing);
  });

  testWidgets('the products shortcut opens the products workspace', (
    tester,
  ) async {
    await _pumpAdmin(tester);
    await _settle(tester);

    // The shortcuts sit below the figures, so the reader scrolls to them. The
    // label is the console's own, not the farmer's "My products".
    await _scrollTo(tester, _shortcut('Produits'));
    await tester.tap(_shortcut('Produits'));
    await _settle(tester);

    expect(find.byType(AdminProductsPage), findsOneWidget);
  });

  testWidgets('the users shortcut opens the users workspace', (tester) async {
    await _pumpAdmin(tester);
    await _settle(tester);

    await _scrollTo(tester, _shortcut('Utilisateurs'));
    await tester.tap(_shortcut('Utilisateurs'));
    await _settle(tester);

    expect(find.byType(AdminUsersPage), findsOneWidget);
  });

  testWidgets('the deliveries shortcut opens the deliveries workspace', (
    tester,
  ) async {
    await _pumpAdmin(tester);
    await _settle(tester);

    await _scrollTo(tester, _shortcut('Livraisons'));
    await tester.tap(_shortcut('Livraisons'));
    await _settle(tester);

    expect(find.byType(AdminDeliveriesPage), findsOneWidget);
  });

  testWidgets('the orders figure opens the orders workspace', (tester) async {
    await _pumpAdmin(tester);
    await _settle(tester);

    expect(
      tester.widget<StatCard>(_key('admin.figure.orders')).onTap,
      isNotNull,
    );

    await _scrollTo(tester, _key('admin.figure.orders'));
    await tester.tap(_key('admin.figure.orders'));
    await _settle(tester);

    expect(find.byType(AdminOrdersPage), findsOneWidget);
  });

  testWidgets('an empty platform says so rather than inventing figures', (
    tester,
  ) async {
    await _pumpAdmin(
      tester,
      repo: FakeAdminRepository(
        users: [],
        products: [],
        orders: [],
        deliveries: [],
      ),
    );
    await _settle(tester);

    expect(_key('attention.clear'), findsOneWidget);
    expect(_figureValue('users', '0'), findsOneWidget);
    expect(_money(0), findsOneWidget);

    await _scrollTo(tester, _key('admin.empty.moderation'));
    expect(_key('admin.empty.moderation'), findsOneWidget);
    expect(_key('admin.empty.recentOrders'), findsOneWidget);
  });

  testWidgets('the dashboard reads the same in English', (tester) async {
    await _pumpAdmin(tester, language: 'en');
    await _settle(tester);

    expect(find.text('Key figures'), findsOneWidget);
    expect(find.text('Order revenue'), findsOneWidget);
    // The header pill carries the label and the date in one text.
    expect(find.textContaining('Today'), findsWidgets);

    await _scrollTo(tester, find.text('Products to moderate'));
    expect(find.text('Latest orders'), findsOneWidget);
  });

  testWidgets('the moderation row separates owner and category with a dot', (
    tester,
  ) async {
    await _pumpAdmin(tester);
    await _settle(tester);

    await _scrollTo(tester, find.text('Ananas'));
    // The dot between the owner and the category used to arrive double-encoded
    // as "Â·", which a reader saw in the middle of the moderation list.
    expect(find.text('Awa Traore · Fruits'), findsOneWidget);
    expect(find.textContaining('Â'), findsNothing);
  });

  for (final size in _widths) {
    final label = '${size.width.toInt()}dp';
    testWidgets('the dashboard holds together on a $label window', (
      tester,
    ) async {
      _useSize(tester, size);
      await _pumpAdmin(tester);
      await _settle(tester);

      expect(_key('admin.figure.users'), findsOneWidget);
      expect(_key('attention.users'), findsOneWidget);
      await _expectNoRenderError(tester, label);
    });
  }

  testWidgets('a large system font does not break the dashboard', (
    tester,
  ) async {
    _useSize(tester, const Size(360, 800), textScale: 1.3);
    await _pumpAdmin(tester);
    await _settle(tester);

    expect(_key('admin.figure.users'), findsOneWidget);
    await _expectNoRenderError(tester, '360dp at 1.3x');
  });

  testWidgets('the distributions share one row on a tablet', (tester) async {
    _useSize(tester, const Size(1280, 800));
    await _pumpAdmin(tester);
    await _settle(tester);

    await _scrollTo(tester, _key('admin.distribution.orders'));
    final top = tester.getTopLeft(_key('admin.distribution.orders')).dy;
    expect(
      tester.getTopLeft(_key('admin.distribution.deliveries')).dy,
      closeTo(top, 0.5),
    );
    expect(
      tester.getTopLeft(_key('admin.distribution.users')).dy,
      closeTo(top, 0.5),
    );
  });

  testWidgets('the distributions stack on a phone', (tester) async {
    _useSize(tester, const Size(412, 915));
    await _pumpAdmin(tester);
    await _settle(tester);

    await _scrollTo(tester, _key('admin.distribution.orders'));
    final top = tester.getTopLeft(_key('admin.distribution.orders')).dy;
    expect(
      tester.getTopLeft(_key('admin.distribution.deliveries')).dy,
      greaterThan(top),
    );
    expect(
      tester.getTopLeft(_key('admin.distribution.users')).dy,
      greaterThan(tester.getTopLeft(_key('admin.distribution.deliveries')).dy),
    );
  });
}
