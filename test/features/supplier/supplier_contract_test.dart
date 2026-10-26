import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/supplier/data/supplier_repository_impl.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('supplier lot DTO matches live supplier view', () {
    final lot = SupplierLot.fromJson(_fixture('supplier_lot.json'));

    expect(lot.lotCode, 'LOT-DEMO-AVAILABLE');
    expect(lot.product.category.code, 'DEMO_LEGUMES');
    expect(lot.product.unit.label, 'Caisse démo');
    expect(lot.agreedUnitPrice, 1000.0);
    expect(lot.quantityAvailable, 100.0);
    expect(lot.status, LotStatus.available);
  });

  test('lot, payout and compensation pages parse the real page shape', () {
    final lots = Paginated<SupplierLot>.fromJson(
      _fixture('supplier_lots_page.json'),
      SupplierLot.fromJson,
    );
    final payouts = Paginated<SupplierPayout>.fromJson(
      _fixture('payouts_page.json'),
      SupplierPayout.fromJson,
    );
    final compensations = Paginated<SupplierCompensation>.fromJson(
      _fixture('compensations_page.json'),
      SupplierCompensation.fromJson,
    );

    expect(lots.total, 1);
    expect(lots.items.single.zone.name, 'Yaoundé Centre');
    expect(payouts.total, 0);
    expect(compensations.total, 0);
  });

  test('lifecycle actions match the allowed status table', () {
    final json = _fixture('supplier_lot.json');
    for (final status in LotStatus.values) {
      final lot = SupplierLot.fromJson({...json, 'status': status.apiValue});
      expect(lot.canEdit, status == LotStatus.pendingValidation);
      expect(
        lot.canDelete,
        status == LotStatus.pendingValidation || status == LotStatus.rejected,
      );
      expect(lot.canWithdraw, status == LotStatus.available);
    }
    final reserved = SupplierLot.fromJson({...json, 'quantityReserved': 1});
    expect(reserved.canWithdraw, isFalse);
  });

  test(
    'multipart builder repeats the images field and adds no extra fields',
    () {
      final file = File('${Directory.systemTemp.path}\\supplier-photo-test.jpg')
        ..writeAsBytesSync([1, 2, 3]);
      try {
        final form = SupplierLotMultipartBuilder.build(
          {'productId': 4, 'quantity': 2.5, 'storageType': 'HUB'},
          [file.path, file.path],
        );
        expect(form.fields.map((field) => field.key), [
          'productId',
          'quantity',
          'storageType',
        ]);
        expect(form.files.map((entry) => entry.key), ['images', 'images']);
      } finally {
        file.deleteSync();
      }
    },
  );
}
