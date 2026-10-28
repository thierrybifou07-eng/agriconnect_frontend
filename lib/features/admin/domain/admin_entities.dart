class AdminStats {
  const AdminStats({
    this.usersByRole = const {},
    this.lotsByStatus = const {},
    this.ordersByStatus = const {},
    this.deliveriesByStatus = const {},
    this.availableStock = 0,
    this.reservedStock = 0,
    this.soldStock = 0,
    this.lostStock = 0,
    this.receivables = 0,
    this.receivablesCount = 0,
    this.pendingPayouts = 0,
    this.pendingCompensationsCount = 0,
    this.pendingCompensationsAmount = 0,
    this.eligibleReferralsCount = 0,
    this.eligibleReferralsAmount = 0,
    this.grossRevenue = 0,
  });

  final Map<String, int> usersByRole;
  final Map<String, int> lotsByStatus;
  final Map<String, int> ordersByStatus;
  final Map<String, int> deliveriesByStatus;
  final double availableStock;
  final double reservedStock;
  final double soldStock;
  final double lostStock;
  final double receivables;
  final int receivablesCount;
  final double pendingPayouts;
  final int pendingCompensationsCount;
  final double pendingCompensationsAmount;
  final int eligibleReferralsCount;
  final double eligibleReferralsAmount;
  final double grossRevenue;

  factory AdminStats.fromJson(Object? json) {
    final map = _object(json, 'admin stats');
    final stock = _optionalObject(map['stock']);
    final compensations = _optionalObject(map['pendingCompensations']);
    final referrals = _optionalObject(map['eligibleReferrals']);
    return AdminStats(
      usersByRole: _countMap(map['usersByRole']),
      lotsByStatus: _countMap(map['lotsByStatus']),
      ordersByStatus: _countMap(map['ordersByStatus']),
      deliveriesByStatus: _countMap(map['deliveriesByStatus']),
      availableStock: _number(stock?['available']),
      reservedStock: _number(stock?['reserved']),
      soldStock: _number(stock?['sold']),
      lostStock: _number(stock?['lost']),
      receivables: _number(map['receivables']),
      receivablesCount: _integerOrZero(map['receivablesCount']),
      pendingPayouts: _number(map['pendingPayouts']),
      pendingCompensationsCount: _integerOrZero(compensations?['count']),
      pendingCompensationsAmount: _number(compensations?['amount']),
      eligibleReferralsCount: _integerOrZero(referrals?['count']),
      eligibleReferralsAmount: _number(referrals?['amount']),
      grossRevenue: _number(map['grossRevenue']),
    );
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    this.firstname,
    this.lastname,
    this.phone,
    this.email,
    this.role,
    this.status,
    this.profileVerificationStatus,
    this.emailVerified,
    this.createdAt,
  });

  final int id;
  final String? firstname;
  final String? lastname;
  final String? phone;
  final String? email;
  final String? role;
  final String? status;
  final String? profileVerificationStatus;
  final bool? emailVerified;
  final DateTime? createdAt;

  String get fullName => [
    firstname,
    lastname,
  ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

  factory AdminUser.fromJson(Object? json) {
    final map = _object(json, 'admin user');
    final role = _optionalObject(map['role']);
    final status = _optionalObject(map['userStatus'] ?? map['status']);
    return AdminUser(
      id: _integer(map['id']),
      firstname: _optionalString(map['firstname']),
      lastname: _optionalString(map['lastname']),
      phone: _optionalString(map['phone']),
      email: _optionalString(map['email']),
      role: _optionalString(role?['code'] ?? map['roleCode'] ?? map['role']),
      status: _optionalString(status?['code'] ?? map['status']),
      profileVerificationStatus: _optionalString(
        map['profileVerificationStatus'],
      ),
      emailVerified: map['emailVerified'] is bool
          ? map['emailVerified'] as bool
          : null,
      createdAt: _date(map['createdAt']),
    );
  }
}

class AdminAgent {
  const AdminAgent({
    required this.id,
    required this.kind,
    required this.displayName,
    required this.isActive,
    required this.capabilities,
    this.autonomy,
    this.userName,
    this.aiProvider,
    this.aiModel,
  });

  final int id;
  final String kind;
  final String displayName;
  final bool isActive;
  final List<String> capabilities;
  final String? autonomy;
  final String? userName;
  final String? aiProvider;
  final String? aiModel;

  bool get isAi => kind.toUpperCase() == 'AI';

  factory AdminAgent.fromJson(Object? json) {
    final map = _object(json, 'admin agent');
    final rawCapabilities = map['capabilities'];
    final capabilities = <String>[];
    if (rawCapabilities is List) {
      for (final item in rawCapabilities) {
        final value = item is Map ? item['capability'] : item;
        final capability = value is Map ? value['code'] : value;
        if (capability is String && !capabilities.contains(capability)) {
          capabilities.add(capability);
        }
      }
    }
    final user = _optionalObject(map['user']);
    return AdminAgent(
      id: _integer(map['id']),
      kind: _optionalString(map['kind']) ?? 'HUMAN',
      displayName: _optionalString(map['displayName']) ?? '',
      isActive: map['isActive'] != false,
      capabilities: List.unmodifiable(capabilities),
      autonomy: _optionalString(map['autonomy']),
      aiProvider: _optionalString(map['aiProvider']),
      aiModel: _optionalString(map['aiModel']),
      userName: user == null
          ? null
          : [
              _optionalString(user['firstname']),
              _optionalString(user['lastname']),
            ].whereType<String>().where((part) => part.isNotEmpty).join(' '),
    );
  }
}

