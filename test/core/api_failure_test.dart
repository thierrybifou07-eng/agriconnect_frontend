import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/api_failure.dart';

void main() {
  test('maps a 401 response', () {
    final failure = _failure(401, {'error': 'Session invalide'});

    expect(failure.status, 401);
    expect(failure.isUnauthorized, isTrue);
    expect(failure.kind, ApiFailureKind.client);
    expect(failure.message, 'Session invalide');
  });

  test('maps profile verification and state conflict codes', () {
    final profile = _failure(403, {
      'error': 'Profil incomplet',
      'code': 'PROFILE_NOT_VERIFIED',
    });
    final conflict = _failure(409, {
      'error': 'Transition invalide',
      'code': 'INVALID_STATE_TRANSITION',
    });

    expect(profile.isProfileNotVerified, isTrue);
    expect(conflict.isStateConflict, isTrue);
  });

  test('detects capability-required failures by code and message', () {
    final coded = _failure(403, {
      'error': 'Accès refusé',
      'code': 'CAPABILITY_REQUIRED',
    });
    final messaged = _failure(403, {'error': 'Capacité requise'});

    expect(coded.isCapabilityRequired, isTrue);
    expect(messaged.isCapabilityRequired, isTrue);
  });

  test('detects suspension from a French message when no code is present', () {
    final failure = _failure(403, {'error': 'Votre compte est suspendu.'});

    expect(failure.isSuspended, isTrue);
  });

  test('maps validation details by field', () {
    final failure = _failure(400, {
      'error': 'Données invalides',
      'details': [
        {'field': 'email', 'message': 'Adresse invalide'},
        {'field': 'password', 'message': 'Trop court'},
      ],
    });

    expect(failure.fieldErrors, {
      'email': 'Adresse invalide',
      'password': 'Trop court',
    });
  });

  test('maps network, timeout, and server failures', () {
    final request = RequestOptions(path: '/test');
    final network = ApiFailure.fromDio(
      DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
      ),
    );
    final timeout = ApiFailure.fromDio(
      DioException(
        requestOptions: request,
        type: DioExceptionType.receiveTimeout,
      ),
    );
    final server = _failure(503, {'error': 'Indisponible'});

    expect(network.kind, ApiFailureKind.network);
    expect(timeout.kind, ApiFailureKind.timeout);
    expect(server.kind, ApiFailureKind.server);
  });
}

ApiFailure _failure(int status, Object data) => ApiFailure.fromDio(
  DioException(
    requestOptions: RequestOptions(path: '/test'),
    response: Response(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: status,
      data: data,
    ),
  ),
);
