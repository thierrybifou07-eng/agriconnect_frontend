// ignore_for_file: cancel_subscriptions

import 'dart:async';

import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/realtime/realtime_transport.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class SocketService extends GetxService {
  SocketService({
    required this.authController,
    required this.apiClient,
    required this.tokenStorage,
    RealtimeTransport? transport,
  }) : _transport = transport ?? SocketIoTransport() {
    apiClient.onTokenRefreshed = _onTokenRefreshed;
  }

  final AuthController authController;
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final RealtimeTransport _transport;

  final RxBool connected = false.obs;
  final Set<int> _conversationRooms = <int>{};
  final Map<String, StreamController<Map<String, dynamic>>> _streams = {
    'message:new': StreamController<Map<String, dynamic>>.broadcast(),
    'conversation:assigned': StreamController<Map<String, dynamic>>.broadcast(),
    'conversation:escalated':
        StreamController<Map<String, dynamic>>.broadcast(),
    'delivery:available': StreamController<Map<String, dynamic>>.broadcast(),
    'delivery:status': StreamController<Map<String, dynamic>>.broadcast(),
    'alert:expiring': StreamController<Map<String, dynamic>>.broadcast(),
    'ai:suggestion': StreamController<Map<String, dynamic>>.broadcast(),
    'ai:suggestion:updated': StreamController<Map<String, dynamic>>.broadcast(),
  };

  StreamSubscription<dynamic>? _userSubscription;
  bool _refreshTried = false;

  Stream<Map<String, dynamic>> get messageNew => _stream('message:new');
  Stream<Map<String, dynamic>> get conversationAssigned =>
      _stream('conversation:assigned');
  Stream<Map<String, dynamic>> get conversationEscalated =>
      _stream('conversation:escalated');
  Stream<Map<String, dynamic>> get deliveryAvailable =>
      _stream('delivery:available');
  Stream<Map<String, dynamic>> get deliveryStatus => _stream('delivery:status');
  Stream<Map<String, dynamic>> get alertExpiring => _stream('alert:expiring');
  Stream<Map<String, dynamic>> get aiSuggestion => _stream('ai:suggestion');
  Stream<Map<String, dynamic>> get aiSuggestionUpdated =>
      _stream('ai:suggestion:updated');
  bool isConversationOpen(int id) => _conversationRooms.contains(id);

  Stream<Map<String, dynamic>> _stream(String event) => _streams[event]!.stream;

  @override
  void onInit() {
    super.onInit();
    for (final entry in _streams.entries) {
      _transport.on(entry.key, (dynamic data) {
        final payload = _asPayload(data);
        if (payload != null) entry.value.add(payload);
      });
    }
    _transport.on('connect', (_) {
      connected.value = true;
      _refreshTried = false;
      unawaited(_rejoinRooms());
    });
    _transport.on('disconnect', (_) => connected.value = false);
    _transport.on('connect_error', (_) => unawaited(_onConnectError()));
    _transport.on('session_revoked', (_) {
      disconnect();
      authController.forceSignOut();
    });
    _userSubscription = authController.user.listen((user) {
      if (user == null) {
        disconnect();
      } else {
        unawaited(_connectFromStorage());
      }
    });
    if (authController.user.value != null) unawaited(_connectFromStorage());
  }

  Future<void> _connectFromStorage() async {
    final pair = await tokenStorage.read();
    if (pair == null || authController.user.value == null) {
      connected.value = false;
      return;
    }
    await _transport.connect(pair.access);
  }

  Future<void> _updateToken(String token) async {
    if (authController.user.value == null) return;
    await _transport.connect(token);
  }

  void _onTokenRefreshed(String token) {
    unawaited(_updateToken(token));
  }

  Future<void> _onConnectError() async {
    connected.value = false;
    if (_refreshTried || authController.user.value == null) return;
    _refreshTried = true;
    final token = await apiClient.ensureFreshToken();
    if (token == null) connected.value = false;
  }

  Future<bool> joinConversation(int id) async {
    _conversationRooms.add(id);
    if (!_transport.isConnected) return false;
    try {
      final ack = await _transport.emitWithAck('join_conversation', id);
      if (ack is Map && ack['ok'] == true) return true;
      _conversationRooms.remove(id);
      return false;
    } on TimeoutException {
      return false;
    } on StateError {
      return false;
    }
  }

  void leaveConversation(int id) {
    _conversationRooms.remove(id);
    if (_transport.isConnected) _transport.emit('leave_conversation', id);
  }

  Future<void> _rejoinRooms() async {
    for (final id in _conversationRooms.toList(growable: false)) {
      try {
        final ack = await _transport.emitWithAck('join_conversation', id);
        if (ack is! Map || ack['ok'] != true) return;
      } on TimeoutException {
        return;
      } on StateError {
        return;
      }
    }
  }

  void disconnect() {
    connected.value = false;
    _conversationRooms.clear();
    _transport.disconnect();
  }

  static Map<String, dynamic>? _asPayload(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  @override
  void onClose() {
    disconnect();
    for (final event in _streams.keys) {
      _transport.off(event);
    }
    _transport
      ..off('connect')
      ..off('disconnect')
      ..off('connect_error')
      ..off('session_revoked');
    final userSubscription = _userSubscription;
    if (userSubscription != null) unawaited(userSubscription.cancel());
    apiClient.onTokenRefreshed = null;
    for (final stream in _streams.values) {
      unawaited(stream.close());
    }
    super.onClose();
  }
}
