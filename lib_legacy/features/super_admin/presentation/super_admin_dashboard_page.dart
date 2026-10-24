import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/super_admin/application/super_admin_providers.dart';
import 'package:agri_connect/features/super_admin/domain/staff_account.dart';
import 'package:agri_connect/features/super_admin/domain/staff_permission.dart';
import 'package:agri_connect/features/super_admin/domain/super_admin_repository.dart';
import 'package:agri_connect/features/super_admin/domain/system_event.dart';
import 'package:agri_connect/features/super_admin/presentation/extensions/staff_permission_l10n.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/super_admin_activity_card.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/super_admin_dashboard_header.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/super_admin_dashboard_skeleton.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/super_admin_states.dart';
import 'package:agri_connect/shared/widgets/attention_card.dart';
import 'package:agri_connect/shared/widgets/distribution_card.dart';
import 'package:agri_connect/shared/widgets/quick_action_grid.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';

/// Platform supervision dashboard.
///
/// Fed exclusively by the [SuperAdminRepository] contract: the figures come from
/// [PlatformOverview], the staff distribution is counted from the directory the
/// repository returns, and the backlog is the counters that aggregate already
/// carries. Nothing here is invented: the console shows totals, and since the
/// repository holds no history it claims no trend either.
class SuperAdminDashboardPage extends ConsumerWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(superAdminRepositoryProvider);
    return SuperAdminDashboardView(repository: repository);
  }
}

/// Stateful leaf owning the dashboard futures and the pull-to-refresh.
///
/// Each section owns its own future, so one failing call degrades to a single
/// retryable card instead of taking the whole console down with it.
class SuperAdminDashboardView extends ConsumerStatefulWidget {
  const SuperAdminDashboardView({
    super.key,
    required this.repository,
    this.currentUserId,
  });

  final SuperAdminRepository repository;

  /// Session identifier, so the console can leave the account in use alone.
  /// Defaults to empty for tests that do not model a session.
  final String? currentUserId;

  @override
  ConsumerState<SuperAdminDashboardView> createState() =>
      _SuperAdminDashboardViewState();
}

