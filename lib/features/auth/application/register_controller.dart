import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

/// Form submission state for the registration screen.
class RegisterState {
  const RegisterState({this.isLoading = false, this.failure});

  final bool isLoading;
  final Failure? failure;

  RegisterState copyWith({bool? isLoading, Failure? failure}) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
    );
  }
}

final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterState>(RegisterController.new);

class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  /// Submits the registration form.
  ///
  /// Returns the [Failure] to display, or `null` when it succeeded. On
  /// success the router redirects to the role dashboard automatically.
  Future<Failure?> submit({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = const RegisterState(isLoading: true);
    final failure = await ref
        .read(authControllerProvider.notifier)
        .register(
          fullName: fullName.trim(),
          email: email.trim(),
          password: password,
          role: role,
        );
    state = RegisterState(failure: failure);
    return failure;
  }
}
