import 'package:agri_connect/core/realtime/realtime_transport.dart';

/// In-memory transport: records connections and emissions, and lets a test
/// fire server events with [fire].
class FakeRealtimeTransport implements RealtimeTransport {
  final Map<String, List<RealtimeHandler>> _handlers = {};
  final List<(String, Object?)> emitted = [];
  final List<String> connectTokens = [];
  String? currentToken;
  Object? acknowledgement = {'ok': true};
  bool connected = false;
  bool disposed = false;

  /// When false, [connect] records the attempt but does not fire `connect`.
  bool acceptConnections = true;

  @override
  bool get isConnected => connected;

  @override
  void connect(String token) {
    connectTokens.add(token);
    currentToken = token;
    if (acceptConnections) {
      connected = true;
      fire('connect');
    }
  }

  @override
  void updateToken(String token) => currentToken = token;

  @override
  void disconnect() {
    if (!connected) return;
    connected = false;
    fire('disconnect');
  }

  @override
  void on(String event, RealtimeHandler handler) {
    (_handlers[event] ??= []).add(handler);
  }

  @override
  void emit(String event, Object? data) => emitted.add((event, data));

  @override
  Future<Object?> emitWithAck(
    String event,
    Object? data, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    emitted.add((event, data));
    return acknowledgement;
  }

  @override
  void dispose() => disposed = true;

  void fire(String event, [Object? data]) {
    for (final handler in List<RealtimeHandler>.of(_handlers[event] ?? [])) {
      handler(data);
    }
  }
}
