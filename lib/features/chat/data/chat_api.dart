import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/chat/data/dto/chat_dto.dart';
import 'package:agri_connect/features/chat/domain/chat_entities.dart';

class ChatApi {
  const ChatApi(this._client);

  final ApiClient _client;

  Future<Paginated<Conversation>> conversations(int page, int limit) async =>
      Paginated<Conversation>.fromJson(
        await _client.get(
          'conversations',
          query: {'page': page, 'limit': limit},
        ),
        ChatDto.conversation,
      );

  Future<Paginated<ChatMessage>> messages(
    int conversationId,
    int page,
    int limit,
  ) async => Paginated<ChatMessage>.fromJson(
    await _client.get(
      'conversations/$conversationId/messages',
      query: {'page': page, 'limit': limit},
    ),
    ChatDto.message,
  );

  Future<Conversation> openConversation({
    int? listingId,
    int? lotId,
    required String content,
  }) async {
    if (listingId != null && lotId != null) {
      throw const ApiFailure(
        status: 400,
        code: null,
        message: 'Specify listingId or lotId, never both',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
    }
    if (content.trim().isEmpty || content.length > 5000) {
      throw const ApiFailure(
        status: 400,
        code: null,
        message: 'Content must contain between 1 and 5000 characters',
        fieldErrors: {'content': 'Invalid content length'},
        kind: ApiFailureKind.client,
      );
    }
    final data = <String, Object?>{'content': content.trim()};
    if (listingId != null) data['listingId'] = listingId;
    if (lotId != null) data['lotId'] = lotId;
    return ChatDto.conversation(
      await _client.post('conversations', data: data),
    );
  }

  Future<ChatMessage> sendMessage(int conversationId, String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || trimmed.length > 5000) {
      throw const ApiFailure(
        status: 400,
        code: null,
        message: 'Content must contain between 1 and 5000 characters',
        fieldErrors: {'content': 'Invalid content length'},
        kind: ApiFailureKind.client,
      );
    }
    return ChatDto.message(
      await _client.post(
        'conversations/$conversationId/messages',
        data: {'content': trimmed},
      ),
    );
  }
}
