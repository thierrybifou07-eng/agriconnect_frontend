import 'package:flutter/material.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/media/product_image.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';
import 'package:agri_connect/shared/widgets/product_thumbnail.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// Tappable product row of the supplier catalog.
///
/// Laid out like the sibling order card: the picture leads, the name and the
/// description take the middle, and the status flag closes the top line on the
/// right; the stock and the price then share the footer. Photo, name, stock,
/// price and status all read at a glance, while every text keeps enough room to
/// ellipsize instead of forcing the row to overflow.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  /// Side of the leading picture. Large enough to recognise the produce, small
  /// enough that the text beside it keeps a readable width on a phone.
  static const double _pictureSize = 64;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductThumbnail(
                    product: product,
                    size: _pictureSize,
                    heroTag: 'product:${product.id}',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (product.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            product.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 132),
                      child: StatusBadge(
                        label: product.declaration.label(l10n),
                        color: product.declaration.color(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  // The stock yields characters first: the price keeps enough
                  // room to stay legible even on the narrowest phone.
                  Expanded(
                    child: Text(
                      l10n.productInStock(product.stockQuantity, product.unit),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      Money.format(product.price, locale: context.localeCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Image-led tile used for the supplier dashboard "recent products" strip.
///
/// The tile reserves an exact [width] x [height] box so the strip can be laid
/// out precisely and its loading skeleton can match it pixel for pixel. The
/// picture takes a fixed [imageHeight], so [height] has to leave room for the
/// text block at the reader's font size: a flat height clips the name and the
/// price as soon as the system font grows.
class ProductImageTile extends StatelessWidget {
  const ProductImageTile({
    super.key,
    required this.product,
    required this.width,
    required this.height,
    this.imageHeight = 126,
    this.heroTag,
    this.onTap,
  });

  final Product product;
  final double width;
  final double height;
  final double imageHeight;

  /// Hero tag for the picture. The dashboard strip needs its own: the shell
  /// keeps every tab alive, so the default tag would sit twice in the same
  /// route, once here and once in the catalog list, and Flutter refuses to
  /// animate two heroes that share a tag.
  final Object? heroTag;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      height: height,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: imageHeight, child: _image(context, product)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${product.stockQuantity} ${product.unit}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              Money.format(
                                product.price,
                                locale: context.localeCode,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Picture with the status flag layered on top.
  Widget _image(BuildContext context, Product product) => Stack(
    fit: StackFit.expand,
    children: [
      ProductImage(
        imageUrl: product.imageUrl,
        bytes: product.photos.isEmpty ? null : product.photos.first.bytes,
        heroTag: heroTag ?? 'product:${product.id}',
        fit: BoxFit.cover,
      ),
      // A quiet top-down shade keeps the badge readable over a bright
      // photograph without hiding the produce itself.
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.black38, Colors.transparent],
          ),
        ),
      ),
      Positioned(
        left: 8,
        top: 8,
        right: 8,
        child: Align(
          alignment: Alignment.centerLeft,
          child: StatusBadge(
            label: product.status.label(context.l10n),
            color: product.status.color(context),
          ),
        ),
      ),
    ],
  );
}
