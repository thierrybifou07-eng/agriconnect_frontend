import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/app/router/app_router.dart';
import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/agent/application/agent_controllers.dart';
import 'package:agri_connect/features/agent/application/agent_providers.dart';
import 'package:agri_connect/features/agent/domain/agent_case.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/shared/widgets/attention_card.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

import 'support/fakes.dart';

/// The demo agent account holds every operational capability, so the full
/// workspace is reachable unless a test narrows the set on purpose.
const _allCapabilities = {
  UserCapability.buyerSupport,
  UserCapability.stockValidation,
  UserCapability.orderProcessing,
  UserCapability.paymentFollowup,
};

Future<({FakeAgentRepository repository, ProviderContainer container})>
_pumpAgent(
  WidgetTester tester, {
  FakeAgentRepository? repository,
  Set<UserCapability> capabilities = _allCapabilities,
}) async {
  final repo = repository ?? FakeAgentRepository();
  final user = AuthUser(
    id: 'a1',
    fullName: 'Awa Diallo',
    email: 'agent@agriconnect.app',
    role: UserRole.agent,
    capabilities: capabilities,
  );
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': 'fr',
    'welcome_selected_role_v1': 'agent',
    'auth_user_v1': jsonEncode(user.toJson()),
  });

  final container = ProviderContainer(
    overrides: [agentRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const AgriConnectApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
  return (repository: repo, container: container);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();
}

Future<void> _flushSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pump();
}

Finder _destinations() => find.descendant(
  of: find.byType(NavigationBar),
  matching: find.byType(NavigationDestination),
);

Finder _navigationEntries() {
  final sidebar = find.byKey(const ValueKey('roleShellSidebar'));
  return find.descendant(
    of: sidebar.evaluate().isNotEmpty ? sidebar : find.byType(NavigationBar),
    matching: sidebar.evaluate().isNotEmpty
        ? find.byType(ListTile)
        : find.byType(NavigationDestination),
  );
}

Future<void> _tapAgentSection(WidgetTester tester, RoleSection section) async {
  final sidebar = find.byKey(const ValueKey('roleShellSidebar'));
  if (sidebar.evaluate().isNotEmpty) {
    final label = section.navLabel(tester.element(sidebar).l10n);
    await tester.tap(
      find.descendant(
        of: sidebar,
        matching: find.widgetWithText(ListTile, label),
      ),
    );
    await _settle(tester);
    return;
  }

  final l10n = tester.element(find.byType(NavigationBar)).l10n;
  final compactLabel = switch (section) {
    RoleSection.buyerSupport => l10n.notificationsCategorySupport,
    RoleSection.orderProcessing => l10n.sectionOrders,
    _ => section.navLabel(l10n),
  };
  final destinations = _destinations();
  final destinationIndex = destinations.evaluate().toList().indexWhere(
    (element) =>
        (element.widget as NavigationDestination).label == compactLabel,
  );
  if (destinationIndex >= 0) {
    await tester.tap(destinations.at(destinationIndex), warnIfMissed: false);
  } else {
    await tester.tap(destinations.last, warnIfMissed: false);
    await _settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.widgetWithText(ListTile, section.label(l10n)),
      ),
    );
  }
  await _settle(tester);
}

Finder _verticalScrollable() => find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .last;

