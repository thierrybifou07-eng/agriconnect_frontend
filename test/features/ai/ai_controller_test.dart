import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/api_failure_events.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/ai/domain/ai_entities.dart';
import 'package:agri_connect/features/ai/domain/ai_repository.dart';
import 'package:agri_connect/features/ai/presentation/controllers/ai_controllers.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

import '../../support/fake_realtime_transport.dart';
import '../../support/get_test_harness.dart';
import '../auth/fake_auth_repository.dart';

dynamic fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync());

void main() {
  setupGetTestHarness();

  test('creation, aiSuggestionUpdated, and edited approval flow', () async {
    final setup = _setup();
    final controller = AiSuggestionController(
      repository: setup.repository,
      socket: setup.socket,
      pollInterval: const Duration(milliseconds: 5),
    )..onInit();
    await controller.suggestReply(18);
    expect(controller.current.value?.isGenerating, isTrue);

    setup.repository.current = _ready();
    setup.transport.fire('ai:suggestion:updated', {'id': 31});
    await _until(() => controller.current.value?.isReady == true);
    expect(controller.current.value?.payload?.reply, contains('devis'));

    expect(
      await controller.approve(editedContent: 'Texte relu et corrigé.'),
      isTrue,
    );
    expect(setup.repository.approvedContent, 'Texte relu et corrigé.');
    controller.onClose();
    setup.dispose();
  });

  test('polling fallback stops at the provider-specific deadline', () async {
    final setup = _setup();
    final controller = AiSuggestionController(
      repository: setup.repository,
      socket: setup.socket,
      pollInterval: const Duration(milliseconds: 3),
      cloudPollLimit: const Duration(milliseconds: 12),
      ollamaPollLimit: const Duration(milliseconds: 20),
    )..onInit();
    controller.setProvider('ollama');
    await controller.suggestReply(18);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final completedPollCalls = setup.repository.detailCalls;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(setup.repository.detailCalls, completedPollCalls);
    expect(completedPollCalls, greaterThan(1));
    controller.onClose();
    setup.dispose();
  });

  test('AI_DISABLED, AI_BUSY, and AI_NO_AGENT codes remain visible', () async {
    final setup = _setup();
    final controller = AiSuggestionController(
      repository: setup.repository,
      socket: setup.socket,
    )..onInit();
    for (final code in ['AI_DISABLED', 'AI_BUSY', 'AI_NO_AGENT']) {
      setup.repository.createFailure = _failure(code);
      await controller.suggestReply(18);
      expect(controller.lastErrorCode.value, code);
    }
    controller.onClose();
    setup.dispose();
  });

  test('reject passes the optional reason through to the repository', () async {
    final setup = _setup();
    final controller = AiSuggestionController(
      repository: setup.repository,
      socket: setup.socket,
    )..onInit();
    await controller.suggestReply(18);
    expect(await controller.reject(reason: 'À vérifier'), isTrue);
    expect(setup.repository.rejectedReason, 'À vérifier');
    controller.onClose();
    setup.dispose();
  });
}

class _Setup {
  _Setup(this.repository, this.socket, this.transport, this.events);

  final _FakeAiRepository repository;
  final SocketService socket;
  final FakeTransport transport;
  final SessionEvents events;

  void dispose() {
    socket.onClose();
    events.close();
  }
}

_Setup _setup() {
  final storage = InMemoryTokenStorage();
  final events = SessionEvents();
  final api = ApiClient(
    tokenStorage: storage,
    sessionEvents: events,
    failureEvents: ApiFailureEvents(),
    baseUrl: 'http://localhost/api/v2',
    dio: Dio(BaseOptions(baseUrl: 'http://localhost/api/v2')),
  );
  final transport = FakeTransport();
  final socket = SocketService(
    authController: AuthController(
      tokenStorage: storage,
      sessionEvents: events,
      repository: FakeAuthRepository(),
    ),
    apiClient: api,
    tokenStorage: storage,
    transport: transport,
  )..onInit();
  return _Setup(_FakeAiRepository(), socket, transport, events);
}

class _FakeAiRepository implements AiRepository {
  AiSuggestion current = _generating();
  ApiFailure? createFailure;
  String? approvedContent;
  String? rejectedReason;
  int detailCalls = 0;

  @override
  Future<AiEngineStatus> engineStatus() async =>
      AiEngineStatus.fromJson(fixture('ai_status.json'));

  @override
  Future<AiTestResult> testEngine({String? prompt}) async =>
      throw UnimplementedError();

  @override
  Future<Paginated<AiSuggestion>> suggestions({
    int page = 1,
    int limit = 20,
    String? status,
    String? kind,
    int? conversationId,
  }) async {
    final matches =
        current.status.name.toUpperCase() == status ||
            status == null ||
            status.isEmpty
        ? current.conversationId == conversationId || conversationId == null
              ? <AiSuggestion>[current]
              : <AiSuggestion>[]
        : <AiSuggestion>[];
    return Paginated(
      items: matches,
      page: page,
      limit: limit,
      total: matches.length,
    );
  }

  @override
  Future<AiSuggestion> suggestion(int id) async {
    detailCalls++;
    return current;
  }

  @override
  Future<AiSuggestion> approve(int id, {String? editedContent}) async {
    approvedContent = editedContent;
    return current;
  }

  @override
  Future<AiSuggestion> reject(int id, {String? reason}) async {
    rejectedReason = reason;
    return current;
  }

  @override
  Future<AiSuggestionRequest> suggestReply(int conversationId) async {
    if (createFailure case final failure?) throw failure;
    return const AiSuggestionRequest(suggestionId: 31, status: 'PENDING');
  }

  @override
  Future<AiSuggestionRequest> suggestListingDraft(int lotId) async =>
      const AiSuggestionRequest(suggestionId: 31, status: 'PENDING');
}

AiSuggestion _generating() =>
    AiSuggestion.fromJson(fixture('ai_suggestion_generating.json'));

AiSuggestion _ready() =>
    AiSuggestion.fromJson(fixture('ai_suggestion_ready.json'));

ApiFailure _failure(String code) => ApiFailure(
  status: 409,
  code: code,
  message: code,
  fieldErrors: const {},
  kind: ApiFailureKind.client,
);

Future<void> _until(bool Function() condition) async {
  for (var attempt = 0; attempt < 50 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  expect(condition(), isTrue);
}