class PlatformSettings {
  const PlatformSettings({
    required this.supplierCommissionRate,
    required this.buyerFeeType,
    required this.buyerFeeValue,
    required this.transportMarkupRate,
    required this.referralBuyerReward,
    required this.referralSupplierReward,
    required this.reservationHours,
    required this.expiryCompensationRate,
    required this.currency,
  });

  final double supplierCommissionRate;
  final String buyerFeeType;
  final double buyerFeeValue;
  final double transportMarkupRate;
  final double referralBuyerReward;
  final double referralSupplierReward;
  final int reservationHours;
  final double expiryCompensationRate;
  final String currency;

  factory PlatformSettings.fromJson(Object? json) {
    final map = _object(json, 'platform settings');
    return PlatformSettings(
      supplierCommissionRate: _requiredNumber(map, 'supplierCommissionRate'),
      buyerFeeType: _requiredString(map, 'buyerFeeType'),
      buyerFeeValue: _requiredNumber(map, 'buyerFeeValue'),
      transportMarkupRate: _requiredNumber(map, 'transportMarkupRate'),
      referralBuyerReward: _requiredNumber(map, 'referralBuyerReward'),
      referralSupplierReward: _requiredNumber(map, 'referralSupplierReward'),
      reservationHours: _requiredInteger(map, 'reservationHours'),
      expiryCompensationRate: _requiredNumber(map, 'expiryCompensationRate'),
      currency: _optionalString(map['currency']) ?? '',
    );
  }
}

class AdminAuditLog {
  const AdminAuditLog({
    required this.id,
    required this.action,
    required this.entityType,
    this.entityId,
    this.actorUser,
    this.actorAgent,
    this.actorUserId,
    this.actorAgentId,
    this.createdAt,
    this.metadata = const {},
  });

  final int id;
  final String action;
  final String entityType;
  final int? entityId;
  final String? actorUser;
  final String? actorAgent;
  final int? actorUserId;
  final int? actorAgentId;
  final DateTime? createdAt;
  final Map<String, Object?> metadata;

  String get actorLabel => actorAgent ?? actorUser ?? '—';

  factory AdminAuditLog.fromJson(Object? json) {
    final map = _object(json, 'audit log');
    final user = _optionalObject(map['actorUser']);
    final agent = _optionalObject(map['actorAgent']);
    final metadata = _optionalObject(map['metadata']);
    final userName = user == null ? null : _personName(user);
    final agentName = agent == null
        ? null
        : _optionalString(agent['displayName']);
    return AdminAuditLog(
      id: _integer(map['id']),
      action: _optionalString(map['action']) ?? '',
      entityType: _optionalString(map['entityType']) ?? '',
      entityId: _optionalInteger(map['entityId']),
      actorUser: userName,
      actorAgent: agentName,
      actorUserId: _optionalInteger(map['actorUserId']),
      actorAgentId: _optionalInteger(map['actorAgentId']),
      createdAt: _date(map['createdAt']),
      metadata: metadata == null
          ? const {}
          : Map<String, Object?>.unmodifiable(
              Map<String, Object?>.from(metadata),
            ),
    );
  }
}

class AdminAgency {
  const AdminAgency({required this.id, required this.name});

  final int id;
  final String name;

  factory AdminAgency.fromJson(Object? json) {
    final map = _object(json, 'agency');
    return AdminAgency(
      id: _integer(map['id']),
      name: _optionalString(map['name']) ?? '',
    );
  }
}

Map<Object?, Object?> _object(Object? value, String label) {
  if (value is Map) return value;
  throw FormatException('Expected $label object');
}

Map<Object?, Object?>? _optionalObject(Object? value) =>
    value is Map ? value : null;

String? _optionalString(Object? value) => value is String ? value : null;

String _requiredString(Map<Object?, Object?> map, String field) {
  final value = map[field];
  if (value is String) return value;
  throw FormatException('Expected $field string');
}

int _integer(Object? value) {
  if (value is int) return value;
  if (value is num && value == value.toInt()) return value.toInt();
  throw const FormatException('Expected integer');
}

int _requiredInteger(Map<Object?, Object?> map, String field) =>
    _integer(map[field]);

int? _optionalInteger(Object? value) => value is int
    ? value
    : value is num
    ? value.toInt()
    : null;

double _number(Object? value) => value is num ? value.toDouble() : 0;

double _requiredNumber(Map<Object?, Object?> map, String field) {
  final value = map[field];
  if (value is num) return value.toDouble();
  throw FormatException('Expected $field number');
}

Map<String, int> _countMap(Object? value) {
  if (value is! Map) return const {};
  return Map<String, int>.unmodifiable({
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: _integerOrZero(entry.value),
  });
}

int _integerOrZero(Object? value) =>
    value is num && value == value.toInt() ? value.toInt() : 0;

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

String _personName(Map<Object?, Object?> person) {
  final name = [
    _optionalString(person['firstname']),
    _optionalString(person['lastname']),
  ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
  return name.isEmpty ? (_optionalString(person['email']) ?? '—') : name;
}
