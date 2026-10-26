import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/buyer/data/catalog_api.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/domain/buyer_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._api);

  final CatalogApi _api;

  @override
  Future<List<CatalogCategory>> categories() => _parse(_api.categories);

  @override
  Future<Paginated<CatalogListing>> listings({
    int? categoryId,
    int? zoneId,
    String? query,
    String? sort,
    required int page,
    required int limit,
  }) => _parse(
    () => _api.listings(
      categoryId: categoryId,
      zoneId: zoneId,
      query: query,
      sort: sort,
      page: page,
      limit: limit,
    ),
  );

  @override
  Future<CatalogListing> listing(int id) => _parse(() => _api.listing(id));

  Future<T> _parse<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FormatException catch (error) {
      throw ApiFailure(
        status: null,
        code: null,
        message: error.message,
        fieldErrors: const {},
        kind: ApiFailureKind.server,
      );
    }
  }
}
