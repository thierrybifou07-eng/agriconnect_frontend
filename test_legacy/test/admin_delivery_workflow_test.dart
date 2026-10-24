import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/presentation/admin_deliveries_page.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';

import 'support/fakes.dart';

/// The admin delivery workspace: one leg at a time, a real read after every
/// write, one request per tap, and three honest states — loading, failure and
/// "this delivery no longer exists" — each with a way forward.

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

Future<void> _openFirstDelivery(WidgetTester tester) async {
  await tester.tap(find.text('d1'));
  await _settle(tester);
}

void main() {
  group('the deliveries workspace reflects its writes', () {
    testWidgets('a status change is re-read on the sheet it was made from', (
      tester,
    ) async {
      final repository = FakeAdminRepository();
      await _pumpPage(tester, AdminDeliveriesPage(repository: repository));
      await _settle(tester);
      await _openFirstDelivery(tester);

      // d1 starts in pick-up; its one offered move is "in transit".
      expect(find.text('Marquer en transit'), findsOneWidget);

      await tester.tap(find.text('Marquer en transit'));
      await _settle(tester);

      expect(find.text('Livraison mise à jour avec succès.'), findsOneWidget);
      // The sheet re-read the delivery: the move is gone, the next leg is here.
      expect(find.text('Marquer en transit'), findsNothing);
      expect(find.text('Marquer livrée'), findsOneWidget);
    });

    testWidgets('pulling the sheet down re-reads the delivery', (tester) async {
      final repository = FakeAdminRepository();
      await _pumpPage(tester, AdminDeliveriesPage(repository: repository));
      await _settle(tester);
      await _openFirstDelivery(tester);

      // Change the delivery behind the sheet's back.
      await repository.updateDeliveryStatus(
        'd1',
        AdminDeliveryStatus.inTransit,
      );

      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await _settle(tester);

      expect(find.text('Marquer livrée'), findsOneWidget);
    });
  });

  group('the deliveries workspace guards concurrent writes', () {
    testWidgets('a second tap while a move is in flight sends one request', (
      tester,
    ) async {
      final repository = _GatedAdminRepository();
      await _pumpPage(tester, AdminDeliveriesPage(repository: repository));
      await _settle(tester);
      await _openFirstDelivery(tester);

      await tester.tap(find.text('Marquer en transit'));
      await tester.pump();

      // The button is already disabled once the first tap set the sheet busy, so
      // the second tap cannot reach the repository.
      await tester.tap(find.text('Marquer en transit'), warnIfMissed: false);
      await tester.pump();
      expect(repository.updates, 1);

      repository.gate.complete();
      await _settle(tester);
      expect(repository.updates, 1);
      expect(find.text('Marquer livrée'), findsOneWidget);
    });
  });

  group('the deliveries workspace tells its states apart', () {
    testWidgets('a failing refresh shows the error card without throwing', (
      tester,
    ) async {
      final repository = FakeAdminRepository();
      await _pumpPage(tester, AdminDeliveriesPage(repository: repository));
      await _settle(tester);

      repository.deliveriesThrows = const ServerFailure('boom');
      final before = repository.fetchDeliveriesCalls;
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 800),
        1000,
      );
      await tester.pumpAndSettle();

      expect(repository.fetchDeliveriesCalls, greaterThan(before));
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('admin.error.deliveries')),
        findsOneWidget,
      );
    });

    testWidgets('a failed load can be retried', (tester) async {
      final repository = FakeAdminRepository(
        deliveriesThrows: const ServerFailure('boom'),
      );
      await _pumpPage(tester, AdminDeliveriesPage(repository: repository));
      await _settle(tester);

      expect(
        find.byKey(const ValueKey('admin.error.deliveries')),
        findsOneWidget,
      );

      repository.deliveriesThrows = null;
      await tester.tap(find.byKey(const ValueKey('admin.retry.deliveries')));
      await _settle(tester);

      expect(
        find.byKey(const ValueKey('admin.error.deliveries')),
        findsNothing,
      );
      expect(find.text('d1'), findsOneWidget);
    });

    testWidgets(
      'an unknown delivery offers a way out, not an endless spinner',
      (tester) async {
        await _pumpPage(
          tester,
          AdminDeliveriesPage(repository: _VanishingAdminRepository()),
        );
        await _settle(tester);
        await _openFirstDelivery(tester);

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(EmptyState), findsOneWidget);
        expect(find.text('Livraison introuvable.'), findsOneWidget);

        // The way out returns to the list the sheet came from.
        await tester.tap(find.text('Retour'));
        await tester.pumpAndSettle();
        expect(find.text('d1'), findsOneWidget);
        expect(find.byType(EmptyState), findsNothing);
      },
    );
  });

  group('the deliveries workspace holds at the sizes it has to survive', () {
    for (final size in [const Size(320, 640), const Size(1200, 900)]) {
      for (final scale in [1.0, 1.5]) {
        testWidgets('the sheet lays out on $size at ${scale}x text', (
          tester,
        ) async {
          await _pumpPage(
            tester,
            AdminDeliveriesPage(repository: FakeAdminRepository()),
            size: size,
            textScale: scale,
          );
          await _settle(tester);
          await _openFirstDelivery(tester);

          expect(tester.takeException(), isNull);
          expect(find.text('Suivi'), findsWidgets);
        });
      }
    }
  });

  group('the delivery sheet labels its rows', () {
    testWidgets('the sheet subtitles speak the reader\'s language', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        AdminDeliveriesPage(repository: FakeAdminRepository()),
      );
      await _settle(tester);
      await _openFirstDelivery(tester);

      expect(find.text('Collecte'), findsOneWidget);
      expect(find.text('Destination'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Suivi'), findsWidgets);
    });
  });
}

/// Holds the first delivery update open, so a second tap lands while the first
/// write is still in flight.
class _GatedAdminRepository extends FakeAdminRepository {
  final Completer<void> gate = Completer<void>();
  int updates = 0;

  @override
  Future<void> updateDeliveryStatus(
    String deliveryId,
    AdminDeliveryStatus status,
  ) async {
    updates++;
    await gate.future;
    return super.updateDeliveryStatus(deliveryId, status);
  }
}

/// Lists a delivery it will not hand back by id: the sheet has to tell a
/// finished, empty lookup from one still running.
class _VanishingAdminRepository extends FakeAdminRepository {
  @override
  Future<AdminDelivery?> fetchDeliveryById(String deliveryId) async => null;
}
