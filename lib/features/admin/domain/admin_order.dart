import 'package:flutter/foundation.dart';

/// Progression of an order inside the admin order-management workspace.
enum AdminOrderStatus { pending, confirmed, inTransit, delivered, cancelled }

extension AdminOrderStatusX on AdminOrderStatus {
  String keyName() => switch (this) {
    AdminOrderStatus.pending => 'pending',
    AdminOrderStatus.confirmed => 'confirmed',
    AdminOrderStatus.inTransit => 'inTransit',
    AdminOrderStatus.delivered => 'delivered',
    AdminOrderStatus.cancelled => 'cancelled',
  };

  bool get isOpen =>
      this == AdminOrderStatus.pending ||
      this == AdminOrderStatus.confirmed ||
      this == AdminOrderStatus.inTransit;

  bool get isFinished =>
      this == AdminOrderStatus.delivered || this == AdminOrderStatus.cancelled;
}

/// One order in its entirety, as reviewed by the admin.
///
/// [items] is a lightweight snapshot of line items (product name, quantity,
/// unit price); the admin uses [buyerId]/[sellerId] to open the accountable
/// accounts and [deliveryId] (when non-null) to inspect the linked delivery.
@immutable
class AdminOrder {
  const AdminOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.amount,
    required this.itemCount,
    required this.placedAt,
    this.deliveryId,
    this.deliveryStatus,
    this.items = const [],
  });

  final String id;
  final String orderNumber;
  final AdminOrderStatus status;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final double amount;
  final int itemCount;
  final DateTime placedAt;

  /// Linked delivery when the order requires transportation.
  final String? deliveryId;
  final String? deliveryStatus;
  final List<AdminOrderItem> items;
}

@immutable
class AdminOrderItem {
  const AdminOrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  final String productId;
  final String name;
  final int quantity;
  final String unit;
  final double unitPrice;

  double get total => unitPrice * quantity;
}
