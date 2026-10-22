import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/onboarding/application/welcome_state.dart';
import 'package:agri_connect/features/onboarding/data/welcome_storage.dart';

final welcomeStorageProvider = Provider<WelcomeStorage>(
  (ref) => const LocalWelcomeStorage(),
);

final welcomeControllerProvider =
    NotifierProvider<WelcomeController, WelcomeState>(WelcomeController.new);

/// Currently selected UI locale, defaulting to the configured default.
final localeProvider = Provider<Locale>((ref) {
  final code =
      ref.watch(welcomeControllerProvider.select((s) => s.languageCode)) ??
      AppLanguage.defaultCode;
  return Locale(code);
});

/// Restores and drives the welcome journey (onboarding, language, role).
class WelcomeController extends Notifier<WelcomeState> {
  bool _restoreStarted = false;

  @override
  WelcomeState build() {
    _restore();
    return const WelcomeState(isLoading: true);
  }

  Future<void> _restore() async {
    if (_restoreStarted) return;
    _restoreStarted = true;
    final storage = ref.read(welcomeStorageProvider);
    try {
      final completed = await storage.readOnboardingCompleted();
      final code = await storage.readLanguageCode();
      final roleName = await storage.readSelectedRole();
      state = WelcomeState(
        onboardingCompleted: completed,
        languageCode: code,
        selectedRole: switch (roleName) {
          null => null,
          final name => UserRole.fromName(name),
        },
      );
    } catch (_) {
      state = const WelcomeState();
    }
  }

  Future<void> completeOnboarding() async {
    await ref.read(welcomeStorageProvider).writeOnboardingCompleted(true);
    state = state.copyWith(onboardingCompleted: true);
  }

  Future<void> selectLanguage(String code) async {
    await ref.read(welcomeStorageProvider).writeLanguageCode(code);
    state = state.copyWith(languageCode: code);
  }

  Future<void> selectRole(UserRole role) async {
    await ref.read(welcomeStorageProvider).writeSelectedRole(role.name);
    state = state.copyWith(selectedRole: role);
  }

  Future<void> clearSelectedRole() async {
    state = WelcomeState(
      isLoading: state.isLoading,
      onboardingCompleted: state.onboardingCompleted,
      languageCode: state.languageCode,
    );
    await ref.read(welcomeStorageProvider).writeSelectedRole(null);
  }
}
