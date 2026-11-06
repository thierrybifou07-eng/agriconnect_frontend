import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_client.dart';

import '../support/fake_http_adapter.dart';

ApiClient _client(FakeHttpAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return ApiClient(dio: dio, baseUrl: 'http://10.0.2.2:4000/api/v2');
}

Future<ApiFailure> _failureOf(Future<Object?> call) async {
  try {
    await call;
  } on ApiFailure catch (failure) {
    return failure;
  }
  fail('Expected an ApiFailure');
}

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('keeps /api/v2 in the URL even when the path starts with a slash', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue('auth/me', const FakeHttpResponse(statusCode: 200, data: {'id': 1}));
    final api = _client(adapter);

    final body = await api.get('/auth/me');

    expect(body, {'id': 1});
    expect(adapter.requests.single.uri.toString(), 'http://10.0.2.2:4000/api/v2/auth/me');
    expect(adapter.requests.single.extra['auth'], isTrue);
  });

  test('marks public calls with auth: false', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue('auth/login', const FakeHttpResponse(statusCode: 200, data: {}));
    await _client(adapter).post('auth/login', data: {'email': 'a@b.cm'}, auth: false);
    expect(adapter.requests.single.extra['auth'], isFalse);
  });

  test('maps the error envelope: code, message, Joi details and extras', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue(
        'supplier/lots',
        const FakeHttpResponse(
          statusCode: 403,
          data: {
            'error': 'Votre profil doit être vérifié',
            'code': 'PROFILE_NOT_VERIFIED',
            'profileVerificationStatus': 'PENDING',
          },
        ),
      )
      ..enqueue(
        'auth/register',
        const FakeHttpResponse(
          statusCode: 400,
          data: {
            'error': 'Données invalides',
            'details': [
              {'field': 'phone', 'message': 'phone invalide'},
            ],
          },
        ),
      );
    final api = _client(adapter);

    final notVerified = await _failureOf(api.post('supplier/lots'));
    expect(notVerified.status, 403);
    expect(notVerified.code, 'PROFILE_NOT_VERIFIED');
    expect(notVerified.isProfileNotVerified, isTrue);
    expect(notVerified.profileVerificationStatus, 'PENDING');
    expect(notVerified.message(fr), fr.apiErrProfileNotVerified);
    expect(notVerified.message(en), en.apiErrProfileNotVerified);

    final invalid = await _failureOf(api.post('auth/register', auth: false));
    expect(invalid.isValidation, isTrue);
    expect(invalid.fieldErrors, {'phone': 'phone invalide'});
    expect(invalid.code, 'http_400');
    expect(invalid.message(fr), fr.errInvalidRequest);
  });

  test('falls back on the HTTP status, then on the server message', () async {
    final adapter = FakeHttpAdapter()
      ..enqueue('a', const FakeHttpResponse(statusCode: 404, data: {'error': 'Lot introuvable'}))
      ..enqueue('b', const FakeHttpResponse(statusCode: 422, data: {'error': 'Message serveur'}))
      ..enqueue('c', const FakeHttpResponse(statusCode: 503, data: {'error': 'Indisponible'}))
      ..enqueue('d', const FakeHttpResponse(statusCode: 429, data: {'error': 'Trop'}));
    final api = _client(adapter);

    expect((await _failureOf(api.get('a'))).message(fr), fr.errNotFound);
    expect((await _failureOf(api.get('b'))).message(fr), 'Message serveur');
    final server = await _failureOf(api.get('c'));
    expect(server.kind, ApiFailureKind.server);
    expect(server.message(fr), fr.errServer);
    final limited = await _failureOf(api.get('d'));
    expect(limited.isRateLimited, isTrue);
    expect(limited.message(en), en.apiErrRateLimited);
  });

  test('turns transport errors into network and timeout failures', () async {
    final adapter = FakeHttpAdapter()
      ..enqueueError('slow', DioExceptionType.receiveTimeout)
      ..enqueueError('down', DioExceptionType.connectionError);
    final api = _client(adapter);

    final slow = await _failureOf(api.get('slow'));
    expect(slow.kind, ApiFailureKind.timeout);
    expect(slow.code, 'timeout');
    expect(slow.message(fr), fr.errTimeout);

    final down = await _failureOf(api.get('down'));
    expect(down.kind, ApiFailureKind.network);
    expect(down.message(en), en.errNetwork);
  });

  test('every mapped backend code has a French and an English message', () {
    const codes = [
      'ACCOUNT_SUSPENDED', 'CAPABILITY_REQUIRED', 'HUMAN_ACTOR_REQUIRED',
      'INVALID_STATE_TRANSITION', 'PRICE_BELOW_SUPPLIER', 'ZONE_NOT_COVERED',
      'DELIVERY_ALREADY_TAKEN', 'TOO_MANY_PENDING_DOCUMENTS', 'AI_BUSY',
      'AI_RATE_LIMITED',
    ];
    for (final code in codes) {
      expect(apiErrorMessage(code, fr), isNotNull, reason: code);
      expect(apiErrorMessage(code, en), isNot(apiErrorMessage(code, fr)), reason: code);
    }
    expect(apiErrorMessage('UNKNOWN_CODE', fr), isNull);
  });
}
