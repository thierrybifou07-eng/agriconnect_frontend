import 'dart:typed_data';

import 'package:agri_connect/features/account/domain/account_entities.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';

abstract interface class AccountRepository {
  Future<AuthUser> updateUser(Map<String, Object?> values);
  Future<void> updateRoleProfile(Map<String, Object?> values);
  Future<void> uploadAvatar(Uint8List bytes, String filename);
  Future<List<VerificationDocument>> listDocuments();
  Future<VerificationDocument> uploadDocument(
    Uint8List bytes,
    String filename,
    String type,
  );
  Future<List<PayoutAccount>> listPayoutAccounts();
  Future<PayoutAccount> createPayoutAccount(Map<String, Object?> values);
  Future<PayoutAccount> updatePayoutAccount(
    int id,
    Map<String, Object?> values,
  );
  Future<void> deletePayoutAccount(int id);
  Future<ReferralSummary> referral();
}
