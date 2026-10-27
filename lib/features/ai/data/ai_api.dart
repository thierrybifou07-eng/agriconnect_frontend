import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/ai/domain/ai_entities.dart';

class AiApi {
  const AiApi(this._client);

  final ApiClient _client;

  Future<AiEngineStatus> engineStatus() async =>
      AiEngineStatus.fromJson(await _client.get('admin/ai/status'));

  Future<AiTestResult> testEngine({String? prompt}) async =>
      AiTestResult.fromJson(
        await _client.post(
          'admin/ai/test',
          data: prompt == null ? const <String, Object?>{} : {'prompt': prompt},
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

  Future<Paginated<AiSuggestion>> suggestions({
    int page = 1,
    int limit = 20,
    String? status,
    String? kind,
    int? conversationId,
  }) async {
    final response = await _client.get(
      'staff/ai/suggestions',
      query: {
        'page': page,
        'limit': limit,
        'status': ?_nonEmpty(status),
        'kind': ?_nonEmpty(kind),
        'conversationId': ?conversationId,
      },
    );
    if (response is! Map) {
      throw const FormatException('Expected paginated AI suggestions');
    }
    return Paginated<AiSuggestion>.fromJson(
      Map<String, dynamic>.from(response),
      AiSuggestion.fromJson,
    );
  }

  Future<AiSuggestion> suggestion(int id) async =>
      AiSuggestion.fromJson(await _client.get('staff/ai/suggestions/$id'));

  Future<AiSuggestion> approve(int id, {String? editedContent}) async =>
      AiSuggestion.fromJson(
        await _client.post(
          'staff/ai/suggestions/$id/approve',
          data: {'editedContent': ?editedContent},
        ),
      );

  Future<AiSuggestion> reject(int id, {String? reason}) async =>
      AiSuggestion.fromJson(
        await _client.post(
          'staff/ai/suggestions/$id/reject',
          data: {'reason': ?_nonEmpty(reason)},
        ),
      );

  Future<AiSuggestionRequest> suggestReply(int conversationId) async =>
      AiSuggestionRequest.fromJson(
        await _client.post('staff/conversations/$conversationId/ai-suggest'),
      );

  Future<AiSuggestionRequest> suggestListingDraft(int lotId) async =>
      AiSuggestionRequest.fromJson(
        await _client.post('staff/lots/$lotId/ai-listing-draft'),
      );
}

String? _nonEmpty(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
