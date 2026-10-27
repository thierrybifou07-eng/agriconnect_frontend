import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/ai/data/ai_api.dart';
import 'package:agri_connect/features/ai/domain/ai_entities.dart';
import 'package:agri_connect/features/ai/domain/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  const AiRepositoryImpl(this._api);

  final AiApi _api;

  @override
  Future<AiEngineStatus> engineStatus() => _guard(_api.engineStatus);

  @override
  Future<AiTestResult> testEngine({String? prompt}) =>
      _guard(() => _api.testEngine(prompt: prompt));

  @override
  Future<Paginated<AiSuggestion>> suggestions({
    int page = 1,
    int limit = 20,
    String? status,
    String? kind,
    int? conversationId,
  }) => _guard(
    () => _api.suggestions(
      page: page,
      limit: limit,
      status: status,
      kind: kind,
      conversationId: conversationId,
    ),
  );

  @override
  Future<AiSuggestion> suggestion(int id) => _guard(() => _api.suggestion(id));

  @override
  Future<AiSuggestion> approve(int id, {String? editedContent}) =>
      _guard(() => _api.approve(id, editedContent: editedContent));

  @override
  Future<AiSuggestion> reject(int id, {String? reason}) =>
      _guard(() => _api.reject(id, reason: reason));

  @override
  Future<AiSuggestionRequest> suggestReply(int conversationId) =>
      _guard(() => _api.suggestReply(conversationId));

  @override
  Future<AiSuggestionRequest> suggestListingDraft(int lotId) =>
      _guard(() => _api.suggestListingDraft(lotId));

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FormatException catch (error) {
      throw ApiFailure(
        status: null,
        code: 'INVALID_RESPONSE',
        message: error.message.toString(),
        fieldErrors: const {},
        kind: ApiFailureKind.server,
      );
    }
  }
}
