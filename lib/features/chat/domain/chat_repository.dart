import 'package:agri_connect/features/chat/domain/chat_conversation.dart';
import 'package:agri_connect/features/chat/domain/chat_message.dart';

/// Storage contract for the chat workspace.
abstract interface class ChatRepository {
  /// Inbox of the signed-in user, most recent conversation first.
  Future<List<ChatConversation>> fetchConversations();

  /// Full message history of [conversationId], oldest first.
  Future<List<ChatMessage>> fetchMessages(String conversationId);

  /// Appends [text] to [conversationId] and returns the created message.
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
  });
}
