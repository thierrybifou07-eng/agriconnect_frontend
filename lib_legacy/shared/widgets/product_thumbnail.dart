import 'package:flutter/material.dart';

import 'package:agri_connect/core/media/product_image.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';

/// Square preview of a product picture.
///
/// Prefers the bundled/remote [Product.imageUrl], then the bytes of the first
/// prepared photo, then falls back to a branded surface.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    required this.product,
    this.size = 64,
    this.heroTag,
  });

  final Product product;
  final double size;

  /// Forwarded to [ProductImage]; only set it when a [Hero] transition is
  /// wanted, since two thumbnails of the same product may share a screen.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final bytes = product.photos.isEmpty ? null : product.photos.first.bytes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: ProductImage(
          imageUrl: product.imageUrl,
          bytes: bytes,
          heroTag: heroTag,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
