enum LotStatus {
  pendingValidation,
  available,
  fullyReserved,
  soldOut,
  expired,
  returned,
  rejected,
  withdrawn;

  static LotStatus parse(Object? value) => switch (value) {
    'PENDING_VALIDATION' => LotStatus.pendingValidation,
    'AVAILABLE' => LotStatus.available,
    'FULLY_RESERVED' => LotStatus.fullyReserved,
    'SOLD_OUT' => LotStatus.soldOut,
    'EXPIRED' => LotStatus.expired,
    'RETURNED' => LotStatus.returned,
    'REJECTED' => LotStatus.rejected,
    'WITHDRAWN' => LotStatus.withdrawn,
    _ => throw FormatException('Unknown lot status: $value'),
  };

  String get apiValue => switch (this) {
    LotStatus.pendingValidation => 'PENDING_VALIDATION',
    LotStatus.available => 'AVAILABLE',
    LotStatus.fullyReserved => 'FULLY_RESERVED',
    LotStatus.soldOut => 'SOLD_OUT',
    LotStatus.expired => 'EXPIRED',
    LotStatus.returned => 'RETURNED',
    LotStatus.rejected => 'REJECTED',
    LotStatus.withdrawn => 'WITHDRAWN',
  };
}

extension SupplierLotActions on SupplierLot {
  bool get canEdit => status == LotStatus.pendingValidation;

  bool get canDelete =>
      status == LotStatus.pendingValidation || status == LotStatus.rejected;

  bool get canWithdraw =>
      status == LotStatus.available && quantityReserved == 0;
}

class SupplierLotImage {
  const SupplierLotImage({
    required this.url,
    required this.position,
    required this.isPrimary,
  });

  final String url;
  final int position;
  final bool isPrimary;

  factory SupplierLotImage.fromJson(Object? json) {
    final map = _map(json, 'image');
    return SupplierLotImage(
      url: _string(map['url'], 'image.url'),
      position: _integer(map['position'], 'image.position'),
      isPrimary: map['isPrimary'] == true,
    );
  }
}

class SupplierLot {
  const SupplierLot({
    required this.id,
    required this.lotCode,
    required this.product,
    required this.zone,
    required this.storageType,
    required this.agreedUnitPrice,
    required this.quantityInitial,
    required this.quantityAvailable,
    required this.quantityReserved,
    required this.quantitySold,
    required this.quantityLost,
    required this.status,
    required this.images,
    this.hub,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.rejectionReason,
    this.packagingNote,
    this.qualityNote,
    this.harvestedAt,
    this.expiresAt,
  });

  final int id;
  final String lotCode;
  final SupplierLotProduct product;
  final SupplierLotZone zone;
  final String storageType;
  final SupplierLotHub? hub;
  final String? pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double agreedUnitPrice;
  final double quantityInitial;
  final double quantityAvailable;
  final double quantityReserved;
  final double quantitySold;
  final double quantityLost;
  final LotStatus status;
  final String? rejectionReason;
  final String? packagingNote;
  final String? qualityNote;
  final List<SupplierLotImage> images;
  final DateTime? harvestedAt;
  final DateTime? expiresAt;

  factory SupplierLot.fromJson(Object? json) {
    final map = _map(json, 'lot');
    final rawImages = map['images'];
    if (rawImages is! List) {
      throw const FormatException('Expected lot.images list');
    }
    return SupplierLot(
      id: _integer(map['id'], 'id'),
      lotCode: _string(map['lotCode'], 'lotCode'),
      product: SupplierLotProduct.fromJson(map['product']),
      zone: SupplierLotZone.fromJson(map['zone']),
      storageType: _string(map['storageType'], 'storageType'),
      hub: map['hub'] == null ? null : SupplierLotHub.fromJson(map['hub']),
      pickupAddress: _optionalString(map['pickupAddress']),
      pickupLatitude: _optionalDouble(map['pickupLatitude']),
      pickupLongitude: _optionalDouble(map['pickupLongitude']),
      agreedUnitPrice: _number(map['agreedUnitPrice'], 'agreedUnitPrice'),
      quantityInitial: _number(map['quantityInitial'], 'quantityInitial'),
      quantityAvailable: _number(map['quantityAvailable'], 'quantityAvailable'),
      quantityReserved: _number(map['quantityReserved'], 'quantityReserved'),
      quantitySold: _number(map['quantitySold'], 'quantitySold'),
      quantityLost: _number(map['quantityLost'], 'quantityLost'),
      status: LotStatus.parse(map['status']),
      rejectionReason: _optionalString(map['rejectionReason']),
      packagingNote: _optionalString(map['packagingNote']),
      qualityNote: _optionalString(map['qualityNote']),
      images: List.unmodifiable(rawImages.map(SupplierLotImage.fromJson)),
      harvestedAt: _optionalDate(map['harvestedAt']),
      expiresAt: _optionalDate(map['expiresAt']),
    );
  }
}

