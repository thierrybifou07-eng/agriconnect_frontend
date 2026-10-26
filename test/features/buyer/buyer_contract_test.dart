import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/buyer/data/dto/buyer_dto.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/shared/domain/order_status.dart';

Map<String, dynamic> _fixture(String filename) =>
    jsonDecode(File('test/fixtures/api/$filename').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('catalog listings page matches the buyer-safe listing DTO', () {
    final page = Paginated<CatalogListing>.fromJson(
      _fixture('catalog_listings_page.json'),
      CatalogListingDto.fromJson,
    );

    expect(page.total, 1);
    expect(page.items.single.reference, 'ANN-DEMO-0001');
    expect(page.items.single.unitPrice, 1500.0);
    expect(page.items.single.quantityAvailable, 100.0);
    expect(page.items.single.zone.city, 'Yaoundé');
  });

  test('catalog listing detail preserves image paths and quality grade', () {
    final listing = CatalogListingDto.fromJson(
      _fixture('catalog_listing_detail.json'),
    );

    expect(listing.images, ['/uploads/listings/riz-local.jpg']);
    expect(listing.qualityGrade, 'A');
    expect(listing.description, 'Riz récolté localement.');
  });

  test(
    'quoted order DTO keeps server-provided amounts and double quantities',
    () {
      final order = BuyerOrderDto.fromJson(_fixture('order_buyer_quoted.json'));

      expect(order.status, OrderStatus.quoted);
      expect(order.total, 16250.0);
      expect(order.subtotal, 15750.0);
      expect(order.items.single.quantity, 10.5);
      expect(order.items.single.lineTotal, 15750.0);
      expect(order.pickup?.address, '1 avenue de la Gare');
      expect(order.reservedUntil, isNotNull);
    },
  );
}
