import 'dart:typed_data';

import 'package:agri_connect/features/account/domain/account_entities.dart';
import 'package:agri_connect/features/account/domain/account_repository.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';

class FakeAccountRepository implements AccountRepository {
  Object? documentError;
  int uploadDocumentCalls = 0;
  List<VerificationDocument> documents = const [];
  List<PayoutAccount> payoutAccounts = const [];
  ReferralSummary referralSummary = const ReferralSummary(
    code: 'TEST',
    totals: ReferralTotals(pending: 0, eligible: 0, paid: 0),
    referrals: [],
  );

  @override
  Future<AuthUser> updateUser(Map<String, Object?> values) async =>
      const AuthUser();

  @override
  Future<void> updateRoleProfile(Map<String, Object?> values) async {}

  @override
  Future<void> uploadAvatar(Uint8List bytes, String filename) async {}

  @override
  Future<List<VerificationDocument>> listDocuments() async => documents;

  @override
  Future<VerificationDocument> uploadDocument(
    Uint8List bytes,
    String filename,
    String type,
  ) async {
    uploadDocumentCalls++;
    if (documentError != null) throw documentError!;
    return const VerificationDocument(
      id: 1,
      type: 'ID_CARD',
      status: 'PENDING',
    );
  }

  @override
  Future<List<PayoutAccount>> listPayoutAccounts() async => payoutAccounts;

  @override
  Future<PayoutAccount> createPayoutAccount(
    Map<String, Object?> values,
  ) async => const PayoutAccount(
    id: 1,
    method: 'CASH',
    accountNumberMasked: '••••1234',
    isDefault: false,
  );

  @override
  Future<PayoutAccount> updatePayoutAccount(
    int id,
    Map<String, Object?> values,
  ) async => const PayoutAccount(
    id: 1,
    method: 'CASH',
    accountNumberMasked: '••••1234',
    isDefault: false,
  );

  @override
  Future<void> deletePayoutAccount(int id) async {}

  @override
  Future<ReferralSummary> referral() async => referralSummary;
}
