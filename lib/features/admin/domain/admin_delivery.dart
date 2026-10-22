import 'package:flutter/foundation.dart';

/// Lifecycle of a delivery in the admin delivery-supervision workspace.
enum AdminDeliveryStatus { pickUp, inTransit, delivered, cancelled }

extension AdminDeliveryStatusX on AdminDeliveryStatus {
  String keyName() => switch (this) {
    AdminDeliveryStatus.pickUp => 'pickUp',
    AdminDeliveryStatus.inTransit => 'inTransit',
    AdminDeliveryStatus.delivered => 'delivered',
    AdminDeliveryStatus.cancelled => 'cancelled',
  };

  bool get isActive =>
      this == AdminDeliveryStatus.pickUp ||
      this == AdminDeliveryStatus.inTransit;
}

/// Resolves a persisted delivery-status key back to its enum value, or `null`
/// when the key is not one the workspace knows.
///
/// An [AdminOrder] carries the linked delivery's status as the raw key it was
/// stored with; the caller resolves it here to name it in the reader's language
/// instead of printing the code.
AdminDeliveryStatus? adminDeliveryStatusByKey(String? key) {
  if (key == null) return null;
  for (final status in AdminDeliveryStatus.values) {
    if (status.keyName() == key) return status;
  }
  return null;
}

/// A delivery as supervised by the admin.
///
/// Mirrors the Driver workspace contract: a [driver] only ever accepts a
/// delivery that is available — the admin never auto-assigns. The admin
/// supervises: progress, distance, fees schemas, origin/destination and the
/// accountability trail (orderId, driverId).
@immutable
class AdminDelivery {
  const AdminDelivery({
    required this.id,
    required this.orderId,
    required this.status,
    required this.driverId,
    required this.driverName,
    required this.pickupLabel,
    required this.destinationLabel,
    required this.distanceKm,
    required this.baseFee,
    required this.totalFee,
    required this.scheduledAt,
    this.startedAt,
    this.completedAt,
  });

  final String id;
  final String orderId;
  final AdminDeliveryStatus status;
  final String driverId;
  final String driverName;
  final String pickupLabel;
  final String destinationLabel;
  final double distanceKm;
  final double baseFee;
  final double totalFee;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
}
