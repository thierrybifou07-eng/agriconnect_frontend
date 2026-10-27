class AiEngineStatus {
  const AiEngineStatus({
    required this.enabled,
    required this.provider,
    required this.model,
    required this.reachable,
    required this.modelInstalled,
    required this.capabilities,
    required this.queuePending,
    required this.queueRunning,
    required this.autonomousEnabled,
    this.baseUrl,
    this.authenticated,
    this.lastLatencyMs,
    this.quota,
  });

  final bool enabled;
  final String provider;
  final String? baseUrl;
  final String model;
  final bool reachable;
  final bool modelInstalled;
  final bool? authenticated;
  final List<String> capabilities;
  final int? lastLatencyMs;
  final int queuePending;
  final int queueRunning;
  final bool autonomousEnabled;
  final AiQuota? quota;

  factory AiEngineStatus.fromJson(Object? json) {
    final map = _aiMap(json, 'AI engine status');
    final queue = _aiMap(map['queue'], 'AI queue');
    final provider = _aiString(map['provider'], 'provider');
    if (provider != 'ollama' && provider != 'gemini') {
      throw FormatException('Unknown AI provider: $provider');
    }
    final capabilities = map['capabilities'];
    if (capabilities is! List || capabilities.any((item) => item is! String)) {
      throw const FormatException('AI capabilities must be a string list');
    }
    return AiEngineStatus(
      enabled: _aiBool(map['enabled'], 'enabled'),
      provider: provider,
      baseUrl: _aiNullableString(map['baseUrl']),
      model: _aiNullableString(map['model']) ?? '',
      reachable: _aiBool(map['reachable'], 'reachable'),
      modelInstalled: _aiBool(map['modelInstalled'], 'modelInstalled'),
      authenticated: _aiNullableBool(map['authenticated']),
      capabilities: List.unmodifiable(capabilities.cast<String>()),
      lastLatencyMs: _aiNullableInt(map['lastLatencyMs']),
      queuePending: _aiInt(queue['pending'], 'queue.pending'),
      queueRunning: _aiInt(queue['running'], 'queue.running'),
      autonomousEnabled: _aiBool(map['autonomousEnabled'], 'autonomousEnabled'),
      quota: map['quota'] == null ? null : AiQuota.fromJson(map['quota']),
    );
  }
}

class AiQuota {
  const AiQuota({
    required this.maxRpm,
    required this.dailyBudget,
    required this.usedToday,
    required this.resetsAt,
  });

  final int maxRpm;
  final int dailyBudget;
  final int usedToday;
  final DateTime? resetsAt;

  factory AiQuota.fromJson(Object? json) {
    final map = _aiMap(json, 'AI quota');
    return AiQuota(
      maxRpm: _aiInt(map['maxRpm'], 'quota.maxRpm'),
      dailyBudget: _aiInt(map['dailyBudget'], 'quota.dailyBudget'),
      usedToday: _aiInt(map['usedToday'], 'quota.usedToday'),
      resetsAt: _aiNullableDate(map['resetsAt']),
    );
  }
}

enum AiSuggestionKind { reply, triage, listingDraft }

enum AiSuggestionStatus {
  pending,
  approved,
  rejected,
  executed,
  failed,
  expired,
}

class AiSuggestionAgent {
  const AiSuggestionAgent({
    required this.id,
    required this.displayName,
    this.autonomy,
  });

  final int id;
  final String displayName;
  final String? autonomy;

  factory AiSuggestionAgent.fromJson(Object? json) {
    final map = _aiMap(json, 'AI suggestion agent');
    return AiSuggestionAgent(
      id: _aiInt(map['id'], 'agent.id'),
      displayName: _aiString(map['displayName'], 'agent.displayName'),
      autonomy: _aiNullableString(map['autonomy']),
    );
  }
}

class AiListingPayload {
  const AiListingPayload({required this.title, required this.description});

  final String title;
  final String description;

  factory AiListingPayload.fromJson(Object? json) {
    final map = _aiMap(json, 'AI listing payload');
    return AiListingPayload(
      title: _aiString(map['title'], 'listing.title'),
      description: _aiString(map['description'], 'listing.description'),
    );
  }
}

class AiPayload {
  const AiPayload({
    this.intent,
    this.language,
    this.confidence,
    this.urgency,
    this.reply,
    this.needsHuman,
    this.reasons = const [],
    this.listing,
  });

  final String? intent;
  final String? language;
  final double? confidence;
  final String? urgency;
  final String? reply;
  final bool? needsHuman;
  final List<String> reasons;
  final AiListingPayload? listing;

  factory AiPayload.fromJson(Object? json) {
    final map = _aiMap(json, 'AI payload');
    final rawReasons = map['reasons'] ?? map['warnings'] ?? const [];
    if (rawReasons is! List || rawReasons.any((item) => item is! String)) {
      throw const FormatException('AI reasons must be a string list');
    }
    return AiPayload(
      intent: _aiNullableString(map['intent']),
      language: _aiNullableString(map['language']),
      confidence: _aiNullableDouble(map['confidence']),
      urgency: _aiNullableString(map['urgency']),
      reply: _aiNullableString(map['reply']),
      needsHuman: _aiNullableBool(map['needsHuman'] ?? map['needs_human']),
      reasons: List.unmodifiable(rawReasons.cast<String>()),
      listing: map['listing'] == null
          ? null
          : AiListingPayload.fromJson(map['listing']),
    );
  }
}

