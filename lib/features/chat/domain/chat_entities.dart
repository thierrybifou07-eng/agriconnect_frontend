class Conversation {
  const Conversation({
    required this.id,
    required this.type,
    required this.status,
    required this.lastMessageAt,
    required this.createdAt,
    this.subject,
    this.listingId,
    this.escalatedAt,
  });

  final int id;
  final ConversationType type;
  final ConversationStatus status;
  final String? subject;
  final int? listingId;
  final DateTime? escalatedAt;
  final DateTime lastMessageAt;
  final DateTime createdAt;

  Conversation copyWith({DateTime? lastMessageAt}) => Conversation(
    id: id,
    type: type,
    status: status,
    subject: subject,
    listingId: listingId,
    escalatedAt: escalatedAt,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    createdAt: createdAt,
  );
}

enum ConversationType { buyerSupport, supplierSupport }

enum ConversationStatus { open, waitingCustomer, closed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.senderLabel,
    required this.createdAt,
  });

  final int id;
  final String content;
  final String senderLabel;
  final DateTime createdAt;

  bool get isMine => senderLabel == 'Vous';
  bool get isAi => senderLabel.endsWith(' (IA)');
}
