import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';

/// One slice of a distribution, e.g. "Pending — 2".
class DistributionSegment {
  const DistributionSegment({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

/// Card turning a handful of real counts into a readable distribution.
///
/// The bar is a plain stack of flexes, so each slice is exactly proportional to
/// its count: no smoothing, no invented trend line, nothing that would need a
/// history the repository does not hold. A distribution whose slices are all
/// empty says so instead of drawing an empty bar.
class DistributionCard extends StatelessWidget {
  const DistributionCard({
    super.key,
    required this.title,
    required this.segments,
  });

  final String title;
  final List<DistributionSegment> segments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final total = segments.fold<int>(0, (sum, s) => sum + s.count);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (total == 0)
              Text(
                l10n.distributionEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      for (final segment in segments)
                        if (segment.count > 0)
                          Expanded(
                            flex: segment.count,
                            child: ColoredBox(
                              color: segment.color,
                              child: const SizedBox.expand(),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // A Wrap, so a fourth status moves to the next line instead of
              // squeezing three labels into an ellipsis. The children get an
              // explicit ceiling because a Wrap hands them an unbounded width:
              // a long permission name would otherwise push its row past the
              // card instead of being shortened.
              LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    for (final segment in segments)
                      if (segment.count > 0)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                          ),
                          child: _LegendItem(segment: segment),
                        ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.segment});

  final DistributionSegment segment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: segment.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            segment.label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '${segment.count}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
