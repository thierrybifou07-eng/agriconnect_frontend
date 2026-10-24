import 'package:flutter/material.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/agent/presentation/widgets/agent_content.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

/// A status filter offered above an agent list. [value] is the stable key the
/// rows are matched against, [label] is its localized name.
class AgentStatusFilter {
  const AgentStatusFilter({required this.value, required this.label});

  final String value;
  final String label;
}

/// Shared list body of the four agent sections.
///
/// The four sections answer the same questions — search, status filter, loading,
/// empty, error, pull-to-refresh, per-row action guarded against a double tap —
/// so they are laid out once here. A section only supplies its data and how a
/// single row looks, which keeps the four screens from drifting apart and keeps
/// a fix in one of them a fix in all of them.
class AgentListView<T> extends StatefulWidget {
  const AgentListView({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.isLoading,
    required this.failure,
    required this.actionFailure,
    required this.updatingIds,
    required this.searchHint,
    required this.searchOf,
    required this.statusFilters,
    required this.statusKeyOf,
    required this.emptyTitle,
    required this.emptyBody,
    required this.onRefresh,
    required this.itemBuilder,
  });

  final String title;
  final IconData icon;
  final List<T> items;
  final bool isLoading;

  /// Initial load failure, retryable through [onRefresh].
  final Failure? failure;

  /// Last action failure, surfaced once; [onRefresh] clears it.
  final Failure? actionFailure;

  final Set<String> updatingIds;
  final String searchHint;

  /// Text a row is matched against when searching.
  final String Function(T item) searchOf;

  final List<AgentStatusFilter> statusFilters;

  /// Stable status key of a row, matched against [AgentStatusFilter.value].
  final String Function(T item) statusKeyOf;

  final String emptyTitle;
  final String emptyBody;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  State<AgentListView<T>> createState() => _AgentListViewState<T>();
}

class _AgentListViewState<T> extends State<AgentListView<T>> {
  final TextEditingController _search = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    final query = _search.text.trim().toLowerCase();
    return widget.items
        .where((item) {
          if (_status != null && widget.statusKeyOf(item) != _status) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          return widget.searchOf(item).toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = widget.items;
    final filtered = _filtered;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          AgentContent(child: _header(context, l10n, items.length)),
          const SizedBox(height: 12),
          if (widget.actionFailure != null) ...[
            AgentContent(child: _actionBanner(context, l10n)),
            const SizedBox(height: 12),
          ],
          AgentContent(child: _searchField(context, l10n)),
          if (widget.statusFilters.length >= 2) ...[
            const SizedBox(height: 12),
            _statusRow(l10n, items),
          ],
          const SizedBox(height: 12),
          ..._body(context, l10n, filtered),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations l10n, int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(widget.icon, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchField(BuildContext context, AppLocalizations l10n) {
    final hasQuery = _search.text.trim().isNotEmpty;
    return TextField(
      controller: _search,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.searchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: hasQuery
            ? IconButton(
                onPressed: () => setState(_search.clear),
                icon: const Icon(Icons.close_rounded),
              )
            : null,
      ),
    );
  }

  Widget _statusRow(AppLocalizations l10n, List<T> items) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    int countOf(String value) =>
        items.where((item) => widget.statusKeyOf(item) == value).length;

    // Unbounded width on purpose: a row of statuses overflows a narrow screen,
    // and squeezing the labels is worse than scrolling them.
    return AgentContent(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(
              label: l10n.agentFilterAll,
              count: items.length,
              selected: _status == null,
              onSelected: () => setState(() => _status = null),
              theme: theme,
              colorScheme: colorScheme,
            ),
            for (final filter in widget.statusFilters)
              _chip(
                label: filter.label,
                count: countOf(filter.value),
                selected: _status == filter.value,
                onSelected: () => setState(() => _status = filter.value),
                theme: theme,
                colorScheme: colorScheme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onSelected,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label · $count'),
        selected: selected,
        onSelected: (_) => onSelected(),
        // The checkmark is replaced by the brand fill: the active chip is
        // obvious without spending width on it.
        showCheckmark: false,
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _actionBanner(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.agentActionError,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.agentActionHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () => widget.onRefresh(),
                icon: const Icon(Icons.verified_user_outlined, size: 18),
                label: Text(l10n.verifyStatus),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    AppLocalizations l10n,
    List<T> filtered,
  ) {
    if (widget.isLoading && widget.items.isEmpty) {
      return const [AgentContent(child: CardListSkeleton(itemCount: 3))];
    }
    if (widget.failure != null && widget.items.isEmpty) {
      return [
        AgentContent(
          child: FailureView(
            failure: widget.failure!,
            onRetry: () => widget.onRefresh(),
          ),
        ),
      ];
    }
    if (widget.items.isEmpty) {
      return [
        AgentContent(
          child: EmptyState(
            icon: widget.icon,
            title: widget.emptyTitle,
            body: widget.emptyBody,
          ),
        ),
      ];
    }
    if (filtered.isEmpty) {
      return [
        AgentContent(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: l10n.agentNoResultTitle,
            body: l10n.agentNoResultBody,
          ),
        ),
      ];
    }

    return [
      for (var i = 0; i < filtered.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        AgentContent(child: widget.itemBuilder(context, filtered[i])),
      ],
    ];
  }
}
