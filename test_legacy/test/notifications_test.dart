import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/app/theme/app_theme.dart';
import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/notifications/data/demo_notifications_repository.dart';
import 'package:agri_connect/features/notifications/data/notification_read_storage.dart';
import 'package:agri_connect/features/notifications/domain/notification_item.dart';
import 'package:agri_connect/features/notifications/presentation/notifications_page.dart';

const _userKey = 'auth_user_v1';
const _tokenKey = 'auth_token_v1';

AuthUser _user(
  UserRole role, {
  String id = 'user-1',
  Set<UserCapability> capabilities = const {
    UserCapability.buyerSupport,
    UserCapability.stockValidation,
    UserCapability.orderProcessing,
    UserCapability.paymentFollowup,
  },
}) => AuthUser(
  id: id,
  fullName: 'Awa Diallo',
  email: 'awa@example.com',
  role: role,
  capabilities: capabilities,
);

class _MemoryReadStorage implements NotificationReadStorage {
  final Map<String, Set<String>> values = {};
  bool failReads = false;
  bool failWrites = false;

  @override
  Future<Set<String>> readIds(String key) async {
    if (failReads) throw const CacheFailure();
    return {...?values[key]};
  }

  @override
  Future<void> writeIds(String key, Set<String> ids) async {
    if (failWrites) throw const CacheFailure();
    values[key] = {...ids};
  }
}

Future<ProviderContainer> _pumpNotifications(
  WidgetTester tester, {
  UserRole role = UserRole.buyer,
  Set<UserCapability> capabilities = const {
    UserCapability.buyerSupport,
    UserCapability.stockValidation,
    UserCapability.orderProcessing,
    UserCapability.paymentFollowup,
  },
  Locale locale = const Locale('fr'),
  _MemoryReadStorage? storage,
  GoRouter? router,
}) async {
  SharedPreferences.setMockInitialValues({
    _userKey: jsonEncode(_user(role, capabilities: capabilities).toJson()),
    _tokenKey: 'token-1',
  });
  final container = ProviderContainer(
    overrides: [
      if (storage != null)
        notificationReadStorageProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  final app = router == null
      ? MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: const NotificationsPage(),
        )
      : MaterialApp.router(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          routerConfig: router,
        );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: app),
  );
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  return container;
}

