import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/chat/presentation/chat_inbox_page.dart';
import 'package:agri_connect/features/chat/presentation/chat_thread_page.dart';
import 'package:agri_connect/features/driver/application/driver_providers.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_trips_page.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

import 'support/fakes.dart';

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

void main() {
  testWidgets('driver dashboard shows the live overview and seeded data', (
    tester,
  ) async {
    await _pumpDriver(tester);

    expect(find.text("Vue d'ensemble"), findsOneWidget);
    expect(find.text('À livrer'), findsOneWidget);
    expect(find.text('En cours'), findsWidgets);
    expect(find.text('Livrée'), findsWidgets);
    expect(find.text('Aminata'), findsWidgets);
    expect(find.text('Livreur'), findsWidgets);
  });

  testWidgets('starting a delivery updates its status everywhere', (
    tester,
  ) async {
    final repo = await _pumpDriver(tester);

    await tester.tap(find.text('Livraisons'));
    await _settle(tester);

    expect(find.text('Aminata'), findsOneWidget);
    expect(find.text('À ramasser'), findsWidgets);

    await tester.ensureVisible(find.text('Démarrer la livraison').first);
    await tester.tap(find.text('Démarrer la livraison').first);
    await _settle(tester);

    expect(repo.updateCalls, 1);
    expect(find.text('Livraison démarrée.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('opening a delivery shows its route and customer', (
    tester,
  ) async {
    await _pumpDriver(tester);

    await tester.tap(find.text('Livraisons'));
    await _settle(tester);

    await tester.tap(find.text('Aminata'));
    await _settle(tester);

    expect(find.text('Détail de la livraison'), findsOneWidget);
    expect(find.text('Itinéraire'), findsOneWidget);
    expect(find.text('Point de collecte'), findsOneWidget);
    expect(find.text('Yopougon, allée 4'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await _settle(tester);
    expect(find.text('Contacter le client'), findsOneWidget);
  });

  testWidgets('a failed delivery action is never retried automatically and '
      'offers verification', (tester) async {
    final repo = FakeDriverRepository(updateThrowsNetwork: true);
    await _pumpDriver(tester, repo: repo);

    await tester.tap(find.text('Livraisons'));
    await _settle(tester);
    await tester.ensureVisible(find.text('Démarrer la livraison').first);
    await tester.tap(find.text('Démarrer la livraison').first);
    await _settle(tester);

    expect(repo.updateCalls, 1);

    await tester.drag(find.byType(ListView).first, const Offset(0, 600));
    await _settle(tester);
    expect(find.text("L'action n'a pas abouti."), findsOneWidget);
    expect(find.text('Vérifier le statut'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await _settle(tester);
    expect(repo.updateCalls, 2);

    await tester.tap(find.text('Vérifier le statut'));
    await _settle(tester);
    expect(find.text("L'action n'a pas abouti."), findsNothing);
  });

  testWidgets('double tapping start sends a single request', (tester) async {
    final repo = FakeDriverRepository(updateGate: Completer<void>());
    await _pumpDriver(tester, repo: repo);

    await tester.tap(find.text('Livraisons'));
    await _settle(tester);
    await tester.ensureVisible(find.text('Démarrer la livraison').first);
    await tester.tap(find.text('Démarrer la livraison').first);
    await tester.pump();

    expect(find.text('Démarrage…'), findsOneWidget);
    await tester.tap(find.text('Démarrage…'), warnIfMissed: false);
    await tester.pump();

    repo.updateGate!.complete();
    await _settle(tester);

    expect(repo.updateCalls, 1);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('the dashboard offers the shortcuts its own routes can serve', (
    tester,
  ) async {
    await _pumpDriver(tester);

    expect(find.byKey(const Key('driverQuickActions')), findsOneWidget);
    expect(find.text('Mes livraisons'), findsOneWidget);
    expect(find.text('Ma livraison active'), findsOneWidget);
    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    // The hero states the real workload instead of an unexplained figure.
    expect(find.text('2 livraison(s) en cours'), findsOneWidget);

    await tester.tap(find.text('Ma livraison active'));
    await _settle(tester);

    // The active shortcut opens a delivery that really exists on the road.
    expect(find.text('Détail de la livraison'), findsOneWidget);
    expect(find.text('En cours'), findsWidgets);
  });

  testWidgets('the history shortcut opens the trips of completed routes', (
    tester,
  ) async {
    await _pumpDriver(tester);

    await tester.tap(find.text('Historique'));
    await _settle(tester);

    expect(find.byType(DriverTripsPage), findsOneWidget);
    expect(find.text('Adjamé → Yopougon'), findsOneWidget);
    expect(find.text('Fourgonnette · ZZ-000-AA'), findsOneWidget);
  });

  testWidgets('the messages shortcut reaches the driver conversation', (
    tester,
  ) async {
    await _pumpDriver(tester);

    await tester.tap(find.text('Messages'));
    await _settle(tester);

    // The chat is cross-role and the driver already has a conversation: the
    // shortcut lands on it instead of on an empty or invented screen.
    expect(find.byType(ChatInboxPage), findsOneWidget);
    expect(find.text('Alassane Traoré'), findsOneWidget);
    expect(find.text('Livraison confirmée pour demain 8h.'), findsOneWidget);

    await tester.tap(find.text('Alassane Traoré'));
    await _settle(tester);

    expect(find.byType(ChatThreadPage), findsOneWidget);
    expect(find.text('Livraison confirmée pour demain 8h.'), findsOneWidget);

    // The inbox is pushed over the dashboard, so the back button has to walk
    // the driver out of the thread and back to the dashboard.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await _settle(tester);
    expect(find.text('Alassane Traoré'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await _settle(tester);
    expect(find.byKey(const Key('driverQuickActions')), findsOneWidget);
  });

  testWidgets('the driver answers in the conversation and the answer lands', (
    tester,
  ) async {
    await _pumpDriver(tester);

    await tester.tap(find.text('Messages'));
    await _settle(tester);
    await tester.tap(find.text('Alassane Traoré'));
    await _settle(tester);

    // The chat contract really supports sending: the driver gets an input, not
    // a read-only transcript.
    await tester.enterText(find.byType(TextField), 'Je suis à l\'entrée nord.');
    await tester.tap(find.byTooltip('Envoyer'));
    await _settle(tester);

    expect(find.text('Je suis à l\'entrée nord.'), findsOneWidget);
    expect(find.text('Livraison confirmée pour demain 8h.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a driver without deliveries is offered no dead shortcut', (
    tester,
  ) async {
    await _pumpDriver(
      tester,
      repo: FakeDriverRepository(deliveries: const [], trips: const []),
    );

    expect(find.byKey(const Key('driverQuickActions')), findsOneWidget);
    expect(find.text('Mes livraisons'), findsOneWidget);
    // Nothing to open: the active-delivery shortcut would dead-end.
    expect(find.text('Ma livraison active'), findsNothing);
    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Aucune livraison en cours'), findsOneWidget);
  });

  testWidgets(
    'the dashboard waits for its deliveries instead of claiming zero',
    (tester) async {
      final gate = Completer<void>();
      await _pumpDriver(
        tester,
        repo: FakeDriverRepository(deliveriesGate: gate),
      );
      await tester.pump();

      // No figure is announced before the repository answered.
      expect(find.text('livraison(s) en cours'), findsNothing);
      expect(find.text('Aucune livraison en cours'), findsNothing);
      expect(find.text('Chargement de vos livraisons\u2026'), findsOneWidget);
      expect(find.byType(CardListSkeleton), findsWidgets);

      gate.complete();
      await _settle(tester);

      expect(find.text('2 livraison(s) en cours'), findsOneWidget);
    },
  );
}
