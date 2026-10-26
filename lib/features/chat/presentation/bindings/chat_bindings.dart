import 'package:get/get.dart';

import 'package:agri_connect/core/storage/prefs_storage.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/features/chat/domain/chat_entities.dart';
import 'package:agri_connect/features/chat/domain/chat_repository.dart';
import 'package:agri_connect/features/chat/presentation/controllers/conversations_controller.dart';
import 'package:agri_connect/app/routes/app_routes.dart';

class ConversationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationsController>(
      () => ConversationsController(
        repository: Get.find<ChatRepository>(),
        prefsStorage: Get.find<PrefsStorage>(),
        socketService: Get.find<SocketService>(),
        authController: Get.find(),
      ),
    );
  }
}

class ThreadBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConversationsController>()) {
      ConversationsBinding().dependencies();
    }
    final arguments = Get.arguments;
    final values = arguments is Map ? arguments : const <Object?, Object?>{};
    final rawId = values['conversationId'];
    if (rawId is! int) {
      throw ArgumentError('Chat thread requires a conversationId');
    }
    final conversation = values['conversation'];
    Get.lazyPut<ThreadController>(
      () => ThreadController(
        conversationId: rawId,
        conversation: conversation is Conversation ? conversation : null,
        repository: Get.find<ChatRepository>(),
        prefsStorage: Get.find<PrefsStorage>(),
        socketService: Get.find<SocketService>(),
        onSeen: Get.find<ConversationsController>().markSeenById,
      ),
    );
  }
}

class ChatStartRequest {
  const ChatStartRequest({this.listingId, this.lotId, this.prefill});

  final int? listingId;
  final int? lotId;
  final String? prefill;
}

abstract final class ChatLauncher {
  static Future<void> openForListing(int listingId, {String? prefill}) =>
      _open(ChatStartRequest(listingId: listingId, prefill: prefill));

  static Future<void> openForLot(int lotId, {String? prefill}) =>
      _open(ChatStartRequest(lotId: lotId, prefill: prefill));

  static Future<void> openSupport({String? prefill}) =>
      _open(ChatStartRequest(prefill: prefill));

  static Future<void> _open(ChatStartRequest request) async {
    if (request.prefill?.trim().isNotEmpty == true) {
      final conversation = await Get.find<ChatRepository>().openConversation(
        listingId: request.listingId,
        lotId: request.lotId,
        content: request.prefill!,
      );
      await Get.toNamed(
        AppRoutes.chatThread,
        arguments: {
          'conversationId': conversation.id,
          'conversation': conversation,
        },
      );
      return;
    }
    await Get.toNamed(AppRoutes.conversations, arguments: request);
  }
}
