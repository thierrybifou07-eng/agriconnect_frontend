import 'package:agri_connect/features/auth/domain/user_role.dart';

/// Immutable snapshot of the welcome journey progress.
class WelcomeState {
  const WelcomeState({
    this.isLoading = false,
    this.onboardingCompleted = false,
    this.languageCode,
    this.selectedRole,
  });

  final bool isLoading;
  final bool onboardingCompleted;
  final String? languageCode;
  final UserRole? selectedRole;

  WelcomeState copyWith({
    bool? isLoading,
    bool? onboardingCompleted,
    String? languageCode,
    UserRole? selectedRole,
  }) {
    return WelcomeState(
      isLoading: isLoading ?? this.isLoading,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      languageCode: languageCode ?? this.languageCode,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}
