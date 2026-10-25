import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/features/account/domain/account_entities.dart';
import 'package:agri_connect/features/auth/data/dto/auth_user_dto.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';

class AccountApi {
  const AccountApi(this._client);

  final ApiClient _client;

  Future<AuthUser> updateUser(Map<String, Object?> values) async =>
      AuthUserDto.fromJson(await _client.patch('auth/me', data: values));

  Future<void> updateRoleProfile(Map<String, Object?> values) async {
    await _client.patch('auth/me/profile', data: values);
  }

  Future<void> uploadAvatar(Uint8List bytes, String filename) async {
    await _client.postMultipart(
      'auth/me/avatar',
      FormData.fromMap({
        'avatar': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    );
  }

  Future<List<VerificationDocument>> listDocuments() async {
    final response = await _client.get('auth/me/documents');
    if (response is! List) {
      throw const FormatException('Expected verification documents list');
    }
    return List.unmodifiable(response.map(VerificationDocument.fromJson));
  }

  Future<VerificationDocument> uploadDocument(
    Uint8List bytes,
    String filename,
    String type,
  ) async {
    final response = await _client.postMultipart(
      'auth/me/documents',
      FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'type': type,
      }),
    );
    return VerificationDocument.fromJson(response);
  }

  Future<List<PayoutAccount>> listPayoutAccounts() async {
    final response = await _client.get('auth/me/payout-accounts');
    if (response is! List) {
      throw const FormatException('Expected payout accounts list');
    }
    return List.unmodifiable(response.map(PayoutAccount.fromJson));
  }

  Future<PayoutAccount> createPayoutAccount(
    Map<String, Object?> values,
  ) async => PayoutAccount.fromJson(
    await _client.post('auth/me/payout-accounts', data: values),
  );

  Future<PayoutAccount> updatePayoutAccount(
    int id,
    Map<String, Object?> values,
  ) async => PayoutAccount.fromJson(
    await _client.patch('auth/me/payout-accounts/$id', data: values),
  );

  Future<void> deletePayoutAccount(int id) async {
    await _client.delete('auth/me/payout-accounts/$id');
  }

  Future<ReferralSummary> referral() async =>
      ReferralSummary.fromJson(await _client.get('auth/me/referral'));
}
