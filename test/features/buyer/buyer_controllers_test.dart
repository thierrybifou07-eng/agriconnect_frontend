import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/presentation/controllers/catalog_controller.dart';
import 'package:agri_connect/features/buyer/presentation/controllers/orders_controller.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';
import 'package:agri_connect/shared/domain/order_status.dart';
import 'fake_buyer_repositories.dart';

void main() {
  test('catalog sends exact filters and loads later pages', () async {
    final repository = FakeCatalogRepository()
      ..listingsByPage.addAll(List.generate(3, (_) => _catalogListing()))
      ..totalListings = 3;
    final controller = CatalogController(repository: repository, limit: 2)
      ..selectedCategoryId.value = 8
      ..selectedZone.value = const RefZone(id: 5, name: 'Centre')
      ..query.value = 'maïs'
      ..sort.value = 'expiry';

    await controller.loadFirst();
    expect(repository.listingRequests.single, (
      categoryId: 8,
      zoneId: 5,
      query: 'maïs',
      sort: 'expiry',
      page: 1,
      limit: 2,
    ));
    expect(
      (controller.state.value as Success<List<CatalogListing>>).data,
      hasLength(2),
    );

    await controller.loadMore();
    expect(repository.listingRequests.last.page, 2);
    expect(
      (controller.state.value as Success<List<CatalogListing>>).data,
      hasLength(3),
    );
  });

  test(
    'confirm success refreshes orders and profile 403 is returned',
    () async {
      final repository = FakeOrdersRepository();
      var refreshes = 0;
      final controller = BuyerOrderDetailController(
        id: 42,
        repository: repository,
        refreshOrders: () async => refreshes++,
      );
      await controller.load();

      expect(await controller.confirm(), isNull);
      expect(refreshes, 1);

      repository.confirmFailure = const ApiFailure(
        status: 403,
        code: 'PROFILE_NOT_VERIFIED',
        message: 'Profile not verified',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
      expect((await controller.confirm())?.isProfileNotVerified, isTrue);
      expect(refreshes, 1);
      controller.onClose();
    },
  );

  test(
    'state conflict refreshes the order before returning the failure',
    () async {
      final repository = FakeOrdersRepository()
        ..confirmFailure = const ApiFailure(
          status: 409,
          code: 'INVALID_STATE_TRANSITION',
          message: 'Invalid state transition',
          fieldErrors: {},
          kind: ApiFailureKind.client,
        );
      final controller = BuyerOrderDetailController(
        id: 42,
        repository: repository,
        refreshOrders: () async {},
      );
      await controller.load();

      expect((await controller.confirm())?.isStateConflict, isTrue);
      expect(repository.detailRequests, 2);
      controller.onClose();
    },
  );

  test(
    'quote countdown uses the injected clock and reloads on expiry',
    () async {
      var now = DateTime.utc(2026, 12, 20, 10);
      final repository = FakeOrdersRepository()
        ..detailResult = _quotedOrder(
          reservedUntil: DateTime.utc(2026, 12, 20, 15, 12),
        );
      final controller = BuyerOrderDetailController(
        id: 42,
        repository: repository,
        refreshOrders: () async {},
        clock: () => now,
      );

      await controller.load();
      expect(controller.countdown.value, '5h 12');
      now = DateTime.utc(2026, 12, 20, 16);
      controller.refreshCountdown();
      await Future<void>.delayed(Duration.zero);

      expect(controller.expired.value, isTrue);
      expect(repository.detailRequests, 2);
      controller.onClose();
    },
  );
}

CatalogListing _catalogListing() => const CatalogListing(
  id: 1,
  reference: 'ANN-1',
  title: 'Maïs',
  category: ListingReference(code: 'CEREALS', label: 'Céréales'),
  unit: ListingReference(code: 'KG', label: 'kg'),
  unitPrice: 300,
  quantityAvailable: 4.5,
  zone: ListingZone(id: 5, name: 'Centre', city: 'Yaoundé'),
  images: [],
);

BuyerOrder _quotedOrder({DateTime? reservedUntil}) => BuyerOrder(
  id: 42,
  orderNumber: 'CMD-42',
  status: OrderStatus.quoted,
  deliveryMode: 'HUB_PICKUP',
  items: const [],
  subtotal: 100,
  buyerFee: 10,
  deliveryFee: 0,
  total: 110,
  reservedUntil: reservedUntil,
  createdAt: DateTime.utc(2026, 12, 20),
);
