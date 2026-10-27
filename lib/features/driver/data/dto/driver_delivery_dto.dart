import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';

abstract final class DriverDeliveryDto {
  static DriverDelivery fromJson(dynamic json) {
    final map = _object(json, 'delivery');
    final rawItems = map['items'];
    if (rawItems is! List) {
      throw const FormatException('delivery.items must be a list');
    }
    return DriverDelivery(
      id: _integer(map['id'], 'delivery.id'),
      status: DeliveryStatus.fromApi(map['status']),
      pickupAddress: _string(map['pickupAddress'], 'delivery.pickupAddress'),
      pickupLatitude: _double(map['pickupLatitude'], 'delivery.pickupLatitude'),
      pickupLongitude: _double(
        map['pickupLongitude'],
        'delivery.pickupLongitude',
      ),
      dropoffAddress: _string(map['dropoffAddress'], 'delivery.dropoffAddress'),
      dropoffLatitude: _double(
        map['dropoffLatitude'],
        'delivery.dropoffLatitude',
      ),
      dropoffLongitude: _double(
        map['dropoffLongitude'],
        'delivery.dropoffLongitude',
      ),
      distanceKm: _double(map['distanceKm'], 'delivery.distanceKm'),
      buyer: _nullableObject(map['buyer'], 'delivery.buyer', (buyer) {
        return DriverBuyer(
          firstname: _string(buyer['firstname'], 'buyer.firstname'),
          lastname: _string(buyer['lastname'], 'buyer.lastname'),
          phone: _string(buyer['phone'], 'buyer.phone'),
        );
      }),
      items: List<DriverDeliveryItem>.unmodifiable(
        rawItems.map((item) {
          final itemMap = _object(item, 'delivery item');
          return DriverDeliveryItem(
            productName: _string(
              itemMap['productName'],
              'delivery item.productName',
            ),
            categoryName: _string(
              itemMap['categoryName'],
              'delivery item.categoryName',
            ),
            quantity: _double(itemMap['quantity'], 'delivery item.quantity'),
          );
        }),
      ),
      acceptedAt: _date(map['acceptedAt'], 'delivery.acceptedAt'),
      pickedUpAt: _date(map['pickedUpAt'], 'delivery.pickedUpAt'),
      deliveredAt: _date(map['deliveredAt'], 'delivery.deliveredAt'),
      failureReason: _nullableString(map['failureReason']),
    );
  }

  static Map<String, dynamic> _object(Object? value, String name) {
    if (value is! Map) throw FormatException('$name must be an object');
    return Map<String, dynamic>.from(value);
  }

  static T? _nullableObject<T>(
    Object? value,
    String name,
    T Function(Map<String, dynamic>) parse,
  ) {
    if (value == null) return null;
    return parse(_object(value, name));
  }

  static String _string(Object? value, String name) {
    if (value is String) return value;
    throw FormatException('$name must be a string');
  }

  static String? _nullableString(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    throw const FormatException('Optional delivery text must be a string');
  }

  static int _integer(Object? value, String name) {
    if (value is int) return value;
    if (value is num && value == value.toInt()) return value.toInt();
    throw FormatException('$name must be an integer');
  }

  static double _double(Object? value, String name) {
    if (value is num) return value.toDouble();
    throw FormatException('$name must be numeric');
  }

  static DateTime? _date(Object? value, String name) {
    if (value == null) return null;
    if (value is String) {
      final date = DateTime.tryParse(value);
      if (date != null) return date.toUtc();
    }
    throw FormatException('$name must be an ISO 8601 date or null');
  }
}
