import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/features/auth/data/dto/auth_user_dto.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';

class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  Future<(AuthUser, AuthTokens)> login(String email, String password) async =>
      _parseAuthResult(
        await _client.post(
          'auth/login',
          auth: false,
          data: {'email': email, 'password': password},
        ),
      );

  Future<(AuthUser, AuthTokens)> register(Map<String, Object?> payload) async =>
      _parseAuthResult(
        await _client.post('auth/register', auth: false, data: payload),
      );

  Future<AuthUser> me() async =>
      AuthUserDto.fromJson(await _client.get('auth/me'));

  Future<void> logout(String refreshToken) async {
    await _client.post(
      'auth/logout',
      auth: false,
      data: {'refreshToken': refreshToken},
    );
  }

  Future<void> forgotPassword(String email) async {
    await _client.post(
      'auth/forgot-password',
      auth: false,
      data: {'email': email},
    );
  }

  Future<void> resendVerification() async {
    await _client.post('auth/resend-verification');
  }

  Future<List<AuthSession>> listSessions() async {
    final response = await _client.get('auth/sessions');
    if (response is! Map || response['sessions'] is! List) {
      throw const FormatException('Expected a sessions object');
    }
    return (response['sessions'] as List)
        .whereType<Map>()
        .map(_session)
        .toList(growable: false);
  }

  Future<void> closeSession(int id) async {
    await _client.delete('auth/sessions/$id');
  }

  Future<void> logoutAll() async {
    await _client.post('auth/logout-all');
  }

  Future<List<LegalDocument>> listLegal(String language) async {
    final response = await _client.get(
      'legal',
      auth: false,
      query: {'lang': language},
    );
    if (response is! List) {
      throw const FormatException('Expected a legal documents list');
    }
    return response.whereType<Map>().map(_legal).toList(growable: false);
  }

  Future<LegalDocument> getLegal(String code, String language) async {
    final response = await _client.get(
      'legal/$code',
      auth: false,
      query: {'lang': language},
    );
    if (response is! Map) {
      throw const FormatException('Expected a legal document');
    }
    return _legal(response);
  }

  static (AuthUser, AuthTokens) _parseAuthResult(Object? response) {
    if (response is! Map ||
        response['accessToken'] is! String ||
        response['refreshToken'] is! String) {
      throw const FormatException('Expected authentication tokens');
    }
    return (
      AuthUserDto.fromJson(response['user']),
      AuthTokens(
        accessToken: response['accessToken'] as String,
        refreshToken: response['refreshToken'] as String,
      ),
    );
  }

  static AuthSession _session(Map session) {
    DateTime? date(String field) =>
        DateTime.tryParse(session[field]?.toString() ?? '');
    return AuthSession(
      id: session['id'] is int ? session['id'] as int : 0,
      userAgent: session['userAgent'] is String
          ? session['userAgent'] as String
          : null,
      ip: session['ip'] is String ? session['ip'] as String : null,
      createdAt: date('createdAt'),
      lastActivityAt: date('lastActivityAt'),
      expiresAt: date('expiresAt'),
      isCurrent: session['isCurrent'] == true,
    );
  }

  static LegalDocument _legal(Map value) => LegalDocument(
    code: value['code'] is String ? value['code'] as String : '',
    title: value['title'] is String
        ? value['title'] as String
        : value['label'] is String
        ? value['label'] as String
        : null,
    version: value['version'] is String ? value['version'] as String : null,
    locale: value['locale'] is String ? value['locale'] as String : null,
    content: value['content'] is String ? value['content'] as String : null,
    publishedAt: DateTime.tryParse(value['publishedAt']?.toString() ?? ''),
  );
}
