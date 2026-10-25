import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/media/media_url.dart';
import 'package:agri_connect/features/account/domain/account_entities.dart';
import 'package:agri_connect/features/auth/data/dto/auth_user_dto.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/profile_verification_status.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';

Object? _fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync());

void main() {
  test('me supplier fixture maps profile, avatar, and verification status', () {
    final user = AuthUserDto.fromJson(_fixture('me_supplier'));

    expect(user.role, RoleCode.supplier);
    expect(
      user.profileVerificationStatus,
      ProfileVerificationStatus.unverified,
    );
    expect(user.profile, isA<SupplierProfile>());
    expect((user.profile as SupplierProfile).zoneId, 2);
    expect(user.avatarUrl, MediaUrl.resolve('/uploads/avatars/73.webp'));
  });

  test(
    'verification documents fixture parses status, rejection note, and date',
    () {
      final documents = (_fixture('documents_list') as List)
          .map(VerificationDocument.fromJson)
          .toList();

      expect(documents, hasLength(3));
      expect(documents.first.status, 'PENDING');
      expect(documents[1].status, 'REJECTED');
      expect(documents[1].note, 'Le document est illisible.');
      expect(documents.first.createdAt, isA<DateTime>());
    },
  );

  test('payout account fixture parses only masked account numbers', () {
    final accounts = (_fixture('payout_accounts') as List)
        .map(PayoutAccount.fromJson)
        .toList();

    expect(accounts, hasLength(2));
    expect(accounts.first.accountNumberMasked, '••••0073');
    expect(accounts.first.isDefault, isTrue);
    expect(
      (_fixture('payout_accounts') as List).first.containsKey('accountNumber'),
      isFalse,
    );
  });

  test('referral fixture matches actual totals envelope and entries', () {
    final summary = ReferralSummary.fromJson(_fixture('referral'));

    expect(summary.code, 'AMINA73');
    expect(summary.totals.pending, 2);
    expect(summary.totals.eligible, 1);
    expect(summary.totals.paid, 3);
    expect(summary.referrals.first.referredFirstname, 'Moussa');
    expect(summary.referrals.first.rewardAmount, 1500);
  });
}
