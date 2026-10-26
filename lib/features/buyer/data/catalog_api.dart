import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/buyer/data/dto/buyer_dto.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';

class CatalogApi {
  CatalogApi(this.client);

  final ApiClient client;

  Future<List<CatalogCategory>> categories() async {
    final response = await client.get('/catalog/categories');
    if (response is! Map ||
        response['value'] is! List ||
        response['Count'] is! num ||
        (response['Count'] as num) < 0) {
      throw const FormatException(
        'Catalog categories response must contain value and Count',
      );
    }
    return List<CatalogCategory>.unmodifiable(
      (response['value'] as List).map(CatalogCategoryDto.fromJson),
    );
  }

  Future<Paginated<CatalogListing>> listings({
    int? categoryId,
    int? zoneId,
    String? query,
    String? sort,
    required int page,
    required int limit,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (categoryId != null) params['categoryId'] = categoryId;
    if (zoneId != null) params['zoneId'] = zoneId;
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
    if (sort != null) params['sort'] = sort;
    final response = await client.get('/catalog/listings', query: params);
    if (response is! Map) {
      throw const FormatException(
        'Catalog listings response must be an object',
      );
    }
    return Paginated.fromJson(
      Map<String, dynamic>.from(response),
      CatalogListingDto.fromJson,
    );
  }

  Future<CatalogListing> listing(int id) async =>
      CatalogListingDto.fromJson(await client.get('/catalog/listings/$id'));
}
