import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/features/auth/data/dto/auth_user_dto.dart';
import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/core/media/media_url.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('login supplier fixture maps role and absent profile fields', () {
    final fixture = _fixture('login_supplier');
    final user = AuthUserDto.fromJson(fixture['user']);

    expect(user.role, RoleCode.supplier);
    expect(user.firstname, 'Amina');
    expect(user.profile, isNull);
    expect(fixture['accessToken'], isA<String>());
    expect(fixture['refreshToken'], isA<String>());
  });

  test('login agent fixture maps each advertised capability', () {
    final fixture = _fixture('login_agent_with_capabilities');
    final user = AuthUserDto.fromJson(fixture['user']);

    expect(user.role, RoleCode.agent);
    expect(user.agent?.capabilities, hasLength(9));
    expect(
      user.agent?.capabilities,
      contains(AgentCapability.userVerification),
    );
  });

  test('me buyer fixture maps profile, avatar and verification status', () {
    final user = AuthUserDto.fromJson(_fixture('me_buyer'));

    expect(user.role, RoleCode.buyer);
    expect(user.emailVerified, isFalse);
    expect(user.profile, isA<BuyerProfile>());
    expect((user.profile as BuyerProfile).buyerType, 'WHOLESALER');
    expect(user.avatarUrl, MediaUrl.resolve('/uploads/avatars/buyer.png'));
  });

  test('validation and conflict fixtures preserve server field errors', () {
    final validation = _fixture('register_validation_error');
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/register'),
          statusCode: 400,
          data: validation,
        ),
      ),
    );
    final conflict = _fixture('error_409_conflict');

    expect(failure.fieldErrors['phone'], contains('téléphone'));
    expect(failure.fieldErrors['farmName'], contains('exploitation'));
    expect(conflict['error'], contains('email'));
  });

  test(
    'sessions fixture uses the sessions envelope and current-session flag',
    () {
      final fixture = _fixture('sessions');
      final sessions = fixture['sessions'] as List<dynamic>;

      expect(sessions, hasLength(1));
      expect(sessions.single['lastActivityAt'], isA<String>());
      expect(sessions.single['isCurrent'], isTrue);
    },
  );

  test('DTO tolerates missing fields and unknown enum values', () {
    final user = AuthUserDto.fromJson({
      'role': {'code': 'NEW_ROLE'},
      'profile': {'unknown': true},
    });

    expect(user.id, isNull);
    expect(user.email, isNull);
    expect(user.role, RoleCode.unknown);
    expect(user.profile, isNull);
  });
}
