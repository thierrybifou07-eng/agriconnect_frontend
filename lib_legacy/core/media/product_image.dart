import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/media/demo_assets.dart';

/// Picture resolver used across the whole app to display a product, category
/// or profile image.
///
/// Resolution order, from most specific to most generic:
///  1. an explicit [imageUrl] (Cloudinary `https://` or bundled asset path),
///  2. raw [bytes] from a locally-prepared photo,
///  3. the branded fallback surface.
///
/// No fallback ever shows a bare icon: when no picture is available, a soft
/// branded surface is used so the grid keeps a premium look.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    this.imageUrl,
    this.bytes,
    this.heroTag,
    this.fit = BoxFit.cover,
  });

  /// Reference to a remote picture or bundled asset. When it is a bundled
  /// asset path it is loaded through the asset bundle, otherwise through the
  /// network. `null` when only raw bytes are available.
  final String? imageUrl;

  /// Raw bytes of a locally-prepared picture, displayed when there is no
  /// remote/bundled reference.
  final Uint8List? bytes;

  /// Helper for [Hero] transitions.
  ///
  /// Left `null` on purpose: a picture shown several times on the same screen
  /// (a product strip and its summary, the items of an order) would otherwise
  /// build two [Hero] widgets sharing a tag, which Flutter rejects. Callers
  /// opt in with a tag that is unique on a route, e.g. `'product:$id'`.
  final Object? heroTag;

  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      final image = Image(
        image: DemoAssets.isRemote(url) ? NetworkImage(url) : AssetImage(url),
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _buildBytesOrDefault(),
      );
      final tag = heroTag;
      return tag == null ? image : Hero(tag: tag, child: image);
    }
    return _buildBytesOrDefault();
  }

  Widget _buildBytesOrDefault() {
    final b = bytes;
    if (b != null) {
      return Image.memory(
        b,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const _BrandedFallback(),
      );
    }
    return const _BrandedFallback();
  }
}

/// Soft branded surface used when no picture is available.
class _BrandedFallback extends StatelessWidget {
  const _BrandedFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          color: Colors.white.withValues(alpha: 0.85),
          size: 34,
        ),
      ),
    );
  }
}
