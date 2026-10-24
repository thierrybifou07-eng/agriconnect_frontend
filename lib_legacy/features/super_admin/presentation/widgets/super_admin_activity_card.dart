import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/super_admin/domain/system_event.dart';
import 'package:agri_connect/features/super_admin/presentation/extensions/system_event_l10n.dart';

/// One line of the platform activity trail.
///
/// The actor, the verb and the target come from the recorded event; only the
/// wording of the verb is localized by the screen that owns this widget, so the
/// trail reads as a sentence instead of as three disconnected fields.
class SuperAdminActivityRow extends StatelessWidget {
  const SuperAdminActivityRow({super.key, required this.event});

  final SystemEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.bolt_rounded,
          size: 19,
          color: scheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        // Actor and verb share the title line; the target keeps its own line so
        // a long member name never pushes the timestamp out of the row.
        l10n.superAdminActivityActor(event.actorName, event.action.label(l10n)),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${event.target} · ${AppFormats.date(event.occurredAt, locale: context.localeCode)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }
}

/// Card wrapping the activity trail with its title.
class SuperAdminActivityCard extends StatelessWidget {
  const SuperAdminActivityCard({
    super.key,
    required this.events,
    required this.title,
  });

  final String title;
  final List<SystemEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    if (events.isEmpty) {
      return Card(
        key: const ValueKey('superAdmin.activity.empty'),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          child: Row(
            children: [
              Icon(Icons.history_toggle_off_rounded, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.superAdminActivityEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (var i = 0; i < events.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 64),
            SuperAdminActivityRow(
              key: ValueKey('superAdmin.activity.${events[i].id}'),
              event: events[i],
            ),
          ],
        ],
      ),
    );
  }
}
