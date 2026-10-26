import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/storage/prefs_storage.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/notifications/domain/app_notification.dart';
import 'package:agri_connect/features/notifications/presentation/controllers/notification_center.dart';
import '../../support/fake_realtime_transport.dart';
import '../../support/get_test_harness.dart';
import '../auth/fake_auth_repository.dart';

void main() {
  setupGetTestHarness();

  testWidgets(
    'creates localized message notifications and persists the unread badge',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: Text('App')),
        ),
      );
      final prefs = PrefsStorage();
      final storage = InMemoryTokenStorage();
      final events = SessionEvents();
      final auth = Get.put(
        AuthController(
          tokenStorage: storage,
          sessionEvents: events,
          repository: FakeAuthRepository(),
        ),
      );
      final transport = FakeTransport();
      final socket = Get.put(
        SocketService(
          authController: auth,
          apiClient: ApiClient(
            tokenStorage: storage,
            sessionEvents: events,
            baseUrl: 'https://example.test/api/v2',
          ),
          tokenStorage: storage,
          transport: transport,
        ),
      );
      final center = Get.put(
        NotificationCenter(prefsStorage: prefs, socketService: socket),
      );
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      transport.fire('message:new', {
        'conversationId': 17,
        'id': 300,
        'content': 'Une réponse est arrivée',
        'senderLabel': 'Équipe AgriConnect',
        'createdAt': DateTime.utc(2026, 10, 26).toIso8601String(),
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(center.notifications, hasLength(1));
      expect(center.notifications.first.kind, AppNotificationKind.message);
      expect(center.notifications.first.title, 'Nouveau message');
      expect(center.unreadCount.value, 1);
      expect(await prefs.readNotificationCache(), contains('"kind":"message"'));
      center.markRead(center.notifications.single.id);
      expect(center.unreadCount.value, 0);
    },
  );
}
