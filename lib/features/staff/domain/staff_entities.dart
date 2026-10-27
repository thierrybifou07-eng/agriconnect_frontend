import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';

enum StaffConversationStatus { open, waitingCustomer, closed }

class StaffConversation {
  const StaffConversation({
    required this.id,
    required this.type,
    required this.status,
    required this.lastMessageAt,
    required this.createdAt,
    required this.customer,
    this.subject,
    this.listingId,
    this.lotId,
    this.assignedAgentId,
    this.assignedAgentName,
    this.escalatedAt,
    this.escalationReason,
  });

  final int id;
  final String type;
  final StaffConversationStatus status;
  final String? subject;
  final int? listingId;
  final int? lotId;
  final Map<String, Object?> customer;
  final int? assignedAgentId;
  final String? assignedAgentName;
  final DateTime? escalatedAt;
  final String? escalationReason;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  bool get isEscalated => escalatedAt != null;

  factory StaffConversation.fromJson(Object? json) {
    final map = _map(json, 'conversation');
    final customer = _map(map['customer'], 'customer');
    final assigned = map['assignedAgent'] == null
        ? null
        : _map(map['assignedAgent'], 'assignedAgent');
    return StaffConversation(
      id: _int(map['id'], 'id'),
      type: _text(map['type'], 'type'),
      status: switch (map['status']) {
        'OPEN' => StaffConversationStatus.open,
        'WAITING_CUSTOMER' => StaffConversationStatus.waitingCustomer,
        'CLOSED' => StaffConversationStatus.closed,
        _ => throw FormatException(
          'Unknown conversation status: ${map['status']}',
        ),
      },
      subject: _optionalText(map['subject']),
      listingId: _optionalInt(map['listingId']),
      lotId: _optionalInt(map['lotId']),
      customer: Map.unmodifiable(customer),
      assignedAgentId: _optionalInt(map['assignedAgentId']),
      assignedAgentName: _optionalText(assigned?['displayName']),
      escalatedAt: _optionalDate(map['escalatedAt']),
      escalationReason: _optionalText(map['escalationReason']),
      lastMessageAt: _date(map['lastMessageAt'], 'lastMessageAt'),
      createdAt: _date(map['createdAt'], 'createdAt'),
    );
  }
}

class StaffMessage {
  const StaffMessage({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.content,
    required this.isInternal,
    required this.createdAt,
    this.senderUserId,
    this.senderAgentId,
  });

  final int id;
  final int conversationId;
  final String senderType;
  final int? senderUserId;
  final int? senderAgentId;
  final String content;
  final bool isInternal;
  final DateTime createdAt;

  factory StaffMessage.fromJson(Object? json) {
    final map = _map(json, 'message');
    return StaffMessage(
      id: _int(map['id'], 'id'),
      conversationId: _int(map['conversationId'], 'conversationId'),
      senderType: _text(map['senderType'], 'senderType'),
      senderUserId: _optionalInt(map['senderUserId']),
      senderAgentId: _optionalInt(map['senderAgentId']),
      content: _text(map['content'], 'content'),
      isInternal: map['isInternal'] == true,
      createdAt: _date(map['createdAt'], 'createdAt'),
    );
  }
}

class StaffLot {
  const StaffLot({
    required this.lot,
    required this.supplier,
    this.qualityGrade,
    this.validatedAt,
  });

  final SupplierLot lot;
  final Map<String, Object?> supplier;
  final String? qualityGrade;
  final DateTime? validatedAt;

  factory StaffLot.fromJson(Object? json) {
    final map = _map(json, 'staff lot');
    final supplier = _map(map['supplier'], 'supplier');
    return StaffLot(
      lot: SupplierLot.fromJson(json),
      supplier: Map.unmodifiable(supplier),
      qualityGrade: _optionalText(map['qualityGrade']),
      validatedAt: _optionalDate(map['validatedAt']),
    );
  }
}

class StaffListing {
  const StaffListing({
    required this.id,
    required this.reference,
    required this.title,
    required this.unitPrice,
    required this.status,
    required this.product,
    required this.zone,
    required this.images,
    this.description,
    this.publishedAt,
    this.lot,
  });

  final int id;
  final String reference;
  final String title;
  final String? description;
  final double unitPrice;
  final String status;
  final Map<String, Object?> product;
  final Map<String, Object?> zone;
  final List<Map<String, Object?>> images;
  final DateTime? publishedAt;
  final StaffLot? lot;

  factory StaffListing.fromJson(Object? json) {
    final map = _map(json, 'listing');
    final images = map['images'];
    if (images is! List) throw const FormatException('Expected listing.images');
    return StaffListing(
      id: _int(map['id'], 'id'),
      reference: _text(map['reference'], 'reference'),
      title: _text(map['title'], 'title'),
      description: _optionalText(map['description']),
      unitPrice: _number(map['unitPrice'], 'unitPrice'),
      status: _text(map['status'], 'status'),
      product: Map.unmodifiable(_map(map['product'], 'product')),
      zone: Map.unmodifiable(_map(map['zone'], 'zone')),
      images: List.unmodifiable(
        images.map(
          (image) => Map<String, Object?>.unmodifiable(_map(image, 'image')),
        ),
      ),
      publishedAt: _optionalDate(map['publishedAt']),
      lot: map['lot'] == null ? null : StaffLot.fromJson(map['lot']),
    );
  }
}

Map<Object?, Object?> _map(Object? value, String name) {
  if (value is Map) return value;
  throw FormatException('Expected $name object');
}

String _text(Object? value, String name) {
  if (value is String) return value;
  throw FormatException('Expected $name string');
}

String? _optionalText(Object? value) => value is String ? value : null;

int _int(Object? value, String name) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Expected $name integer');
}

int? _optionalInt(Object? value) => value is num ? value.toInt() : null;

double _number(Object? value, String name) {
  if (value is num) return value.toDouble();
  throw FormatException('Expected $name number');
}

DateTime _date(Object? value, String name) {
  if (value is String) {
    final date = DateTime.tryParse(value);
    if (date != null) return date.toUtc();
  }
  throw FormatException('Expected $name date');
}

DateTime? _optionalDate(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toUtc() : null;
