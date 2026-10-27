import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/api_failure_events.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/ai/domain/ai_entities.dart';
import 'package:agri_connect/features/ai/domain/ai_repository.dart';
import 'package:agri_connect/features/ai/presentation/controllers/ai_controllers.dart';
import 'package:agri_connect/features/ai/presentation/widgets/ai_suggestion_widgets.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import '../../support/fake_realtime_transport.dart';
import '../../support/get_test_harness.dart';
import '../auth/fake_auth_repository.dart';

dynamic fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync());

void main() {
  setupGetTestHarness();

  testWidgets(
    'suggestion panel renders none, generating, ready, triage, failed',
    (tester) async {
      final repository = _WidgetAiRepository();
      final setup = _setupSocket();
      final controller = Get.put(
        AiSuggestionController(repository: repository, socket: setup.socket),
      );
      final messageText = TextEditingController();
      addTearDown(() {
        messageText.dispose();
        controller.onClose();
        setup.socket.onClose();
        setup.events.close();
      });
      final labels = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AiSuggestionPanel(
              conversationId: 18,
              messageText: messageText,
              closed: false,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text(labels.aiSuggestReply), findsOneWidget);

      controller.current.value = AiSuggestion.fromJson(
        fixture('ai_suggestion_generating.json'),
      );
      await tester.pump();
      expect(find.textContaining(labels.aiGenerating), findsOneWidget);

      controller.current.value = AiSuggestion.fromJson(
        fixture('ai_suggestion_ready.json'),
      );
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Bonjour, votre demande de devis est bien reçue.',
      );
      expect(find.text(labels.aiHumanNeeded), findsOneWidget);
      expect(find.text(labels.aiVerifyNumbers), findsOneWidget);
      expect(find.text(labels.aiSend), findsOneWidget);

      final triageJson =
          Map<String, dynamic>.from(fixture('ai_suggestion_ready.json') as Map)
            ..['kind'] = 'TRIAGE'
            ..['payload'] = {
              'intent': 'DELIVERY_QUESTION',
              'urgency': 'HIGH',
              'needsHuman': true,
              'reasons': [],
            };
      controller.current.value = AiSuggestion.fromJson(triageJson);
      await tester.pump();
      expect(find.text(labels.aiUrgencyHigh), findsOneWidget);
      expect(find.text(labels.aiEscalate), findsOneWidget);

      controller.current.value = AiSuggestion.fromJson(
        fixture('ai_suggestion_failed.json'),
      );
      await tester.pump();
      expect(find.text(labels.aiInvalidOutput), findsOneWidget);
      expect(find.text(labels.aiRetry), findsOneWidget);
    },
  );
}

class _SocketSetup {
  const _SocketSetup(this.socket, this.events);

  final SocketService socket;
  final SessionEvents events;
}

_SocketSetup _setupSocket() {
  final storage = InMemoryTokenStorage();
  final events = SessionEvents();
  final api = ApiClient(
    tokenStorage: storage,
    sessionEvents: events,
    failureEvents: ApiFailureEvents(),
    baseUrl: 'http://localhost/api/v2',
    dio: Dio(BaseOptions(baseUrl: 'http://localhost/api/v2')),
  );
  final socket = SocketService(
    authController: AuthController(
      tokenStorage: storage,
      sessionEvents: events,
      repository: FakeAuthRepository(),
    ),
    apiClient: api,
    tokenStorage: storage,
    transport: FakeTransport(),
  );
  socket.onInit();
  return _SocketSetup(socket, events);
}

class _WidgetAiRepository implements AiRepository {
  @override
  Future<AiEngineStatus> engineStatus() async =>
      AiEngineStatus.fromJson(fixture('ai_status.json'));

  @override
  Future<AiTestResult> testEngine({String? prompt}) =>
      throw UnimplementedError();

  @override
  Future<Paginated<AiSuggestion>> suggestions({
    int page = 1,
    int limit = 20,
    String? status,
    String? kind,
    int? conversationId,
  }) async => Paginated(items: const [], page: page, limit: limit, total: 0);

  @override
  Future<AiSuggestion> suggestion(int id) => throw UnimplementedError();

  @override
  Future<AiSuggestion> approve(int id, {String? editedContent}) =>
      throw UnimplementedError();

  @override
  Future<AiSuggestion> reject(int id, {String? reason}) =>
      throw UnimplementedError();

  @override
  Future<AiSuggestionRequest> suggestReply(int conversationId) =>
      throw UnimplementedError();

  @override
  Future<AiSuggestionRequest> suggestListingDraft(int lotId) =>
      throw UnimplementedError();
}
