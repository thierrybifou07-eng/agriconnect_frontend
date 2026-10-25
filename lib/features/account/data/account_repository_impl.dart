import 'dart:typed_data';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/features/account/data/account_api.dart';
import 'package:agri_connect/features/account/domain/account_entities.dart';
import 'package:agri_connect/features/account/domain/account_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._api);

  final AccountApi _api;

  @override
  Future<AuthUser> updateUser(Map<String, Object?> values) =>
      _parse(_api.updateUser(values));

  @override
  Future<void> updateRoleProfile(Map<String, Object?> values) =>
      _parse(_api.updateRoleProfile(values));

  @override
  Future<void> uploadAvatar(Uint8List bytes, String filename) =>
      _parse(_api.uploadAvatar(bytes, filename));

  @override
  Future<List<VerificationDocument>> listDocuments() =>
      _parse(_api.listDocuments());

  @override
  Future<VerificationDocument> uploadDocument(
    Uint8List bytes,
    String filename,
    String type,
  ) => _parse(_api.uploadDocument(bytes, filename, type));

  @override
  Future<List<PayoutAccount>> listPayoutAccounts() =>
      _parse(_api.listPayoutAccounts());

  @override
  Future<PayoutAccount> createPayoutAccount(Map<String, Object?> values) =>
      _parse(_api.createPayoutAccount(values));

  @override
  Future<PayoutAccount> updatePayoutAccount(
    int id,
    Map<String, Object?> values,
  ) => _parse(_api.updatePayoutAccount(id, values));

  @override
  Future<void> deletePayoutAccount(int id) =>
      _parse(_api.deletePayoutAccount(id));

  @override
  Future<ReferralSummary> referral() => _parse(_api.referral());

  Future<T> _parse<T>(Future<T> request) async {
    try {
      return await request;
    } on FormatException catch (error) {
      throw ApiFailure(
        status: null,
        code: null,
        message: error.message,
        fieldErrors: const {},
        kind: ApiFailureKind.server,
      );
    }
  }
}
