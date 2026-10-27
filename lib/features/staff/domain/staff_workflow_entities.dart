import 'package:agri_connect/shared/domain/order_status.dart';

class StaffOrder {
  const StaffOrder({
    required this.id,
    required this.status,
    required this.items,
    required this.buyer,
    required this.total,
    this.origins = const [],
    this.reference,
    this.deliveryMode,
    this.subtotal,
    this.buyerFee,
    this.deliveryFee,
    this.commissionTotal,
    this.paymentStatus,
    this.conversationId,
    this.handledByAgentId,
    this.reservedUntil,
    this.deliveryStatus,
    this.deliveryAvailable,
  });

  final int id;
  final String? reference;
  final OrderStatus status;
  final String? deliveryMode;
  final List<StaffOrderItem> items;
  final Map<String, Object?> buyer;
  final double total;
  final List<Map<String, Object?>> origins;
  final double? subtotal;
  final double? buyerFee;
  final double? deliveryFee;
  final double? commissionTotal;
  final String? paymentStatus;
  final int? conversationId;
  final int? handledByAgentId;
  final DateTime? reservedUntil;
  final String? deliveryStatus;
  final bool? deliveryAvailable;

  factory StaffOrder.fromJson(Object? json) {
    final map = _object(json, 'staff order');
    final rawItems = map['items'];
    if (rawItems is! List) {
      throw const FormatException('Expected order.items list');
    }
    final rawOrigins = map['origins'];
    if (rawOrigins != null && rawOrigins is! List) {
      throw const FormatException('Expected order.origins list');
    }
    return StaffOrder(
      id: _integer(map['id'], 'id'),
      reference: _optionalString(map['reference'] ?? map['orderNumber']),
      status: OrderStatus.fromApi(map['status']),
      deliveryMode: _optionalString(map['deliveryMode']),
      items: List.unmodifiable(rawItems.map(StaffOrderItem.fromJson)),
      buyer: Map.unmodifiable(_object(map['buyer'], 'buyer')),
      total: _number(map['total'] ?? map['totalPrice'], 'total'),
      origins: List.unmodifiable(
        (rawOrigins as List? ?? const []).map(
          (origin) => Map<String, Object?>.unmodifiable(
            _object(origin, 'order origin'),
          ),
        ),
      ),
      subtotal: _optionalNumber(map['subtotal']),
      buyerFee: _optionalNumber(map['buyerFee']),
      deliveryFee: _optionalNumber(map['deliveryFee']),
      commissionTotal: _optionalNumber(map['commissionTotal']),
      paymentStatus: _optionalString(map['paymentStatus']),
      conversationId: _optionalInteger(map['conversationId']),
      handledByAgentId: _optionalInteger(map['handledByAgentId']),
      reservedUntil: _optionalDate(map['reservedUntil']),
      deliveryStatus: _optionalString(map['deliveryStatus']),
      deliveryAvailable: map['deliveryAvailable'] is bool
          ? map['deliveryAvailable'] as bool
          : null,
    );
  }
}

class StaffOrderItem {
  const StaffOrderItem({
    required this.id,
    required this.listingId,
    required this.lotId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.listingReference,
    this.listingTitle,
    this.supplierUnitPrice,
    this.commissionRate,
    this.commissionAmount,
    this.supplierNetAmount,
  });

  final int id;
  final int listingId;
  final int lotId;
  final double quantity;
  final double unitPrice;
  final double lineTotal;
  final String? listingReference;
  final String? listingTitle;
  final double? supplierUnitPrice;
  final double? commissionRate;
  final double? commissionAmount;
  final double? supplierNetAmount;

  factory StaffOrderItem.fromJson(Object? json) {
    final map = _object(json, 'order item');
    final quantity = _number(map['quantity'], 'quantity');
    final unitPrice = _number(map['unitPrice'], 'unitPrice');
    return StaffOrderItem(
      id: _integer(map['id'], 'id'),
      listingId: _integer(map['listingId'], 'listingId'),
      lotId: _integer(map['lotId'], 'lotId'),
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: _optionalNumber(map['lineTotal']) ?? quantity * unitPrice,
      listingReference: _optionalString(map['listingReference']),
      listingTitle: _optionalString(map['listingTitle']),
      supplierUnitPrice: _optionalNumber(map['supplierUnitPrice']),
      commissionRate: _optionalNumber(map['commissionRate']),
      commissionAmount: _optionalNumber(map['commissionAmount']),
      supplierNetAmount: _optionalNumber(map['supplierNetAmount']),
    );
  }
}

