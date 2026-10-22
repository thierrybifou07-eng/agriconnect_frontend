import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/driver/application/driver_providers.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';
import 'package:agri_connect/features/driver/presentation/driver_dashboard_page.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_deliveries_page.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_trips_page.dart';
import 'package:agri_connect/features/driver/presentation/widgets/driver_content.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

import 'support/fakes.dart';

/// Longest line the lists may take on a desktop window.
const double maxContentWidth = DriverContent.maxContentWidth;

Future<FakeDriverRepository> _pumpDriver(
  WidgetTester tester, {
  FakeDriverRepository? repo,
  String languageCode = 'fr',
}) async {
  final repository = repo ?? FakeDriverRepository();
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': languageCode,
    'welcome_selected_role_v1': 'driver',
    'auth_user_v1': jsonEncode(
      AuthUser(
        id: 'd1',
        fullName: 'Ibrahim Cissé',
        email: 'driver@agriconnect.app',
        role: UserRole.driver,
      ).toJson(),
    ),
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [driverRepositoryProvider.overrideWithValue(repository)],
      child: const AgriConnectApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
  return repository;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();
}

/// Opens a shell section by its own route: the navigation itself is already
/// covered by the dashboard tests, and the labels here would have to be
/// repeated in two languages.
Future<void> _openSection(WidgetTester tester, String path) async {
  // The shell keeps the previous section alive offstage, so the context is
  // taken from the whole tree rather than from what is on screen.
  final context = tester.element(
    find.byType(DriverDashboardPage, skipOffstage: false),
  );
  context.go(path);
  await _settle(tester);
}

Future<void> _openDeliveries(WidgetTester tester) async {
  await _openSection(tester, RoutePaths.driverDeliveries);
  expect(find.byType(DriverDeliveriesPage), findsOneWidget);
}

Future<void> _openTrips(WidgetTester tester) async {
  await _openSection(tester, RoutePaths.driverTrips);
  expect(find.byType(DriverTripsPage), findsOneWidget);
}

