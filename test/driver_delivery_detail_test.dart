import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:agri_connect/features/driver/presentation/driver_dashboard_page.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_deliveries_page.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_delivery_detail_page.dart';
import 'package:agri_connect/features/driver/presentation/widgets/delivery_summary.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';

import 'support/fakes.dart';

const double maxContentWidth = 720;

Future<FakeDriverRepository> _pumpDriver(
  WidgetTester tester, {
  FakeDriverRepository? repo,
}) async {
  final repository = repo ?? FakeDriverRepository();
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': 'fr',
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

/// Opens the delivery the dashboard is really working on, through its own
/// shortcut: no path is typed here, the driver reaches it the way he would.
Future<void> _openActiveDelivery(WidgetTester tester) async {
  await tester.tap(find.text('Ma livraison active'));
  await _settle(tester);
}

/// Opens a sheet by its route, for the paths no list can offer — a delivery
/// opened while the list itself failed to load.
Future<void> _openDeliveryByRoute(
  WidgetTester tester,
  String deliveryId,
) async {
  final context = tester.element(find.byType(DriverDashboardPage));
  context.go(RoutePaths.driverDelivery(deliveryId));
  await _settle(tester);
}

void main() {
  testWidgets('the active sheet joins the route, the items, the trip and the '
      'contact without inventing a figure', (tester) async {
    await _pumpDriver(tester);
    await _openActiveDelivery(tester);

    // The header and the progression: what the parcel really is, and how far
    // along the delivery actually stands.
    expect(find.text('Commande b_9002'), findsOneWidget);
    expect(find.text('Fatoumata'), findsWidgets);
    expect(find.text('Programmée le 10 sept. 2026'), findsOneWidget);
    expect(find.text('Suivi de livraison'), findsOneWidget);
    expect(find.text('Étape 2 sur 3'), findsOneWidget);
    expect(find.text('À ramasser'), findsOneWidget);
    expect(find.text('Livrée'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Trajets'), 240);
    await _settle(tester);
    expect(find.text('Itinéraire'), findsOneWidget);
    expect(find.text('Entrepôt central'), findsOneWidget);
    expect(find.text('Cocody, stand 8'), findsOneWidget);
    expect(find.text('Articles'), findsOneWidget);
    // The volume is stated once for the delivery and once per line, without a
    // second bare quantity on the same row.
    expect(find.text('Manioc'), findsOneWidget);
    expect(find.text('30 kg'), findsOneWidget);

    // The trip is joined on the identifiers both sides really hold.
    expect(find.text('Trajets'), findsOneWidget);
    expect(find.text('Adjamé → Yopougon'), findsOneWidget);
    expect(find.text('Fourgonnette · ZZ-000-AA'), findsOneWidget);
    expect(find.text('0 / 2 arrêts livrés'), findsOneWidget);

    // No distance, no fee, no ETA: the driver contract holds none of them.
    expect(find.textContaining('km'), findsNothing);
    expect(find.textContaining('FCFA'), findsNothing);
  });

  testWidgets('the customer is reachable by the phone the delivery carries', (
    tester,
  ) async {
    String? copiedNumber;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedNumber =
              (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await _pumpDriver(tester);
    await _openActiveDelivery(tester);

    await tester.scrollUntilVisible(find.text('Contacter le client'), 240);
    await _settle(tester);
    expect(find.text('+225 07 00 00 00 02'), findsOneWidget);

    await tester.tap(find.text('Contacter le client'));
    await _settle(tester);

    expect(find.text('Copier le numéro'), findsOneWidget);
    await tester.tap(find.text('Copier le numéro'));
    await _settle(tester);

    // The number really comes from the delivery, and the sheet hands it back.
    expect(copiedNumber, '+225 07 00 00 00 02');
    expect(find.text('Numéro copié.'), findsOneWidget);
  });

  testWidgets('closing the delivery from the sheet retires its action', (
    tester,
  ) async {
    final repo = await _pumpDriver(tester);
    await _openActiveDelivery(tester);

    expect(find.byType(DeliveryActionBar), findsOneWidget);
    expect(find.text('Marquer comme livrée'), findsOneWidget);

    await tester.tap(find.text('Marquer comme livrée'));
    await _settle(tester);

    expect(repo.updateCalls, 1);
    // The last transition leaves nothing to do: no action, and the progression
    // states the delivery is closed.
    expect(find.byType(DeliveryActionBar), findsNothing);
    expect(find.text('Étape 3 sur 3'), findsOneWidget);
    expect(find.text('Livraison terminée avec succès.'), findsWidgets);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('double tapping the action sends a single request', (
    tester,
  ) async {
    final repo = await _pumpDriver(
      tester,
      repo: FakeDriverRepository(updateGate: Completer<void>()),
    );
    await _openActiveDelivery(tester);

    await tester.tap(find.text('Marquer comme livrée'));
    await tester.pump();

    // The bar holds the call: the action turns into a loader and is disabled,
    // so a second tap has nothing left to send.
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNull,
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNull,
    );

    repo.updateGate!.complete();
    await _settle(tester);

    expect(repo.updateCalls, 1);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('a failed action leaves the sheet honest and offers the two real '
      'ways out', (tester) async {
    final repo = await _pumpDriver(
      tester,
      repo: FakeDriverRepository(updateThrowsNetwork: true),
    );
    await _openActiveDelivery(tester);

    await tester.tap(find.text('Marquer comme livrée'));
    await _settle(tester);

    expect(repo.updateCalls, 1);
    expect(find.text("L'action n'a pas abouti."), findsOneWidget);
    expect(find.text('Vérifier le statut'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    // Nothing was sent twice on its own: the driver decides.
    await tester.tap(find.text('Réessayer'));
    await _settle(tester);
    expect(repo.updateCalls, 2);

    // Verifying the real status drops the warning instead of guessing.
    repo.updateThrowsNetwork = false;
    await tester.tap(find.text('Vérifier le statut'));
    await _settle(tester);
    expect(find.text("L'action n'a pas abouti."), findsNothing);
    expect(find.text('Marquer comme livrée'), findsOneWidget);
  });

  testWidgets(
    'the action warning belongs to the delivery whose action failed',
    (tester) async {
      await _pumpDriver(
        tester,
        repo: FakeDriverRepository(updateThrowsNetwork: true),
      );

      await tester.tap(find.text('Livraisons'));
      await _settle(tester);
      await tester.ensureVisible(find.text('Démarrer la livraison').first);
      await tester.tap(find.text('Démarrer la livraison').first);
      await _settle(tester);

      // The other sheet must not offer to verify and resend a parcel that never
      // failed: the warning is scoped to the delivery it belongs to.
      final context = tester.element(find.byType(DriverDeliveriesPage));
      context.go(RoutePaths.driverDelivery('d2'));
      await _settle(tester);

      expect(find.byType(DriverDeliveriesPage), findsNothing);
      expect(find.text("L'action n'a pas abouti."), findsNothing);
      expect(find.byType(DeliveryActionBar), findsOneWidget);
    },
  );

  testWidgets(
    'a delivery opened while the list fails is a retry, not a missing '
    'parcel',
    (tester) async {
      final repo = await _pumpDriver(
        tester,
        repo: FakeDriverRepository(deliveriesThrows: const NetworkFailure()),
      );
      await _openDeliveryByRoute(tester, 'd2');

      expect(find.byType(FailureView), findsOneWidget);
      expect(
        find.text('Erreur réseau. Vérifiez votre connexion.'),
        findsOneWidget,
      );
      expect(find.text('Réessayer'), findsOneWidget);
      // The load failed: the parcel is not claimed to be missing.
      expect(find.text('Livraison introuvable.'), findsNothing);

      repo.deliveriesThrows = null;
      await tester.tap(find.text('Réessayer'));
      await _settle(tester);

      expect(find.byType(FailureView), findsNothing);
      expect(find.text('Itinéraire'), findsOneWidget);
    },
  );

  testWidgets('the sheet waits with a skeleton shaped like the finished one', (
    tester,
  ) async {
    final gate = Completer<void>();
    final repo = await _pumpDriver(
      tester,
      repo: FakeDriverRepository(deliveriesGate: gate),
    );
    await _openDeliveryByRoute(tester, 'd2');

    expect(find.byType(DetailSkeleton), findsOneWidget);
    expect(find.text('Itinéraire'), findsNothing);

    gate.complete();
    await _settle(tester);

    expect(find.byType(DetailSkeleton), findsNothing);
    expect(repo.fetchDeliveriesCalls, greaterThan(0));
    expect(find.text('Itinéraire'), findsOneWidget);
  });

  testWidgets('an unknown delivery offers the list it came from', (
    tester,
  ) async {
    await _pumpDriver(tester);
    await _openDeliveryByRoute(tester, 'd_unknown');

    expect(find.text('Livraison introuvable.'), findsOneWidget);
    expect(find.text('Mes livraisons'), findsOneWidget);

    await tester.tap(find.text('Mes livraisons'));
    await _settle(tester);

    expect(find.byType(DriverDeliveriesPage), findsOneWidget);
  });

  testWidgets('the sheet reflows from 320 px to a desktop window', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const widths = [320.0, 360.0, 390.0, 412.0, 430.0, 800.0, 1280.0];

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);
      // A fresh tree per width, so the shell is rebuilt instead of keeping the
      // previous viewport state.
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpDriver(tester);
      await _openActiveDelivery(tester);

      final action = tester.getRect(find.byType(DeliveryActionBar));
      expect(action.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(action.right, lessThanOrEqualTo(width), reason: 'width $width');
      // Pinned under the content, never floating over it.
      expect(action.bottom, 900, reason: 'width $width');
      expect(action.height, lessThan(200), reason: 'width $width');

      final button = tester.getRect(find.text('Marquer comme livrée'));
      expect(button.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(button.right, lessThanOrEqualTo(width), reason: 'width $width');

      // A wide window reads the sheet in a bounded measure instead of letting
      // the route stretch from edge to edge.
      final route = tester.getRect(find.text('Entrepôt central'));
      expect(route.left, greaterThanOrEqualTo(0), reason: 'width $width');
      expect(route.right, lessThanOrEqualTo(width), reason: 'width $width');
      if (width > 2 * 16 + maxContentWidth) {
        // Centered measure, with the page padding kept on its sides.
        expect(
          route.left,
          greaterThanOrEqualTo(16 + 16),
          reason: 'width $width',
        );
      }

      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });
}
