import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/buyer/application/catalog_filters_controller.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_filter_chip.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/category_artwork.dart';

/// Horizontally scrollable row of the catalog categories.
///
/// "All" is part of the row, so the family filter is never a one-way trip: the
/// selected chip is tinted with the brand colour and can be tapped again to
/// release it, and the row scrolls the active chip back into view when the
/// selection changes, so a chip picked near the end of the row does not stay
/// hidden behind the fold.
class CatalogCategoryFilter extends StatefulWidget {
  const CatalogCategoryFilter({
    super.key,
    required this.filters,
    required this.onToggle,
    required this.onClear,
  });

  final CatalogFilters filters;
  final ValueChanged<CatalogCategory> onToggle;
  final VoidCallback onClear;

  @override
  State<CatalogCategoryFilter> createState() => _CatalogCategoryFilterState();
}

class _CatalogCategoryFilterState extends State<CatalogCategoryFilter> {
  final _activeKey = GlobalKey();
  late final ScrollController _scrollController;
  bool _hasMoreCategories = false;
  bool _scrollHintUpdateScheduled = false;
  Size? _viewportSize;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_updateScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollHint)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    if (size == _viewportSize) return;
    _viewportSize = size;
    _scheduleScrollHintUpdate();
  }

  @override
  void didUpdateWidget(covariant CatalogCategoryFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters.category != widget.filters.category) {
      _revealActiveChip();
    }
  }

  /// Brings the selected chip back on screen. Runs after the frame so the chip
  /// has its final position, and does nothing while the row is not laid out.
  void _revealActiveChip() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chipContext = _activeKey.currentContext;
      if (chipContext == null || !chipContext.mounted) return;

      Scrollable.ensureVisible(
        chipContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        alignment: 0.5,
      );
    });
  }

  void _updateScrollHint() {
    if (!_scrollController.hasClients) return;
    final canScrollFurther =
        _scrollController.position.maxScrollExtent - _scrollController.offset >
        1;
    if (canScrollFurther != _hasMoreCategories && mounted) {
      setState(() => _hasMoreCategories = canScrollFurther);
    }
  }

  void _scheduleScrollHintUpdate() {
    if (_scrollHintUpdateScheduled) return;
    _scrollHintUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollHintUpdateScheduled = false;
      if (mounted) _updateScrollHint();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = widget.filters.category;
    final surface = Theme.of(context).colorScheme.surface;

    // Scrolls sideways and grows downwards: a fixed height would clip the
    // chips at a large text scale, and bounded width would squeeze them.
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        _scheduleScrollHintUpdate();
        return false;
      },
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CatalogFilterChip(
                  key: selected == null ? _activeKey : null,
                  label: l10n.filterAll,
                  selected: selected == null,
                  icon: Icons.grid_view_rounded,
                  onSelected: widget.onClear,
                ),
                for (final category in CatalogCategory.values) ...[
                  const SizedBox(width: 8),
                  CatalogFilterChip(
                    key: selected == category ? _activeKey : null,
                    label: category.label(l10n),
                    selected: selected == category,
                    icon: category.icon,
                    onSelected: () => widget.onToggle(category),
                  ),
                ],
              ],
            ),
          ),
          if (_hasMoreCategories)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ExcludeSemantics(
                    child: Container(
                      width: 34,
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            surface.withValues(alpha: 0),
                            surface.withValues(alpha: 0.96),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Wrapping row of the delivery areas, with the same chips as the categories.
class CatalogLocationFilter extends StatelessWidget {
  const CatalogLocationFilter({
    super.key,
    required this.filters,
    required this.onSelect,
  });

  final CatalogFilters filters;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final location in [null, ...CatalogLocations.all])
          CatalogFilterChip(
            label: location ?? l10n.filterAll,
            selected: filters.location == location,
            icon: location == null
                ? Icons.public_rounded
                : Icons.place_outlined,
            onSelected: () => onSelect(location),
          ),
      ],
    );
  }
}
