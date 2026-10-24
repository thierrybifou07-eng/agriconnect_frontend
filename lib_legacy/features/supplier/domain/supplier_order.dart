/// Lifecycle of an order received by a supplier.
enum OrderStatus { pending, confirmed, cancelled }

/// A single product line inside an order.
class OrderItem {
  const OrderItem({
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

/// An order received by a supplier.
class SupplierOrder {
  const SupplierOrder({
    required this.id,
    required this.buyerName,
    required this.buyerEmail,
    required this.items,
    required this.status,
    required this.createdAt,
    this.buyerPhone,
  });

  final String id;
  final String buyerName;
  final String buyerEmail;
  final String? buyerPhone;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;

  int get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  bool get isPending => status == OrderStatus.pending;

  SupplierOrder copyWith({OrderStatus? status}) => SupplierOrder(
    id: id,
    buyerName: buyerName,
    buyerEmail: buyerEmail,
    buyerPhone: buyerPhone,
    items: items,
    status: status ?? this.status,
    createdAt: createdAt,
  );
}
