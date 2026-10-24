/// Lifecycle of an order followed by its buyer.
enum BuyerOrderStatus { pending, confirmed, inTransit, delivered, cancelled }

/// Statuses an order goes through on its way to the buyer, in order.
///
/// [BuyerOrderStatus.cancelled] is deliberately absent: it leaves the delivery
/// progression instead of being a step of it.
const List<BuyerOrderStatus> buyerOrderTrackingSteps = [
  BuyerOrderStatus.pending,
  BuyerOrderStatus.confirmed,
  BuyerOrderStatus.inTransit,
  BuyerOrderStatus.delivered,
];

/// Where a status stands in the delivery progression.
///
/// The UI groups and filters orders from these, so a new status only has to be
/// classified once here.
extension BuyerOrderStatusProgressX on BuyerOrderStatus {
  /// True while the order is still moving towards the buyer.
  bool get isOngoing =>
      this == BuyerOrderStatus.pending ||
      this == BuyerOrderStatus.confirmed ||
      this == BuyerOrderStatus.inTransit;

  /// True once the progression is over, whether the order arrived or not.
  bool get isClosed => !isOngoing;

  /// Position in [buyerOrderTrackingSteps], or `null` when the order left it.
  int? get trackingStep {
    final index = buyerOrderTrackingSteps.indexOf(this);
    return index < 0 ? null : index;
  }
}

/// A single product line inside a buyer order.
class BuyerOrderItem {
  const BuyerOrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String productName;

  /// Unit price in FCFA at order time.
  final int unitPrice;

  final int quantity;

  int get total => unitPrice * quantity;
}

/// Driver assigned to an order, enabling the delivery contact feature.
class DriverInfo {
  const DriverInfo({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.vehicleLabel,
  });

  final String id;
  final String fullName;

  /// Phone number the buyer can use to reach the driver.
  final String phone;

  /// Human-readable vehicle description (type and registration).
  final String vehicleLabel;
}

/// An order placed by the current buyer.
class BuyerOrder {
  const BuyerOrder({
    required this.id,
    required this.items,
    required this.status,
    required this.deliveryAddress,
    required this.buyerPhone,
    required this.createdAt,
    this.deliveryNote,
    this.driver,
  });

  final String id;
  final List<BuyerOrderItem> items;
  final BuyerOrderStatus status;
  final String deliveryAddress;
  final String buyerPhone;
  final String? deliveryNote;
  final DateTime createdAt;

  /// Assigned once the order enters delivery.
  final DriverInfo? driver;

  int get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  /// How many units the order holds, across every line.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get hasDriver => driver != null;

  /// Products ordered, joined for the places that only have room for a summary.
  ///
  /// Empty when the order carries no line, so callers never index into an empty
  /// list.
  String get productSummary => items.map((item) => item.productName).join(', ');
}
