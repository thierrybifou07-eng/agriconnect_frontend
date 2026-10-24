import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/admin/application/admin_providers.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/domain/admin_moderation_status.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/domain/admin_product.dart';
import 'package:agri_connect/features/admin/domain/admin_user.dart';
import 'package:agri_connect/features/admin/presentation/admin_analytics_page.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

import 'support/fakes.dart';

/// Widths the section actually meets: the narrowest phone still sold, the
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

/// Signs an administrator in and mounts the real application.
///
/// The full app is used on purpose: it is the only way to prove the router
/// serves the analytics section instead of the generic placeholder, so a
/// regression in `app_router.dart` fails here rather than in a demo.
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

/// Opens a console section from the bottom navigation.
///
/// The bar is always on screen, unlike the dashboard shortcuts, and tapping it
/// is the route a reader actually takes.
Future<void> _openSection(WidgetTester tester, String label) async {
  final sidebar = find.byKey(const ValueKey('roleShellSidebar'));
  if (sidebar.evaluate().isNotEmpty) {
    await tester.tap(
      find.descendant(
        of: sidebar,
        matching: find.widgetWithText(ListTile, label),
      ),
    );
    await _settle(tester);
    return;
  }

  final destinations = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byType(NavigationDestination),
  );
  final matchingIndex = destinations.evaluate().toList().indexWhere(
    (element) => (element.widget as NavigationDestination).label == label,
  );
  if (matchingIndex >= 0) {
    await tester.tap(destinations.at(matchingIndex));
  } else {
    await tester.tap(destinations.last);
    await _settle(tester);
    await tester.tap(
      find.descendant(of: find.byType(BottomSheet), matching: find.text(label)),
    );
  }
  await _settle(tester);
}

ScrollableState _mainScrollable(WidgetTester tester) =>
    tester.state<ScrollableState>(
      find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
    );

/// Brings a widget into the viewport, building it first when it is lazy.
Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      target,
      220,
      scrollable: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    );
  }
  await tester.ensureVisible(target);
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await _settle(tester);
}

Finder _key(String name) => find.byKey(ValueKey(name));

