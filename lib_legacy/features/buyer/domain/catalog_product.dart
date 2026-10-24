import 'package:agri_connect/core/media/prepared_photo.dart';

/// Category of a catalog product, used to browse and filter the marketplace.
enum CatalogCategory { cereals, vegetables, fruits, tubers, spices }

/// Delivery areas exposed by the demo catalog.
abstract final class CatalogLocations {
  static const List<String> all = [
    'Abidjan',
    'Yamoussoukro',
    'Bouaké',
    'Korhogo',
    'San-Pedro',
    'Daloa',
  ];
}

/// A product offered on the buyer catalog.
class BuyerProduct {
  const BuyerProduct({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.stockQuantity,
    required this.unit,
    required this.category,
    required this.location,
    required this.sellerName,
    this.photos = const [],
    this.imageUrl,
    this.published = false,
  });

  final String id;
  final String name;
  final String description;

  /// Unit price in FCFA.
  final int price;

  /// Current available stock in [unit].
  final int stockQuantity;

  final String unit;

  final CatalogCategory category;

  /// Commune or region where the seller operates.
  final String location;

  final String sellerName;

  /// Pictures attached by the supplier, prepared for a future upload.
  final List<PreparedPhoto> photos;

  /// Remote or bundled picture reference.
  ///
  /// When the backend starts serving Cloudinary URLs, products will carry a
  /// `https://` reference here and [ProductImage] will load it over the
  /// network seamlessly. A bundled asset path is used by the demo data.
  final String? imageUrl;

  /// Whether the listing is cleared for the public catalog.
  ///
  /// Defaults to `false`: a [BuyerProduct] only reaches buyers when a catalog
  /// source explicitly sets `published: true`. This fail-closed default makes an
  /// omission hide the listing instead of leaking a supplier declaration into
  /// the public catalog. The backend remains the sole authority on publication
  /// in production.
  final bool published;

  bool get inStock => stockQuantity > 0;
}
