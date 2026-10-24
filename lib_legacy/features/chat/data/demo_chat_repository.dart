import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/chat/domain/chat_conversation.dart';
import 'package:agri_connect/features/chat/domain/chat_message.dart';
import 'package:agri_connect/features/chat/domain/chat_participant.dart';
import 'package:agri_connect/features/chat/domain/chat_repository.dart';

/// In-memory chat repository for the demo.
///
/// The inbox is derived from the signed-in [AuthUser]: counterpart contacts
/// and message ownership (isMine) are computed from the running session so
/// the same repository serves the supplier, buyer and driver workspaces without
/// role-specific branches — it only needs to know who “me” is.
final class DemoChatRepository implements ChatRepository {
  DemoChatRepository({required AuthUser currentUser})
    : _me = ChatParticipant(
        id: currentUser.id,
        fullName: currentUser.fullName,
        role: currentUser.role,
      ) {
    _seed();
  }

  final ChatParticipant _me;
  final List<ChatConversation> _conversations = [];
  final Map<String, List<ChatMessage>> _messagesByConversation = {};
  int _nextMessageId = 1;

  void _seed() {
    final now = DateTime.now();
    final role = _me.role;
    switch (role) {
      case UserRole.supplier:
        _conversations.addAll([
          _conversation(
            id: 'chat_5001',
            counterpart: ChatParticipant(
              id: 'buyer_marie',
              fullName: 'Marie Koné',
              role: UserRole.buyer,
            ),
            lastMessage: 'Commande de 5 sacs de riz demain matin.',
            lastMessageAt: now.subtract(const Duration(hours: 3)),
            unreadByMe: true,
            unreadCount: 2,
          ),
          _conversation(
            id: 'chat_5002',
            counterpart: ChatParticipant(
              id: 'driver_ibrahim',
              fullName: 'Ibrahim Cissé',
              role: UserRole.driver,
            ),
            lastMessage: 'Je passe au hangar cet après-midi.',
            lastMessageAt: now.subtract(const Duration(hours: 8)),
          ),
        ]);
      case UserRole.buyer:
        _conversations.addAll([
          _conversation(
            id: 'chat_5003',
            counterpart: ChatParticipant(
              id: 'supplier_alassane',
              fullName: 'Alassane Traoré',
              role: UserRole.supplier,
            ),
            lastMessage: 'Les tomates sont disponibles cette semaine.',
            lastMessageAt: now.subtract(const Duration(hours: 2)),
            unreadByMe: true,
            unreadCount: 1,
          ),
        ]);
      case UserRole.driver:
        _conversations.addAll([
          _conversation(
            id: 'chat_5004',
            counterpart: ChatParticipant(
              id: 'supplier_alassane',
              fullName: 'Alassane Traoré',
              role: UserRole.supplier,
            ),
            lastMessage: 'Livraison confirmée pour demain 8h.',
            lastMessageAt: now.subtract(const Duration(hours: 5)),
            unreadByMe: true,
            unreadCount: 1,
          ),
        ]);
      default:
        break;
    }

    for (final conversation in _conversations) {
      final counterpart = conversation.participant;
      _messagesByConversation[conversation.id] = [
        ChatMessage(
          id: 'm_${conversation.id}_01',
          conversationId: conversation.id,
          sender: counterpart,
          text: conversation.lastMessage,
          sentAt: conversation.lastMessageAt,
          isMine: false,
        ),
      ];
    }
  }

  ChatConversation _conversation({
    required String id,
    required ChatParticipant counterpart,
    required String lastMessage,
    required DateTime lastMessageAt,
    bool unreadByMe = false,
    int unreadCount = 0,
  }) {
    return ChatConversation(
      id: id,
      participant: counterpart,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      unreadByMe: unreadByMe,
      unreadCount: unreadCount,
    );
  }

  @override
  Future<List<ChatConversation>> fetchConversations() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List<ChatConversation>.unmodifiable(_conversations);
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List<ChatMessage>.unmodifiable(
      _messagesByConversation[conversationId] ?? const [],
    );
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final message = ChatMessage(
      id: 'm_${conversationId}_${_nextMessageId++}',
      conversationId: conversationId,
      sender: _me,
      text: text,
      sentAt: DateTime.now(),
      isMine: true,
    );
    _messagesByConversation[conversationId] = [
      ...?_messagesByConversation[conversationId],
      message,
    ];
    final conversation = _conversations.firstWhere(
      (element) => element.id == conversationId,
    );
    final index = _conversations.indexOf(conversation);
    _conversations[index] = conversation.copyWith(
      lastMessage: text,
      lastMessageAt: message.sentAt,
    );
    return message;
  }
}