class _SuperAdminDashboardViewState
    extends ConsumerState<SuperAdminDashboardView> {
  late Future<PlatformOverview> _overview;
  late Future<List<StaffAccount>> _staff;
  late Future<List<SystemEvent>> _events;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _overview = _guard(widget.repository.fetchOverview());
    // Unfiltered on purpose: the staff distribution needs every access level,
    // not only the active members.
    _staff = _guard(widget.repository.fetchStaff());
    _events = _guard(widget.repository.fetchRecentEvents());
  }

  /// Keeps an immediate repository failure from escaping before the rebuild.
  ///
  /// These futures are created outside a build, and a builder only subscribes
  /// on the next frame. Without a listener already attached, a call that fails
  /// right away reaches the zone as an unhandled error instead of becoming the
  /// retryable card the console shows.
  static Future<T> _guard<T>(Future<T> future) {
    unawaited(future.then<void>((_) {}, onError: (Object _) {}));
    return future;
  }

  Future<void> _refresh() async {
    setState(_load);
    // Every call is awaited before the indicator disappears: a refresh that
    // animates without reloading teaches the reader to distrust the gesture.
    //
    // The errors are absorbed on purpose. Each section renders its own
    // retryable card, and letting one of them escape here would turn a
    // recoverable section failure into an unhandled error that never reaches
    // the reader.
    await Future.wait([
      _overview.then<void>((_) {}, onError: (Object _) {}),
      _staff.then<void>((_) {}, onError: (Object _) {}),
      _events.then<void>((_) {}, onError: (Object _) {}),
    ]);
  }

  /// Reloads the console after a section failed.
  ///
  /// The three calls share the same in-memory state, so reloading them together
  /// keeps the figures and the distributions consistent instead of leaving one
  /// stale next to a fresh neighbour.
  void _retry(VoidCallback reload) => setState(reload);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    // The shell only exists for a signed-in Super Admin, but the session can be
    // dropped in the frame the router is redirecting: rendering nothing beats a
    // null assertion crash on the way out.
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePadding,
            AppSizes.pagePadding,
            AppSizes.pagePadding,
            // Clears the shell's navigation bar so the last card is reachable.
            28,
          ),
          children: [
            // A console stretched across a desktop window reads as a list of
            // lonely columns; the content keeps a readable measure and centres
            // itself instead.
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SuperAdminDashboardHeader(
                      fullName: user.fullName,
                      onRefresh: _refresh,
                    ),
                    const SizedBox(height: 18),
                    _buildOverview(context),
                    const SizedBox(height: 18),
                    _buildAttention(context),
                    const SizedBox(height: 18),
                    _buildQuickActions(context),
                    const SizedBox(height: 22),
                    _buildDistribution(context),
                    const SizedBox(height: 22),
                    _buildActivity(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- overview

  Widget _buildOverview(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return FutureBuilder<PlatformOverview>(
      future: _overview,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SuperAdminSectionError(
            id: 'overview',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final overview = snapshot.data;
        if (overview == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SuperAdminDashboardSkeleton(),
          );
        }

        final figures = <SuperAdminFigure>[
          SuperAdminFigure(
            id: 'users',
            icon: Icons.group_rounded,
            label: l10n.superAdminStatUsers,
            value: '${overview.totalUsers}',
            caption: l10n.superAdminStatUsersCaption(overview.pendingUsers),
            onTap: () => _goTo(RoleSection.analytics),
          ),
          SuperAdminFigure(
            id: 'staff',
            icon: Icons.admin_panel_settings_rounded,
            label: l10n.superAdminStatStaff,
            value: '${overview.staff}',
            caption: l10n.superAdminStatStaffCaption,
            onTap: () => _goTo(RoleSection.users),
          ),
          SuperAdminFigure(
            id: 'products',
            icon: Icons.inventory_2_rounded,
            label: l10n.superAdminStatProducts,
            value: '${overview.publishedProducts}',
            caption: l10n.superAdminStatProductsCaption(
              overview.publishedProducts,
            ),
            // Moderation belongs to the Administrator console, which the
            // Super Admin does not own: the tile states a fact without
            // advertising a destination the router will not serve.
            onTap: null,
          ),
          SuperAdminFigure(
            id: 'deliveries',
            icon: Icons.local_shipping_rounded,
            label: l10n.superAdminStatDeliveries,
            value: '${overview.activeDeliveries}',
            caption: l10n.superAdminStatDeliveriesCaption(
              overview.activeDeliveries,
            ),
            onTap: null,
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.superAdminOverviewTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            // Volume of business leads: it is the one figure a platform is
            // judged on, so it gets the full width and the brand gradient.
            StatCard(
              key: const ValueKey('superAdmin.figure.gmv'),
              icon: Icons.payments_rounded,
              accent: true,
              label: l10n.superAdminStatGmv,
              value: Money.format(
                overview.grossMerchandiseValue.round(),
                locale: context.localeCode,
              ),
              subtitle: l10n.superAdminStatGmvCaption,
              labelMaxLines: 2,
            ),
            const SizedBox(height: 12),
            SuperAdminFigureGrid(figures: figures),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------------- attention

  Widget _buildAttention(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<PlatformOverview>(
      future: _overview,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const SizedBox.shrink();
        final overview = snapshot.data;
        if (overview == null) {
          return const SkeletonBox(height: 132, radius: 16);
        }

        // Only counters above zero become rows, so an idle platform shows the
        // "nothing to do" card instead of three zeroes.
        final items = <AttentionItem>[
          if (overview.pendingModeration > 0)
            AttentionItem(
              id: 'moderation',
              count: overview.pendingModeration,
              label: l10n.superAdminAttentionModeration,
              icon: Icons.inventory_2_rounded,
              color: AppColors.warning,
            ),
          if (overview.pendingUsers > 0)
            AttentionItem(
              id: 'users',
              count: overview.pendingUsers,
              label: l10n.superAdminAttentionUsers,
              icon: Icons.verified_user_rounded,
              color: AppColors.accent,
            ),
          if (overview.activeDeliveries > 0)
            AttentionItem(
              id: 'deliveries',
              count: overview.activeDeliveries,
              label: l10n.superAdminAttentionDeliveries,
              icon: Icons.local_shipping_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
        ];

        return AttentionCard(
          title: l10n.superAdminAttentionTitle,
          items: items,
          emptyTitle: l10n.superAdminAttentionClearTitle,
          emptyBody: l10n.superAdminAttentionClearBody,
        );
      },
    );
  }

  // ------------------------------------------------------------ quick actions

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.superAdminQuickActionsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        // Every tile below is a console section the router already serves.
        FutureBuilder<PlatformOverview>(
          future: _overview,
          builder: (context, snapshot) {
            final data = snapshot.data;
            return QuickActionGrid(
              actions: [
                QuickAction(
                  label: l10n.superAdminQuickActionStaff,
                  icon: Icons.admin_panel_settings_rounded,
                  primary: true,
                  badgeCount: data?.staff,
                  onTap: () => _goTo(RoleSection.users),
                ),
                QuickAction(
                  label: l10n.superAdminQuickActionPlatform,
                  icon: Icons.settings_rounded,
                  onTap: () => _goTo(RoleSection.platform),
                ),
                QuickAction(
                  label: l10n.superAdminQuickActionAnalytics,
                  icon: Icons.bar_chart_rounded,
                  onTap: () => _goTo(RoleSection.analytics),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------- distribution

  Widget _buildDistribution(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<List<StaffAccount>>(
      future: _staff,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SuperAdminSectionError(
            id: 'distribution',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final staff = snapshot.data;
        if (staff == null) {
          return const SkeletonBox(height: 150, radius: 16);
        }

        // Counted from the directory itself rather than from a stored rollup, so
        // the distribution cannot disagree with the tiles above it.
        final scheme = Theme.of(context).colorScheme;
        int countWhere(StaffAccessLevel level) =>
            staff.where((s) => s.accessLevel == level).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.superAdminDistributionTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  DistributionCard(
                    key: const ValueKey('superAdmin.distribution.staff'),
                    title: l10n.superAdminDistributionStaff,
                    segments: [
                      DistributionSegment(
                        label: l10n.superAdminStaffAccessFull,
                        count: countWhere(StaffAccessLevel.fullAccess),
                        color: AppColors.success,
                      ),
                      DistributionSegment(
                        label: l10n.superAdminStaffAccessReadOnly,
                        count: countWhere(StaffAccessLevel.readOnly),
                        color: scheme.primary,
                      ),
                      DistributionSegment(
                        label: l10n.superAdminStaffAccessSuspended,
                        count: countWhere(StaffAccessLevel.suspended),
                        color: scheme.error,
                      ),
                    ],
                  ),
                  DistributionCard(
                    key: const ValueKey('superAdmin.distribution.permissions'),
                    title: l10n.superAdminAnalyticsStaffShare,
                    segments: [
                      for (final permission in StaffPermission.values)
                        DistributionSegment(
                          label: permission.label(l10n),
                          count: staff
                              .where((s) => s.hasPermission(permission))
                              .length,
                          color: permission.isSuperAdminOnly
                              ? AppColors.accent
                              : scheme.primary,
                        ),
                    ],
                  ),
                ];

                // Two cards side by side only once each holds a legend without
                // wrapping; below that they stack, which is what a phone needs.
                if (constraints.maxWidth >= 760) {
                  // Start, not stretch: this row sits in an unbounded column,
                  // so a stretched cross axis would ask for an infinite height,
                  // and an IntrinsicHeight cannot wrap a LayoutBuilder.
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[1]),
                    ],
                  );
                }
                return Column(
                  children: [cards[0], const SizedBox(height: 12), cards[1]],
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------------- activity

  Widget _buildActivity(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<List<SystemEvent>>(
      future: _events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SuperAdminSectionError(
            id: 'activity',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final events = snapshot.data;
        if (events == null) {
          return const SkeletonBox(height: 190, radius: 16);
        }
        return SuperAdminActivityCard(
          title: l10n.superAdminActivityTitle,
          events: events,
        );
      },
    );
  }

  void _goTo(RoleSection section) {
    final role = ref.read(authControllerProvider).user?.role ?? UserRole.root;
    context.go('${role.routePrefix}/${section.routeName}');
  }
}

/// One secondary figure of the overview grid.
class SuperAdminFigure {
  const SuperAdminFigure({
    required this.id,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.onTap,
  });

  /// Stable identifier of the figure, independent of its localized label.
  final String id;

  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final VoidCallback? onTap;
}

/// Responsive grid of [SuperAdminFigure] tiles.
///
/// Two columns on a phone, four once the tiles are wide enough to hold a
/// caption. Rows share their height through [IntrinsicHeight] and every tile
/// sizes itself from its text, so no fixed height can break when a caption wraps
/// or when the reader enlarges the fonts.
class SuperAdminFigureGrid extends StatelessWidget {
  const SuperAdminFigureGrid({super.key, required this.figures});

  final List<SuperAdminFigure> figures;

  /// Width needed before four tiles fit on one row.
  static const double _wideBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= _wideBreakpoint ? 4 : 2;
        final rows = <List<SuperAdminFigure>>[
          for (var i = 0; i < figures.length; i += columns)
            figures.sublist(
              i,
              i + columns > figures.length ? figures.length : i + columns,
            ),
        ];

        return Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = 0; j < rows[i].length; j++) ...[
                      if (j > 0) const SizedBox(width: 12),
                      Expanded(child: _tile(rows[i][j])),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _tile(SuperAdminFigure figure) => StatCard(
    key: ValueKey('superAdmin.figure.${figure.id}'),
    icon: figure.icon,
    label: figure.label,
    value: figure.value,
    subtitle: figure.caption,
    onTap: figure.onTap,
    labelMaxLines: 2,
  );
}
