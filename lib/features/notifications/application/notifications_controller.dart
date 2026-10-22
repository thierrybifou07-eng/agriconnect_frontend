import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/notifications/data/demo_notifications_repository.dart';
import 'package:agri_connect/features/notifications/data/notification_read_storage.dart';
import 'package:agri_connect/features/notifications/domain/notification_item.dart';

final demoNotificationsRepositoryProvider =
    Provider<DemoNotificationsRepository>(
      (ref) => DemoNotificationsRepository(
        ref.watch(notificationReadStorageProvider),
      ),
    );

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<NotificationItem>>(
      NotificationsController.new,
    );

class NotificationsController extends AsyncNotifier<List<NotificationItem>> {
  AuthUser? _user;
  bool _saving = false;

  @override
  Future<List<NotificationItem>> build() async {
    final user = ref.watch(
      authControllerProvider.select((state) => state.user),
    );
    if (user == null) {
      throw StateError('Notifications require an authenticated session.');
    }
    _user = user;
    return ref.watch(demoNotificationsRepositoryProvider).fetchFor(user);
  }

  Future<void> markRead(String id) async {
    final current = state.asData?.value;
    final user = _user;
    if (_saving || current == null || user == null) return;
    final itemIndex = current.indexWhere((item) => item.id == id);
    if (itemIndex < 0 || current[itemIndex].isRead) return;

    _saving = true;
    try {
      final readIds = current
          .where((item) => item.isRead)
          .map((item) => item.id)
          .toSet()
        ..add(id);
      await ref
          .read(demoNotificationsRepositoryProvider)
          .saveReadState(user, readIds);
      state = AsyncData([
        for (final item in current)
          item.id == id ? item.copyWith(isRead: true) : item,
      ]);
    } finally {
      _saving = false;
    }
  }

  Future<void> markAllRead() async {
    final current = state.asData?.value;
    final user = _user;
    if (_saving || current == null || user == null) return;
    if (current.every((item) => item.isRead)) return;

    _saving = true;
    try {
      final readIds = current.map((item) => item.id).toSet();
      await ref
          .read(demoNotificationsRepositoryProvider)
          .saveReadState(user, readIds);
      state = AsyncData([
        for (final item in current) item.copyWith(isRead: true),
      ]);
    } finally {
      _saving = false;
    }
  }
}
