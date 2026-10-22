import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/core/errors/failures.dart';

abstract interface class SessionStorage {
  Future<String?> readUserJson();
  Future<void> writeUserJson(String value);
  Future<String?> readToken();
  Future<void> writeToken(String value);
  Future<DateTime?> readExpiryAt();
  Future<void> writeExpiryAt(DateTime? value);
  Future<void> clear();
}

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => const LocalSessionStorage(),
);

/// Persists the user session (identity, JWT and optional expiry) across
/// launches using [SharedPreferences].
final class LocalSessionStorage implements SessionStorage {
  const LocalSessionStorage();

  static const _userKey = 'auth_user_v1';
  static const _tokenKey = 'auth_token_v1';
  static const _expiryKey = 'auth_token_expires_at_v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<SharedPreferences> _guarded() async {
    try {
      return await _prefs;
    } on Exception {
      throw const CacheFailure();
    }
  }

  @override
  Future<String?> readUserJson() async {
    final prefs = await _guarded();
    return prefs.getString(_userKey);
  }

  @override
  Future<void> writeUserJson(String value) async {
    final prefs = await _guarded();
    await prefs.setString(_userKey, value);
  }

  @override
  Future<String?> readToken() async {
    final prefs = await _guarded();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> writeToken(String value) async {
    final prefs = await _guarded();
    await prefs.setString(_tokenKey, value);
  }

  @override
  Future<DateTime?> readExpiryAt() async {
    final prefs = await _guarded();
    final raw = prefs.getString(_expiryKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> writeExpiryAt(DateTime? value) async {
    final prefs = await _guarded();
    if (value == null) {
      await prefs.remove(_expiryKey);
    } else {
      await prefs.setString(_expiryKey, value.toIso8601String());
    }
  }

  @override
  Future<void> clear() async {
    final prefs = await _guarded();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
  }
}
