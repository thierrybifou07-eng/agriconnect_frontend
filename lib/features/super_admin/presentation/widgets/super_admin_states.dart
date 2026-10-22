/// Failure states shared by the Super Admin console.
///
/// The console reports a failed section the same way everywhere: name what
/// failed, show the reason, offer a retry. Kept in one file so a new console
/// screen cannot invent a fourth spelling of the same state.
library;

import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/shared/widgets/section_states.dart';

/// Retryable card shown in place of one failing section of a page.
///
/// Binds the shared [SectionErrorCard] layout to the Super Admin wording and
/// key namespace, so the console cannot drift away from the Admin dashboard.
class SuperAdminSectionError extends StatelessWidget {
  const SuperAdminSectionError({
    super.key,
    required this.id,
    required this.message,
    required this.onRetry,
  });

  /// Stable identifier of the section, used to build the widget keys.
  final String id;

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectionErrorCard(
      keyPrefix: 'superAdmin',
      id: id,
      title: l10n.superAdminSectionLoadError,
      detail: l10n.superAdminSectionLoadErrorDetail(message),
      retryLabel: l10n.retry,
      onRetry: onRetry,
    );
  }
}

/// Full-page failure state, used when a console screen cannot load at all.
class SuperAdminPageError extends StatelessWidget {
  const SuperAdminPageError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 44, color: scheme.error),
              const SizedBox(height: 14),
              Text(
                l10n.superAdminSectionLoadError,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.superAdminSectionLoadErrorDetail(message),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline "nothing here" card, for a section rather than a whole screen.
class SuperAdminInlineEmpty extends StatelessWidget {
  const SuperAdminInlineEmpty({
    super.key,
    required this.id,
    required this.icon,
    required this.label,
  });

  final String id;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SectionInlineEmpty(
      keyPrefix: 'superAdmin',
      id: id,
      icon: icon,
      label: label,
    );
  }
}
