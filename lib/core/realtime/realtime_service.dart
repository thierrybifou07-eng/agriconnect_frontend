import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/network/network_providers.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/realtime/realtime_transport.dart';
import 'package:agri_connect/core/storage/token_storage.dart';

/// Server → client events (docs/API_CONTRACT.md § 7).
abstract final class RealtimeEvent {
  static const messageNew = 'message:new';
  static const conversationAssigned = 'conversation:assigned';
  static const conversationEscalated = 'conversation:escalated';
  static const deliveryAvailable = 'delivery:available';
  static const deliveryStatus = 'delivery:status';
  static const alertExpiring = 'alert:expiring';
  static const aiSuggestion = 'ai:suggestion';
  static const aiSuggestionUpdated = 'ai:suggestion_updated';
  static const errorMessage = 'error_message';

  /// The payload events above, forwarded as typed streams.
  static const all = [
    messageNew,
    conversationAssigned,
    conversationEscalated,
    deliveryAvailable,
    deliveryStatus,
    alertExpiring,
    aiSuggestion,
    aiSuggestionUpdated,
    errorMessage,
  ];
}

/// Real-time connection of the signed-in user.
///
/// - Connects with the stored access token; before every reconnection the
///   handshake token is re-read, because a REST call may have rotated it.
/// - A handshake refused for an invalid token triggers ONE token refresh
///   (shared with the REST interceptor), then a reconnection.
/// - `session_revoked` and a refused handshake for a suspended account stop
///   the connection and report the end of the session on [SessionEvents].
/// - Conversation rooms joined with [joinConversation] are joined again after
///   every reconnection.
///
/// Message content and tokens are never logged.
class RealtimeService {
  RealtimeService({
    required RealtimeTransport transport,
    required TokenStorage tokenStorage,
    required Future<String?> Function() refreshAccessToken,
    required SessionEvents sessionEvents,
  }) : _transport = transport,
       _tokenStorage = tokenStorage,
       _refreshAccessToken = refreshAccessToken,
       _sessionEvents = sessionEvents {
    for (final event in RealtimeEvent.all) {
      final controller = StreamController<Map<String, dynamic>>.broadcast();
      _controllers[event] = controller;
      _transport.on(event, (data) {
        final payload = _asPayload(data);
        if (payload != null && !controller.isClosed) controller.add(payload);
      });
    }
    _transport
      ..on('connect', (_) => _onConnected())
      ..on('disconnect', (_) => connected.value = false)
      ..on('reconnect_attempt', (_) => unawaited(_reloadToken()))
      ..on('connect_error', (data) => unawaited(_onConnectError(data)))
      ..on('session_revoked', (_) => _endSession(SessionEndReason.revoked));
  }

  final RealtimeTransport _transport;
  final TokenStorage _tokenStorage;
  final Future<String?> Function() _refreshAccessToken;
  final SessionEvents _sessionEvents;
  final Map<String, StreamController<Map<String, dynamic>>> _controllers = {};
  final Set<int> _rooms = {};
  bool _started = false;
  bool _refreshTried = false;

  /// Whether the socket is currently connected (offline banner, etc.).
  final ValueNotifier<bool> connected = ValueNotifier(false);

  Stream<Map<String, dynamic>> events(String event) {
    final controller = _controllers[event];
    if (controller == null) {
      throw ArgumentError.value(event, 'event', 'Unknown realtime event');
    }
    return controller.stream;
  }

  Stream<Map<String, dynamic>> get messageNew =>
      events(RealtimeEvent.messageNew);
  Stream<Map<String, dynamic>> get conversationAssigned =>
      events(RealtimeEvent.conversationAssigned);
  Stream<Map<String, dynamic>> get conversationEscalated =>
      events(RealtimeEvent.conversationEscalated);
  Stream<Map<String, dynamic>> get deliveryAvailable =>
      events(RealtimeEvent.deliveryAvailable);
  Stream<Map<String, dynamic>> get deliveryStatus =>
      events(RealtimeEvent.deliveryStatus);
  Stream<Map<String, dynamic>> get alertExpiring =>
      events(RealtimeEvent.alertExpiring);
  Stream<Map<String, dynamic>> get aiSuggestion =>
      events(RealtimeEvent.aiSuggestion);
  Stream<Map<String, dynamic>> get aiSuggestionUpdated =>
      events(RealtimeEvent.aiSuggestionUpdated);

  bool get isStarted => _started;

  /// Connects with the stored token. No-op without a session.
  Future<void> start() async {
    final tokens = await _tokenStorage.read();
    if (tokens == null) return;
    _started = true;
    _refreshTried = false;
    _transport.connect(tokens.access);
  }

  /// Disconnects and forgets the joined rooms (sign-out, session loss).
  void stop() {
    _started = false;
    _rooms.clear();
    connected.value = false;
    _transport.disconnect();
  }

  /// Joins a conversation room; resolves `true` once the server acknowledged.
  ///
  /// The room is remembered even when the socket is offline, and joined as
  /// soon as the connection comes back.
  Future<bool> joinConversation(int id) async {
    _rooms.add(id);
    if (!_transport.isConnected) return false;
    return _join(id);
  }

  void leaveConversation(int id) {
    _rooms.remove(id);
    if (_transport.isConnected) _transport.emit('leave_conversation', id);
  }

  Future<bool> _join(int id) async {
    try {
      final ack = await _transport.emitWithAck('join_conversation', id);
      final ok = ack is Map && ack['ok'] == true;
      if (!ok) _rooms.remove(id);
      return ok;
    } on TimeoutException {
      return false;
    } on StateError {
      return false;
    }
  }

  void _onConnected() {
    connected.value = true;
    _refreshTried = false;
    for (final id in _rooms.toList(growable: false)) {
      unawaited(_join(id));
    }
  }

  Future<void> _reloadToken() async {
    final tokens = await _tokenStorage.read();
    if (tokens != null) _transport.updateToken(tokens.access);
  }

  Future<void> _onConnectError(Object? data) async {
    connected.value = false;
    if (!_started) return;
    final message = _errorMessage(data).toLowerCase();
    if (message.contains('suspendu')) {
      _endSession(SessionEndReason.suspended);
      return;
    }
    final tokenRefused =
        message.contains('token') || message.contains('authentification');
    if (!tokenRefused || _refreshTried) return;
    _refreshTried = true;
    final token = await _refreshAccessToken();
    if (!_started) return;
    if (token == null) {
      // The refresh itself already reported the end of the session.
      stop();
      return;
    }
    _transport.connect(token);
  }

  void _endSession(SessionEndReason reason) {
    stop();
    _sessionEvents.emit(reason);
  }

  void dispose() {
    stop();
    _transport.dispose();
    for (final controller in _controllers.values) {
      unawaited(controller.close());
    }
    connected.dispose();
  }

  static Map<String, dynamic>? _asPayload(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  static String _errorMessage(Object? data) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (data is Map && data['error'] is String) return data['error'] as String;
    return data?.toString() ?? '';
  }
}

/// Real-time service of the session. It is started and stopped by the
/// authentication state (sign-in, restore, sign-out).
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService(
    transport: SocketIoTransport(),
    tokenStorage: ref.watch(tokenStorageProvider),
    refreshAccessToken: ref.watch(authInterceptorProvider).refreshAccessToken,
    sessionEvents: ref.watch(sessionEventsProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
