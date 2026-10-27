import 'package:agri_connect/core/network/paginated.dart';

class AdminOperationRecord {
  const AdminOperationRecord({required this.id, required this.values});

  final int id;
  final Map<String, Object?> values;

  Object? operator [](String key) => values[key];

  factory AdminOperationRecord.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('Expected admin record object');
    }
    final values = Map<String, Object?>.from(json);
    final id = values['id'];
    if (id is! num || id != id.toInt()) {
      throw const FormatException('Expected admin record integer id');
    }
    return AdminOperationRecord(
      id: id.toInt(),
      values: Map.unmodifiable(values),
    );
  }
}

class AdminLegalDocument {
  const AdminLegalDocument({
    this.id,
    required this.code,
    required this.version,
    required this.status,
    this.title,
    this.publishedAt,
  });

  final int? id;
  final String code;
  final String version;
  final String status;
  final String? title;
  final DateTime? publishedAt;

  factory AdminLegalDocument.fromJson(
    Object? json, {
    String? status,
    bool requireId = false,
  }) {
    if (json is! Map) {
      throw const FormatException('Expected legal document object');
    }
    final id = json['id'];
    if (requireId && (id is! num || id != id.toInt())) {
      throw const FormatException('Expected legal document integer id');
    }
    final code = json['code'];
    final version = json['version'];
    if (code is! String || version is! String) {
      throw const FormatException('Expected legal document code and version');
    }
    final rawStatus = json['status'];
    final rawDate = json['publishedAt'];
    return AdminLegalDocument(
      id: id is num && id == id.toInt() ? id.toInt() : null,
      code: code,
      version: version,
      status: status ?? (rawStatus is String ? rawStatus : 'DRAFT'),
      title: json['title'] is String
          ? json['title'] as String
          : json['label'] is String
          ? json['label'] as String
          : null,
      publishedAt: rawDate is String ? DateTime.tryParse(rawDate) : null,
    );
  }
}

abstract interface class AdminOperationsRepository {
  Future<Paginated<AdminOperationRecord>> referentials(
    String kind, {
    required int page,
    required int limit,
    bool? active,
  });
  Future<void> saveReferential(String kind, int? id, Map<String, Object?> body);
  Future<Paginated<AdminOperationRecord>> agencies({
    required int page,
    required int limit,
  });
  Future<void> saveAgency(int? id, Map<String, Object?> body);
  Future<void> saveAgencyZone(
    int agencyId,
    int zoneId,
    Map<String, Object?> body,
  );
  Future<void> removeAgencyZone(int agencyId, int zoneId);
  Future<List<AdminOperationRecord>> agencyDrivers(int agencyId);
  Future<Paginated<AdminOperationRecord>> moneyRecords(
    String kind, {
    required int page,
    required int limit,
    String? status,
  });
  Future<void> payout(int id, Map<String, Object?> body);
  Future<void> referralAction(int id, String action, Map<String, Object?> body);
  Future<void> compensationAction(
    int id,
    String action,
    Map<String, Object?> body,
  );
  Future<List<AdminLegalDocument>> publishedLegal();
  Future<AdminLegalDocument> createLegalVersion(
    String code,
    Map<String, Object?> body,
  );
  Future<void> publishLegalVersion(int id);
}
