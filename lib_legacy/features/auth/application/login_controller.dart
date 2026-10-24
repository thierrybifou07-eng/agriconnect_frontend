import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

class LoginState {
  const LoginState({this.isLoading = false, this.failure});

  final bool isLoading;
  final Failure? failure;

  LoginState copyWith({
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);

/// Drives the sign-in form state.
class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> submit({
    required String email,
    required String password,
    UserRole? expectedRole,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final failure = await ref
        .read(authControllerProvider.notifier)
        .signIn(email: email, password: password, expectedRole: expectedRole);
    state = state.copyWith(isLoading: false, failure: failure);
  }
}
