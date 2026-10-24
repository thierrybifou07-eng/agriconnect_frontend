import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/core/errors/failures.dart';

/// Persists whether the buyer workspace welcome banner was seen.
///
/// Frontend-only, local demo state: it makes no claim that a server has
/// validated anything, it only remembers a dismissed onboarding message.
abstract interface class BuyerWelcomeStorage {
  Future<bool> readSeen();
  Future<void> writeSeen(bool value);
}

final buyerWelcomeStorageProvider = Provider<BuyerWelcomeStorage>(
  (ref) => const LocalBuyerWelcomeStorage(),
);

final class LocalBuyerWelcomeStorage implements BuyerWelcomeStorage {
  const LocalBuyerWelcomeStorage();

  static const _key = 'buyer_welcome_seen_v1';

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
