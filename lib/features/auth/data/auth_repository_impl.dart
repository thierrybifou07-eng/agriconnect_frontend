import 'package:agri_connect/features/auth/data/auth_api.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._api);

  final AuthApi _api;

  @override
  Future<(AuthUser, AuthTokens)> signIn(String email, String password) =>
      _api.login(email, password);

  @override
  Future<(AuthUser, AuthTokens)> signUp(Map<String, Object?> payload) =>
      _api.register(payload);

  @override
  Future<AuthUser> me() => _api.me();

  @override
  Future<void> logout(String refreshToken) => _api.logout(refreshToken);

  @override
  Future<void> logoutAll() => _api.logoutAll();

  @override
  Future<void> forgotPassword(String email) => _api.forgotPassword(email);

  @override
  Future<void> resendVerification() => _api.resendVerification();

  @override
  Future<List<AuthSession>> listSessions() => _api.listSessions();

  @override
  Future<void> closeSession(int id) => _api.closeSession(id);

  @override
  Future<List<LegalDocument>> listLegal(String language) =>
      _api.listLegal(language);

  @override
  Future<LegalDocument> getLegal(String code, String language) =>
      _api.getLegal(code, language);
}
