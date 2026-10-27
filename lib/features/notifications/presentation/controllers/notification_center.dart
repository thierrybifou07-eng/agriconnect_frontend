import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/storage/prefs_storage.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/features/notifications/domain/app_notification.dart';

class NotificationCenter extends GetxService {
  NotificationCenter({required this.prefsStorage, required this.socketService});

  final PrefsStorage prefsStorage;
  final SocketService socketService;
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final List<StreamSubscription<Map<String, dynamic>>> _subscriptions = [];
  Future<void> _writeQueue = Future<void>.value();

  @override
  void onInit() {
    super.onInit();
    unawaited(_restore());
    // GetX cancels these listeners in onClose.
    // ignore: cancel_subscriptions
    _subscriptions
      ..add(socketService.messageNew.listen(_onMessage))
      ..add(
        socketService.deliveryAvailable.listen((data) {
          _add(
            AppNotificationKind.deliveryAvailable,
            title: _labels().notificationDeliveryAvailableTitle,
            body: _labels().notificationDeliveryAvailableBody,
            route: AppRoutes.driver,
            args: _safeArgs(data),
            priority: true,
          );
        }),
      )
      ..add(
        socketService.deliveryStatus.listen((data) {
          _add(
            AppNotificationKind.deliveryStatus,
            title: _labels().notificationDeliveryStatusTitle,
            body: _labels().notificationDeliveryStatusBody,
            route: AppRoutes.buyer,
            args: _safeArgs(data),
            priority: true,
          );
        }),
      )
      ..add(
        socketService.alertExpiring.listen((data) {
          _add(
            AppNotificationKind.expiring,
            title: _labels().notificationExpiringTitle,
            body: _labels().notificationExpiringBody,
            route: AppRoutes.staff,
            args: _safeArgs(data),
            priority: true,
          );
        }),
      )
      ..add(
        socketService.aiSuggestion.listen((data) {
          _add(
            AppNotificationKind.aiSuggestion,
            title: _labels().notificationAiSuggestionTitle,
            body: _labels().notificationAiSuggestionBody,
            route: AppRoutes.staff,
            args: _safeArgs(data),
          );
        }),
      )
      ..add(
        socketService.aiSuggestionUpdated.listen((data) {
          _add(
            AppNotificationKind.aiSuggestion,
            title: _labels().notificationAiSuggestionTitle,
            body: _labels().notificationAiSuggestionBody,
            route: AppRoutes.staff,
            args: _safeArgs(data),
          );
        }),
      );
  }

  AppLocalizations _labels() {
    final context = Get.context;
    if (context == null) {
      throw StateError('Notifications require an active localization context');
    }
    return AppLocalizations.of(context);
  }

  Future<void> _restore() async {
    final stored = await prefsStorage.readNotificationCache();
    if (stored == null || stored.isEmpty) return;
    final decoded = jsonDecode(stored);
    if (decoded is! List) {
      throw const FormatException('Invalid notification cache');
    }
    final restored = <AppNotification>[];
    for (final item in decoded) {
      if (item is Map) {
        restored.add(AppNotification.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    notifications.assignAll(restored.take(50));
    _updateUnread();
  }

  void _onMessage(Map<String, dynamic> payload) {
    final rawId =
        payload['conversationId'] ??
        (payload['message'] is Map
            ? (payload['message'] as Map)['conversationId']
            : null);
    if (rawId is! int || socketService.isConversationOpen(rawId)) return;
    _add(
      AppNotificationKind.message,
      title: _labels().notificationMessageTitle,
      body: _labels().notificationMessageBody,
      route: AppRoutes.chatThread,
      args: {'conversationId': rawId},
      priority: true,
    );
  }

  static Map<String, dynamic> _safeArgs(Map<String, dynamic> payload) =>
      payload['id'] is int ? {'id': payload['id']} : <String, dynamic>{};

  void _add(
    AppNotificationKind kind, {
    required String title,
    required String body,
    required String route,
    required Map<String, dynamic> args,
    bool priority = false,
  }) {
    if (kind == AppNotificationKind.aiSuggestion &&
        notifications.any(
          (existing) =>
              existing.kind == kind &&
              existing.args?['id'] == args['id'] &&
              args['id'] != null,
        )) {
      return;
    }
    final now = DateTime.now().toUtc();
    final notification = AppNotification(
      id: '${now.microsecondsSinceEpoch}',
      kind: kind,
      title: title,
      body: body,
      createdAt: now,
      read: false,
      route: route,
      args: args,
    );
    notifications.insert(0, notification);
    if (notifications.length > 50) {
      notifications.removeRange(50, notifications.length);
    }
    _updateUnread();
    _persist();
    if (priority &&
        Get.context != null &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      AppNotifier.info(title);
    }
  }

  void markRead(String id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index < 0 || notifications[index].read) return;
    notifications[index] = notifications[index].copyWith(read: true);
    _updateUnread();
    _persist();
  }

  void markAllRead() {
    notifications.assignAll(
      notifications.map((notification) => notification.copyWith(read: true)),
    );
    _updateUnread();
    _persist();
  }

  void clear() {
    notifications.clear();
    _updateUnread();
    _persist();
  }

  void _updateUnread() =>
      unreadCount.value = notifications.where((item) => !item.read).length;

  void _persist() {
    final snapshot = jsonEncode(
      notifications.map((item) => item.toJson()).toList(),
    );
    _writeQueue = _writeQueue.then(
      (_) => prefsStorage.saveNotificationCache(snapshot),
    );
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.onClose();
  }
}
