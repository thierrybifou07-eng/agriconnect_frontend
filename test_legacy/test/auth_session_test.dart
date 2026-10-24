import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/storage/session_storage.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/application/auth_state.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';

/// LocalSessionStorage key names, mirrored so tests can assert what the real
/// storage persisted and removed.
const _userKey = 'auth_user_v1';
const _tokenKey = 'auth_token_v1';
const _expiryKey = 'auth_token_expires_at_v1';

AuthUser _demoUser() => AuthUser(
  id: 'u-1',
  fullName: 'Ada Diallo',
  email: 'ada@example.com',
  role: UserRole.supplier,
);

/// Wait until the controller finished its async session restore.
Future<AuthState> _awaitAuth(ProviderContainer container) async {
  var state = container.read(authControllerProvider);
  var attempts = 0;
  while (state.status == AuthStatus.initial && attempts < 100) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    state = container.read(authControllerProvider);
    attempts++;
  }
  return state;
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository();

  @override
  Future<AuthResult> signIn(SignInRequest request) async {
    return AuthResult(user: _demoUser(), accessToken: 'token-1');
  }

  @override
  Future<AuthResult> register(RegisterRequest request) async {
    return AuthResult(user: _demoUser(), accessToken: 'token-1');
  }
}

class _FakeSessionStorage implements SessionStorage {
  final Map<String, String> data = {};
  bool failReads = false;
  bool failTokenWrite = false;
  bool failClear = false;
  int clearCalls = 0;
  final List<String> writeOrder = [];

  @override
  Future<String?> readUserJson() async {
    if (failReads) throw const CacheFailure();
    return data[_userKey];
  }

  @override
  Future<void> writeUserJson(String value) async {
    writeOrder.add('writeUserJson');
    data[_userKey] = value;
  }

  @override
  Future<String?> readToken() async {
    if (failReads) throw const CacheFailure();
    return data[_tokenKey];
  }

  @override
  Future<void> writeToken(String value) async {
    writeOrder.add('writeToken');
    if (failTokenWrite) throw const CacheFailure();
    data[_tokenKey] = value;
  }

  @override
  Future<DateTime?> readExpiryAt() async {
    if (failReads) throw const CacheFailure();
    final raw = data[_expiryKey];
    return raw == null ? null : DateTime.tryParse(raw);
  }

  @override
  Future<void> writeExpiryAt(DateTime? value) async {
    writeOrder.add('writeExpiryAt');
    if (value == null) {
      data.remove(_expiryKey);
    } else {
      data[_expiryKey] = value.toIso8601String();
    }
  }

  @override
  Future<void> clear() async {
    clearCalls++;
    if (failClear) throw const CacheFailure();
    data.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthController session restore (real SharedPreferences)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('restores a valid persisted session with its token', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final failure = await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'ada@example.com', password: 'x');
      expect(failure, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_tokenKey), 'token-1');
      expect(prefs.getString(_userKey), isNotNull);

      final fresh = ProviderContainer();
      addTearDown(fresh.dispose);
      final state = await _awaitAuth(fresh);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.email, 'ada@example.com');
      expect(state.accessToken, 'token-1');
    });

    test('stays unauthenticated when nothing is stored', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = await _awaitAuth(container);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
    });

    test('signs out and clears storage when the session is expired', () async {
      SharedPreferences.setMockInitialValues({
        _userKey: jsonEncode(_demoUser().toJson()),
        _tokenKey: 'token-expired',
        _expiryKey: DateTime(2020).toIso8601String(),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = await _awaitAuth(container);
      expect(state.status, AuthStatus.unauthenticated);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
    });

    test('restores a stored user even when no token was persisted', () async {
      SharedPreferences.setMockInitialValues({
        _userKey: jsonEncode(_demoUser().toJson()),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = await _awaitAuth(container);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.email, 'ada@example.com');
      expect(state.accessToken, isNull);
    });

    test('wipes corrupt stored JSON and signs out', () async {
      SharedPreferences.setMockInitialValues({
        _userKey: '{not-json',
        _tokenKey: 'token-orphan',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = await _awaitAuth(container);
      expect(state.status, AuthStatus.unauthenticated);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
    });

    test('drops a stored JSON that is not a user object', () async {
      SharedPreferences.setMockInitialValues({
        _userKey: '"just-a-string"',
        _tokenKey: 'token-orphan',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = await _awaitAuth(container);
      expect(state.status, AuthStatus.unauthenticated);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
    });

    test('sign-out removes every session key from storage', () async {
      SharedPreferences.setMockInitialValues({
        _userKey: jsonEncode(_demoUser().toJson()),
        _tokenKey: 'token-1',
        _expiryKey: DateTime(2999).toIso8601String(),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _awaitAuth(container);

      await container.read(authControllerProvider.notifier).signOut();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
      expect(
        container.read(authControllerProvider).status,
        AuthStatus.unauthenticated,
      );
    });
  });

  group('AuthController session restore (storage failures)', () {
    test('signs out without wiping when the store cannot be read', () async {
      final storage = _FakeSessionStorage()
        ..data[_userKey] = jsonEncode(_demoUser().toJson())
        ..data[_tokenKey] = 'token-1'
        ..failReads = true;
      final container = ProviderContainer(
        overrides: [sessionStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      final state = await _awaitAuth(container);
      expect(state.status, AuthStatus.unauthenticated);
      expect(storage.clearCalls, 0);
      expect(storage.data.containsKey(_tokenKey), isTrue);
    });

    test(
      'sign-in with a failing token write cleans half-written session',
      () async {
        final storage = _FakeSessionStorage()..failTokenWrite = true;
        final container = ProviderContainer(
          overrides: [
            sessionStorageProvider.overrideWithValue(storage),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          ],
        );
        addTearDown(container.dispose);

        final failure = await container
            .read(authControllerProvider.notifier)
            .signIn(email: 'ada@example.com', password: 'x');

        expect(failure, isA<CacheFailure>());
        expect(
          container.read(authControllerProvider).status,
          AuthStatus.unauthenticated,
        );
        expect(storage.clearCalls, greaterThanOrEqualTo(1));
        expect(storage.data, isEmpty);
      },
    );

    test(
      'sign-out signed out in memory even when the store cannot be cleared',
      () async {
        final storage = _FakeSessionStorage();
        final container = ProviderContainer(
          overrides: [
            sessionStorageProvider.overrideWithValue(storage),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(authControllerProvider.notifier)
            .signIn(email: 'ada@example.com', password: 'x');
        expect(
          container.read(authControllerProvider).status,
          AuthStatus.authenticated,
        );

        storage.failClear = true;
        await container.read(authControllerProvider.notifier).signOut();

        expect(
          container.read(authControllerProvider).status,
          AuthStatus.unauthenticated,
        );
        expect(storage.data.containsKey(_tokenKey), isTrue);
      },
    );

    test('persists token and expiry before the user restore marker', () async {
      final storage = _FakeSessionStorage()
        ..data[_expiryKey] = DateTime(2999).toIso8601String();
      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'ada@example.com', password: 'x');

      expect(storage.writeOrder, [
        'writeToken',
        'writeExpiryAt',
        'writeUserJson',
      ]);
    });
  });
}
