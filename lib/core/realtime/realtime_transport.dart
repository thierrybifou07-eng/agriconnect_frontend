import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:agri_connect/core/config/env.dart';

typedef RealtimeHandler = void Function(dynamic data);

/// Minimal surface of a Socket.io client, so the service can be tested with
/// a fake transport and no network.
abstract interface class RealtimeTransport {
  bool get isConnected;

  /// Opens the connection with [token] as handshake `auth.token`.
  void connect(String token);

  /// Token used by the next (re)connection handshake.
  void updateToken(String token);

  void disconnect();
  void on(String event, RealtimeHandler handler);
  void emit(String event, Object? data);
  Future<Object?> emitWithAck(
    String event,
    Object? data, {
    Duration timeout = const Duration(seconds: 5),
  });
  void dispose();
}

/// Socket.io transport connected to the backend ORIGIN (not `/api/v2`).
class SocketIoTransport implements RealtimeTransport {
  SocketIoTransport({String? url}) : _url = url ?? Env.origin;

  final String _url;
  io.Socket? _socket;
  String _token = '';
  final Map<String, List<RealtimeHandler>> _handlers = {};

  /// Reconnection events are emitted by the Manager, not by the socket.
  static const _managerEvents = {
    'reconnect_attempt',
    'reconnect',
    'reconnect_failed',
  };

  io.Socket _ensureSocket() {
    final existing = _socket;
    if (existing != null) return existing;
    final socket = io.io(_url, <String, dynamic>{
      'transports': ['websocket'],
      // Never connect before a token is set: the server would refuse the
      // handshake ("Authentification requise").
      'autoConnect': false,
      // Each session gets its own manager: no state leaks between accounts.
      'forceNew': true,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 30000,
      // Evaluated at EVERY (re)connection handshake, so the latest token
      // given to [updateToken] is always the one sent.
      'auth': (dynamic callback) => callback({'token': _token}),
    });
    for (final entry in _handlers.entries) {
      for (final handler in entry.value) {
        _register(socket, entry.key, handler);
      }
    }
    _socket = socket;
    return socket;
  }

  void _register(io.Socket socket, String event, RealtimeHandler handler) {
    if (_managerEvents.contains(event)) {
      socket.io.on(event, handler);
    } else {
      socket.on(event, handler);
    }
  }

  @override
  bool get isConnected => _socket?.connected ?? false;

  @override
  void connect(String token) {
    _token = token;
    _ensureSocket().connect();
  }

  @override
  void updateToken(String token) => _token = token;

  @override
  void disconnect() => _socket?.disconnect();

  @override
  void on(String event, RealtimeHandler handler) {
    (_handlers[event] ??= []).add(handler);
    final socket = _socket;
    if (socket != null) _register(socket, event, handler);
  }

  @override
  void emit(String event, Object? data) => _socket?.emit(event, data);

  @override
  Future<Object?> emitWithAck(
    String event,
    Object? data, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      return Future<Object?>.error(StateError('Socket not connected'));
    }
    final completer = Completer<Object?>();
    socket.emitWithAck(
      event,
      data,
      ack: (dynamic result) {
        if (!completer.isCompleted) completer.complete(result);
      },
    );
    return completer.future.timeout(timeout);
  }

  @override
  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
