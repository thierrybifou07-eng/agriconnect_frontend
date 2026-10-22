import 'package:flutter/material.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';

/// Pulsing placeholder used while real content is loading.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, this.height = 16, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.long,
    lowerBound: 0.4,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// A column of skeleton cards mimicking a typical list layout.
class CardListSkeleton extends StatelessWidget {
  const CardListSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < itemCount; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const SkeletonBox(width: 64, height: 64, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonBox(height: 14),
                          SizedBox(height: 8),
                          SkeletonBox(width: 140, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A grid of image-led skeleton tiles, used while the catalog, dashboard
/// featured products or any other product grid is loading.
///
/// The tile count and the column count mirror the real grid, so the page keeps
/// its final shape while the data lands instead of collapsing into a spinner.
class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key, this.itemCount = 4, this.crossAxisCount = 2});

  /// Number of skeleton tiles.
  final int itemCount;

  /// Columns of the real grid being reproduced.
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final columns = crossAxisCount < 1 ? 1 : crossAxisCount;
    final rows = <Widget>[];

    for (var start = 0; start < itemCount; start += columns) {
      final inThisRow = (itemCount - start).clamp(0, columns);
      // A partially filled last row keeps the same tile width as the full ones
      // by spacing its children out, otherwise it would stretch to the right.
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: start + columns < itemCount ? 10 : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < columns; i++) ...[
                Expanded(child: _TileSkeleton(filled: i < inThisRow)),
                if (i < columns - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton({this.filled = true});

  /// A trailing slot of an incomplete row stays transparent instead of drawing
  /// a phantom tile.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (!filled) return const SizedBox.shrink();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            AspectRatio(aspectRatio: 1.4, child: SkeletonBox(radius: 12)),
            SizedBox(height: 10),
            SkeletonBox(height: 14),
            SizedBox(height: 6),
            SkeletonBox(width: 80, height: 12),
            SizedBox(height: 8),
            SkeletonBox(width: 60, height: 18),
          ],
        ),
      ),
    );
  }
}

/// A horizontal row of image-led skeleton tiles, used while a "recent
/// products" strip is loading in a dashboard.
///
/// Passing [tileWidth] and [imageHeight] reproduces the exact geometry of the
/// real tiles, so the strip does not jump when the data lands. Without them
/// the tiles simply share the available width.
class StripSkeleton extends StatelessWidget {
  const StripSkeleton({
    super.key,
    this.itemCount = 3,
    this.tileWidth,
    this.imageHeight,
  });

  final int itemCount;

  /// Width of a tile, mirroring `ProductImageTile.width`.
  final double? tileWidth;

  /// Height of the picture area, mirroring `ProductImageTile.imageHeight`.
  final double? imageHeight;

  @override
  Widget build(BuildContext context) {
    final width = tileWidth;
    final picture = imageHeight;

    if (width == null || picture == null) {
      return Row(
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            const Expanded(child: _StripTileSkeleton()),
            if (i < itemCount - 1) const SizedBox(width: 10),
          ],
        ],
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(right: index < itemCount - 1 ? 10 : 0),
        child: _StripTileSkeleton(imageHeight: picture, width: width),
      ),
    );
  }
}

class _StripTileSkeleton extends StatelessWidget {
  const _StripTileSkeleton({this.imageHeight, this.width});

  final double? imageHeight;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final picture = imageHeight;
    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: picture ?? 120, radius: 12),
            const SizedBox(height: 10),
            const SkeletonBox(height: 14),
            const SizedBox(height: 6),
            const SkeletonBox(width: 60, height: 12),
          ],
        ),
      ),
    );

    final tileWidth = width;
    if (tileWidth == null) return card;
    return SizedBox(width: tileWidth, child: card);
  }
}

/// Placeholder matching the stacked layout of a form, used while the data
/// behind that form is still loading.
class FormSkeleton extends StatelessWidget {
  const FormSkeleton({
    super.key,
    this.fieldCount = 2,
    this.withPreview = false,
  });

  /// How many grouped sections of fields to draw below the title.
  final int fieldCount;

  /// Whether a large media placeholder is drawn first, as on a product form.
  final bool withPreview;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SkeletonBox(width: 180, height: 26, radius: 8),
            const SizedBox(height: 12),
            const SkeletonBox(height: 14),
            const SizedBox(height: 20),
            if (withPreview) ...[
              const SkeletonBox(height: 200, radius: 16),
              const SizedBox(height: 24),
            ],
            for (var i = 0; i < fieldCount; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i < fieldCount - 1 ? 18 : 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SkeletonBox(width: 120, height: 14),
                        const SizedBox(height: 14),
                        const SkeletonBox(height: 48, radius: 14),
                        const SizedBox(height: 14),
                        const SkeletonBox(height: 48, radius: 14),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder mirroring a [StatGrid] overview: the same tiles, in the same
/// arrangement, while a dashboard waits for its figures.
///
/// It follows the grid's own responsive rule and reserved tile height, so the
/// page keeps its final shape instead of jumping when the numbers land.
class StatGridSkeleton extends StatelessWidget {
  const StatGridSkeleton({super.key, this.tileCount = 3});

  /// Number of metric tiles to draw.
  final int tileCount;

  @override
  Widget build(BuildContext context) {
    final isNarrow =
        MediaQuery.sizeOf(context).width < AppBreakpoints.narrowContent;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final tile = StatGrid.tileHeight * textScale;
    final wideTile = StatGrid.wideTileHeight * textScale;

    if (!isNarrow) {
      return SizedBox(
        height: tile,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < tileCount; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              const Expanded(child: _StatTileSkeleton()),
            ],
          ],
        ),
      );
    }

    final secondary = <Widget>[];
    for (var i = 1; i < tileCount; i++) {
      if (secondary.isNotEmpty) secondary.add(const SizedBox(width: 10));
      secondary.add(const Expanded(child: _StatTileSkeleton()));
    }

    return Column(
      children: [
        SizedBox(height: wideTile, child: const _StatTileSkeleton()),
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: tile,
            child: Row(children: secondary),
          ),
        ],
      ],
    );
  }
}

class _StatTileSkeleton extends StatelessWidget {
  const _StatTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SkeletonBox(width: 64, height: 12),
            SizedBox(height: 12),
            SkeletonBox(width: 44, height: 22),
          ],
        ),
      ),
    );
  }
}