class SupplierLotProduct {
  const SupplierLotProduct({
    required this.id,
    required this.name,
    required this.isPerishable,
    required this.category,
    required this.unit,
  });

  final int id;
  final String name;
  final bool isPerishable;
  final SupplierLotLabel category;
  final SupplierLotLabel unit;

  factory SupplierLotProduct.fromJson(Object? json) {
    final map = _map(json, 'product');
    return SupplierLotProduct(
      id: _integer(map['id'], 'product.id'),
      name: _string(map['name'], 'product.name'),
      isPerishable: map['isPerishable'] == true,
      category: SupplierLotLabel.fromJson(map['category']),
      unit: SupplierLotLabel.fromJson(map['unit']),
    );
  }
}

class SupplierLotLabel {
  const SupplierLotLabel({required this.code, required this.label});

  final String code;
  final String label;

  factory SupplierLotLabel.fromJson(Object? json) {
    final map = _map(json, 'label');
    return SupplierLotLabel(
      code: _string(map['code'], 'code'),
      label: _string(map['label'], 'label'),
    );
  }
}

class SupplierLotZone {
  const SupplierLotZone({required this.id, required this.name});

  final int id;
  final String name;

  factory SupplierLotZone.fromJson(Object? json) {
    final map = _map(json, 'zone');
    return SupplierLotZone(
      id: _integer(map['id'], 'zone.id'),
      name: _string(map['name'], 'zone.name'),
    );
  }
}

class SupplierLotHub {
  const SupplierLotHub({required this.id, required this.name, this.city});

  final int id;
  final String name;
  final String? city;

  factory SupplierLotHub.fromJson(Object? json) {
    final map = _map(json, 'hub');
    return SupplierLotHub(
      id: _integer(map['id'], 'hub.id'),
      name: _string(map['name'], 'hub.name'),
      city: _optionalString(map['city']),
    );
  }
}

class SupplierPayout {
  const SupplierPayout({
    required this.id,
    required this.grossAmount,
    required this.commissionAmount,
    required this.netAmount,
    required this.status,
    this.reference,
    this.paidAt,
  });

  final int id;
  final double grossAmount;
  final double commissionAmount;
  final double netAmount;
  final String status;
  final String? reference;
  final DateTime? paidAt;

  factory SupplierPayout.fromJson(Object? json) {
    final map = _map(json, 'payout');
    return SupplierPayout(
      id: _integer(map['id'], 'id'),
      grossAmount: _number(map['grossAmount'], 'grossAmount'),
      commissionAmount: _number(map['commissionAmount'], 'commissionAmount'),
      netAmount: _number(map['netAmount'], 'netAmount'),
      status: _string(map['status'], 'status'),
      reference: _optionalString(map['reference']),
      paidAt: _optionalDate(map['paidAt']),
    );
  }
}

class SupplierCompensation {
  const SupplierCompensation({
    required this.id,
    required this.reason,
    required this.quantity,
    required this.amount,
    required this.status,
    this.note,
  });

  final int id;
  final String reason;
  final double quantity;
  final double amount;
  final String status;
  final String? note;

  factory SupplierCompensation.fromJson(Object? json) {
    final map = _map(json, 'compensation');
    return SupplierCompensation(
      id: _integer(map['id'], 'id'),
      reason: _string(map['reason'], 'reason'),
      quantity: _number(map['quantity'], 'quantity'),
      amount: _number(map['amount'], 'amount'),
      status: _string(map['status'], 'status'),
      note: _optionalString(map['note']),
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

int _integer(Object? value, String field) {
  if (value is int) return value;
  if (value is num && value == value.toInt()) return value.toInt();
  throw FormatException('Expected $field integer');
}

double _number(Object? value, String field) {
  if (value is num) return value.toDouble();
  throw FormatException('Expected $field number');
}

double? _optionalDouble(Object? value) =>
    value is num ? value.toDouble() : null;

DateTime? _optionalDate(Object? value) {
  if (value == null) return null;
  if (value is String) return DateTime.parse(value);
  throw const FormatException('Expected nullable ISO date');
}
