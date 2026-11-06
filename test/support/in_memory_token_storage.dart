import 'package:agri_connect/core/storage/token_storage.dart';

/// Token storage kept in memory, for tests (no platform keystore).
class InMemoryTokenStorage implements TokenStorage {
  TokenPair? _tokens;
  int saveCount = 0;

  @override
  Future<TokenPair?> read() async => _tokens;

  @override
  Future<void> save({required String access, required String refresh}) async {
    saveCount++;
    _tokens = TokenPair(access: access, refresh: refresh);
  }

  @override
  Future<void> clear() async => _tokens = null;
}
