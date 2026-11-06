import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Why the session ended without the user signing out.
enum SessionEndReason {
  /// The refresh token was refused (expired, reused, revoked).
  expired,

  /// The account was suspended (403 ACCOUNT_SUSPENDED).
  suspended,

  /// The server closed the session (Socket.io `session_revoked`).
  revoked,
}

/// Broadcasts session losses detected by the network layer, so the
/// authentication state can sign out once, whatever call noticed it.
class SessionEvents {
  final StreamController<SessionEndReason> _controller =
      StreamController<SessionEndReason>.broadcast();

  Stream<SessionEndReason> get stream => _controller.stream;

  void emit(SessionEndReason reason) {
    if (!_controller.isClosed) _controller.add(reason);
  }

  Future<void> close() => _controller.close();
}

final sessionEventsProvider = Provider<SessionEvents>((ref) {
  final events = SessionEvents();
  ref.onDispose(events.close);
  return events;
});
