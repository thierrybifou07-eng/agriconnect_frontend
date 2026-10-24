import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';

/// A shortcut offered under the buyer welcome banner.
class BuyerQuickAction {
  const BuyerQuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  /// Highlights the main action of the dashboard.
  final bool primary;

  /// Quantity badge, e.g. the number of items in the cart.
  final int? badgeCount;
}

/// Grid of the four buyer shortcuts, laid out on two columns on a narrow
/// screen and on a single row of four once the tiles are wide enough.
///
/// Tiles share their height inside a row through [IntrinsicHeight] and size
/// themselves from their content: no hard-coded tile height to break when a
/// label wraps or when the text scale changes.
class BuyerQuickActions extends StatelessWidget {
  const BuyerQuickActions({super.key, required this.actions});

  final List<BuyerQuickAction> actions;

  /// Available width needed before four tiles fit on one row comfortably.
  static const double _fourColumnBreakpoint = 360;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 2 * AppSizes.pagePadding;
    final columns = width >= _fourColumnBreakpoint ? 4 : 2;
    final rows = <List<BuyerQuickAction>>[
      for (var i = 0; i < actions.length; i += columns)
        actions.sublist(
          i,
          i + columns > actions.length ? actions.length : i + columns,
        ),
    ];

    return Column(
      key: const Key('buyerQuickActions'),
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < rows[i].length; j++) ...[
                  if (j > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionTile(
                      action: rows[i][j],
                      vertical: columns == 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One shortcut tile.
///
/// The tile owns a short busy state: a second tap while the first one is still
/// being dispatched would queue a duplicate navigation, so the tile turns
/// inert and shows a small spinner for the duration of the transition.
class _QuickActionTile extends StatefulWidget {
  const _QuickActionTile({required this.action, required this.vertical});

  final BuyerQuickAction action;

  /// Stacks the icon above the label; the only readable arrangement once the
  /// four shortcuts share one row.
  final bool vertical;

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _isBusy = false;
  Timer? _resetTimer;

  void _handleTap() {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    widget.action.onTap();
    // Cleared after the navigation settled: long enough to swallow a double
    // tap, short enough that the tile never feels stuck. The timer is owned by
    // the state so leaving the page cancels it instead of leaking it.
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isBusy = false);
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final action = widget.action;
    final primary = action.primary;
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    final badgeCount = action.badgeCount ?? 0;

    return Semantics(
      button: true,
      label: action.label,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: primary ? AppColors.brandGradient : null,
            color: primary ? null : colorScheme.surface,
            borderRadius: radius,
            border: primary
                ? null
                : Border.fromBorderSide(
                    BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
          ),
          child: InkWell(
            onTap: _isBusy ? null : _handleTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: widget.vertical
                  ? _vertical(theme, colorScheme, primary, badgeCount)
                  : _row(theme, colorScheme, primary, badgeCount),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    ThemeData theme,
    ColorScheme colorScheme,
    bool primary,
    int badgeCount,
  ) {
    return Row(
      children: [
        _badge(colorScheme, primary, badgeCount, size: 36, iconSize: 20),
        const SizedBox(width: 10),
        Expanded(
          child: _label(
            theme,
            colorScheme,
            primary,
            maxLines: 2,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _vertical(
    ThemeData theme,
    ColorScheme colorScheme,
    bool primary,
    int badgeCount,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _badge(colorScheme, primary, badgeCount, size: 40, iconSize: 22),
        const SizedBox(height: 10),
        _label(
          theme,
          colorScheme,
          primary,
          maxLines: 3,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Icon plate, replaced by a small spinner while the shortcut is dispatching.
  Widget _badge(
    ColorScheme colorScheme,
    bool primary,
    int badgeCount, {
    required double size,
    required double iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primary
            ? Colors.white.withValues(alpha: 0.22)
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: _isBusy
          ? Center(
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primary
                      ? Colors.white
                      : colorScheme.onPrimaryContainer,
                ),
              ),
            )
          : Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Icon(
                    widget.action.icon,
                    size: iconSize,
                    color: primary
                        ? Colors.white
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -size / 6,
                    top: -size / 8,
                    child: _CountBadge(count: badgeCount),
                  ),
              ],
            ),
    );
  }

  Widget _label(
    ThemeData theme,
    ColorScheme colorScheme,
    bool primary, {
    required int maxLines,
    required TextAlign textAlign,
  }) {
    return Text(
      widget.action.label,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style:
          (widget.vertical
                  ? theme.textTheme.labelMedium
                  : theme.textTheme.labelLarge)
              ?.copyWith(
                color: primary ? Colors.white : colorScheme.onSurface,
                fontWeight: primary || widget.vertical
                    ? FontWeight.w700
                    : FontWeight.w600,
                height: 1.2,
              ),
    );
  }
}

/// Small quantity bubble laid over a shortcut icon, e.g. the cart contents.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
