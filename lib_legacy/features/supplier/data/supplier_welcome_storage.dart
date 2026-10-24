import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/core/errors/failures.dart';

/// Persists whether the supplier workspace welcome banner was seen.
abstract interface class SupplierWelcomeStorage {
  Future<bool> readSeen();
  Future<void> writeSeen(bool value);
}

final supplierWelcomeStorageProvider = Provider<SupplierWelcomeStorage>(
  (ref) => const LocalSupplierWelcomeStorage(),
);

final class LocalSupplierWelcomeStorage implements SupplierWelcomeStorage {
  const LocalSupplierWelcomeStorage();

  static const _key = 'supplier_welcome_seen_v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<SharedPreferences> _guarded() async {
    try {
      return await _prefs;
    } on Exception {
      throw const CacheFailure();
    }
  }

  @override
  Future<bool> readSeen() async {
    final prefs = await _guarded();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> writeSeen(bool value) async {
    final prefs = await _guarded();
    await prefs.setBool(_key, value);
  }
}
