import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/storage/session_storage.dart';
import 'package:agri_connect/features/auth/application/auth_state.dart';
import 'package:agri_connect/features/auth/data/demo_auth_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => DemoAuthRepository(),
);

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Live access token used to sign authenticated API calls, or `null` when
/// signed out or when no token has been issued yet.
final authAccessTokenProvider = Provider<String?>(
  (ref) => ref.watch(authControllerProvider.select((s) => s.accessToken)),
);

/// Owns the authentication session state machine.
class AuthController extends Notifier<AuthState> {
  bool _restoreStarted = false;
  Completer<void>? _profileUpdateCompletion;

  @override
  AuthState build() {
    _restoreSession();
    return const AuthState.initial();
  }

  Future<void> _restoreSession() async {
    if (_restoreStarted) return;
    _restoreStarted = true;
    final storage = ref.read(sessionStorageProvider);
    try {
      final raw = await storage.readUserJson();
      if (raw == null) {
        state = const AuthState.unauthenticated();
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        await _tryClear(storage);
        state = const AuthState.unauthenticated();
        return;
      }
      final user = AuthUser.fromJson(decoded);
      final token = await storage.readToken();
      final expiresAt = await storage.readExpiryAt();
      if (expiresAt != null && !expiresAt.isAfter(DateTime.now())) {
        await _tryClear(storage);
        state = const AuthState.unauthenticated();
        return;
      }
      state = AuthState.authenticated(
        user,
        accessToken: token,
        expiresAt: expiresAt,
      );
    } on CacheFailure {
      // The store itself is unavailable: sign out without masking or wiping it.
      state = const AuthState.unauthenticated();
    } catch (_) {
      // Corrupt session data: wipe it so no stale token survives at rest.
      await _tryClear(storage);
      state = const AuthState.unauthenticated();
    }
  }

  /// Best-effort wipe of the persisted session, never propagating errors.
  Future<void> _tryClear(SessionStorage storage) async {
    try {
      await storage.clear();
    } catch (_) {
      // The store may be failing entirely; the in-memory state still signs out.
    }
  }

  Future<void> _persist(AuthResult result) async {
    final storage = ref.read(sessionStorageProvider);
    try {
      // Token and expiry first: the user JSON is the restore marker, written
      // last so a partial write never looks like a complete session.
      await storage.writeToken(result.accessToken);
      await storage.writeExpiryAt(result.expiresAt);
      await storage.writeUserJson(jsonEncode(result.user.toJson()));
    } catch (_) {
      await _tryClear(storage);
      rethrow;
    }
  }

  /// Attempts a sign-in, persisting the session (identity + JWT) on success.
  ///
  /// [expectedRole] is the role selected during onboarding; a mismatch is
  /// surfaced as a localized `role_mismatch` failure.
  ///
  /// Returns the [Failure] to display, or `null` when the sign-in succeeded.
  Future<Failure?> signIn({
    required String email,
    required String password,
    UserRole? expectedRole,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    try {
      final result = await repository.signIn(
        SignInRequest(
          email: email,
          password: password,
          expectedRole: expectedRole,
        ),
      );
      await _persist(result);
      state = AuthState.authenticated(
        result.user,
        accessToken: result.accessToken,
        expiresAt: result.expiresAt,
      );
      return null;
    } on Failure catch (failure) {
      return failure;
    } catch (_) {
      return const UnexpectedFailure();
    }
  }

  /// Registers a new account, persisting the session on success.
  ///
  /// Returns the [Failure] to display, or `null` when the registration and
  /// session persistence both succeeded.
  Future<Failure?> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    try {
      final result = await repository.register(
        RegisterRequest(
          fullName: fullName,
          email: email,
          password: password,
          role: role,
        ),
      );
      await _persist(result);
      state = AuthState.authenticated(
        result.user,
        accessToken: result.accessToken,
        expiresAt: result.expiresAt,
      );
      return null;
    } on Failure catch (failure) {
      return failure;
    } catch (_) {
      return const UnexpectedFailure();
    }
  }

  /// Updates only the displayed name in the current session and local store.
  ///
  /// Role, capabilities, account identity and contact details remain owned by
  /// authentication; a remote profile update requires a backend contract.
  Future<Failure?> updateProfileName(String value) async {
    final current = state.user;
    if (state.status != AuthStatus.authenticated || current == null) {
      return const AccessDeniedFailure();
    }

    final fullName = value.trim();
    if (fullName.length < 2 || fullName.length > 80) {
      return const AuthFailure('profile_name_invalid');
    }
    if (fullName == current.fullName) return null;
    if (_profileUpdateCompletion != null) {
      return const UnexpectedFailure('profile_update_in_progress');
    }

    final completion = Completer<void>();
    _profileUpdateCompletion = completion;
    try {
      final updatedUser = AuthUser(
        id: current.id,
        fullName: fullName,
        email: current.email,
        role: current.role,
        photoUrl: current.photoUrl,
        capabilities: current.capabilities,
      );
      await ref
          .read(sessionStorageProvider)
          .writeUserJson(jsonEncode(updatedUser.toJson()));
      state = AuthState.authenticated(
        updatedUser,
        accessToken: state.accessToken,
        expiresAt: state.expiresAt,
      );
      return null;
    } on Failure catch (failure) {
      return failure;
    } catch (_) {
      return const UnexpectedFailure();
    } finally {
      if (identical(_profileUpdateCompletion, completion)) {
        _profileUpdateCompletion = null;
      }
      completion.complete();
    }
  }

  Future<void> signOut() async {
    await _profileUpdateCompletion?.future;
    try {
      await ref.read(sessionStorageProvider).clear();
    } catch (_) {
      // Session is cleared in memory regardless of storage failures.
    }
    state = const AuthState.unauthenticated();
  }
}
