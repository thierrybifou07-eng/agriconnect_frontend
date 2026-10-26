import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';
import 'package:agri_connect/features/supplier/presentation/controllers/lot_draft_controller.dart';
import '../../support/get_test_harness.dart';

class _SupplierRepository implements SupplierRepository {
  ApiFailure? createFailure;

  @override
  Future<SupplierLot> createLot(
    Map<String, Object?> fields,
    List<String> paths,
  ) async {
    final failure = createFailure;
    if (failure != null) throw failure;
    throw StateError('No lot configured');
  }

  @override
  Future<Paginated<SupplierCompensation>> compensations({
    int page = 1,
    int limit = 20,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteLot(int id) => throw UnimplementedError();

  @override
  Future<SupplierLot> lot(int id) => throw UnimplementedError();

  @override
  Future<Paginated<SupplierLot>> lots({
    String? status,
    int page = 1,
    int limit = 20,
  }) => throw UnimplementedError();

  @override
  Future<Paginated<SupplierPayout>> payouts({int page = 1, int limit = 20}) =>
      throw UnimplementedError();

  @override
  Future<SupplierLot> updateLot(int id, Map<String, Object?> fields) =>
      throw UnimplementedError();

  @override
  Future<SupplierLot> withdrawLot(int id, String reason) =>
      throw UnimplementedError();
}

void main() {
  setupGetTestHarness();
  late _SupplierRepository repository;
  late LotDraftController controller;

  setUp(() {
    repository = _SupplierRepository();
    controller = Get.put(LotDraftController(repository: repository));
  });

  test('validates product and quantity and price precision per step', () {
    expect(controller.validateStep(0), 'product');
    controller.product.value = _product();
    expect(controller.validateStep(0), isNull);

    controller.quantity.value = '1.2345';
    controller.agreedUnitPrice.value = '10';
    expect(controller.validateStep(1), 'quantity');
    controller.quantity.value = '1.234';
    controller.agreedUnitPrice.value = '10.001';
    expect(controller.validateStep(1), 'price');
    controller.agreedUnitPrice.value = '10.01';
    expect(controller.validateStep(1), isNull);
  });

  test('perishable product requires expiry and HUB requires hubId', () {
    _setBaseDraft(controller);
    expect(controller.validateStep(2), 'hub');
    controller.hub.value = const RefHub(
      id: 8,
      name: 'Hub',
      zoneId: 2,
      acceptsDropoff: true,
      acceptsPickup: true,
    );
    expect(controller.validateStep(2), isNull);
    _addOnePhoto(controller);
    expect(controller.validateStep(3), 'expiresAt');
    controller.expiresAt.value = DateTime.utc(2026, 10, 30);
    expect(controller.validateStep(3), isNull);
  });

  test('supplier site requires address and in-range coordinates', () {
    _setBaseDraft(controller);
    controller.selectStorage('SUPPLIER_SITE');
    expect(controller.validateStep(2), 'pickupAddress');
    controller.pickupAddress.value = 'Farm gate';
    controller.pickupLatitude.value = '90.1';
    controller.pickupLongitude.value = '0';
    expect(controller.validateStep(2), 'pickupLatitude');
    controller.pickupLatitude.value = '-90';
    controller.pickupLongitude.value = '180.1';
    expect(controller.validateStep(2), 'pickupLongitude');
    controller.pickupLongitude.value = '180';
    expect(controller.validateStep(2), isNull);
  });

  test('rejects no photos, six photos and files larger than 5 MB', () async {
    _setBaseDraft(controller);
    controller.hub.value = const RefHub(
      id: 8,
      name: 'Hub',
      zoneId: 2,
      acceptsDropoff: true,
      acceptsPickup: true,
    );
    controller.expiresAt.value = DateTime.utc(2026, 10, 30);
    expect(controller.validateStep(3), 'photos');

    final directory = await Directory.systemTemp.createTemp('lot-photos');
    try {
      final files = <XFile>[];
      for (var i = 0; i < 6; i++) {
        final file = File('${directory.path}\\photo-$i.jpg')
          ..writeAsBytesSync([1]);
        files.add(XFile(file.path));
      }
      expect(await controller.addPhotos(files), isFalse);
      expect(controller.photos, isEmpty);
      expect(await controller.addPhotos(files.take(5)), isTrue);
      expect(controller.validateStep(3), isNull);

      final tooLarge = File('${directory.path}\\too-large.jpg')
        ..writeAsBytesSync(List<int>.filled(5 * 1024 * 1024 + 1, 0));
      controller.photos.clear();
      expect(await controller.addPhotos([XFile(tooLarge.path)]), isFalse);
      expect(controller.validationError.value, 'photoSize');
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test(
    'builds only allowed HUB fields and uses site pickup fields instead',
    () {
      _setBaseDraft(controller);
      controller.hub.value = const RefHub(
        id: 8,
        name: 'Hub',
        zoneId: 2,
        acceptsDropoff: true,
        acceptsPickup: true,
      );
      controller.expiresAt.value = DateTime.utc(2026, 10, 30);
      _addOnePhoto(controller);
      final hubFields = controller.createFields();
      expect(hubFields.keys.toSet(), {
        'productId',
        'zoneId',
        'agreedUnitPrice',
        'quantity',
        'storageType',
        'hubId',
        'expiresAt',
      });

      controller.selectStorage('SUPPLIER_SITE');
      controller.pickupAddress.value = 'Farm gate';
      controller.pickupLatitude.value = '4.1';
      controller.pickupLongitude.value = '11.5';
      final siteFields = controller.createFields();
      expect(siteFields, containsPair('pickupAddress', 'Farm gate'));
      expect(siteFields, containsPair('pickupLatitude', 4.1));
      expect(siteFields, containsPair('pickupLongitude', 11.5));
      expect(siteFields, isNot(contains('hubId')));
    },
  );

  test('403 PROFILE_NOT_VERIFIED is kept as an API failure', () async {
    _setBaseDraft(controller);
    controller.hub.value = const RefHub(
      id: 8,
      name: 'Hub',
      zoneId: 2,
      acceptsDropoff: true,
      acceptsPickup: true,
    );
    controller.expiresAt.value = DateTime.utc(2026, 10, 30);
    _addOnePhoto(controller);
    repository.createFailure = const ApiFailure(
      status: 403,
      code: 'PROFILE_NOT_VERIFIED',
      message: 'Profile must be verified',
      fieldErrors: {},
      kind: ApiFailureKind.client,
    );
    final sent = await controller.submit();
    expect(sent, isFalse);
    final state = controller.submitState.value;
    expect(state, isA<Failure<SupplierLot>>());
    expect(
      (state as Failure<SupplierLot>).failure.isProfileNotVerified,
      isTrue,
    );
  });
}

void _setBaseDraft(LotDraftController controller) {
  controller.product.value = _product();
  controller.zone.value = const RefZone(id: 2, name: 'Zone');
  controller.quantity.value = '12.125';
  controller.agreedUnitPrice.value = '140.50';
}

void _addOnePhoto(LotDraftController controller) {
  final file = File('${Directory.systemTemp.path}\\supplier-photo.png')
    ..writeAsBytesSync([1]);
  controller.photos.add(XFile(file.path));
  addTearDown(() {
    if (file.existsSync()) file.deleteSync();
  });
}

RefProduct _product({bool perishable = true}) => RefProduct(
  id: 4,
  name: 'Tomato',
  isPerishable: perishable,
  category: const RefCategory(id: 1, code: 'VEG', label: 'Vegetables'),
  unit: const RefUnit(id: 2, code: 'KG', label: 'kg'),
);
