import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';

class ReferenceApi {
  const ReferenceApi(this._client);

  final ApiClient _client;

  Future<List<T>> fetchAll<T>(
    String path,
    T Function(Object?) parse, {
    Map<String, Object?> filters = const {},
  }) async {
    const limit = 100;
    var page = 1;
    final result = <T>[];
    while (true) {
      final response = await _client.get(
        'reference/$path',
        query: {'page': page, 'limit': limit, ...filters},
      );
      if (response is! Map) {
        throw FormatException('Expected paginated $path response');
      }
      final parsed = Paginated<T>.fromJson(
        Map<String, dynamic>.from(response),
        parse,
      );
      result.addAll(parsed.items);
      if (!parsed.hasMore) return List.unmodifiable(result);
      page++;
    }
  }

  Future<List<RefCategory>> categories() =>
      fetchAll('categories', RefCategory.fromJson);

  Future<List<RefUnit>> units() => fetchAll('units', RefUnit.fromJson);

  Future<List<RefProduct>> products({String? q, int? categoryId}) {
    final filters = <String, Object?>{};
    final query = q?.trim();
    if (query != null && query.isNotEmpty) filters['q'] = query;
    if (categoryId != null) filters['categoryId'] = categoryId;
    return fetchAll('products', RefProduct.fromJson, filters: filters);
  }

  Future<List<RefZone>> zones() => fetchAll('zones', RefZone.fromJson);

  Future<List<RefHub>> hubs({int? zoneId}) {
    final filters = <String, Object?>{};
    if (zoneId != null) filters['zoneId'] = zoneId;
    return fetchAll('hubs', RefHub.fromJson, filters: filters);
  }
}
