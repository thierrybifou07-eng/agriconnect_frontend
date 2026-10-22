import 'package:flutter/foundation.dart';

import 'package:agri_connect/features/chat/domain/chat_participant.dart';

/// A conversation of the signed-in user with one marketplace counterpart.
///
/// The inbox is derived from the session: unread state is either owned by the
/// signed-in user ([isUnreadByMe]) or belongs to the counterpart (the reply
/// badge), and [lastMessage] only ever describes the counterpart's latest
/// message update previewed on the tile.
@immutable
class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.participant,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadByMe = false,
    this.unreadCount = 0,
  });

  final String id;

  /// The counterpart (never the signed-in user).
  final ChatParticipant participant;

  /// Preview of the most recent message of the thread.
  final String lastMessage;
  final DateTime lastMessageAt;

  /// Whether the latest message belongs to the counterpart and is not yet read.
  final bool unreadByMe;
  final int unreadCount;

  ChatConversation copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    bool? unreadByMe,
    int? unreadCount,
  }) {
    return ChatConversation(
      id: id,
      participant: participant,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadByMe: unreadByMe ?? this.unreadByMe,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
