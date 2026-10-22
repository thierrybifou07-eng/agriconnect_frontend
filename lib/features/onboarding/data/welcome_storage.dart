import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/core/errors/failures.dart';

/// Persists the welcome journey progress across launches.
abstract interface class WelcomeStorage {
  Future<bool> readOnboardingCompleted();
  Future<void> writeOnboardingCompleted(bool value);
  Future<String?> readLanguageCode();
  Future<void> writeLanguageCode(String value);
  Future<String?> readSelectedRole();
  Future<void> writeSelectedRole(String? value);
}

final welcomeStorageProvider = Provider<WelcomeStorage>(
  (ref) => const LocalWelcomeStorage(),
);

final class LocalWelcomeStorage implements WelcomeStorage {
  const LocalWelcomeStorage();

  static const _onboardingKey = 'welcome_onboarding_completed_v1';
  static const _languageKey = 'welcome_language_code_v1';
  static const _roleKey = 'welcome_selected_role_v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<SharedPreferences> _guarded() async {
    try {
      return await _prefs;
    } on Exception {
      throw const CacheFailure();
    }
  }

  @override
  Future<bool> readOnboardingCompleted() async {
    final prefs = await _guarded();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> writeOnboardingCompleted(bool value) async {
    final prefs = await _guarded();
    await prefs.setBool(_onboardingKey, value);
  }

  @override
  Future<String?> readLanguageCode() async {
    final prefs = await _guarded();
    return prefs.getString(_languageKey);
  }

  @override
  Future<void> writeLanguageCode(String value) async {
    final prefs = await _guarded();
    await prefs.setString(_languageKey, value);
  }

  @override
  Future<String?> readSelectedRole() async {
    final prefs = await _guarded();
    return prefs.getString(_roleKey);
  }

  @override
  Future<void> writeSelectedRole(String? value) async {
    final prefs = await _guarded();
    if (value == null) {
      await prefs.remove(_roleKey);
    } else {
      await prefs.setString(_roleKey, value);
    }
  }
}
