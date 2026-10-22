import 'package:flutter/material.dart';

import 'package:agri_connect/shared/widgets/status_badge.dart';

/// One labelled fact of an agent case: an icon and an already-composed line.
///
/// The page owns the wording ("Buyer · Marie Koné") because the same card
/// carries facts whose label and value differ from one section to the next; the
/// card only has to lay them out without ever overflowing.
class AgentFact {
  const AgentFact({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

/// A single-line fact of a case card or its detail sheet.
class AgentFactRow extends StatelessWidget {
  const AgentFactRow({super.key, required this.fact});

  final AgentFact fact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(fact.icon, size: 17, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            fact.text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Header row of a case card and of its detail sheet: a leading element, a
/// title and a status badge.
///
/// A badge left to size itself is laid out with unbounded width and so never
/// learns to ellipsize: its French label ("En attente de confirmation") then
/// pushes a card past the screen at a large system font. Reserving the badge a
/// share of the row means the title always keeps room and the badge gives up
/// characters instead of the row overflowing.
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    this.leading,
  });

  final Widget title;
  final String statusLabel;
  final Color statusColor;
  final Widget? leading;

  /// Most of the row a status badge may take; the title keeps the rest.
  static const double _badgeWidthFactor = 0.55;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBadgeWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth * _badgeWidthFactor
            : double.infinity;
        return Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(child: title),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBadgeWidth),
              child: StatusBadge(label: statusLabel, color: statusColor),
            ),
          ],
        );
      },
    );
  }
}

/// Square icon plate used as the leading element of a case card.
class AgentIconPlate extends StatelessWidget {
  const AgentIconPlate({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: colorScheme.onPrimaryContainer),
    );
  }
}

/// Card of a single agent case: who it is about, its status and the facts the
/// agent needs to take the decision, plus one primary action.
///
/// The whole card opens the detail sheet; [isUpdating] makes it inert while a
/// decision is in flight so a second tap cannot reissue it.
class AgentCaseCard extends StatelessWidget {
  const AgentCaseCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.facts,
    required this.onTap,
    this.isUpdating = false,
    this.action,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final List<AgentFact> facts;
  final VoidCallback onTap;
  final bool isUpdating;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isUpdating ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusHeader(
                leading: leading,
                statusLabel: statusLabel,
                statusColor: statusColor,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (facts.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (var i = 0; i < facts.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  AgentFactRow(fact: facts[i]),
                ],
              ],
              if (action != null) ...[const SizedBox(height: 12), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the scrollable detail sheet of an agent case.
///
/// Scrollable because a bottom sheet is capped by the screen: with a large
/// system font on a short phone the action would otherwise sit below the cap,
/// unreachable behind the sheet's own edge.
Future<void> showAgentDetailSheet(
  BuildContext context, {
  required String title,
  required String statusLabel,
  required Color statusColor,
  required List<AgentFact> facts,
  Widget? action,
}) {
  final theme = Theme.of(context);
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (sheetContext) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusHeader(
            statusLabel: statusLabel,
            statusColor: statusColor,
            title: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < facts.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            AgentFactRow(fact: facts[i]),
          ],
          if (action != null) ...[const SizedBox(height: 20), action],
        ],
      ),
    ),
  );
}

/// Standard decision button of an agent case, with its in-flight spinner.
class AgentCaseAction extends StatelessWidget {
  const AgentCaseAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isBusy = false,
    this.tonal = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isBusy;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final child = isBusy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Icon(icon, size: 20);

    return SizedBox(
      height: 44,
      child: tonal
          ? FilledButton.tonalIcon(
              onPressed: isBusy ? null : onPressed,
              icon: child,
              label: Text(label),
            )
          : FilledButton.icon(
              onPressed: isBusy ? null : onPressed,
              icon: child,
              label: Text(label),
            ),
    );
  }
}