Future<void> _pumpSignedInApp(WidgetTester tester, UserRole role) async {
  SharedPreferences.setMockInitialValues({
    'welcome_onboarding_completed_v1': true,
    'welcome_language_code_v1': 'fr',
    'welcome_selected_role_v1': role.key,
    _userKey: jsonEncode(_user(role).toJson()),
    _tokenKey: 'token-1',
  });
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const AgriConnectApp(),
    ),
  );
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DemoNotificationsRepository', () {
    late _MemoryReadStorage storage;
    late DemoNotificationsRepository repository;

    setUp(() {
      storage = _MemoryReadStorage();
      repository = DemoNotificationsRepository(storage);
    });

    for (final role in UserRole.values) {
      test('returns only demo entries for ${role.name}', () async {
        final items = await repository.fetchFor(_user(role));

        expect(items, isNotEmpty);
        expect(items.every((item) => item.role == role), isTrue);
        expect(items.every((item) => !item.isRead), isTrue);
        expect(
          items.every((item) => item.createdAt.isBefore(DateTime.now())),
          isTrue,
        );
      });
    }

    test('filters agent entries using granted capabilities', () async {
      final items = await repository.fetchFor(
        _user(
          UserRole.agent,
          capabilities: const {UserCapability.buyerSupport},
        ),
      );

      expect(items, hasLength(1));
      expect(items.single.message, DemoNotificationMessage.agentSupportRequest);
    });

    test('read state persists per role and account', () async {
      final buyer = _user(UserRole.buyer);
      final supplier = _user(UserRole.supplier);
      final buyerItems = await repository.fetchFor(buyer);
      await repository.saveReadState(buyer, {buyerItems.first.id});

      final rereadBuyer = await repository.fetchFor(buyer);
      final otherBuyer = await repository.fetchFor(
        _user(UserRole.buyer, id: 'another-user'),
      );
      final rereadSupplier = await repository.fetchFor(supplier);
      expect(rereadBuyer.first.isRead, isTrue);
      expect(otherBuyer.every((item) => !item.isRead), isTrue);
      expect(rereadSupplier.every((item) => !item.isRead), isTrue);
    });
  });

  testWidgets('marks one item read, updates the count, and persists it', (
    tester,
  ) async {
    await _pumpNotifications(tester);

    expect(find.text('Non lues : 2'), findsOneWidget);
    await tester.tap(find.byTooltip('Marquer comme lu').first);
    await tester.pumpAndSettle();
    expect(find.text('Non lues : 1'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getKeys().any(
        (key) => key.startsWith('agri_notifications_read_v1_buyer_'),
      ),
      isTrue,
    );
    final restored = await DemoNotificationsRepository(
      const LocalNotificationReadStorage(),
    ).fetchFor(_user(UserRole.buyer));
    expect(restored.where((item) => item.isRead), hasLength(1));
  });

  testWidgets('marks all notifications read and shows the empty unread count', (
    tester,
  ) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text('Tout marquer comme lu'));
    await tester.pumpAndSettle();
    expect(find.text('Non lues : 0'), findsOneWidget);
    expect(find.text('Tout marquer comme lu'), findsNothing);
    expect(find.byTooltip('Marquer comme lu'), findsNothing);
  });

  testWidgets(
    'shows a designed empty state when the role has no capabilities',
    (tester) async {
      await _pumpNotifications(
        tester,
        role: UserRole.agent,
        capabilities: const {},
      );

      expect(find.text('Vous êtes à jour'), findsOneWidget);
      expect(find.text('Non lues : 0'), findsOneWidget);
      expect(find.text('Tout marquer comme lu'), findsNothing);
    },
  );

  testWidgets('shows a load failure and retries successfully', (tester) async {
    final storage = _MemoryReadStorage()..failReads = true;
    await _pumpNotifications(tester, storage: storage);

    expect(
      find.text('Impossible de charger les notifications.'),
      findsOneWidget,
    );
    storage.failReads = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Exemple de mise à jour de commande'), findsOneWidget);
  });

  testWidgets('surfaces local storage write failures without losing entries', (
    tester,
  ) async {
    final storage = _MemoryReadStorage()..failWrites = true;
    await _pumpNotifications(tester, storage: storage);

    await tester.tap(find.byTooltip('Marquer comme lu').first);
    await tester.pumpAndSettle();
    expect(
      find.text("Impossible d'accéder au stockage local."),
      findsOneWidget,
    );
    expect(find.text('Non lues : 2'), findsOneWidget);
  });

  testWidgets('provides French and English content', (tester) async {
    await _pumpNotifications(tester);
    expect(
      find.text(
        'Exemples de démonstration uniquement. Ce ne sont pas des alertes en direct et elles ne sont pas synchronisées avec un serveur.',
      ),
      findsOneWidget,
    );

    await _pumpNotifications(tester, locale: const Locale('en'));
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Example order update'), findsOneWidget);
    expect(
      find.text(
        'Demonstration examples only. These are not live alerts and are not synchronized with a server.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('follows an existing role destination when opening an item', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/buyer/notifications',
      routes: [
        GoRoute(
          path: '/buyer/notifications',
          builder: (_, _) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/buyer/orders',
          builder: (_, _) => const Scaffold(body: Text('Orders destination')),
        ),
        GoRoute(
          path: '/buyer/home',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await _pumpNotifications(tester, router: router);

    await tester.tap(find.text('Exemple de mise à jour de commande'));
    await tester.pumpAndSettle();
    expect(find.text('Orders destination'), findsOneWidget);
  });

  for (final entry in {
    UserRole.buyer: 'Exemple de mise à jour de commande',
    UserRole.supplier: 'Exemple de nouvelle commande',
    UserRole.driver: 'Exemple de livraison attribuée',
    UserRole.agent: 'Exemple de demande de support',
    UserRole.admin: 'Exemple de produit à examiner',
    UserRole.root: "Exemple d'activité de plateforme",
  }.entries) {
    testWidgets('the ${entry.key.name} shell opens its own notifications', (
      tester,
    ) async {
      await _pumpSignedInApp(tester, entry.key);

      final expectedUnread = entry.key == UserRole.agent ? '3' : '2';
      expect(
        find.descendant(
          of: find.byTooltip('Notifications'),
          matching: find.text(expectedUnread),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      expect(
        find.text('Exemple de mise à jour de commande'),
        entry.key == UserRole.buyer ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('fits the supported widths with enlarged text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await _pumpNotifications(tester);

    for (final size in [
      const Size(320, 720),
      const Size(360, 800),
      const Size(412, 840),
      const Size(600, 900),
      const Size(720, 900),
      const Size(1024, 900),
      const Size(1280, 900),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'layout at $size: $exception');
      expect(find.text('Exemple de mise à jour de commande'), findsOneWidget);
    }
  });
}