/// The figure of one tile, addressed by its key rather than by its value.
Finder _figureValue(String id, String value) => find.descendant(
  of: _key('admin.analytics.figure.$id'),
  matching: find.text(value),
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

AdminUser _user(String id, UserRole role) => AdminUser(
  id: id,
  fullName: 'User $id',
  email: '$id@agriconnect.app',
  role: role,
  joinedAt: DateTime(2026, 7, 1),
  lastActiveAt: DateTime(2026, 9, 10),
);

void main() {
  group('Admin analytics', () {
    testWidgets('the section shows the figures the repository returns', (
      tester,
    ) async {
      _useSize(tester, const Size(430, 932));
      await _pumpAdmin(tester);
      await _settle(tester);
      await _openSection(tester, 'Statistiques');

      // The router served the real page, not the generic placeholder.
      expect(find.byType(AdminAnalyticsPage), findsOneWidget);
      expect(find.text('Statistiques de la plateforme'), findsOneWidget);

      // Six accounts, four products, five orders, four deliveries — counted
      // from the same lists the other admin sections read, never hard-coded.
      expect(_figureValue('users', '6'), findsOneWidget);
      expect(_figureValue('products', '4'), findsOneWidget);
      expect(_figureValue('orders', '5'), findsOneWidget);
      expect(_figureValue('deliveries', '4'), findsOneWidget);

      // The three indicators the dashboard left dormant, read from the
      // aggregate rather than recomputed: two live products, three open orders
      // (pending + confirmed + in transit), one completed delivery.
      expect(_figureValue('published', '2'), findsOneWidget);
      expect(_figureValue('activeOrders', '3'), findsOneWidget);
      expect(_figureValue('completedDeliveries', '1'), findsOneWidget);

      // The four distributions, each drawn from the repository's own lists.
      await _scrollTo(tester, _key('admin.analytics.distribution.users'));
      expect(_key('admin.analytics.distribution.users'), findsOneWidget);
      expect(_key('admin.analytics.distribution.products'), findsOneWidget);
      expect(_key('admin.analytics.distribution.orders'), findsOneWidget);
      expect(_key('admin.analytics.distribution.deliveries'), findsOneWidget);

      // No history means no chart: the absence is stated, not drawn.
      expect(
        find.textContaining("L'historique et les séries temporelles"),
        findsOneWidget,
      );
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('the figures follow the repository, not a fixed seed', (
      tester,
    ) async {
      _useSize(tester, const Size(430, 932));
      await _pumpAdmin(
        tester,
        repo: FakeAdminRepository(
          users: [
            _user('u1', UserRole.supplier),
            _user('u2', UserRole.supplier),
            _user('u3', UserRole.buyer),
          ],
          products: [
            AdminProduct(
              id: 'p1',
              name: 'Igname',
              category: 'Tubercules',
              price: 700,
              stockQuantity: 80,
              unit: 'kg',
              ownerId: 'u1',
              ownerName: 'User u1',
              submittedAt: DateTime(2026, 9, 1),
              moderation: AdminModerationStatus.validated,
            ),
            AdminProduct(
              id: 'p2',
              name: 'Manioc',
              category: 'Tubercules',
              price: 500,
              stockQuantity: 40,
              unit: 'kg',
              ownerId: 'u2',
              ownerName: 'User u2',
              submittedAt: DateTime(2026, 9, 2),
              moderation: AdminModerationStatus.pending,
            ),
          ],
          orders: [
            AdminOrder(
              id: 'o1',
              orderNumber: 'CMD-1',
              status: AdminOrderStatus.pending,
              buyerId: 'u3',
              buyerName: 'User u3',
              sellerId: 'u1',
              sellerName: 'User u1',
              amount: 12000,
              itemCount: 2,
              placedAt: DateTime(2026, 9, 5),
            ),
            AdminOrder(
              id: 'o2',
              orderNumber: 'CMD-2',
              status: AdminOrderStatus.pending,
              buyerId: 'u3',
              buyerName: 'User u3',
              sellerId: 'u2',
              sellerName: 'User u2',
              amount: 8000,
              itemCount: 1,
              placedAt: DateTime(2026, 9, 6),
            ),
          ],
          deliveries: [
            AdminDelivery(
              id: 'd1',
              orderId: 'o1',
              status: AdminDeliveryStatus.delivered,
              driverId: 'u1',
              driverName: 'User u1',
              pickupLabel: 'A',
              destinationLabel: 'B',
              distanceKm: 4.0,
              baseFee: 1000,
              totalFee: 1500,
              scheduledAt: DateTime(2026, 9, 5),
            ),
          ],
        ),
      );
      await _settle(tester);
      await _openSection(tester, 'Statistiques');

      // Three accounts, two products, two orders, one delivery: numbers that
      // differ from the default seed, so a hard-coded dashboard would fail.
      expect(_figureValue('users', '3'), findsOneWidget);
      expect(_figureValue('products', '2'), findsOneWidget);
      expect(_figureValue('orders', '2'), findsOneWidget);
      expect(_figureValue('deliveries', '1'), findsOneWidget);
      expect(_figureValue('published', '1'), findsOneWidget);
      expect(_figureValue('activeOrders', '2'), findsOneWidget);
      expect(_figureValue('completedDeliveries', '1'), findsOneWidget);
    });

    testWidgets('a skeleton holds the figures until the aggregate is known', (
      tester,
    ) async {
      _useSize(tester, const Size(430, 932));
      final gate = Completer<void>();
      await _pumpAdmin(tester, repo: FakeAdminRepository(statsGate: gate));

      // Deliberately not pumpAndSettle: the skeleton breathes forever, so the
      // tree never reaches a quiet frame while it is on screen.
      await _openSection(tester, 'Statistiques');
      await tester.pump();
      expect(find.byType(SkeletonBox), findsWidgets);
      expect(_figureValue('users', '6'), findsNothing);

      gate.complete();
      await _settle(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(_figureValue('users', '6'), findsOneWidget);
    });

    testWidgets('a failed figures section says so and can be retried', (
      tester,
    ) async {
      _useSize(tester, const Size(430, 932));
      final repo = FakeAdminRepository();
      repo.setStatsThrows(const ServerFailure('stats_unavailable'));
      await _pumpAdmin(tester, repo: repo);
      await _settle(tester);
      await _openSection(tester, 'Statistiques');

      expect(_key('admin.error.figures'), findsOneWidget);
      expect(_figureValue('users', '6'), findsNothing);

      repo.setStatsThrows(null);
      await tester.tap(_key('admin.retry.figures'));
      await _settle(tester);

      expect(_key('admin.error.figures'), findsNothing);
      expect(_figureValue('users', '6'), findsOneWidget);
      expect(repo.fetchStatsCalls, greaterThanOrEqualTo(2));
    });

    testWidgets('one failing distribution degrades alone', (tester) async {
      _useSize(tester, const Size(430, 932));
      await _pumpAdmin(
        tester,
        repo: FakeAdminRepository(ordersThrows: const NetworkFailure()),
      );
      await _settle(tester);
      await _openSection(tester, 'Statistiques');

      // The orders distribution reports the failure…
      await _scrollTo(tester, _key('admin.error.distribution.orders'));
      expect(_key('admin.error.distribution.orders'), findsOneWidget);

      // …while the figures and the other distributions, served by other calls,
      // stay readable.
      await _scrollTo(tester, _key('admin.analytics.distribution.users'));
      expect(_key('admin.analytics.distribution.users'), findsOneWidget);
      expect(_key('admin.analytics.distribution.products'), findsOneWidget);
      expect(_key('admin.analytics.distribution.deliveries'), findsOneWidget);
    });

    testWidgets('an empty platform is stated in words, not as zeroes', (
      tester,
    ) async {
      _useSize(tester, const Size(430, 932));
      await _pumpAdmin(
        tester,
        repo: FakeAdminRepository(
          users: const [],
          products: const [],
          orders: const [],
          deliveries: const [],
        ),
      );
      await _settle(tester);
      await _openSection(tester, 'Statistiques');

      expect(_key('admin.empty.figures'), findsOneWidget);
      expect(
        find.text('Aucune donnée à analyser pour le moment'),
        findsOneWidget,
      );
      expect(_figureValue('users', '0'), findsNothing);

      // Each distribution says there is nothing to split rather than drawing an
      // empty bar.
      await _scrollTo(tester, _key('admin.analytics.distribution.users'));
      expect(find.text('Rien à répartir pour le moment'), findsNWidgets(4));
    });

    testWidgets('the section speaks English when the reader does', (
      tester,
    ) async {
      _useSize(tester, const Size(430, 932));
      await _pumpAdmin(tester, language: 'en');
      await _settle(tester);
      await _openSection(tester, 'Analytics');

      expect(find.text('Platform analytics'), findsOneWidget);
      expect(_figureValue('published', '2'), findsOneWidget);
      expect(find.text('Published products'), findsOneWidget);
      expect(find.text('Active orders'), findsOneWidget);
      expect(find.text('Completed deliveries'), findsOneWidget);

      await _scrollTo(tester, _key('admin.analytics.distribution.products'));
      expect(find.text('Products by status'), findsOneWidget);
      expect(
        find.textContaining('History and time series are not available'),
        findsOneWidget,
      );
    });

    test('every new analytic key is translated in both languages', () {
      const keys = [
        'adminAnalyticsTitle',
        'adminAnalyticsSubtitle',
        'adminAnalyticsVolumeTitle',
        'adminAnalyticsIndicatorsTitle',
        'adminAnalyticsPublished',
        'adminAnalyticsActiveOrders',
        'adminAnalyticsCompletedDeliveries',
        'adminAnalyticsEmpty',
        'adminAnalyticsNoHistory',
        'adminDistributionProducts',
      ];
      final fr =
          jsonDecode(
                File(
                  'lib/core/localization/l10n/app_fr.arb',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final en =
          jsonDecode(
                File(
                  'lib/core/localization/l10n/app_en.arb',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;

      for (final key in keys) {
        expect(fr[key], isA<String>(), reason: '$key missing in app_fr.arb');
        expect(en[key], isA<String>(), reason: '$key missing in app_en.arb');
        expect((fr[key] as String).trim(), isNotEmpty);
        expect((en[key] as String).trim(), isNotEmpty);
      }
    });

    for (final size in _widths) {
      testWidgets('lays out at ${size.width.toInt()}px without overflow', (
        tester,
      ) async {
        _useSize(tester, size);
        await _pumpAdmin(tester);
        await _settle(tester);
        await _openSection(tester, 'Statistiques');
        await _expectNoRenderError(tester, 'analytics ${size.width}px');
      });
    }

    testWidgets('holds at large text', (tester) async {
      _useSize(tester, const Size(360, 800), textScale: 1.6);
      await _pumpAdmin(tester);
      await _settle(tester);
      await _openSection(tester, 'Statistiques');
      await _expectNoRenderError(tester, 'analytics 1.6x text');
    });
  });
}
