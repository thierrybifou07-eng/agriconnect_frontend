import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/core/errors/failures.dart';

abstract interface class NotificationReadStorage {
  Future<Set<String>> readIds(String key);
  Future<void> writeIds(String key, Set<String> ids);
}

final notificationReadStorageProvider = Provider<NotificationReadStorage>(
  (ref) => const LocalNotificationReadStorage(),
);

final class LocalNotificationReadStorage implements NotificationReadStorage {
  const LocalNotificationReadStorage();

  Future<SharedPreferences> _preferences() async {
    try {
      return await SharedPreferences.getInstance();
    } on Exception {
      throw const CacheFailure();
    }
  }

  @override
  Future<Set<String>> readIds(String key) async {
    final preferences = await _preferences();
    return (preferences.getStringList(key) ?? const <String>[]).toSet();
  }

  @override
  Future<void> writeIds(String key, Set<String> ids) async {
    final preferences = await _preferences();
    try {
      final saved = await preferences.setStringList(key, ids.toList()..sort());
      if (!saved) throw const CacheFailure();
    } on CacheFailure {
      rethrow;
    } on Exception {
      throw const CacheFailure();
    }
  }
}
