import 'dart:async';

enum SessionEndReason { expired, suspended, revoked }

class SessionEnded {
  const SessionEnded(this.reason);

  final SessionEndReason reason;
}

class SessionEvents {
  final StreamController<SessionEnded> _controller =
      StreamController<SessionEnded>.broadcast();

  Stream<SessionEnded> get stream => _controller.stream;

  void emit(SessionEndReason reason) {
    _controller.add(SessionEnded(reason));
  }

  Future<void> close() => _controller.close();
}
