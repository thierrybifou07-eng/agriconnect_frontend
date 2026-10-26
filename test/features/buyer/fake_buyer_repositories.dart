import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/domain/buyer_repository.dart';
import 'package:agri_connect/shared/domain/order_status.dart';

class FakeCatalogRepository implements CatalogRepository {
  final List<
    ({
      int? categoryId,
      int? zoneId,
      String? query,
      String? sort,
      int page,
      int limit,
    })
  >
  listingRequests = [];
  final List<CatalogListing> listingsByPage = [];
  int totalListings = 0;

  @override
  Future<List<CatalogCategory>> categories() async => const [];

  @override
  Future<CatalogListing> listing(int id) async => _listing;

  @override
  Future<Paginated<CatalogListing>> listings({
    int? categoryId,
    int? zoneId,
    String? query,
    String? sort,
    required int page,
    required int limit,
  }) async {
    listingRequests.add((
      categoryId: categoryId,
      zoneId: zoneId,
      query: query,
      sort: sort,
      page: page,
      limit: limit,
    ));
    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, listingsByPage.length);
    final items = start >= listingsByPage.length
        ? <CatalogListing>[]
        : listingsByPage.sublist(start, end);
    return Paginated(
      items: items,
      page: page,
      limit: limit,
      total: totalListings,
    );
  }
}

class FakeOrdersRepository implements OrdersRepository {
  final List<(int page, int limit)> requestedPages = [];
  final List<int> loadedOrderIds = [];
  ApiFailure? confirmFailure;
  BuyerOrder? confirmResult;
  BuyerOrder? cancelResult;
  int detailRequests = 0;
  BuyerOrder detailResult = _quotedOrder;

  @override
  Future<BuyerOrder> cancel(int id, {String? reason}) async =>
      cancelResult ?? detailResult;

  @override
  Future<BuyerOrder> confirm(int id) async {
    if (confirmFailure != null) throw confirmFailure!;
    return confirmResult ?? detailResult;
  }

  @override
  Future<BuyerOrder> order(int id) async {
    detailRequests++;
    return detailResult;
  }

  @override
  Future<Paginated<BuyerOrder>> orders({
    required int page,
    required int limit,
  }) async {
    requestedPages.add((page, limit));
    return Paginated(
      items: loadedOrderIds.contains(page) ? [_quotedOrder] : const [],
      page: page,
      limit: limit,
      total: loadedOrderIds.length,
    );
  }
}

const CatalogListing _listing = CatalogListing(
  id: 1,
  reference: 'ANN-DEMO-0001',
  title: 'Riz local',
  category: ListingReference(code: 'CEREALS', label: 'Céréales'),
  unit: ListingReference(code: 'KG', label: 'kg'),
  unitPrice: 1500,
  quantityAvailable: 100,
  zone: ListingZone(id: 1, name: 'Centre', city: 'Yaoundé'),
  images: [],
);

final BuyerOrder _quotedOrder = BuyerOrder(
  id: 42,
  orderNumber: 'CMD-2026-00042',
  status: OrderStatus.quoted,
  deliveryMode: 'HUB_PICKUP',
  items: [],
  subtotal: 15750,
  buyerFee: 500,
  deliveryFee: 0,
  total: 16250,
  reservedUntil: null,
  createdAt: DateTime.utc(2026, 12, 20),
);
