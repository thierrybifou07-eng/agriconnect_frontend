import 'package:agri_connect/features/buyer/domain/buyer_order.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';

/// Buyer-provided input used to place an order.
class PlaceOrderRequest {
  const PlaceOrderRequest({
    required this.deliveryAddress,
    required this.buyerPhone,
    this.deliveryNote,
    required this.items,
  });

  final String deliveryAddress;
  final String buyerPhone;
  final String? deliveryNote;
  final List<BuyerOrderItem> items;
}

/// Data access contract of the buyer workspace.
///
/// Swapping the demo implementation for a remote one backed by the real API
/// must be the only change required to go live.
abstract interface class BuyerRepository {
  Future<List<BuyerProduct>> fetchCatalog();

  Future<List<BuyerOrder>> fetchOrders();

  /// Places a new order and returns its created state.
  Future<BuyerOrder> placeOrder(PlaceOrderRequest request);
}
