import 'package:dio/dio.dart';

import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';

class SupplierApi {
  const SupplierApi(this._client);

  final ApiClient _client;

  Future<Paginated<SupplierLot>> lots({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, Object?>{'page': page, 'limit': limit};
    if (status != null) query['status'] = status;
    return _page('supplier/lots', query, SupplierLot.fromJson);
  }

  Future<SupplierLot> lot(int id) async =>
      SupplierLot.fromJson(await _client.get('supplier/lots/$id'));

  Future<SupplierLot> createLot(FormData data) async =>
      SupplierLot.fromJson(await _client.postMultipart('supplier/lots', data));

  Future<SupplierLot> updateLot(int id, Map<String, Object?> fields) async =>
      SupplierLot.fromJson(
        await _client.patch('supplier/lots/$id', data: fields),
      );

  Future<void> deleteLot(int id) async =>
      _client.delete('supplier/lots/$id').then((_) {});

  Future<SupplierLot> withdrawLot(int id, String reason) async =>
      SupplierLot.fromJson(
        await _client.post(
          'supplier/lots/$id/withdraw',
          data: {'reason': reason},
        ),
      );

  Future<Paginated<SupplierPayout>> payouts({int page = 1, int limit = 20}) =>
      _page('supplier/payouts', {
        'page': page,
        'limit': limit,
      }, SupplierPayout.fromJson);

  Future<Paginated<SupplierCompensation>> compensations({
    int page = 1,
    int limit = 20,
  }) => _page('supplier/compensations', {
    'page': page,
    'limit': limit,
  }, SupplierCompensation.fromJson);

  Future<Paginated<T>> _page<T>(
    String path,
    Map<String, Object?> query,
    T Function(Object?) parse,
  ) async {
    final response = await _client.get(path, query: query);
    if (response is! Map) {
      throw FormatException('Expected paginated $path response');
    }
    return Paginated<T>.fromJson(Map<String, dynamic>.from(response), parse);
  }
}
