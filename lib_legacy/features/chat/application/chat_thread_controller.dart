import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/chat/application/chat_providers.dart';
import 'package:agri_connect/features/chat/domain/chat_message.dart';

/// Immutable snapshot of one conversation thread.
class ChatThreadState {
  const ChatThreadState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.messages = const [],
    this.sendingIds = const {},
    this.actionFailure,
    this.failedMessageText,
  });

  final bool isLoading;
  final bool isRefreshing;

  /// Initial-load failure (retryable through [ChatThreadController.refresh]).
  final Failure? failure;

  final List<ChatMessage> messages;

  /// Message sentinel currently being submitted; guards the send button.
  final Set<String> sendingIds;

  /// Latest send failure, surfaced once (never retried automatically).
  final Failure? actionFailure;

  /// Draft text of the last failed send, offered for a manual retry.
  final String? failedMessageText;

  bool isSending(String messageId) => sendingIds.contains(messageId);

  /// Whether any submission is currently in flight; gates the composer.
  bool get isSendingAny => sendingIds.isNotEmpty;

  ChatThreadState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    List<ChatMessage>? messages,
    Set<String>? sendingIds,
    Failure? actionFailure,
    String? failedMessageText,
    bool clearFailure = false,
    bool clearActionFailure = false,
    bool clearFailedMessageText = false,
  }) {
    return ChatThreadState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      // The failures are values with a life of their own, so dropping one is
      // asked for explicitly: a copyWith that simply omitted it would keep a
      // send error on screen forever, long after the retry succeeded.
      failure: clearFailure ? null : (failure ?? this.failure),
      messages: messages ?? this.messages,
      sendingIds: sendingIds ?? this.sendingIds,
      actionFailure: clearActionFailure
          ? null
          : (actionFailure ?? this.actionFailure),
      failedMessageText: clearFailedMessageText
          ? null
          : (failedMessageText ?? this.failedMessageText),
    );
  }
}

final chatThreadControllerProvider =
    NotifierProvider.family<ChatThreadController, ChatThreadState, String>(
      ChatThreadController.new,
    );

/// Loads a single conversation thread and sends messages with a
/// single-submission gate: while a message is being sent, extra taps are
/// ignored, and a failed send is surfaced once with a manual retry.
class ChatThreadController extends Notifier<ChatThreadState> {
  ChatThreadController(this.conversationId);

  final String conversationId;

  @override
  ChatThreadState build() {
    Future<void>.microtask(_load);
    return const ChatThreadState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final messages = await ref
          .read(chatRepositoryProvider)
          .fetchMessages(conversationId);
      state = state.copyWith(isLoading: false, messages: messages);
    } on Failure catch (failure) {
      state = state.copyWith(isLoading: false, failure: failure);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        failure: const UnexpectedFailure(),
      );
    }
  }

  Future<void> refresh() async {
    if (state.isLoading || state.isRefreshing) return;
    // The old error goes with the retry: a thread that reloads cleanly must not
    // keep the failure view of the attempt that failed.
    state = state.copyWith(isRefreshing: true, clearFailure: true);
    try {
      final messages = await ref
          .read(chatRepositoryProvider)
          .fetchMessages(conversationId);
      state = state.copyWith(isRefreshing: false, messages: messages);
    } on Failure catch (failure) {
      state = state.copyWith(isRefreshing: false, failure: failure);
    } catch (_) {
      state = state.copyWith(
        isRefreshing: false,
        failure: const UnexpectedFailure(),
      );
    }
  }

  /// Sends [text] into the conversation with a single-submission gate:
  /// while a message is being sent, extra taps are ignored.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    const inFlight = 'in_flight';
    if (state.isSending(inFlight)) return;
    state = state.copyWith(
      sendingIds: <String>{...state.sendingIds, inFlight},
      // A new attempt starts on a clean slate: the previous error banner and
      // its retry draft belong to the send that just left.
      clearActionFailure: true,
      clearFailedMessageText: true,
    );
    try {
      final message = await ref
          .read(chatRepositoryProvider)
          .sendMessage(conversationId: conversationId, text: trimmed);
      state = state.copyWith(
        sendingIds: <String>{...state.sendingIds}..remove(inFlight),
        messages: [...state.messages, message],
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        sendingIds: <String>{...state.sendingIds}..remove(inFlight),
        actionFailure: failure,
        failedMessageText: trimmed,
      );
    } catch (_) {
      state = state.copyWith(
        sendingIds: <String>{...state.sendingIds}..remove(inFlight),
        actionFailure: const UnexpectedFailure(),
        failedMessageText: trimmed,
      );
    }
  }
}
