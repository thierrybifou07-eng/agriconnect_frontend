import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/realtime/realtime_service.dart';

import '../support/fake_realtime_transport.dart';
import '../support/in_memory_token_storage.dart';

class _Harness {
  _Harness({String? Function()? refresh}) {
    service = RealtimeService(
      transport: transport,
      tokenStorage: storage,
      refreshAccessToken: () async {
        refreshCalls++;
        final token = refresh?.call();
        if (token != null) await storage.save(access: token, refresh: 'r2');
        return token;
      },
      sessionEvents: events,
    );
    events.stream.listen(reasons.add);
  }

  final transport = FakeRealtimeTransport();
  final storage = InMemoryTokenStorage();
  final events = SessionEvents();
  final reasons = <SessionEndReason>[];
  int refreshCalls = 0;
  late final RealtimeService service;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('start connects with the stored token; without a session it does nothing', () async {
    final h = _Harness();
    await h.service.start();
    expect(h.transport.connectTokens, isEmpty);

    await h.storage.save(access: 'a1', refresh: 'r1');
    await h.service.start();
    expect(h.transport.connectTokens, ['a1']);
    expect(h.service.connected.value, isTrue);

    h.service.stop();
    expect(h.service.connected.value, isFalse);
    expect(h.transport.connected, isFalse);
  });

  test('forwards typed payloads, including ai:suggestion_updated', () async {
    final h = _Harness();
    final received = <Map<String, dynamic>>[];
    h.service.aiSuggestionUpdated.listen(received.add);
    h.service.messageNew.listen(received.add);

    h.transport.fire('ai:suggestion_updated', {'id': 7, 'status': 'PENDING'});
    h.transport.fire('message:new', {'id': 1, 'content': 'Bonjour'});
    h.transport.fire('message:new', 'not a map');
    await _settle();

    expect(received, [
      {'id': 7, 'status': 'PENDING'},
      {'id': 1, 'content': 'Bonjour'},
    ]);
  });

  test('re-reads the stored token before every reconnection attempt', () async {
    final h = _Harness();
    await h.storage.save(access: 'a1', refresh: 'r1');
    await h.service.start();

    await h.storage.save(access: 'a2', refresh: 'r2');
    h.transport.fire('reconnect_attempt', 1);
    await _settle();

    expect(h.transport.currentToken, 'a2');
  });

  test('a refused handshake token triggers one refresh, then reconnects', () async {
    final h = _Harness(refresh: () => 'a-new');
    await h.storage.save(access: 'a-old', refresh: 'r1');
    h.transport.acceptConnections = false;
    await h.service.start();

    h.transport.fire('connect_error', {'message': 'Token invalide'});
    await _settle();
    await _settle();
    h.transport.fire('connect_error', {'message': 'Token invalide'});
    await _settle();

    expect(h.refreshCalls, 1);
    expect(h.transport.connectTokens, ['a-old', 'a-new']);
  });

  test('a suspended account or session_revoked stops and ends the session', () async {
    final h = _Harness();
    await h.storage.save(access: 'a1', refresh: 'r1');
    await h.service.start();
    h.transport.fire('connect_error', 'Ce compte a été suspendu');
    await _settle();
    expect(h.reasons, [SessionEndReason.suspended]);
    expect(h.service.isStarted, isFalse);

    await h.service.start();
    h.transport.fire('session_revoked', {'reason': 'session_closed'});
    await _settle();
    expect(h.reasons, [SessionEndReason.suspended, SessionEndReason.revoked]);
    expect(h.transport.connected, isFalse);
  });

  test('joined rooms wait for the ack and are joined again after reconnection', () async {
    final h = _Harness();
    await h.storage.save(access: 'a1', refresh: 'r1');
    await h.service.start();

    expect(await h.service.joinConversation(42), isTrue);
    h.transport.disconnect();
    h.transport.connect('a1');
    await _settle();

    final joins = h.transport.emitted.where((e) => e.$1 == 'join_conversation');
    expect(joins.map((e) => e.$2), [42, 42]);

    h.service.leaveConversation(42);
    expect(h.transport.emitted.last, ('leave_conversation', 42));
  });

  test('a refused join is forgotten', () async {
    final h = _Harness();
    await h.storage.save(access: 'a1', refresh: 'r1');
    await h.service.start();
    h.transport.acknowledgement = {'ok': false};

    expect(await h.service.joinConversation(9), isFalse);
    h.transport.disconnect();
    h.transport.connect('a1');
    await _settle();

    final joins = h.transport.emitted.where((e) => e.$1 == 'join_conversation');
    expect(joins, hasLength(1));
  });
}