void main() {
  group('deliveries list', () {
    testWidgets('waits with a skeleton shaped like the cards it will show', (
      tester,
    ) async {
      final gate = Completer<void>();
      await _pumpDriver(
        tester,
        repo: FakeDriverRepository(deliveriesGate: gate),
      );
      await _openDeliveries(tester);

      expect(find.byType(CardListSkeleton), findsOneWidget);
      // A skeleton is not an empty state: nothing is claimed about the driver.
      expect(find.byType(EmptyState), findsNothing);
      expect(find.text('Aminata'), findsNothing);

      gate.complete();
      await _settle(tester);

      expect(find.byType(CardListSkeleton), findsNothing);
      expect(find.text('Aminata'), findsOneWidget);
    });

    testWidgets('a failed load is a retry, not an empty road', (tester) async {
      final repo = FakeDriverRepository(
        deliveriesThrows: const NetworkFailure(),
      );
      await _pumpDriver(tester, repo: repo);
      await _openDeliveries(tester);

      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byType(EmptyState), findsNothing);

      // The retry reaches the repository again instead of leaving the driver
      // with a dead screen.
      repo.deliveriesThrows = null;
      await tester.tap(find.text('Réessayer'));
      await _settle(tester);

      expect(repo.fetchDeliveriesCalls, greaterThan(1));
      expect(find.byType(FailureView), findsNothing);
      expect(find.text('Aminata'), findsOneWidget);
    });

    testWidgets('an empty road says so instead of showing a skeleton forever', (
      tester,
    ) async {
      await _pumpDriver(
        tester,
        repo: FakeDriverRepository(deliveries: const []),
      );
      await _openDeliveries(tester);

      expect(find.byType(CardListSkeleton), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Aucune livraison'), findsOneWidget);
      expect(find.text('Vos livraisons apparaîtront ici.'), findsOneWidget);
    });
  });

  group('history', () {
    testWidgets('waits with a skeleton before its routes are known', (
      tester,
    ) async {
      final gate = Completer<void>();
      await _pumpDriver(tester, repo: FakeDriverRepository(tripsGate: gate));
      await _openTrips(tester);

      expect(find.byType(CardListSkeleton), findsOneWidget);
      expect(find.text('Adjamé → Yopougon'), findsNothing);

      gate.complete();
      await _settle(tester);

      expect(find.text('Adjamé → Yopougon'), findsOneWidget);
    });

    testWidgets('a failed history load offers the retry that works', (
      tester,
    ) async {
      final repo = FakeDriverRepository(tripsThrows: const NetworkFailure());
      await _pumpDriver(tester, repo: repo);
      await _openTrips(tester);

      expect(find.byType(FailureView), findsOneWidget);

      repo.tripsThrows = null;
      await tester.tap(find.text('Réessayer'));
      await _settle(tester);

      expect(repo.fetchTripsCalls, greaterThan(1));
      expect(find.byType(FailureView), findsNothing);
      expect(find.text('Adjamé → Yopougon'), findsOneWidget);
    });

    testWidgets('a driver without routes gets the empty history, not a dead '
        'screen', (tester) async {
      await _pumpDriver(tester, repo: FakeDriverRepository(trips: const []));
      await _openTrips(tester);

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Aucun trajet'), findsOneWidget);
      expect(find.text('Vos trajets apparaîtront ici.'), findsOneWidget);
    });
  });

  group('dashboard upcoming trips', () {
    /// A trip whose deliveries are all delivered is over: it belongs to the
    /// history, not to the list of what is still ahead.
    DeliveryTrip finishedTrip() => DeliveryTrip(
      id: 't_done',
      routeLabel: 'Treichville → Cocody',
      vehicleLabel: 'Fourgonnette · ZZ-000-AA',
      deliveryIds: const ['d3'],
      scheduledAt: DateTime(2026, 9, 7),
      createdAt: DateTime(2026, 9, 7),
    );

    testWidgets('a route already driven is not announced as upcoming', (
      tester,
    ) async {
      await _pumpDriver(tester);
      await tester.scrollUntilVisible(
        find.text('Trajets à venir'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await _settle(tester);

      // t1 carries d1 and d2, both still open: the section has something real
      // to show.
      expect(find.text('Adjamé → Yopougon'), findsOneWidget);
      expect(find.text('Aucun trajet à venir'), findsNothing);
    });

    testWidgets('a driver whose routes are over is pointed at the history', (
      tester,
    ) async {
      await _pumpDriver(
        tester,
        repo: FakeDriverRepository(trips: [finishedTrip()]),
      );
      await tester.scrollUntilVisible(
        find.text('Trajets à venir'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await _settle(tester);

      expect(find.text('Treichville → Cocody'), findsNothing);
      expect(find.text('Aucun trajet à venir'), findsOneWidget);
      expect(
        find.text("Vos tournées terminées restent dans l'historique."),
        findsOneWidget,
      );
    });

    testWidgets('the history shortcut still opens the finished route', (
      tester,
    ) async {
      await _pumpDriver(
        tester,
        repo: FakeDriverRepository(trips: [finishedTrip()]),
      );
      await _openTrips(tester);

      // Left out of the dashboard, never lost: the history is where a finished
      // route belongs.
      expect(find.byType(DriverTripsPage), findsOneWidget);
      expect(find.text('Treichville → Cocody'), findsOneWidget);
    });
  });

  testWidgets('the lists keep their content in a readable measure on a desktop '
      'window', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const widths = [320.0, 390.0, 800.0, 1280.0];

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpDriver(tester);

      // The dashboard the driver lands on first reads in the same measure.
      final hero = tester.getRect(find.text('Bonjour, Ibrahim'));
      expect(hero.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(hero.right, lessThanOrEqualTo(width), reason: 'width $width');

      await _openDeliveries(tester);

      final card = tester.getRect(find.text('Aminata'));
      expect(card.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(card.right, lessThanOrEqualTo(width), reason: 'width $width');
      if (width > 2 * 16 + maxContentWidth) {
        // Centered measure, with the page padding kept on its sides.
        expect(
          card.left,
          greaterThanOrEqualTo(16 + 16),
          reason: 'width $width',
        );
      }

      await _openTrips(tester);
      final trip = tester.getRect(find.text('Adjamé → Yopougon'));
      expect(trip.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(trip.right, lessThanOrEqualTo(width), reason: 'width $width');
      if (width > 2 * 16 + maxContentWidth) {
        expect(
          trip.left,
          greaterThanOrEqualTo(16 + 16),
          reason: 'width $width',
        );
      }

      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('the lists speak the language the driver picked', (tester) async {
    await _pumpDriver(tester, languageCode: 'en');
    await _openDeliveries(tester);

    expect(find.text('Deliveries'), findsWidgets);
    expect(find.text('In transit'), findsWidgets);
    // The date follows the locale instead of staying on the French pattern.
    expect(find.text('Sep 10, 2026'), findsWidgets);

    // The delivered parcel is further down the road: its status is English too.
    await tester.scrollUntilVisible(find.text('Souleymane'), 240);
    await _settle(tester);
    expect(find.text('Delivered'), findsWidgets);
    expect(find.text('Sep 8, 2026'), findsWidgets);

    await _openTrips(tester);

    expect(find.text('Trips'), findsWidgets);
    expect(find.text('0 / 2 stops delivered'), findsOneWidget);
    expect(find.text('0 / 2 arrêts livrés'), findsNothing);
  });
}
