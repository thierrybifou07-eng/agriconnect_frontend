import 'package:agri_connect/shared/domain/delivery_status.dart';

class DriverBuyer {
  const DriverBuyer({
    required this.firstname,
    required this.lastname,
    required this.phone,
  });

  final String firstname;
  final String lastname;
  final String phone;

  String get fullName => '$firstname $lastname'.trim();
}

class DriverDeliveryItem {
  const DriverDeliveryItem({
    required this.productName,
    required this.categoryName,
    required this.quantity,
  });

  final String productName;
  final String categoryName;
  final double quantity;
}

class DriverDelivery {
  const DriverDelivery({
    required this.id,
    required this.status,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.distanceKm,
    required this.items,
    this.buyer,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.failureReason,
  });

  final int id;
  final DeliveryStatus status;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String dropoffAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final double distanceKm;
  final DriverBuyer? buyer;
  final List<DriverDeliveryItem> items;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? failureReason;

  DriverDelivery copyWith({DeliveryStatus? status}) => DriverDelivery(
    id: id,
    status: status ?? this.status,
    pickupAddress: pickupAddress,
    pickupLatitude: pickupLatitude,
    pickupLongitude: pickupLongitude,
    dropoffAddress: dropoffAddress,
    dropoffLatitude: dropoffLatitude,
    dropoffLongitude: dropoffLongitude,
    distanceKm: distanceKm,
    buyer: buyer,
    items: items,
    acceptedAt: acceptedAt,
    pickedUpAt: pickedUpAt,
    deliveredAt: deliveredAt,
    failureReason: failureReason,
  );
}
