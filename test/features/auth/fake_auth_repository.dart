import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/profile_verification_status.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

class FakeAuthRepository implements AuthRepository {
  Object? signInError;
  Object? signUpError;
  Object? meError;
  AuthUser user = const AuthUser(
    id: 1,
    firstname: 'Test',
    lastname: 'User',
    email: 'test@example.test',
    phone: '+237600000000',
    role: RoleCode.supplier,
    roleLabel: 'Supplier',
    emailVerified: true,
    profileVerificationStatus: ProfileVerificationStatus.verified,
  );
  AuthTokens tokens = const AuthTokens(
    accessToken: 'test-access',
    refreshToken: 'test-refresh',
  );
  int logoutCalls = 0;
  int logoutAllCalls = 0;
  int forgotPasswordCalls = 0;
  int meCalls = 0;
  int signUpCalls = 0;
  Map<String, Object?>? lastPayload;

  @override
  Future<(AuthUser, AuthTokens)> signIn(String email, String password) async {
    _throwIfPresent(signInError);
    return (user, tokens);
  }

  @override
  Future<(AuthUser, AuthTokens)> signUp(Map<String, Object?> payload) async {
    signUpCalls++;
    lastPayload = payload;
    _throwIfPresent(signUpError);
    return (user, tokens);
  }

  @override
  Future<AuthUser> me() async {
    meCalls++;
    _throwIfPresent(meError);
    return user;
  }

  @override
  Future<void> logout(String refreshToken) async {
    logoutCalls++;
  }

  @override
  Future<void> logoutAll() async {
    logoutAllCalls++;
  }

  @override
  Future<void> forgotPassword(String email) async {
    forgotPasswordCalls++;
  }

  @override
  Future<void> resendVerification() async {}

  @override
  Future<List<AuthSession>> listSessions() async => const [];

  @override
  Future<void> closeSession(int id) async {}

  @override
  Future<List<LegalDocument>> listLegal(String language) async => const [];

  @override
  Future<LegalDocument> getLegal(String code, String language) async =>
      LegalDocument(code: code);

  void _throwIfPresent(Object? error) {
    if (error != null) throw error;
  }
}
