import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

/// Input of a sign-in attempt.
class SignInRequest {
  const SignInRequest({
    required this.email,
    required this.password,
    this.expectedRole,
  });

  final String email;
  final String password;

  /// Role selected during onboarding. When set, the repository must reject
  /// accounts whose role differs (code `role_mismatch`) so that users can
  /// never land in the wrong workspace.
  final UserRole? expectedRole;
}

/// Input of a registration attempt.
class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  });

  final String fullName;
  final String email;
  final String password;
  final UserRole role;
}

/// Session materialized by a successful authentication.
///
/// [accessToken] is the JWT issued by the backend; [expiresAt] is optional and
/// mirrors the token `exp` claim when the server provides one.
class AuthResult {
  const AuthResult({
    required this.user,
    required this.accessToken,
    this.expiresAt,
  });

  final AuthUser user;
  final String accessToken;
  final DateTime? expiresAt;
}

/// Contract for authenticating users.
abstract interface class AuthRepository {
  /// Authenticates [request] and returns the authenticated session.
  ///
  /// Throws a [Failure] (usually [AuthFailure]) when credentials are rejected.
  Future<AuthResult> signIn(SignInRequest request);

  /// Registers a new user from [request] and returns its session.
  ///
  /// Throws an [AuthFailure] with code `email_exists` when the address is
  /// already in use.
  Future<AuthResult> register(RegisterRequest request);
}
