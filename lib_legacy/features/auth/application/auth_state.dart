import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';

enum AuthStatus { initial, unauthenticated, authenticated }

/// Immutable snapshot of the authentication session.
class AuthState {
  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      accessToken = null,
      expiresAt = null;

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null,
      accessToken = null,
      expiresAt = null;

  const AuthState.authenticated(
    AuthUser this.user, {
    this.accessToken,
    this.expiresAt,
  }) : status = AuthStatus.authenticated;

  final AuthStatus status;
  final AuthUser? user;

  /// JWT used to sign API requests, when a token has been issued.
  final String? accessToken;

  /// Optional token expiry mirroring the JWT `exp` claim.
  final DateTime? expiresAt;

  bool get isAuthenticated => user != null;

  /// Capabilities of the signed-in session, empty before authentication.
  Set<UserCapability> get capabilities => user?.capabilities ?? const {};

  /// Whether a known expiry has already passed, requiring a fresh sign-in.
  bool get isExpired =>
      expiresAt != null && !expiresAt!.isAfter(DateTime.now());

  @override
  bool operator ==(Object other) =>
      other is AuthState &&
      other.status == status &&
      other.user?.id == user?.id &&
      other.user?.role == user?.role &&
      other.accessToken == accessToken;

  @override
  int get hashCode => Object.hash(status, user?.id, user?.role, accessToken);
}
