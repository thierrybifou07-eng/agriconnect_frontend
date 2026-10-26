import 'package:agri_connect/features/chat/domain/chat_entities.dart';

abstract final class ChatDto {
  static Conversation conversation(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Expected conversation object');
    }
    final json = Map<String, dynamic>.from(value);
    return Conversation(
      id: _integer(json['id'], 'id'),
      type: switch (json['type']) {
        'BUYER_SUPPORT' => ConversationType.buyerSupport,
        'SUPPLIER_SUPPORT' => ConversationType.supplierSupport,
        _ => throw const FormatException('Unknown conversation type'),
      },
      status: switch (json['status']) {
        'OPEN' => ConversationStatus.open,
        'WAITING_CUSTOMER' => ConversationStatus.waitingCustomer,
        'CLOSED' => ConversationStatus.closed,
        _ => throw const FormatException('Unknown conversation status'),
      },
      subject: json['subject'] as String?,
      listingId: json['listingId'] == null
          ? null
          : _integer(json['listingId'], 'listingId'),
      escalatedAt: _dateOrNull(json['escalatedAt'], 'escalatedAt'),
      lastMessageAt: _date(json['lastMessageAt'], 'lastMessageAt'),
      createdAt: _date(json['createdAt'], 'createdAt'),
    );
  }

  static ChatMessage message(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Expected message object');
    }
    final json = Map<String, dynamic>.from(value);
    return ChatMessage(
      id: _integer(json['id'], 'id'),
      content: _string(json['content'], 'content'),
      senderLabel: _string(json['senderLabel'], 'senderLabel'),
      createdAt: _date(json['createdAt'], 'createdAt'),
    );
  }

  static int _integer(Object? value, String field) {
    if (value is int) return value;
    if (value is num && value == value.toInt()) return value.toInt();
    throw FormatException('Invalid $field');
  }

  static String _string(Object? value, String field) {
    if (value is String) return value;
    throw FormatException('Invalid $field');
  }

  static DateTime _date(Object? value, String field) {
    if (value is String) {
      final date = DateTime.tryParse(value);
      if (date != null) return date.toUtc();
    }
    throw FormatException('Invalid $field');
  }

  static DateTime? _dateOrNull(Object? value, String field) =>
      value == null ? null : _date(value, field);
}
