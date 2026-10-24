import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/category_artwork.dart';

/// Vertical metrics of [CatalogProductCard].
///
/// A grid hands its tiles a fixed height, so a card that sizes itself from the
/// text it happens to receive would overflow as soon as a name runs to a second
/// line or the reader enlarges the fonts. These metrics reserve the exact room
/// every line needs, resolved from the current text scale, and the catalog grid
/// asks for a tile height built from them: the two can no longer disagree.
@immutable
class CatalogCardMetrics {
  const CatalogCardMetrics({
    required this.titleLine,
    required this.metaLine,
    required this.priceLine,
  });

  /// Height of one line of the product name.
  final double titleLine;

  /// Height of one muted line under the name.
  final double metaLine;

  /// Height of the price line.
  final double priceLine;

  /// Ratio of the picture, above the text block.
  static const double imageAspect = 1.4;

  static const double _paddingTop = 8;
  static const double _paddingBottom = 10;
  static const double _gapTitle = 4;
  static const double _gapMeta = 2;
  static const double _gapPrice = 8;

  /// Height of the whole card for a tile of [tileWidth] logical pixels.
  double cardHeight(double tileWidth) =>
      tileWidth / imageAspect +
      _paddingTop +
      titleLine * 2 +
      _gapTitle +
      metaLine +
      _gapMeta +
      metaLine +
      _gapPrice +
      priceLine +
      _paddingBottom;

  /// Metrics of the card in the current theme and text scale.
  factory CatalogCardMetrics.of(BuildContext context) {
    final theme = Theme.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    const extra = 0.5; // Absorbs the rounding of the line metrics.

    double lineHeight(TextStyle? style) {
      final fontSize = style?.fontSize ?? 14;
      final factor = style?.height ?? 1.2;
      return scaler.scale(fontSize) * factor + extra;
    }

    return CatalogCardMetrics(
      titleLine: lineHeight(
        theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
      metaLine: lineHeight(theme.textTheme.bodySmall?.copyWith(height: 1.2)),
      priceLine: lineHeight(
        theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Grid card of the catalog.
///
/// Shows what a buyer decides on before opening a product: the picture, the
/// name, who sells it, where it comes from, the price per unit and whether any
/// is left. The whole card opens the buyer product detail, the button laid over
/// the picture adds it to the cart without leaving the catalog.
///
/// Every text line is bounded by [CatalogCardMetrics], so the card never
/// overflows its grid cell, at any width and at any text scale.
class CatalogProductCard extends StatelessWidget {
  const CatalogProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAdd,
  });

  final BuyerProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final metrics = CatalogCardMetrics.of(context);
    final inStock = product.inStock;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: CatalogCardMetrics.imageAspect,
                  child: CategoryArtwork(product: product, compact: true),
                ),
                // The add button sits on the picture so the price keeps the
                // whole width of the card and never has to fight it for room.
                Positioned(
                  right: 6,
                  top: 6,
                  child: _AddButton(
                    onPressed: inStock ? onAdd : null,
                    tooltip: l10n.addToCart,
                  ),
                ),
                // The family is the first thing a buyer filters on, so it is
                // readable straight from the picture without opening the card.
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: _CategoryBadge(label: product.category.label(l10n)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: metrics.titleLine * 2,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _MetaLine(
                    height: metrics.metaLine,
                    icon: Icons.storefront_outlined,
                    value: '${product.sellerName} · ${product.location}',
                  ),
                  _MetaLine(
                    height: metrics.metaLine,
                    icon: inStock
                        ? Icons.inventory_2_outlined
                        : Icons.remove_shopping_cart_outlined,
                    value: inStock
                        ? l10n.catalogProductStock(
                            product.stockQuantity,
                            product.unit,
                          )
                        : l10n.productStatusOutOfStock,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: metrics.priceLine,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            Money.format(
                              product.price,
                              locale: context.localeCode,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '/ ${product.unit}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single muted fact under the product name, always one line tall.
class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.height,
    required this.icon,
    required this.value,
  });

  final double height;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Round add button laid over the artwork of a product.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed, required this.tooltip});

  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enabled = onPressed != null;

    return Material(
      color: enabled
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      elevation: enabled ? 2 : 0,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 34, height: 34),
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(
          Icons.add_shopping_cart_rounded,
          color: enabled
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

/// Translucent label laid over the artwork of a product.
class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      constraints: const BoxConstraints(maxWidth: 130),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
