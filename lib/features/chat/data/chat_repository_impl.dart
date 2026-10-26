import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/chat/data/chat_api.dart';
import 'package:agri_connect/features/chat/domain/chat_entities.dart';
import 'package:agri_connect/features/chat/domain/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._api);

  final ChatApi _api;

  @override
  Future<Paginated<Conversation>> conversations(int page, int limit) =>
      _parse(() => _api.conversations(page, limit));

  @override
  Future<Paginated<ChatMessage>> messages(
    int conversationId,
    int page,
    int limit,
  ) => _parse(() => _api.messages(conversationId, page, limit));

  @override
  Future<Conversation> openConversation({
    int? listingId,
    int? lotId,
    required String content,
  }) => _parse(
    () => _api.openConversation(
      listingId: listingId,
      lotId: lotId,
      content: content,
    ),
  );

  @override
  Future<ChatMessage> sendMessage(int conversationId, String content) =>
      _parse(() => _api.sendMessage(conversationId, content));

  Future<T> _parse<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FormatException catch (error) {
      throw ApiFailure(
        status: null,
        code: null,
        message: error.message,
        fieldErrors: const {},
        kind: ApiFailureKind.server,
      );
    }
  }
}
