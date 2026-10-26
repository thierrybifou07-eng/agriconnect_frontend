import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/chat/domain/chat_entities.dart';

abstract interface class ChatRepository {
  Future<Paginated<Conversation>> conversations(int page, int limit);
  Future<Paginated<ChatMessage>> messages(
    int conversationId,
    int page,
    int limit,
  );
  Future<Conversation> openConversation({
    int? listingId,
    int? lotId,
    required String content,
  });
  Future<ChatMessage> sendMessage(int conversationId, String content);
}
