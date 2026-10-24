/// Lifecycle of a delivery handled by a driver, from pickup to the client.
enum DriverDeliveryStatus { pickUp, inTransit, delivered }

/// Statuses a delivery goes through on the road, in order.
///
/// The driver contract holds no status outside this list: there is no way to
/// send a delivery backwards and none to cancel it, so the progression is the
/// enum itself and a new status has to be placed in it deliberately.
const List<DriverDeliveryStatus> driverDeliverySteps = [
  DriverDeliveryStatus.pickUp,
  DriverDeliveryStatus.inTransit,
  DriverDeliveryStatus.delivered,
];

extension DriverDeliveryStatusProgressX on DriverDeliveryStatus {
  /// Position in [driverDeliverySteps].
  int? get progressStep {
    final index = driverDeliverySteps.indexOf(this);
    return index < 0 ? null : index;
  }

  /// The only status the driver may move to from here, `null` once over.
  ///
  /// The action buttons are built from this, so the screen can only ever offer
  /// a transition the progression actually contains.
  DriverDeliveryStatus? get nextStatus => switch (this) {
    DriverDeliveryStatus.pickUp => DriverDeliveryStatus.inTransit,
    DriverDeliveryStatus.inTransit => DriverDeliveryStatus.delivered,
    DriverDeliveryStatus.delivered => null,
  };
}

/// A single product line carried by a delivery.
class DriverDeliveryItem {
  const DriverDeliveryItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    this.unit,
  });

  final String productId;
  final String productName;
  final int quantity;
  final String? unit;
}

/// A delivery assigned to the driver: an order to pick up from a farmer and
/// drop off at a customer address.
class DriverDelivery {
  const DriverDelivery({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.pickupLocation,
    required this.deliveryAddress,
    required this.items,
    required this.status,
    required this.scheduledAt,
    required this.createdAt,
    this.note,
  });

  final String id;

  /// The original marketplace order this delivery fulfils.
  final String orderId;

  final String customerName;
  final String customerPhone;

  /// Place where the goods are collected (farm, warehouse, market).
  final String pickupLocation;

  final String deliveryAddress;
  final List<DriverDeliveryItem> items;
  final DriverDeliveryStatus status;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final String? note;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isPickUp => status == DriverDeliveryStatus.pickUp;

  bool get isInTransit => status == DriverDeliveryStatus.inTransit;

  bool get isDelivered => status == DriverDeliveryStatus.delivered;

  /// True once the progression is over: nothing can be done to the delivery.
  bool get isClosed => isDelivered;

  /// The status this delivery may move to next, `null` when it is closed.
  DriverDeliveryStatus? get nextStatus => status.nextStatus;

  DriverDelivery copyWith({DriverDeliveryStatus? status}) => DriverDelivery(
    id: id,
    orderId: orderId,
    customerName: customerName,
    customerPhone: customerPhone,
    pickupLocation: pickupLocation,
    deliveryAddress: deliveryAddress,
    items: items,
    status: status ?? this.status,
    scheduledAt: scheduledAt,
    createdAt: createdAt,
    note: note,
  );
}
