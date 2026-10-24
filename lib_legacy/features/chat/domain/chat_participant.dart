import 'package:flutter/foundation.dart';

import 'package:agri_connect/features/auth/domain/user_role.dart';

/// A marketplace actor reachable through Espace Chat.
///
/// Chat is cross-role by design: suppliers, buyers and drivers can all discuss
/// their ongoing transactions. The signed-in user is not stored here — the
/// pages derive _mine_ ownership from the session instead, so this identifier
/// only describes the counterpart.
@immutable
class ChatParticipant {
  const ChatParticipant({
    required this.id,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String fullName;
  final UserRole role;

  /// Monogram used by avatar initials, mirroring shared `UserAvatar`.
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.first[0].toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatParticipant &&
          other.id == id &&
          other.fullName == fullName &&
          other.role == role;

  @override
  int get hashCode => Object.hash(id, fullName, role);
}
