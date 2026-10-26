// ignore_for_file: cancel_subscriptions

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/storage/prefs_storage.dart';
import 'package:agri_connect/core/ui/paginated_controller.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/chat/data/dto/chat_dto.dart';
import 'package:agri_connect/features/chat/domain/chat_entities.dart';
import 'package:agri_connect/features/chat/domain/chat_repository.dart';

class ConversationsController extends PaginatedController<Conversation> {
  ConversationsController({
    required this.repository,
    required this.prefsStorage,
    required this.socketService,
    required this.authController,
  }) : super(limit: 100);

  final ChatRepository repository;
  final PrefsStorage prefsStorage;
  final SocketService socketService;
  final AuthController authController;
  final RxInt unreadCount = 0.obs;
  final RxSet<int> unreadConversations = <int>{}.obs;
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  StreamSubscription<dynamic>? _userSubscription;

  @override
  void onInit() {
    super.onInit();
    _messageSubscription = socketService.messageNew.listen(_onMessage);
    _userSubscription = authController.user.listen((user) {
      if (user != null) unawaited(loadFirst());
    });
    if (authController.user.value != null) unawaited(loadFirst());
  }

  Future<Conversation> startConversation({
    int? listingId,
    int? lotId,
    required String content,
  }) async {
    final conversation = await repository.openConversation(
      listingId: listingId,
      lotId: lotId,
      content: content,
    );
    await loadFirst();
    return conversation;
  }

  @override
  Future<Paginated<Conversation>> fetch(int page, int limit) =>
      repository.conversations(page, limit);

  @override
  Future<void> loadFirst() async {
    await super.loadFirst();
    await _refreshUnread();
  }

  @override
  Future<void> loadMore() async {
    await super.loadMore();
    await _refreshUnread();
  }

  List<Conversation> get sortedConversations {
    final current = state.value;
    if (current is! Success<List<Conversation>>) return const [];
    return [...current.data]
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  }

  bool isUnread(int conversationId) =>
      unreadConversations.contains(conversationId);

  Future<void> markSeen(Conversation conversation) async {
    await markSeenById(conversation.id, conversation.lastMessageAt);
  }

  Future<void> markSeenById(int conversationId, DateTime lastMessageAt) async {
    await prefsStorage.saveLastSeenAt(conversationId, lastMessageAt);
    await _refreshUnread();
  }

  void _onMessage(Map<String, dynamic> payload) {
    final message = _nestedMessage(payload);
    final rawId = payload['conversationId'] ?? message['conversationId'];
    if (rawId is! int) return;
    final current = state.value;
    if (current is! Success<List<Conversation>>) return;
    final index = current.data.indexWhere((item) => item.id == rawId);
    if (index < 0) {
      unawaited(loadFirst());
      return;
    }
    final createdAt = DateTime.tryParse(
      message['createdAt'] is String ? message['createdAt'] as String : '',
    );
    final updated = [...current.data];
    if (createdAt != null) {
      updated[index] = updated[index].copyWith(
        lastMessageAt: createdAt.toUtc(),
      );
      state.value = Success(List.unmodifiable(updated));
    }
    unawaited(_refreshUnread());
  }

  Future<void> _refreshUnread() async {
    final current = state.value;
    if (current is! Success<List<Conversation>>) return;
    final unread = <int>{};
    for (final conversation in current.data) {
      final lastSeen = await prefsStorage.readLastSeenAt(conversation.id);
      if (lastSeen == null || conversation.lastMessageAt.isAfter(lastSeen)) {
        unread.add(conversation.id);
      }
    }
    unreadConversations.assignAll(unread);
    unreadCount.value = unread.length;
  }

  static Map<String, dynamic> _nestedMessage(Map<String, dynamic> payload) {
    final nested = payload['message'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return payload;
  }

  @override
  void onClose() {
    final messageSubscription = _messageSubscription;
    if (messageSubscription != null) unawaited(messageSubscription.cancel());
    final userSubscription = _userSubscription;
    if (userSubscription != null) unawaited(userSubscription.cancel());
    super.onClose();
  }
}

class ThreadController extends GetxController {
  ThreadController({
    required this.conversationId,
    required this.repository,
    required this.prefsStorage,
    required this.socketService,
    Conversation? conversation,
    this.onSeen,
  }) : currentConversation = Rxn<Conversation>(conversation),
       super();

