import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/ai/domain/ai_entities.dart';

dynamic fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync());

void main() {
  test('AI status preserves the live Ollama response shape', () {
    final status = AiEngineStatus.fromJson(fixture('ai_status.json'));
    expect(status.provider, 'ollama');
    expect(status.enabled, isFalse);
    expect(status.authenticated, isNull);
    expect(status.queuePending, 0);
    expect(status.quota, isNull);
  });

  test('pending without payload means generation is in progress', () {
    final suggestion = AiSuggestion.fromJson(
      fixture('ai_suggestion_generating.json'),
    );
    expect(suggestion.isGenerating, isTrue);
    expect(suggestion.isReady, isFalse);
  });

  test('pending with payload means a human decision is required', () {
    final suggestion = AiSuggestion.fromJson(
      fixture('ai_suggestion_ready.json'),
    );
    expect(suggestion.isReady, isTrue);
    expect(suggestion.payload?.intent, 'PRICE_QUOTE_REQUEST');
    expect(suggestion.payload?.reasons, ['UNVERIFIED_NUMBER']);
    expect(suggestion.agent.autonomy, 'ACT_WITH_APPROVAL');
  });

  test('failed suggestion parses its error code', () {
    final suggestion = AiSuggestion.fromJson(
      fixture('ai_suggestion_failed.json'),
    );
    expect(suggestion.status, AiSuggestionStatus.failed);
    expect(suggestion.error, 'AI_INVALID_OUTPUT');
  });

  test('AI suggestion queue uses the standard pagination envelope', () {
    final page = Paginated<AiSuggestion>.fromJson({
      'items': [fixture('ai_suggestion_ready.json')],
      'page': 1,
      'limit': 20,
      'total': 1,
    }, AiSuggestion.fromJson);
    expect(page.items.single.isReady, isTrue);
    expect(page.hasMore, isFalse);
  });
}