class AiSuggestion {
  const AiSuggestion({
    required this.id,
    required this.kind,
    required this.status,
    required this.agent,
    required this.model,
    required this.createdAt,
    this.conversationId,
    this.lotId,
    this.latencyMs,
    this.payload,
    this.error,
    this.decidedAt,
    this.executedAt,
  });

  final int id;
  final AiSuggestionKind kind;
  final AiSuggestionStatus status;
  final int? conversationId;
  final int? lotId;
  final AiSuggestionAgent agent;
  final String model;
  final int? latencyMs;
  final AiPayload? payload;
  final String? error;
  final DateTime? decidedAt;
  final DateTime? executedAt;
  final DateTime createdAt;

  bool get isGenerating =>
      status == AiSuggestionStatus.pending && payload == null;
  bool get isReady => status == AiSuggestionStatus.pending && payload != null;

  factory AiSuggestion.fromJson(Object? json) {
    final map = _aiMap(json, 'AI suggestion');
    return AiSuggestion(
      id: _aiInt(map['id'], 'id'),
      kind: _aiEnum(AiSuggestionKind.values, map['kind'], const {
        'REPLY': AiSuggestionKind.reply,
        'TRIAGE': AiSuggestionKind.triage,
        'LISTING_DRAFT': AiSuggestionKind.listingDraft,
      }, 'kind'),
      status: _aiEnum(AiSuggestionStatus.values, map['status'], const {
        'PENDING': AiSuggestionStatus.pending,
        'APPROVED': AiSuggestionStatus.approved,
        'REJECTED': AiSuggestionStatus.rejected,
        'EXECUTED': AiSuggestionStatus.executed,
        'FAILED': AiSuggestionStatus.failed,
        'EXPIRED': AiSuggestionStatus.expired,
      }, 'status'),
      conversationId: _aiNullableInt(map['conversationId']),
      lotId: _aiNullableInt(map['lotId']),
      agent: AiSuggestionAgent.fromJson(map['agent']),
      model: _aiString(map['model'], 'model'),
      latencyMs: _aiNullableInt(map['latencyMs']),
      payload: map['payload'] == null
          ? null
          : AiPayload.fromJson(map['payload']),
      error: _aiNullableString(map['error']),
      decidedAt: _aiNullableDate(map['decidedAt']),
      executedAt: _aiNullableDate(map['executedAt']),
      createdAt: _aiDate(map['createdAt'], 'createdAt'),
    );
  }
}

class AiSuggestionRequest {
  const AiSuggestionRequest({required this.suggestionId, required this.status});

  final int suggestionId;
  final String status;

  factory AiSuggestionRequest.fromJson(Object? json) {
    final map = _aiMap(json, 'AI suggestion request');
    return AiSuggestionRequest(
      suggestionId: _aiInt(map['suggestionId'], 'suggestionId'),
      status: _aiString(map['status'], 'status'),
    );
  }
}

class AiTestResult {
  const AiTestResult({
    required this.ok,
    required this.latencyMs,
    required this.output,
  });

  final bool ok;
  final int latencyMs;
  final AiPayload output;

  factory AiTestResult.fromJson(Object? json) {
    final map = _aiMap(json, 'AI test result');
    return AiTestResult(
      ok: _aiBool(map['ok'], 'ok'),
      latencyMs: _aiInt(map['latencyMs'], 'latencyMs'),
      output: AiPayload.fromJson(map['output']),
    );
  }
}

Map<String, dynamic> _aiMap(Object? value, String name) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('Expected $name object');
}

String _aiString(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('Expected AI $field string');
}

String? _aiNullableString(Object? value) {
  if (value == null || value is String) return value as String?;
  throw const FormatException('Expected nullable AI string');
}

bool _aiBool(Object? value, String field) {
  if (value is bool) return value;
  throw FormatException('Expected AI $field boolean');
}

bool? _aiNullableBool(Object? value) {
  if (value == null || value is bool) return value as bool?;
  throw const FormatException('Expected nullable AI boolean');
}

int _aiInt(Object? value, String field) {
  if (value is int) return value;
  if (value is num && value == value.toInt()) return value.toInt();
  throw FormatException('Expected AI $field integer');
}

int? _aiNullableInt(Object? value) =>
    value == null ? null : _aiInt(value, 'nullable integer');

double? _aiNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  throw const FormatException('Expected nullable AI number');
}

DateTime _aiDate(Object? value, String field) {
  final date = value is String ? DateTime.tryParse(value) : null;
  if (date == null) throw FormatException('Expected AI $field date');
  return date.toUtc();
}

DateTime? _aiNullableDate(Object? value) => value == null
    ? null
    : value is num
    ? DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true)
    : _aiDate(value, 'nullable');

T _aiEnum<T>(
  List<T> values,
  Object? value,
  Map<String, T> byName,
  String field,
) {
  final result = value is String ? byName[value] : null;
  if (result != null && values.contains(result)) return result;
  throw FormatException('Unknown AI $field: $value');
}
