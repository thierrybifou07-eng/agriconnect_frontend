import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';

/// Compact metric tile used on dashboards (revenue, products, orders…).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent = false,
    this.subtitle,
    this.onTap,
    this.labelMaxLines = 1,
  }) : _wide = false;

  /// Horizontal variant used as the leading tile of a narrow [StatGrid], where
  /// the icon has room to sit next to the figure instead of above it.
  const StatCard.wide({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent = false,
    this.subtitle,
    this.onTap,
  }) : _wide = true,
       labelMaxLines = 1;

  final String label;
  final String value;
  final IconData? icon;
  final bool accent;
  final VoidCallback? onTap;

  /// Short annotation displayed under the value/icon.
  final String? subtitle;

  /// Lines allowed to the label before it is truncated; raise it on narrow
  /// tiles so long labels such as "En attente de confirmation" stay readable.
  final int labelMaxLines;

  final bool _wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final decoration = accent
        ? BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.soft,
          )
        : BoxDecoration(
            color: theme.cardTheme.color ?? scheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          );

    final foreground = accent ? Colors.white : scheme.onSurface;

    final labelWidget = Text(
      label,
      maxLines: _wide ? 1 : labelMaxLines,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelMedium?.copyWith(
        color: foreground.withValues(alpha: 0.75),
        fontWeight: FontWeight.w600,
      ),
    );

    final valueWidget = Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleLarge?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w800,
      ),
    );

    final subtitleWidget = subtitle == null
        ? null
        : Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: foreground.withValues(alpha: 0.7),
            ),
          );

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: decoration,
      child: _wide
          ? Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 22,
                    color: foreground.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      labelWidget,
                      const SizedBox(height: 6),
                      valueWidget,
                      if (subtitleWidget != null) ...[
                        const SizedBox(height: 4),
                        subtitleWidget,
                      ],
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 20,
                        color: foreground.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(child: labelWidget),
                  ],
                ),
                const SizedBox(height: 10),
                valueWidget,
                if (subtitleWidget != null) ...[
                  const SizedBox(height: 4),
                  subtitleWidget,
                ],
              ],
            ),
    );

    if (onTap == null) return card;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: card,
      ),
    );
  }
}

/// Responsive row of [StatCard] tiles for dashboard overviews.
///
/// On a regular screen the three metrics sit side by side. Below
/// [narrowBreakpoint] the first metric takes the full width and the remaining
/// ones share a second row, so no label is ever squeezed into an ellipsis.
class StatGrid extends StatelessWidget {
  const StatGrid({
    super.key,
    required this.values,
    required this.labels,
    this.icons = const [],
    this.accents = const [],
    this.onTap = const [],
    this.narrowBreakpoint = AppBreakpoints.narrowContent,
  });

  final List<String> values;
  final List<String> labels;
  final List<IconData> icons;
  final List<bool> accents;
  final List<VoidCallback> onTap;

  /// Screen width under which the tiles are stacked.
  final double narrowBreakpoint;

  /// Height of a standard tile, tall enough for a two-line label.
  static const double tileHeight = 108;

  /// Height of the leading wide tile.
  static const double wideTileHeight = 88;

  @override
  Widget build(BuildContext context) {
    assert(values.length == labels.length, 'values and labels must match');
    final isNarrow = MediaQuery.sizeOf(context).width < narrowBreakpoint;
    // A tile is a fixed height, so a reader who enlarges the fonts would
    // otherwise watch the figures spill out of it. The text is what grows, so
    // the reserved room grows with it.
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final tile = tileHeight * textScale;
    final wideTile = wideTileHeight * textScale;

    if (!isNarrow) {
      return SizedBox(
        height: tile,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < values.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _tile(i, labelMaxLines: 2)),
            ],
          ],
        ),
      );
    }

    final secondary = <Widget>[];
    for (var i = 1; i < values.length; i++) {
      if (secondary.isNotEmpty) secondary.add(const SizedBox(width: 10));
      secondary.add(Expanded(child: _tile(i, labelMaxLines: 2)));
    }

    return Column(
      children: [
        SizedBox(height: wideTile, child: _tile(0, wide: true)),
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

  Widget _tile(int index, {bool wide = false, int labelMaxLines = 1}) {
    final icon = index < icons.length ? icons[index] : null;
    final accent = index < accents.length && accents[index];
    final tap = index < onTap.length ? onTap[index] : null;

    if (wide) {
      return StatCard.wide(
        label: labels[index],
        value: values[index],
        icon: icon,
        accent: accent,
        onTap: tap,
      );
    }
    return StatCard(
      label: labels[index],
      value: values[index],
      icon: icon,
      accent: accent,
      onTap: tap,
      labelMaxLines: labelMaxLines,
    );
  }
}