  final int conversationId;
  final Rxn<Conversation> currentConversation;
  final ChatRepository repository;
  final PrefsStorage prefsStorage;
  final SocketService socketService;
  final Future<void> Function(int conversationId, DateTime seenAt)? onSeen;
  final Rx<UiState<List<ChatMessage>>> state = Rx<UiState<List<ChatMessage>>>(
    const Idle(),
  );
  final RxBool isSending = false.obs;
  final RxBool isLoadingOlder = false.obs;
  final RxBool hasOlder = false.obs;
  final Rxn<ApiFailure> sendFailure = Rxn<ApiFailure>();
  final TextEditingController composerController = TextEditingController();
  final int limit = 50;
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  int _olderPage = 0;
  bool _closed = false;

  bool get isConversationClosed =>
      _closed || currentConversation.value?.status == ConversationStatus.closed;

  Future<void> reload() => _initialize();

  @override
  void onInit() {
    super.onInit();
    _messageSubscription = socketService.messageNew.listen(_onMessage);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    state.value = const Loading();
    try {
      if (currentConversation.value == null) {
        final page = await repository.conversations(1, 100);
        for (final item in page.items) {
          if (item.id == conversationId) currentConversation.value = item;
        }
      }
      _closed = currentConversation.value?.status == ConversationStatus.closed;
      await socketService.joinConversation(conversationId);
      final first = await repository.messages(conversationId, 1, limit);
      final lastPage = first.total == 0 ? 0 : (first.total / limit).ceil();
      final latest = lastPage <= 1
          ? first
          : await repository.messages(conversationId, lastPage, limit);
      _olderPage = lastPage - 1;
      hasOlder.value = _olderPage >= 1;
      state.value = Success(_unique(latest.items));
      if (latest.items.isNotEmpty) {
        await _saveLastSeen(latest.items.last.createdAt);
      }
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }

  Future<void> loadOlder() async {
    if (isLoadingOlder.value || !hasOlder.value || _olderPage < 1) return;
    isLoadingOlder.value = true;
    try {
      final page = await repository.messages(conversationId, _olderPage, limit);
      final current = state.value;
      if (current is Success<List<ChatMessage>>) {
        state.value = Success(_unique([...page.items, ...current.data]));
      }
      _olderPage--;
      hasOlder.value = _olderPage >= 1;
    } on ApiFailure catch (failure) {
      sendFailure.value = failure;
    } finally {
      isLoadingOlder.value = false;
    }
  }

  Future<bool> send(String content) async {
    if (isSending.value || isConversationClosed || content.trim().isEmpty) {
      return false;
    }
    isSending.value = true;
    sendFailure.value = null;
    try {
      final message = await repository.sendMessage(conversationId, content);
      _append(message);
      await _saveLastSeen(message.createdAt);
      return true;
    } on ApiFailure catch (failure) {
      sendFailure.value = failure;
      return false;
    } finally {
      isSending.value = false;
    }
  }

  void _onMessage(Map<String, dynamic> payload) {
    final nested = payload['message'];
    final messageJson = nested is Map
        ? Map<String, dynamic>.from(nested)
        : payload;
    final id = payload['conversationId'] ?? messageJson['conversationId'];
    if (id != null && id != conversationId) return;
    try {
      final message = ChatDto.message(messageJson);
      _append(message);
      unawaited(_saveLastSeen(message.createdAt));
    } on FormatException catch (error) {
      sendFailure.value = ApiFailure(
        status: null,
        code: null,
        message: error.message,
        fieldErrors: const {},
        kind: ApiFailureKind.server,
      );
    }
  }

  void _append(ChatMessage message) {
    final current = state.value;
    if (current is! Success<List<ChatMessage>>) return;
    state.value = Success(_unique([...current.data, message]));
  }

  Future<void> _saveLastSeen(DateTime seenAt) async {
    await prefsStorage.saveLastSeenAt(conversationId, seenAt);
    await onSeen?.call(conversationId, seenAt);
  }

  static List<ChatMessage> _unique(List<ChatMessage> messages) {
    final byId = <int, ChatMessage>{};
    for (final message in messages) {
      byId[message.id] = message;
    }
    final result = byId.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.unmodifiable(result);
  }

  @override
  void onClose() {
    socketService.leaveConversation(conversationId);
    composerController.dispose();
    final subscription = _messageSubscription;
    if (subscription != null) unawaited(subscription.cancel());
    super.onClose();
  }
}
