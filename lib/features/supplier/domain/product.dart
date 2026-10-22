import 'package:agri_connect/core/media/prepared_photo.dart';

/// Availability of a product, derived from its available stock.
///
/// This is deliberately distinct from [DeclarationStatus]: stock tells whether
/// the goods are available, while the declaration status tells whether the
/// platform has cleared the product for the public catalog. A product can be in
/// stock and still not be published.
enum ProductStatus { onSale, outOfStock }

/// Review state of a supplier *declaration*.
///
/// A declaration is the internal record a supplier submits; it is never the
/// public listing itself. Only [approvedForPublication] may ever surface as a
/// buyer listing, and the demo keeps the two data sources fully separate.
///
/// DEMO STATES: the demo stores and displays these states locally, in memory.
/// No real review, validation or publication happens here, and nothing in this
/// app enforces authorization or protects data across users. In production the
/// backend owns every transition and is the only authority on publication.
enum DeclarationStatus {
  draft,
  pendingReview,
  additionalInfoRequired,
  underDiscussion,
  approvedForPublication,
  rejected;

  bool get isApprovedForPublication =>
      this == DeclarationStatus.approvedForPublication;
}

/// Catalog availability of a reviewed product.
///
/// Approval and publication are separate decisions. A product only becomes
/// visible to buyers after its publication state is explicitly [published].
enum ProductPublicationStatus { unpublished, published, suspended, archived }

/// Supported sellable units.
abstract final class ProductUnits {
  static const List<String> all = ['kg', 'sac', 'litre', 'pièce'];
}

/// A product *declaration* owned by a supplier.
///
/// This is the internal model of the supplier workspace, not the public
/// listing: the buyer catalog is served by a separate model and data source
/// and never reads a declaration directly.
class Product {
  const Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.stockQuantity,
    required this.unit,
    this.photos = const [],
    this.imageUrl,
    this.createdAt,
    this.declaration = DeclarationStatus.draft,
    this.publicationStatus = ProductPublicationStatus.unpublished,
  });

  final String id;
  final String name;
  final String description;

  /// Unit price in FCFA.
  final int price;

  /// Current available stock in [unit].
  final int stockQuantity;

  final String unit;

  /// Pictures attached to the product, prepared for a future upload.
  final List<PreparedPhoto> photos;

  /// Remote or bundled picture reference.
  ///
  /// Supports both a bundled demo asset path and a future Cloudinary `https://`
  /// URL, so switching to the real backend requires no UI change.
  final String? imageUrl;

  final DateTime? createdAt;

  /// Review state of the declaration. Defaults to [DeclarationStatus.draft]:
  /// a declaration never becomes public on its own.
  final DeclarationStatus declaration;

  /// Publication state, independently controlled from declaration review.
  final ProductPublicationStatus publicationStatus;

  bool get isPublished =>
      declaration.isApprovedForPublication &&
      publicationStatus == ProductPublicationStatus.published;

  ProductStatus get status =>
      stockQuantity > 0 ? ProductStatus.onSale : ProductStatus.outOfStock;
}