void main() {
  testWidgets('the agent dashboard shows the operational overview and the '
      'shortcuts its own routes can serve', (tester) async {
    await _pumpAgent(tester);
    await _settle(tester);

    expect(find.text('Bonjour, Awa'), findsOneWidget);
    expect(find.text('À traiter'), findsOneWidget);
    // The backlog carries real figures read from the same controllers the
    // sections use, not decoration.
    expect(find.text('2 demandes en attente de réponse'), findsOneWidget);

    // All four capabilities are granted, so all four sections are offered next
    // to the dashboard and the profile.
    expect(_navigationEntries(), findsNWidgets(6));

    await tester.scrollUntilVisible(
      find.byKey(const Key('agentQuickActions')),
      300,
      scrollable: _verticalScrollable(),
    );
    expect(find.byKey(const Key('agentQuickActions')), findsOneWidget);
    expect(find.text("Vue d'ensemble"), findsOneWidget);
    expect(find.text('2 demandes ouvertes'), findsOneWidget);
  });

  testWidgets('agent queue summary links meet the 48dp touch target', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(412, 915);
    addTearDown(tester.view.reset);

    await _pumpAgent(tester);
    await _settle(tester);

    for (final id in ['support', 'stock', 'orders', 'payments']) {
      final link = find.descendant(
        of: find.byKey(Key('agentQueue_$id')),
        matching: find.byType(InkWell),
      );
      expect(link, findsOneWidget, reason: '$id queue');
      final size = tester.getSize(link);
      expect(size.width, greaterThanOrEqualTo(48), reason: '$id width');
      expect(size.height, greaterThanOrEqualTo(48), reason: '$id height');
    }
  });

  testWidgets('a queue still loading is not presented as an empty queue', (
    tester,
  ) async {
    final repo = FakeAgentRepository(
      fetchGates: {'support': Completer<void>()},
    );
    await _pumpAgent(tester, repository: repo);
    await _settle(tester);

    final supportCard = find.byKey(const Key('agentQueue_support'));
    expect(
      find.descendant(of: supportCard, matching: find.byType(SkeletonBox)),
      findsOneWidget,
    );
    expect(find.byType(AttentionCard), findsNothing);
  });

  testWidgets('a failed queue shows a real retry action', (tester) async {
    final repo = FakeAgentRepository(
      fetchFailures: {'support': const NetworkFailure()},
    );
    await _pumpAgent(tester, repository: repo);
    await _settle(tester);

    expect(find.text("Cette section n'a pas pu être chargée"), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.byType(AttentionCard), findsNothing);

    repo.fetchFailures.remove('support');
    await tester.ensureVisible(find.text('Réessayer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réessayer'));
    await _settle(tester);

    expect(repo.fetchSupportCalls, 2);
    expect(find.text("Cette section n'a pas pu être chargée"), findsNothing);
    expect(find.byType(AttentionCard), findsOneWidget);
  });

  testWidgets('an empty queue shows zero only after a successful response', (
    tester,
  ) async {
    final repo = FakeAgentRepository(supportRequests: []);
    await _pumpAgent(tester, repository: repo);
    await _settle(tester);

    expect(
      find.descendant(
        of: find.byKey(const Key('agentQueue_support')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
    expect(find.byType(AttentionCard), findsOneWidget);
  });

  testWidgets('a non-empty queue labels its old count while refreshing', (
    tester,
  ) async {
    final repo = FakeAgentRepository();
    final result = await _pumpAgent(tester, repository: repo);
    await _settle(tester);

    final gate = Completer<void>();
    repo.fetchGates['support'] = gate;
    final refresh = result.container
        .read(agentSupportControllerProvider.notifier)
        .refresh();
    await tester.pump();

    final supportCard = find.byKey(const Key('agentQueue_support'));
    expect(find.text('Actualisation en cours…'), findsOneWidget);
    expect(find.text('Dernière valeur connue : 2'), findsOneWidget);
    expect(
      find.descendant(
        of: supportCard,
        matching: find.text('2 demandes ouvertes'),
      ),
      findsOneWidget,
    );
    expect(find.byType(AttentionCard), findsNothing);

    gate.complete();
    await refresh;
    await tester.pump();
    expect(find.text('Actualisation en cours…'), findsNothing);
    expect(find.byType(AttentionCard), findsOneWidget);
  });

  testWidgets('a refreshing authorized queue hides the global clear summary', (
    tester,
  ) async {
    final repo = FakeAgentRepository(
      supportRequests: [],
      stockValidations: [
        StockValidationCase(
          id: 'stk_done',
          reference: 'STK-DONE',
          productName: 'Riz local',
          supplierName: 'Coopérative de Bouaké',
          declaredQuantity: 10,
          unit: 'sac',
          location: 'Bouaké',
          status: StockValidationStatus.validated,
          submittedAt: DateTime(2026, 9, 10),
        ),
      ],
      orderCases: [],
      paymentFollowups: [],
    );
    final result = await _pumpAgent(tester, repository: repo);
    await _settle(tester);
    expect(find.byKey(const ValueKey('attention.clear')), findsOneWidget);

    final gate = Completer<void>();
    repo.fetchGates['stock'] = gate;
    final refresh = result.container
        .read(agentStockControllerProvider.notifier)
        .refresh();
    await tester.pump();

    expect(find.byKey(const ValueKey('attention.clear')), findsNothing);
    expect(find.text('Actualisation en cours…'), findsOneWidget);
    expect(find.text('Dernière valeur connue : 0'), findsOneWidget);

    gate.complete();
    await refresh;
    await tester.pump();
    expect(find.byKey(const ValueKey('attention.clear')), findsOneWidget);
  });

  testWidgets(
    'refresh failure preserves old data as stale and retry updates it',
    (tester) async {
      final repo = FakeAgentRepository();
      final result = await _pumpAgent(tester, repository: repo);
      await _settle(tester);

      repo.fetchFailures['support'] = const NetworkFailure();
      await result.container
          .read(agentSupportControllerProvider.notifier)
          .refresh();
      await tester.pump();

      expect(find.text('Dernière valeur connue : 2'), findsOneWidget);
      expect(
        find.text("Cette section n'a pas pu être chargée"),
        findsOneWidget,
      );
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.byType(AttentionCard), findsNothing);

      await repo.updateSupportRequest('sup_1', SupportRequestStatus.resolved);
      repo.fetchFailures.remove('support');
      final gate = Completer<void>();
      repo.fetchGates['support'] = gate;
      final retry = result.container
          .read(agentSupportControllerProvider.notifier)
          .refresh();
      await tester.pump();

      expect(find.text('Actualisation en cours…'), findsOneWidget);
      expect(find.text('Dernière valeur connue : 2'), findsOneWidget);
      expect(find.byType(AttentionCard), findsNothing);

      gate.complete();
      await retry;
      await tester.pump();

      expect(find.text("Cette section n'a pas pu être chargée"), findsNothing);
      expect(find.text('Dernière valeur connue : 2'), findsNothing);
      expect(find.text('1 demande ouverte'), findsOneWidget);
      expect(find.byType(AttentionCard), findsOneWidget);
    },
  );

  testWidgets('refreshing queue counts are not presented as current badges', (
    tester,
  ) async {
    final repo = FakeAgentRepository();
    final result = await _pumpAgent(tester, repository: repo);
    await _settle(tester);

    final gate = Completer<void>();
    repo.fetchGates['support'] = gate;
    final refresh = result.container
        .read(agentSupportControllerProvider.notifier)
        .refresh();
    await tester.pump();

    final quickActions = find.byKey(const Key('agentQuickActions'));
    expect(find.text('Dernière valeur connue : 2'), findsOneWidget);
    expect(
      find.descendant(of: quickActions, matching: find.text('2')),
      findsNothing,
    );

    gate.complete();
    await refresh;
    await tester.pump();
  });

  testWidgets('queue states remain independent while another queue loads', (
    tester,
  ) async {
    final repo = FakeAgentRepository(fetchGates: {'stock': Completer<void>()});
    await _pumpAgent(tester, repository: repo);
    await _settle(tester);

    expect(
      find.descendant(
        of: find.byKey(const Key('agentQueue_support')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('agentQueue_stock')),
        matching: find.byType(SkeletonBox),
      ),
      findsOneWidget,
    );
    expect(find.byType(AttentionCard), findsNothing);
  });

  testWidgets('only queues granted to the agent are loaded and shown', (
    tester,
  ) async {
    final repo = FakeAgentRepository();
    await _pumpAgent(
      tester,
      repository: repo,
      capabilities: const {UserCapability.stockValidation},
    );
    await _settle(tester);

    expect(repo.fetchStockCalls, 1);
    expect(repo.fetchSupportCalls, 0);
    expect(repo.fetchOrderCalls, 0);
    expect(repo.fetchPaymentCalls, 0);
    expect(find.byKey(const Key('agentQueue_stock')), findsOneWidget);
    expect(find.byKey(const Key('agentQueue_support')), findsNothing);
    expect(find.byKey(const Key('agentQueue_orders')), findsNothing);
    expect(find.byKey(const Key('agentQueue_payments')), findsNothing);
  });

  testWidgets(
    'answering a support request updates its status and confirms it',
    (tester) async {
      final result = await _pumpAgent(tester);
      await _settle(tester);

      await _tapAgentSection(tester, RoleSection.buyerSupport);
      expect(find.textContaining('Marie Koné'), findsOneWidget);
      expect(find.text('Prendre en charge'), findsOneWidget);

      await tester.tap(find.text('Prendre en charge'));
      await _settle(tester);

      expect(result.repository.actionCalls, 1);
      expect(find.text('Demande mise à jour.'), findsOneWidget);
      // The open request moved on: its only action is now the resolution.
      expect(find.text('Prendre en charge'), findsNothing);
      expect(find.text('Marquer comme résolue'), findsWidgets);

      await _flushSnackBar(tester);
    },
  );

  testWidgets('a double tap on an agent action sends a single request', (
    tester,
  ) async {
    final repo = FakeAgentRepository(actionGate: Completer<void>());
    final result = await _pumpAgent(tester, repository: repo);
    await _settle(tester);

    await _tapAgentSection(tester, RoleSection.buyerSupport);
    await tester.tap(find.text('Prendre en charge'));
    await tester.pump();

    // Still in flight: the second tap must be ignored by both the button and the
    // controller.
    await tester.tap(find.text('Prendre en charge'), warnIfMissed: false);
    await tester.pump();

    repo.actionGate!.complete();
    await _settle(tester);

    expect(result.repository.actionCalls, 1);

    await _flushSnackBar(tester);
  });

  testWidgets('a failed agent action is never retried automatically and offers '
      'verification', (tester) async {
    final repo = FakeAgentRepository(actionThrows: const NetworkFailure());
    final result = await _pumpAgent(tester, repository: repo);
    await _settle(tester);

    await _tapAgentSection(tester, RoleSection.buyerSupport);
    await tester.tap(find.text('Prendre en charge'));
    await _settle(tester);

    expect(result.repository.actionCalls, 1);
    expect(find.text("L'action n'a pas pu être réalisée."), findsOneWidget);
    expect(find.text('Vérifier le statut'), findsOneWidget);

    repo.actionThrows = null;
    await tester.tap(find.text('Vérifier le statut'));
    await _settle(tester);

    expect(find.text("L'action n'a pas pu être réalisée."), findsNothing);
  });

  testWidgets('each operational section moves its own case forward', (
    tester,
  ) async {
    final result = await _pumpAgent(tester);
    await _settle(tester);

    await _tapAgentSection(tester, RoleSection.stockValidation);
    expect(find.text('Valider'), findsOneWidget);
    await tester.tap(find.text('Valider'));
    await _settle(tester);
    expect(find.text('Dossier mis à jour.'), findsOneWidget);
    await _flushSnackBar(tester);

    await _tapAgentSection(tester, RoleSection.orderProcessing);
    expect(find.text('Démarrer le traitement'), findsOneWidget);
    await tester.tap(find.text('Démarrer le traitement'));
    await _settle(tester);
    expect(find.text('Commande mise à jour.'), findsOneWidget);
    await _flushSnackBar(tester);

    await _tapAgentSection(tester, RoleSection.paymentFollowup);
    expect(find.text('Confirmer la réception'), findsOneWidget);
    await tester.tap(find.text('Confirmer la réception'));
    await _settle(tester);
    expect(find.text('Paiement mis à jour.'), findsOneWidget);
    await _flushSnackBar(tester);

    expect(result.repository.actionCalls, 3);
  });

  testWidgets('a section the session cannot open is refused, not hidden only', (
    tester,
  ) async {
    final result = await _pumpAgent(
      tester,
      capabilities: const {UserCapability.orderProcessing},
    );
    await _settle(tester);

    // The shell offers only the reachable tabs.
    expect(_navigationEntries(), findsNWidgets(3));

    // A deep link straight to the stock route still lands on a refusal: hiding
    // the tab was ergonomics, the page enforces the capability.
    result.container.read(routerProvider).go('/agent/stock');
    await _settle(tester);

    expect(find.text('Accès non autorisé'), findsOneWidget);
  });

  testWidgets('a session with no capability is told so instead of shown an '
      'empty workspace', (tester) async {
    await _pumpAgent(tester, capabilities: const <UserCapability>{});
    await _settle(tester);

    expect(find.text('Aucun accès opérationnel'), findsOneWidget);
    expect(_navigationEntries(), findsNWidgets(2));
    expect(find.byKey(const Key('agentQuickActions')), findsNothing);
  });
}
