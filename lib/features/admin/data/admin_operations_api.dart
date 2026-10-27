import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/admin/domain/admin_operations.dart';

class AdminOperationsApi {
  const AdminOperationsApi(this._client);

  final ApiClient _client;

  Future<Paginated<AdminOperationRecord>> referentials(
    String kind, {
    required int page,
    required int limit,
    bool? active,
  }) async => _page(
    await _client.get(
      'admin/$kind',
      query: {
        'page': page,
        'limit': limit,
        if (kind != 'units' && active != null) 'active': active,
      },
    ),
    'admin $kind',
  );

  Future<void> createReferential(String kind, Map<String, Object?> body) async {
    await _client.post('admin/$kind', data: body);
  }

  Future<void> updateReferential(
    String kind,
    int id,
    Map<String, Object?> body,
  ) async {
    await _client.patch('admin/$kind/$id', data: body);
  }

  Future<Paginated<AdminOperationRecord>> agencies({
    required int page,
    required int limit,
  }) async => _page(
    await _client.get('admin/agencies', query: {'page': page, 'limit': limit}),
    'admin agencies',
  );

  Future<void> saveAgency(int? id, Map<String, Object?> body) async {
    if (id == null) {
      await _client.post('admin/agencies', data: body);
    } else {
      await _client.patch('admin/agencies/$id', data: body);
    }
  }

  Future<void> saveAgencyZone(
    int agencyId,
    int zoneId,
    Map<String, Object?> body,
  ) async {
    await _client.put('admin/agencies/$agencyId/zones/$zoneId', data: body);
  }

  Future<void> removeAgencyZone(int agencyId, int zoneId) async {
    await _client.delete('admin/agencies/$agencyId/zones/$zoneId');
  }

  Future<List<AdminOperationRecord>> agencyDrivers(int agencyId) async {
    final response = await _client.get('admin/agencies/$agencyId/drivers');
    if (response is List) {
      return List.unmodifiable(response.map(AdminOperationRecord.fromJson));
    }
    if (response is Map && response['items'] is List) {
      return List.unmodifiable(
        (response['items'] as List).map(AdminOperationRecord.fromJson),
      );
    }
    throw const FormatException('Expected admin agency drivers');
  }

  Future<Paginated<AdminOperationRecord>> moneyRecords(
    String kind, {
    required int page,
    required int limit,
    String? status,
  }) async => _page(
    await _client.get(
      'admin/$kind',
      query: {'page': page, 'limit': limit, 'status': ?status},
    ),
    'admin $kind',
  );

  Future<void> payout(int id, Map<String, Object?> body) async {
    await _client.patch('admin/payouts/$id/pay', data: body);
  }

  Future<void> referralAction(
    int id,
    String action,
    Map<String, Object?> body,
  ) async {
    await _client.patch('admin/referrals/$id/$action', data: body);
  }

  Future<void> compensationAction(
    int id,
    String action,
    Map<String, Object?> body,
  ) async {
    await _client.patch('admin/compensations/$id/$action', data: body);
  }

  Future<List<AdminLegalDocument>> publishedLegal() async {
    final response = await _client.get('legal', auth: false);
    if (response is! List) {
      throw const FormatException('Expected published legal documents');
    }
    return List.unmodifiable(
      response.map(
        (item) => AdminLegalDocument.fromJson(item, status: 'PUBLISHED'),
      ),
    );
  }

  Future<AdminLegalDocument> createLegalVersion(
    String code,
    Map<String, Object?> body,
  ) async {
    final response = await _client.post(
      'admin/legal/$code/versions',
      data: body,
    );
    if (response is Map) {
      final nested =
          response['legalVersion'] ??
          response['legalDocument'] ??
          response['data'] ??
          response;
      final id = nested is Map ? nested['id'] : null;
      if (nested is Map && id is num && id == id.toInt() && id > 0) {
        final translations = body['translations'];
        Map? french;
        if (translations is List) {
          for (final entry in translations.whereType<Map>()) {
            if (entry['locale'] == 'fr') {
              french = entry;
              break;
            }
          }
        }
        return AdminLegalDocument(
          id: id.toInt(),
          code: code,
          version: body['version'] as String,
          status: 'DRAFT',
          title: french?['title'] is String ? french!['title'] as String : null,
        );
      }
    }
    throw const FormatException('Expected created legal version');
  }

  Future<void> publishLegalVersion(int id) async {
    await _client.patch('admin/legal/versions/$id/publish');
  }

  Paginated<AdminOperationRecord> _page(Object? response, String label) {
    if (response is! Map) {
      throw FormatException('Expected paginated $label response');
    }
    return Paginated<AdminOperationRecord>.fromJson(
      Map<String, dynamic>.from(response),
      AdminOperationRecord.fromJson,
    );
  }
}
