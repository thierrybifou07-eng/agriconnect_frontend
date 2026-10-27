import 'package:dio/dio.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';

class StaffApi {
  const StaffApi(this._client);
  final ApiClient _client;

  Future<Paginated<T>> _page<T>(
    String path,
    Map<String, Object?> query,
    T Function(Object?) parse,
  ) async =>
      Paginated<T>.fromJson(await _client.get(path, query: query), parse);

  Future<Paginated<StaffConversation>> conversations({
    required int page,
    required int limit,
    String? status,
    bool? unassigned,
    bool? mine,
    bool? escalated,
  }) {
    final query = <String, Object?>{'page': page, 'limit': limit};
    if (status != null) query['status'] = status;
    if (unassigned != null) query['unassigned'] = unassigned;
    if (mine != null) query['mine'] = mine;
    if (escalated != null) query['escalated'] = escalated;
    return _page('staff/conversations', query, StaffConversation.fromJson);
  }

  Future<StaffConversation> conversation(int id) async =>
      StaffConversation.fromJson(await _client.get('staff/conversations/$id'));

  Future<Paginated<StaffMessage>> messages(int id, int page, int limit) =>
      _page('staff/conversations/$id/messages', {
        'page': page,
        'limit': limit,
      }, StaffMessage.fromJson);

  Future<StaffMessage> sendMessage(
    int id,
    String content,
    bool isInternal,
  ) async => StaffMessage.fromJson(
    await _client.post(
      'staff/conversations/$id/messages',
      data: {'content': content.trim(), 'isInternal': isInternal},
    ),
  );

  Future<void> assign(int id, {int? agentId}) async {
    await _client.post(
      'staff/conversations/$id/assign',
      data: agentId == null ? const <String, Object?>{} : {'agentId': agentId},
    );
  }

  Future<void> escalate(int id, String reason) async {
    await _client.post(
      'staff/conversations/$id/escalate',
      data: {'reason': reason.trim()},
    );
  }

  Future<void> closeConversation(int id) async {
    await _client.post('staff/conversations/$id/close');
  }

  Future<Paginated<StaffLot>> lots({
    required int page,
    required int limit,
    String? status,
    int? supplierId,
    int? productId,
  }) {
    final query = <String, Object?>{'page': page, 'limit': limit};
    if (status != null) query['status'] = status;
    if (supplierId != null) query['supplierId'] = supplierId;
    if (productId != null) query['productId'] = productId;
    return _page('staff/lots', query, StaffLot.fromJson);
  }

  Future<StaffLot> lot(int id) async =>
      StaffLot.fromJson(await _client.get('staff/lots/$id'));

  Future<void> validateLot(int id) async {
    await _client.post('staff/lots/$id/validate');
  }

  Future<void> rejectLot(int id, String reason) async {
    await _client.post(
      'staff/lots/$id/reject',
      data: {'reason': reason.trim()},
    );
  }

  Future<void> returnLot(int id, String reason) async {
    await _client.post(
      'staff/lots/$id/return',
      data: {'reason': reason.trim()},
    );
  }

  Future<void> qualityCheck(int id, String grade, String? notes) async {
    await _client.post(
      'staff/lots/$id/quality-checks',
      data: {
        'grade': grade,
        if (notes?.trim().isNotEmpty == true) 'notes': notes!.trim(),
      },
    );
  }

  Future<List<Map<String, Object?>>> qualityChecks(int id) async {
    final response = await _client.get('staff/lots/$id/quality-checks');
    if (response is! List) {
      throw const FormatException('Expected quality-check list');
    }
    return List.unmodifiable(
      response.map((item) => Map<String, Object?>.unmodifiable(_object(item))),
    );
  }

  Future<Paginated<Map<String, Object?>>> stockMovements(
    int lotId, {
    required int page,
    required int limit,
  }) => _page('staff/stock-movements', {
    'lotId': lotId,
    'page': page,
    'limit': limit,
  }, (item) => Map<String, Object?>.unmodifiable(_object(item)));

  Future<Paginated<StaffListing>> listings({
    required int page,
    required int limit,
    String? status,
    int? productId,
    int? supplierId,
  }) {
    final query = <String, Object?>{'page': page, 'limit': limit};
    if (status != null) query['status'] = status;
    if (productId != null) query['productId'] = productId;
    if (supplierId != null) query['supplierId'] = supplierId;
    return _page('staff/listings', query, StaffListing.fromJson);
  }

  Future<StaffListing> listing(int id) async =>
      StaffListing.fromJson(await _client.get('staff/listings/$id'));

  Future<StaffListing> createListing(
    int lotId,
    String title,
    String? description,
    List<String> imagePaths,
  ) async {
    final form = FormData()
      ..fields.addAll([
        MapEntry('lotIds', '$lotId'),
        MapEntry('title', title.trim()),
        if (description?.trim().isNotEmpty == true)
          MapEntry('description', description!.trim()),
      ]);
    for (final path in imagePaths) {
      form.files.add(MapEntry('images', await MultipartFile.fromFile(path)));
    }
    return StaffListing.fromJson(
      await _client.postMultipart('staff/listings', form),
    );
  }

  Future<StaffListing> updateListing(
    int id,
    Map<String, Object?> fields,
  ) async => StaffListing.fromJson(
    await _client.patch('staff/listings/$id', data: fields),
  );

  Future<void> publishListing(int id) async {
    await _client.post('staff/listings/$id/publish');
  }

  Future<void> unpublishListing(int id) async {
    await _client.post('staff/listings/$id/unpublish');
  }

  static Map<String, dynamic> _object(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const FormatException('Expected object');
  }
}
