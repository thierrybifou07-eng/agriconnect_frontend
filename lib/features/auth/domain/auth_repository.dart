import 'package:agri_connect/features/auth/domain/auth_user.dart';

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

class AuthSession {
  const AuthSession({
    required this.id,
    this.userAgent,
    this.ip,
    this.createdAt,
    this.lastActivityAt,
    this.expiresAt,
    this.isCurrent = false,
  });

  final int id;
  final String? userAgent;
  final String? ip;
  final DateTime? createdAt;
  final DateTime? lastActivityAt;
  final DateTime? expiresAt;
  final bool isCurrent;
}

class LegalDocument {
  const LegalDocument({
    required this.code,
    this.title,
    this.version,
    this.locale,
    this.content,
    this.publishedAt,
  });

  final String code;
  final String? title;
  final String? version;
  final String? locale;
  final String? content;
  final DateTime? publishedAt;
}

abstract interface class AuthRepository {
  Future<(AuthUser, AuthTokens)> signIn(String email, String password);
  Future<(AuthUser, AuthTokens)> signUp(Map<String, Object?> payload);
  Future<AuthUser> me();
  Future<void> logout(String refreshToken);
  Future<void> logoutAll();
  Future<void> forgotPassword(String email);
  Future<void> resendVerification();
  Future<List<AuthSession>> listSessions();
  Future<void> closeSession(int id);
  Future<List<LegalDocument>> listLegal(String language);
  Future<LegalDocument> getLegal(String code, String language);
}