class StaffPayment {
  const StaffPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    this.reference,
    this.paidAt,
  });

  final int id;
  final double amount;
  final String method;
  final String status;
  final String? reference;
  final DateTime? paidAt;

  factory StaffPayment.fromJson(Object? json) {
    final map = _object(json, 'payment');
    return StaffPayment(
      id: _integer(map['id'], 'id'),
      amount: _number(map['amount'], 'amount'),
      method: _string(map['method'], 'method'),
      status: _string(map['status'], 'status'),
      reference: _optionalString(map['reference']),
      paidAt: _optionalDate(map['paidAt']),
    );
  }
}

class StaffDelivery {
  const StaffDelivery({
    required this.id,
    required this.orderId,
    required this.status,
    this.agencyId,
    this.agencyName,
    this.agencyCost,
    this.deliveryFee,
    this.insuredValue,
    this.insurancePolicyNumber,
    this.pickupAddress,
    this.dropoffAddress,
  });

  final int id;
  final int orderId;
  final String status;
  final int? agencyId;
  final String? agencyName;
  final double? agencyCost;
  final double? deliveryFee;
  final double? insuredValue;
  final String? insurancePolicyNumber;
  final String? pickupAddress;
  final String? dropoffAddress;

  factory StaffDelivery.fromJson(Object? json) {
    final map = _object(json, 'staff delivery');
    return StaffDelivery(
      id: _integer(map['id'], 'id'),
      orderId: _integer(map['orderId'], 'orderId'),
      status: _string(map['status'], 'status'),
      agencyId: _optionalInteger(map['agencyId']),
      agencyName: _optionalString(map['agencyName']),
      agencyCost: _optionalNumber(map['agencyCost']),
      deliveryFee: _optionalNumber(map['deliveryFee']),
      insuredValue: _optionalNumber(map['insuredValue']),
      insurancePolicyNumber: _optionalString(map['insurancePolicyNumber']),
      pickupAddress: _optionalString(map['pickupAddress']),
      dropoffAddress: _optionalString(map['dropoffAddress']),
    );
  }
}

class StaffVerification {
  const StaffVerification({
    required this.id,
    required this.type,
    required this.status,
    required this.user,
    required this.media,
    this.note,
    this.createdAt,
  });

  final int id;
  final String type;
  final String status;
  final Map<String, Object?> user;
  final Map<String, Object?> media;
  final String? note;
  final DateTime? createdAt;

  factory StaffVerification.fromJson(Object? json) {
    final map = _object(json, 'verification');
    return StaffVerification(
      id: _integer(map['id'], 'id'),
      type: _string(map['type'], 'type'),
      status: _string(map['status'], 'status'),
      user: Map.unmodifiable(_object(map['user'], 'user')),
      media: Map.unmodifiable(_object(map['media'], 'media')),
      note: _optionalString(map['note']),
      createdAt: _optionalDate(map['createdAt']),
    );
  }

  String get mimeType => _optionalString(media['mimeType']) ?? '';
  int? get fileSize => _optionalInteger(media['fileSize']);
}

class StaffVerificationDetail extends StaffVerification {
  const StaffVerificationDetail({
    required super.id,
    required super.type,
    required super.status,
    required super.user,
    required super.media,
    required this.signedUrl,
    super.note,
    super.createdAt,
  });

  final String? signedUrl;

  factory StaffVerificationDetail.fromJson(Object? json) {
    final map = _object(json, 'verification detail');
    return StaffVerificationDetail(
      id: _integer(map['id'], 'id'),
      type: _string(map['type'], 'type'),
      status: _string(map['status'], 'status'),
      user: Map.unmodifiable(
        map['user'] is Map
            ? Map<String, Object?>.from(_object(map['user'], 'user'))
            : <String, Object?>{},
      ),
      media: Map.unmodifiable(
        map['media'] is Map
            ? Map<String, Object?>.from(_object(map['media'], 'media'))
            : <String, Object?>{},
      ),
      note: _optionalString(map['note']),
      createdAt: _optionalDate(map['createdAt']),
      signedUrl: _optionalString(map['signedUrl']),
    );
  }
}

Map<Object?, Object?> _object(Object? value, String name) {
  if (value is Map) return value;
  throw FormatException('Expected $name object');
}

String _string(Object? value, String name) {
  if (value is String) return value;
  throw FormatException('Expected $name string');
}

String? _optionalString(Object? value) => value is String ? value : null;

int _integer(Object? value, String name) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Expected $name integer');
}

int? _optionalInteger(Object? value) => value is num ? value.toInt() : null;

double _number(Object? value, String name) {
  if (value is num) return value.toDouble();
  throw FormatException('Expected $name number');
}

double? _optionalNumber(Object? value) =>
    value is num ? value.toDouble() : null;

DateTime? _optionalDate(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toUtc() : null;
