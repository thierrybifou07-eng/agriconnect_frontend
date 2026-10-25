class VerificationDocument {
  const VerificationDocument({
    required this.id,
    required this.type,
    required this.status,
    this.note,
    this.createdAt,
  });

  final int id;
  final String type;
  final String status;
  final String? note;
  final DateTime? createdAt;

  factory VerificationDocument.fromJson(Object? json) {
    final map = _map(json, 'verification document');
    return VerificationDocument(
      id: _int(map['id'], 'id'),
      type: _string(map['type'], 'type'),
      status: _string(map['status'], 'status'),
      note: _optionalString(map['note']),
      createdAt: _date(map['createdAt']),
    );
  }
}

class PayoutAccount {
  const PayoutAccount({
    required this.id,
    required this.method,
    this.provider,
    this.accountName,
    required this.accountNumberMasked,
    required this.isDefault,
    this.createdAt,
  });

  final int id;
  final String method;
  final String? provider;
  final String? accountName;
  final String accountNumberMasked;
  final bool isDefault;
  final DateTime? createdAt;

  factory PayoutAccount.fromJson(Object? json) {
    final map = _map(json, 'payout account');
    return PayoutAccount(
      id: _int(map['id'], 'id'),
      method: _string(map['method'], 'method'),
      provider: _optionalString(map['provider']),
      accountName: _optionalString(map['accountName']),
      accountNumberMasked: _string(
        map['accountNumberMasked'],
        'accountNumberMasked',
      ),
      isDefault: map['isDefault'] == true,
      createdAt: _date(map['createdAt']),
    );
  }
}

class ReferralTotals {
  const ReferralTotals({
    required this.pending,
    required this.eligible,
    required this.paid,
  });

  final int pending;
  final int eligible;
  final int paid;

  factory ReferralTotals.fromJson(Object? json) {
    final map = _map(json, 'referral totals');
    return ReferralTotals(
      pending: _int(map['pending'], 'pending'),
      eligible: _int(map['eligible'], 'eligible'),
      paid: _int(map['paid'], 'paid'),
    );
  }
}

class ReferralEntry {
  const ReferralEntry({
    required this.status,
    required this.kind,
    required this.rewardAmount,
    this.createdAt,
    this.referredFirstname,
  });

  final String status;
  final String kind;
  final double rewardAmount;
  final DateTime? createdAt;
  final String? referredFirstname;

  factory ReferralEntry.fromJson(Object? json) {
    final map = _map(json, 'referral');
    return ReferralEntry(
      status: _string(map['status'], 'status'),
      kind: _string(map['kind'], 'kind'),
      rewardAmount: _double(map['rewardAmount'], 'rewardAmount'),
      createdAt: _date(map['createdAt']),
      referredFirstname: _optionalString(map['referredFirstname']),
    );
  }
}

class ReferralSummary {
  const ReferralSummary({
    this.code,
    required this.totals,
    required this.referrals,
  });

  final String? code;
  final ReferralTotals totals;
  final List<ReferralEntry> referrals;

  factory ReferralSummary.fromJson(Object? json) {
    final map = _map(json, 'referral summary');
    final referrals = map['referrals'];
    if (referrals is! List) {
      throw const FormatException('Expected referrals list');
    }
    return ReferralSummary(
      code: _optionalString(map['code']),
      totals: ReferralTotals.fromJson(map['totals']),
      referrals: List.unmodifiable(referrals.map(ReferralEntry.fromJson)),
    );
  }
}

Map<Object?, Object?> _map(Object? value, String label) {
  if (value is Map) return value;
  throw FormatException('Expected $label object');
}

String _string(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('Expected $field string');
}

String? _optionalString(Object? value) => value is String ? value : null;

int _int(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('Expected $field integer');
}

double _double(Object? value, String field) {
  if (value is num) return value.toDouble();
  throw FormatException('Expected $field number');
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
