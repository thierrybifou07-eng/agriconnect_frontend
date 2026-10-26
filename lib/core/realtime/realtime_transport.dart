import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:agri_connect/core/config/app_env.dart';

typedef RealtimeHandler = void Function(dynamic data);

abstract interface class RealtimeTransport {
  Future<void> connect(String token);
  void disconnect();
  void on(String event, RealtimeHandler handler);
  void off(String event);
  void emit(String event, dynamic data);
  Future<dynamic> emitWithAck(
    String event,
    dynamic data, {
    Duration timeout = const Duration(seconds: 10),
  });
  bool get isConnected;
}

class SocketIoTransport implements RealtimeTransport {
  io.Socket? _socket;
  final Map<String, List<RealtimeHandler>> _handlers = {};

  io.Socket _createSocket() {
    final url = AppEnv.socketUrl.trim().isNotEmpty
        ? AppEnv.socketUrl.trim()
        : AppEnv.origin;
    if (url.isEmpty) throw StateError('Socket URL is not configured');
    final socket = io.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'disableAutoConnect': true,
    });
    for (final entry in _handlers.entries) {
      for (final handler in entry.value) {
        socket.on(entry.key, handler);
      }
    }
    _socket = socket;
    return socket;
  }

  @override
  bool get isConnected => _socket?.connected ?? false;

  @override
  Future<void> connect(String token) async {
    final socket = _socket ?? _createSocket();
    socket.auth = {'token': token};
    socket.connect();
  }

  @override
  void disconnect() {
    final socket = _socket;
    if (socket == null) return;
    socket.disconnect();
  }

  @override
  void on(String event, RealtimeHandler handler) {
    (_handlers[event] ??= []).add(handler);
    _socket?.on(event, handler);
  }

  @override
  void off(String event) {
    _handlers.remove(event);
    _socket?.off(event);
  }

  @override
  void emit(String event, dynamic data) => _socket?.emit(event, data);

  @override
  Future<dynamic> emitWithAck(
    String event,
    dynamic data, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      return Future<dynamic>.error(StateError('Socket is not connected'));
    }
    final completer = Completer<dynamic>();
    socket.emitWithAck(
      event,
      data,
      ack: (dynamic result) {
        if (!completer.isCompleted) completer.complete(result);
      },
    );
    return completer.future.timeout(timeout);
  }
}
