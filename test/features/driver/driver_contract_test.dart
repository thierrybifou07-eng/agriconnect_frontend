import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/driver/data/dto/driver_delivery_dto.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';

Map<String, dynamic> _fixture(String filename) =>
    jsonDecode(File('test/fixtures/api/$filename').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('available page matches the driver-safe delivery DTO', () {
    final page = Paginated<DriverDelivery>.fromJson(
      _fixture('driver_available_page.json'),
      DriverDeliveryDto.fromJson,
    );
    final delivery = page.items.single;

    expect(page.total, 1);
    expect(delivery.id, 37);
    expect(delivery.status, DeliveryStatus.pending);
    expect(delivery.distanceKm, 4.8);
    expect(delivery.items.single.quantity, 12.5);
    expect(delivery.buyer?.fullName, 'Amina N.');
    expect(delivery.failureReason, isNull);
  });

  test('delivery contract allows a missing buyer and parses status dates', () {
    final json = _fixture('driver_delivery.json')
      ..['buyer'] = null
      ..['status'] = 'PICKED_UP'
      ..['acceptedAt'] = '2026-10-26T10:00:00.000Z'
      ..['pickedUpAt'] = '2026-10-26T10:15:00.000Z';
    final delivery = DriverDeliveryDto.fromJson(json);

    expect(delivery.buyer, isNull);
    expect(delivery.status, DeliveryStatus.pickedUp);
    expect(delivery.acceptedAt, DateTime.utc(2026, 10, 26, 10));
    expect(delivery.pickedUpAt, DateTime.utc(2026, 10, 26, 10, 15));
  });
}
