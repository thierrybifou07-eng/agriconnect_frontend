import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/storage/prefs_storage.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/chat/domain/chat_entities.dart';
import 'package:agri_connect/features/chat/presentation/controllers/conversations_controller.dart';

import '../auth/fake_auth_repository.dart';
import '../../support/fake_chat_repository.dart';
import '../../support/fake_realtime_transport.dart';
import '../../support/get_test_harness.dart';

void main() {
  setupGetTestHarness();

  test(
    'loads the newest message page first, then older pages; deduplicates ids',
    () async {
      final messageSets = {
        1: _messages(1, 50),
        2: _messages(51, 100),
        3: _messages(101, 125),
      };
      final repository = FakeChatRepository(
        conversation: _conversation(),
        messagesByPage: messageSets,
        totalMessages: 125,
      );
      final prefs = Get.put(PrefsStorage());
      final (socket, transport) = await _socket();
      final controller = Get.put(
        ThreadController(
          conversationId: 10,
          conversation: _conversation(),
          repository: repository,
          prefsStorage: prefs,
          socketService: socket,
        ),
      );

      await _until(() => controller.state.value is Success<List<ChatMessage>>);
      expect(repository.requestedMessagePages, [1, 3]);
      expect(
        (controller.state.value as Success<List<ChatMessage>>).data.first.id,
        101,
      );

      await controller.loadOlder();
      expect(repository.requestedMessagePages, [1, 3, 2]);
      transport.fire('message:new', {
        'conversationId': 10,
        'id': 125,
        'content': 'Message 125',
        'senderLabel': 'Équipe AgriConnect',
        'createdAt': DateTime.utc(2026, 10, 26).toIso8601String(),
      });

      final messages =
          (controller.state.value as Success<List<ChatMessage>>).data;
      expect(messages.length, 75);
      expect(messages.map((message) => message.id).toSet().length, 75);
      expect(socket.isConversationOpen(10), isTrue);
    },
  );

  test('closed conversation prevents message submission', () async {
    final repository = FakeChatRepository(
      conversation: _conversation(status: ConversationStatus.closed),
      messagesByPage: const {},
      totalMessages: 0,
    );
    final prefs = Get.put(PrefsStorage());
    final (socket, _) = await _socket();
    final controller = Get.put(
      ThreadController(
        conversationId: 10,
        conversation: _conversation(status: ConversationStatus.closed),
        repository: repository,
        prefsStorage: prefs,
        socketService: socket,
      ),
    );

    expect(controller.isConversationClosed, isTrue);
    expect(await controller.send('Should not be sent'), isFalse);
    expect(repository.sentContents, isEmpty);
  });
}

Future<(SocketService, FakeTransport)> _socket() async {
  final storage = InMemoryTokenStorage();
  await storage.save(access: 'test-access', refresh: 'test-refresh');
  final events = SessionEvents();
  final auth = Get.put(
    AuthController(
      tokenStorage: storage,
      sessionEvents: events,
      repository: FakeAuthRepository(),
    ),
  );
  final transport = FakeTransport();
  final socket = Get.put(
    SocketService(
      authController: auth,
      apiClient: ApiClient(tokenStorage: storage, sessionEvents: events),
      tokenStorage: storage,
      transport: transport,
    ),
  );
  auth.setUser(FakeAuthRepository().user);
  return (socket, transport);
}

Conversation _conversation({
  ConversationStatus status = ConversationStatus.open,
}) => Conversation(
  id: 10,
  type: ConversationType.buyerSupport,
  status: status,
  lastMessageAt: DateTime.utc(2026, 10, 26, 10),
  createdAt: DateTime.utc(2026, 10, 26, 9),
);

List<ChatMessage> _messages(int start, int end) => [
  for (var id = start; id <= end; id++)
    ChatMessage(
      id: id,
      content: 'Message $id',
      senderLabel: 'Équipe AgriConnect',
      createdAt: DateTime.utc(2026, 10, 26).add(Duration(minutes: id)),
    ),
];

Future<void> _until(bool Function() condition) async {
  for (var attempt = 0; attempt < 20 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  expect(condition(), isTrue);
}
