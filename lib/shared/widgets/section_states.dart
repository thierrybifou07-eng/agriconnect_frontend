/// Loading, failure and "nothing here" states shared by the Admin and Super
/// Admin consoles.
///
/// Both consoles report a failed section the same way: name what failed, show
/// the reason, offer a retry, and keep the rest of the screen usable. The layout
/// lives here so a new console section cannot invent a second spelling of it;
/// each console still passes its own wording and its own key prefix.
library;

import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';

/// Retryable card shown in place of one failing section of a page.
///
/// Sized for a section rather than a whole page: the reader keeps the rest of
/// the screen instead of losing the console to a single unavailable call.
///
/// [keyPrefix] keeps the keys of two consoles side by side apart, so a failed
/// section of each can coexist in one test without fighting over one key.
class SectionErrorCard extends StatelessWidget {
  const SectionErrorCard({
    super.key,
    required this.keyPrefix,
    required this.id,
    required this.title,
    required this.detail,
    required this.onRetry,
    this.retryLabel,
  });

  /// Namespace of the owning console, e.g. `admin` or `superAdmin`.
  final String keyPrefix;

  /// Stable identifier of the section, used to build the widget keys.
  final String id;

  final String title;
  final String detail;
  final VoidCallback onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      key: ValueKey('$keyPrefix.error.$id'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: scheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              key: ValueKey('$keyPrefix.retry.$id'),
              onPressed: onRetry,
              child: Text(retryLabel ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline "nothing here" card, for a section rather than a whole screen.
class SectionInlineEmpty extends StatelessWidget {
  const SectionInlineEmpty({
    super.key,
    required this.keyPrefix,
    required this.id,
    required this.icon,
    required this.label,
  });

  final String keyPrefix;
  final String id;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: ValueKey('$keyPrefix.empty.$id'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
