import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';

/// One item an administrator may have to act on.
///
/// Only items whose count comes from the repository are built, and [onTap] is
/// optional on purpose: an alert whose destination does not exist in the
/// workspace navigation is still worth showing, it simply does not pretend to be
/// tappable.
class AttentionItem {
  const AttentionItem({
    required this.id,
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  /// Stable identifier of the backlog line, independent of its localized label.
  final String id;

  final int count;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}

/// Card listing what is waiting for an administrator decision.
///
/// The card is a genuine backlog, not decoration: it is fed by the moderation
/// and confirmation counters the repository already computes, and it collapses
/// into a short confirmation when there is nothing to do.
class AttentionCard extends StatelessWidget {
  const AttentionCard({
    super.key,
    required this.title,
    required this.items,
    required this.emptyTitle,
    required this.emptyBody,
  });

  /// Header of the backlog; the caller owns the wording because the same card
  /// serves several workspaces.
  final String title;

  /// Pending items; an empty list renders the "nothing to do" state.
  final List<AttentionItem> items;

  final String emptyTitle;
  final String emptyBody;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (items.isEmpty) {
      return Card(
        key: const ValueKey('attention.clear'),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emptyTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      emptyBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(
                  Icons.priority_high_rounded,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            _AttentionRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.item});

  final AttentionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tappable = item.onTap != null;

    return InkWell(
      key: ValueKey('attention.${item.id}'),
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 19, color: item.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // The counter is what the section is scanned for, so it is the
            // loudest element of the row and keeps its own space.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${item.count}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: item.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (tappable) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
