import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';

abstract interface class CatalogRepository {
  Future<List<CatalogCategory>> categories();
  Future<Paginated<CatalogListing>> listings({
    int? categoryId,
    int? zoneId,
    String? query,
    String? sort,
    required int page,
    required int limit,
  });
  Future<CatalogListing> listing(int id);
}

abstract interface class OrdersRepository {
  Future<Paginated<BuyerOrder>> orders({required int page, required int limit});
  Future<BuyerOrder> order(int id);
  Future<BuyerOrder> confirm(int id);
  Future<BuyerOrder> cancel(int id, {String? reason});
}
