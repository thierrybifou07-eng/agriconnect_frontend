import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/ai/domain/ai_entities.dart';

abstract interface class AiRepository {
  Future<AiEngineStatus> engineStatus();
  Future<AiTestResult> testEngine({String? prompt});
  Future<Paginated<AiSuggestion>> suggestions({
    int page,
    int limit,
    String? status,
    String? kind,
    int? conversationId,
  });
  Future<AiSuggestion> suggestion(int id);
  Future<AiSuggestion> approve(int id, {String? editedContent});
  Future<AiSuggestion> reject(int id, {String? reason});
  Future<AiSuggestionRequest> suggestReply(int conversationId);
  Future<AiSuggestionRequest> suggestListingDraft(int lotId);
}
