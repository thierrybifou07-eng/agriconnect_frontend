import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Access and refresh tokens of the current session.
class TokenPair {
  const TokenPair({required this.access, required this.refresh});

  final String access;
  final String refresh;
}

/// Where the session tokens live.
///
/// The refresh token grants 30 days of access: it never goes to
/// `shared_preferences`, only to the platform keystore (Android Keystore,
/// iOS Keychain) through [SecureTokenStorage].
abstract interface class TokenStorage {
  Future<TokenPair?> read();
  Future<void> save({required String access, required String refresh});
  Future<void> clear();
}

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);

final class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'agri_access_token_v2';
  static const _refreshKey = 'agri_refresh_token_v2';

  final FlutterSecureStorage _storage;

  @override
  Future<TokenPair?> read() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) return null;
    return TokenPair(access: access, refresh: refresh);
  }

  @override
  Future<void> save({required String access, required String refresh}) async {
    // Refresh token first: a session interrupted between the two writes
    // keeps a usable refresh token and recovers on the next 401.
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(key: _accessKey, value: access);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
