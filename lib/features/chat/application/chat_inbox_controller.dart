import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/chat/application/chat_providers.dart';
import 'package:agri_connect/features/chat/domain/chat_conversation.dart';

/// Immutable snapshot of the signed-in user inbox.
class ChatInboxState {
  const ChatInboxState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.conversations = const [],
  });

  final bool isLoading;
  final bool isRefreshing;

  /// Load failure; retryable through [ChatInboxController.refresh].
  final Failure? failure;

  /// Conversations ordered by most recent message first.
  final List<ChatConversation> conversations;

  /// Total number of unread messages across the inbox.
  int get unreadCount => conversations.fold(
    0,
    (total, conversation) => total + conversation.unreadCount,
  );

  ChatInboxState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    List<ChatConversation>? conversations,
    bool clearFailure = false,
  }) {
    return ChatInboxState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      // A failure is dropped only when the caller says so: a copy that simply
      // omitted it must not make a failed load look like it never happened.
      failure: clearFailure ? null : (failure ?? this.failure),
      conversations: conversations ?? this.conversations,
    );
  }
}

final chatInboxControllerProvider =
    NotifierProvider<ChatInboxController, ChatInboxState>(
      ChatInboxController.new,
    );

/// Loads the inbox of the signed-in user and keeps it refreshable.
class ChatInboxController extends Notifier<ChatInboxState> {
  @override
  ChatInboxState build() {
    Future<void>.microtask(_load);
    return const ChatInboxState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final conversations = await ref
          .read(chatRepositoryProvider)
          .fetchConversations();
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        conversations: conversations,
        clearFailure: true,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        failure: failure,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        failure: const UnexpectedFailure(),
      );
    }
  }

  /// Reloads the inbox on pull-to-refresh and on retry after a failure.
  ///
  /// Refreshes rather than loads: the conversations already on screen stay
  /// there under the pull indicator instead of being replaced by a skeleton.
  Future<void> refresh() async {
    if (state.isLoading || state.isRefreshing) return;
    // Nothing on screen yet (a retry after a failure) means a load the user can
    // see as a skeleton; conversations already there only get the pull
    // indicator, so the inbox never blanks out under the finger.
    state = state.copyWith(
      isLoading: state.conversations.isEmpty,
      isRefreshing: true,
      clearFailure: true,
    );
    await _load();
  }
}
