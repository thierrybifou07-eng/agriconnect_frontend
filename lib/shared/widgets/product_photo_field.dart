import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/media/prepared_photo.dart';
import 'package:agri_connect/core/media/product_image.dart';

/// Photo area of the product form.
///
/// A large preview of the first picture carries the section, and the remaining
/// ones sit in a strip below it. The first picture is the main one, as the
/// catalog and the read-only sheet both display it, so the order of the tiles
/// is meaningful. The preview is cropped rather than stretched, and the whole
/// area stays a stable height so nothing jumps while a picture is read.
class ProductPhotoField extends StatelessWidget {
  const ProductPhotoField({
    super.key,
    required this.photos,
    required this.onPick,
    required this.onRemove,
    this.isLoading = false,
    this.hasError = false,
    this.maxPhotos = 5,
    this.emptyLabel = '',
    this.hint = '',
    this.pickLabel = '',
    this.replaceLabel = '',
    this.removeLabel = '',
    this.loadingLabel = '',
    this.errorLabel = '',
  });

  final List<PreparedPhoto> photos;
  final VoidCallback onPick;
  final ValueChanged<PreparedPhoto> onRemove;
  final bool isLoading;
  final bool hasError;
  final int maxPhotos;
  final String emptyLabel;
  final String hint;
  final String pickLabel;
  final String replaceLabel;
  final String removeLabel;
  final String loadingLabel;
  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final main = photos.isEmpty ? null : photos.first;
    final rest = photos.length > 1
        ? photos.sublist(1)
        : const <PreparedPhoto>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreviewSurface(
          main: main,
          isLoading: isLoading,
          hasError: hasError,
          emptyLabel: emptyLabel,
          loadingLabel: loadingLabel,
          errorLabel: errorLabel,
          removeLabel: removeLabel,
          onRemove: main == null ? null : () => onRemove(main),
        ),
        if (hint.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            hint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: rest.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final photo = rest[index];
                return _Thumb(
                  photo: photo,
                  removeLabel: removeLabel,
                  onRemove: () => onRemove(photo),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onPick,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined, size: 20),
                label: Text(
                  isLoading
                      ? loadingLabel
                      : (photos.isEmpty ? pickLabel : replaceLabel),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${photos.length}/$maxPhotos',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Large preview of the main picture, or a placeholder when there is none.
class _PreviewSurface extends StatelessWidget {
  const _PreviewSurface({
    required this.main,
    required this.isLoading,
    required this.hasError,
    required this.emptyLabel,
    required this.loadingLabel,
    required this.errorLabel,
    required this.removeLabel,
    required this.onRemove,
  });

  final PreparedPhoto? main;
  final bool isLoading;
  final bool hasError;
  final String emptyLabel;
  final String loadingLabel;
  final String errorLabel;
  final String removeLabel;
  final VoidCallback? onRemove;

  /// Fixed aspect ratio rather than a pixel height, so the preview scales with
  /// the card instead of collapsing on a narrow phone.
  static const double _aspectRatio = 16 / 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final photo = main;
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photo == null)
              _Placeholder(
                label: hasError ? errorLabel : emptyLabel,
                hasError: hasError,
              )
            else
              // BoxFit.cover crops the picture instead of distorting it.
              ProductImage(bytes: photo.bytes, fit: BoxFit.cover),
            if (isLoading)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: Colors.white,
                        ),
                      ),
                      if (loadingLabel.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          loadingLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            if (photo != null && !isLoading && onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: _RemoveButton(
                  tooltip: removeLabel,
                  onPressed: onRemove!,
                ),
              ),
            if (photo == null && !hasError)
              const Positioned(
                right: 12,
                top: 12,
                child: Icon(
                  Icons.storefront_rounded,
                  color: Colors.white30,
                  size: 30,
                ),
              ),
          ],
        ),
      ),
    ).withBorder(
      color: hasError ? colorScheme.error : colorScheme.outlineVariant,
      radius: radius,
    );
  }
}

/// Extra picture in the horizontal strip.
class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.photo,
    required this.removeLabel,
    required this.onRemove,
  });

  final PreparedPhoto photo;
  final String removeLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.tileRadius),
          child: SizedBox(
            width: 76,
            height: 76,
            child: ProductImage(bytes: photo.bytes, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: _RemoveButton(tooltip: removeLabel, onPressed: onRemove),
        ),
      ],
    );
  }
}

/// Circular remove affordance shared by the preview and the strip.
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.close_rounded, size: 15, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Neutral surface shown while the product has no picture.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label, required this.hasError});

  final String label;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasError
              ? [colorScheme.errorContainer, colorScheme.errorContainer]
              : const [Color(0xFFEDF3EA), AppColors.primarySoft],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasError ? Icons.error_outline_rounded : Icons.image_outlined,
              size: 34,
              color: hasError ? colorScheme.error : colorScheme.primary,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasError
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Adds a hairline border around a clipped child.
extension on Widget {
  Widget withBorder({required Color color, required BorderRadius radius}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: color),
      ),
      child: this,
    );
  }
}
