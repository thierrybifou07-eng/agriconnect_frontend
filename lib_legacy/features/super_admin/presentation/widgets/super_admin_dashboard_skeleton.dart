import 'package:flutter/material.dart';

import 'package:agri_connect/shared/widgets/skeletons.dart';

/// Placeholder reproducing the real shape of the Super Admin console.
///
/// Each block stands for one section of the loaded page and keeps that
/// section's geometry: the branded header, the leading figure, a KPI grid, a
/// backlog card, the quick actions and two list rows of activity. The console
/// therefore keeps its layout from the first frame instead of collapsing into a
/// spinner and jumping when the data lands.
class SuperAdminDashboardSkeleton extends StatelessWidget {
  const SuperAdminDashboardSkeleton({super.key, this.columns = 2});

  /// Number of KPI columns of the real grid being reproduced.
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: a plate with an identity block and a trailing action.
        Container(
          height: 148,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(18),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(width: 38, height: 38, radius: 12),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(height: 18),
                        SizedBox(height: 8),
                        SkeletonBox(width: 150, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              SkeletonBox(width: 190, height: 26, radius: 999),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // Leading figure, then the secondary grid.
        const SkeletonBox(height: 84, radius: 18),
        const SizedBox(height: 12),
        _SkeletonGrid(columns: columns),
        const SizedBox(height: 18),
        const SkeletonBox(height: 132, radius: 16),
        const SizedBox(height: 18),
        const SkeletonBox(height: 150, radius: 16),
        const SizedBox(height: 18),
        const SkeletonBox(height: 190, radius: 16),
      ],
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid({required this.columns});

  final int columns;

  /// The console always shows four secondary figures, whether they sit on one
  /// row or on two.
  static const int _tileCount = 4;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < _tileCount; start += columns) {
      final filled = (_tileCount - start).clamp(0, columns);
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: start + columns < _tileCount ? 12 : 0,
          ),
          child: Row(
            children: [
              for (var i = 0; i < columns; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: i < filled
                      ? const SkeletonBox(height: 104, radius: 18)
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}
