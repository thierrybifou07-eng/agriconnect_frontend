import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/media/product_image.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';

extension CatalogCategoryIconX on CatalogCategory {
  IconData get icon => switch (this) {
    CatalogCategory.cereals => Icons.grain_rounded,
    CatalogCategory.vegetables => Icons.eco_rounded,
    CatalogCategory.fruits => Icons.local_florist_rounded,
    CatalogCategory.tubers => Icons.landscape_rounded,
    CatalogCategory.spices => Icons.local_dining_rounded,
  };
}

/// Rich artwork used to illustrate a catalog product.
///
/// Displays the real product [BuyerProduct.imageUrl] when available and only
/// falls back to the category artwork otherwise.
class CategoryArtwork extends StatelessWidget {
  const CategoryArtwork({
    super.key,
    required this.product,
    this.compact = false,
  });

  final BuyerProduct product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bytes = product.photos.isEmpty ? null : product.photos.first.bytes;
    final showPhoto = product.imageUrl != null || bytes != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: showPhoto ? null : AppColors.brandGradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showPhoto)
            ProductImage(
              imageUrl: product.imageUrl,
              bytes: bytes,
              fit: BoxFit.cover,
            )
          else
            Center(
              child: Icon(
                product.category.icon,
                color: Colors.white.withValues(alpha: 0.9),
                size: compact ? 26 : 44,
              ),
            ),
          if (!product.inStock)
            // Bounded on the right as well: the pill then truncates instead of
            // running under the add button, at any text scale.
            Positioned(
              left: 6,
              top: 6,
              right: 46,
              child: StatusPill(label: context.l10n.productStatusOutOfStock),
            ),
        ],
      ),
    );
  }
}

/// Small dark pill used to overlay labels on artwork.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
