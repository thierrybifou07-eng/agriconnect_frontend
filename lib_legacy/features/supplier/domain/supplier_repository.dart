import 'package:agri_connect/core/media/prepared_photo.dart';
import 'package:agri_connect/features/supplier/domain/supplier_order.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';

/// User-provided input used to create or update a product.
class ProductDraft {
  const ProductDraft({
    required this.name,
    this.description = '',
    required this.price,
    required this.stockQuantity,
    required this.unit,
    this.photos = const [],
    this.imageUrl,
  });

  final String name;
  final String description;
  final int price;
  final int stockQuantity;
  final String unit;
  final List<PreparedPhoto> photos;

  /// Bundled demo asset or Cloudinary URL attached to the product.
  final String? imageUrl;
}

/// Data access contract of the supplier workspace.
///
/// Swapping the demo implementation for a remote one backed by the real API
/// must be the only change required to go live.
abstract interface class SupplierRepository {
  Future<List<Product>> fetchProducts();

  /// Saves a declaration and returns its stored state.
  ///
  /// [declaration] carries the supplier's explicit choice between keeping the
  /// record as a draft and submitting it for review. The supplier can only
  /// ever ask for [DeclarationStatus.draft] or
  /// [DeclarationStatus.pendingReview]; every later state is owned by the
  /// platform and is never produced from this app.
  Future<Product> saveProduct({
    String? productId,
    required ProductDraft draft,
    required DeclarationStatus declaration,
  });

  Future<List<SupplierOrder>> fetchOrders();

  /// Confirms a pending order and returns its refreshed state.
  ///
  /// Confirmation is not atomic on the server: a failure leaves the order
  /// untouched, so callers must re-read the real status before retrying
  /// instead of assuming the previous attempt succeeded.
  Future<SupplierOrder> confirmOrder(String orderId);
}
