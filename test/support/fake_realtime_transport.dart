import 'package:agri_connect/core/realtime/realtime_transport.dart';

class FakeTransport implements RealtimeTransport {
  final Map<String, List<RealtimeHandler>> _handlers = {};
  final List<(String, dynamic)> emitted = [];
  final List<String> tokens = [];
  dynamic acknowledgement = {'ok': true};
  bool connected = false;

  @override
  bool get isConnected => connected;

  @override
  Future<void> connect(String token) async {
    tokens.add(token);
    connected = true;
    fire('connect');
  }

  @override
  void disconnect() {
    connected = false;
    fire('disconnect');
  }

  @override
  void on(String event, RealtimeHandler handler) {
    (_handlers[event] ??= []).add(handler);
  }

  @override
  void off(String event) {
    _handlers.remove(event);
  }

  @override
  void emit(String event, dynamic data) {
    emitted.add((event, data));
  }

  @override
  Future<dynamic> emitWithAck(
    String event,
    dynamic data, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    emitted.add((event, data));
    return acknowledgement;
  }

  void fire(String event, [dynamic data]) {
    for (final handler in List<RealtimeHandler>.of(_handlers[event] ?? [])) {
      handler(data);
    }
  }
}
