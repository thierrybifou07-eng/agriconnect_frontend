import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/chat/domain/chat_entities.dart';
import 'package:agri_connect/features/chat/domain/chat_repository.dart';

class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    required this.conversation,
    required this.messagesByPage,
    required this.totalMessages,
  });

  final Conversation conversation;
  final Map<int, List<ChatMessage>> messagesByPage;
  final int totalMessages;
  final List<int> requestedMessagePages = [];
  final List<String> sentContents = [];

  @override
  Future<Paginated<Conversation>> conversations(int page, int limit) async =>
      Paginated<Conversation>(
        items: [conversation],
        page: page,
        limit: limit,
        total: 1,
      );

  @override
  Future<Paginated<ChatMessage>> messages(
    int conversationId,
    int page,
    int limit,
  ) async {
    requestedMessagePages.add(page);
    return Paginated<ChatMessage>(
      items: messagesByPage[page] ?? const [],
      page: page,
      limit: limit,
      total: totalMessages,
    );
  }

  @override
  Future<Conversation> openConversation({
    int? listingId,
    int? lotId,
    required String content,
  }) async => conversation;

  @override
  Future<ChatMessage> sendMessage(int conversationId, String content) async {
    sentContents.add(content);
    return ChatMessage(
      id: 999,
      content: content,
      senderLabel: 'Vous',
      createdAt: DateTime.utc(2026, 10, 26, 12),
    );
  }
}
