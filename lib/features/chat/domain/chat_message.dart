import 'package:flutter/foundation.dart';

import 'package:agri_connect/features/chat/domain/chat_participant.dart';

/// One message inside a conversation thread.
///
/// [isMine] is computed at load time from the signed-in user's identity and is
/// never stored: it only decides bubble alignment and ownership styling.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.text,
    required this.sentAt,
    this.isMine = false,
  });

  final String id;
  final String conversationId;

  /// Author of the message (the counterpart or the signed-in user).
  final ChatParticipant sender;
  final String text;
  final DateTime sentAt;

  /// Whether [sender] is the signed-in user, used for bubble alignment.
  final bool isMine;

  ChatMessage copyWith({bool? isMine}) => ChatMessage(
    id: id,
    conversationId: conversationId,
    sender: sender,
    text: text,
    sentAt: sentAt,
    isMine: isMine ?? this.isMine,
  );
}
