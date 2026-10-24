import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/admin/application/admin_providers.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/domain/admin_product.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/domain/admin_stats.dart';
import 'package:agri_connect/features/admin/presentation/extensions/admin_status_l10n.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_dashboard_header.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_dashboard_skeleton.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/shared/widgets/attention_card.dart';
import 'package:agri_connect/shared/widgets/distribution_card.dart';
import 'package:agri_connect/shared/widgets/quick_action_grid.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/section_states.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// Administrator supervision dashboard.
///
/// Fed exclusively by the [AdminRepository] contract: figures come from
/// [AdminStats], the distributions are counted from the orders and deliveries
/// the repository returns, and the backlog comes from the moderation counters
/// the same aggregate already carries. No figure, trend or percentage on this
/// page is invented: when the repository cannot answer something, the section is
/// left out rather than filled with a plausible number.
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(adminRepositoryProvider);
    return AdminDashboardView(repository: repository);
  }
}

/// Stateful leaf owning the dashboard futures and the pull-to-refresh.
///
/// Each section owns its own future so one failing call degrades to a single
/// retryable card instead of taking the whole supervision surface down with it.
class AdminDashboardView extends ConsumerStatefulWidget {
  const AdminDashboardView({super.key, required this.repository});

  final AdminRepository repository;

  @override
  ConsumerState<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends ConsumerState<AdminDashboardView> {
  late Future<AdminStats> _stats;
  late Future<List<AdminOrder>> _orders;
  late Future<List<AdminDelivery>> _deliveries;
  late Future<List<AdminProduct>> _pendingProducts;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _stats = widget.repository.fetchStats();
    // Unfiltered on purpose: the distributions need every status, not only the
    // active slice.
    _orders = widget.repository.fetchOrders(recent: true);
    _deliveries = widget.repository.fetchDeliveries();
    _pendingProducts = widget.repository.fetchPendingModerationProducts();
  }

  Future<void> _refresh() async {
    setState(_load);
    // Every call is awaited before the indicator disappears: a refresh that
    // animates without reloading teaches the reader to distrust the gesture.
    await Future.wait([_stats, _orders, _deliveries, _pendingProducts]);
  }

  /// Reloads the dashboard after a section failed.
  ///
  /// The four calls are cheap and interdependent enough (a figure and its
  /// distribution come from the same state) that reloading them together is
  /// simpler than tracking, per section, which one is stale.
  void _retry(VoidCallback reload) => setState(reload);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    // The shell only exists for a signed-in administrator, but the session can
    // be dropped in the frame the router is redirecting: rendering nothing
    // beats a null assertion crash on the way out.
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
            // A dashboard stretched across a desktop window reads as a list of
            // lonely columns; the content keeps a readable measure and centres
            // itself instead.
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AdminDashboardHeader(
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
                    _buildModeration(context),
                    const SizedBox(height: 22),
                    _buildRecentOrders(context),
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

    return FutureBuilder<AdminStats>(
      future: _stats,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SectionError(
            id: 'overview',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final stats = snapshot.data;
        if (stats == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: AdminDashboardSkeleton(),
          );
        }

        final figures = <_Figure>[
          _Figure(
            id: 'users',
            icon: Icons.group_rounded,
            label: l10n.adminStatUsers,
            value: '${stats.totalUsers}',
            caption: l10n.adminStatUsersCaption(stats.pendingUsers),
            onTap: () => _goTo(RoleSection.users),
          ),
          _Figure(
            id: 'products',
            icon: Icons.inventory_2_rounded,
            label: l10n.adminStatProducts,
            value: '${stats.totalProducts}',
            caption: l10n.adminStatProductsCaption(stats.pendingProducts),
            onTap: () => _goTo(RoleSection.products),
          ),
          _Figure(
            id: 'orders',
            icon: Icons.receipt_long_rounded,
            label: l10n.adminStatOrders,
            value: '${stats.totalOrders}',
            caption: l10n.adminStatOrdersCaption(stats.pendingOrders),
            onTap: () => _goTo(RoleSection.orders),
          ),
          _Figure(
            id: 'deliveries',
            icon: Icons.local_shipping_rounded,
            label: l10n.adminStatDeliveries,
            value: '${stats.totalDeliveries}',
            caption: l10n.adminStatDeliveriesCaption(stats.activeDeliveries),
            onTap: () => _goTo(RoleSection.deliveries),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.adminOverviewTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            // Revenue leads: it is the one figure an administrator reports
            // upwards, so it gets the full width and the brand gradient.
            StatCard(
              key: const ValueKey('admin.figure.revenue'),
              icon: Icons.payments_rounded,
              accent: true,
              label: l10n.adminStatRevenue,
              value: Money.format(
                stats.ordersRevenue.round(),
                locale: context.localeCode,
              ),
              subtitle: l10n.adminStatRevenueCaption,
              labelMaxLines: 2,
            ),
            const SizedBox(height: 12),
            _FigureGrid(figures: figures),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------------- attention

  Widget _buildAttention(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<AdminStats>(
      future: _stats,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        if (stats == null) {
          // Loading or failed: the overview already explains itself, and an
          // empty backlog card would claim there is nothing to do.
          return const SizedBox.shrink();
        }

        final items = <AttentionItem>[
          if (stats.pendingUsers > 0)
            AttentionItem(
              id: 'users',
              count: stats.pendingUsers,
              label: l10n.adminAttentionUsers(stats.pendingUsers),
              icon: Icons.how_to_reg_rounded,
              color: AppColors.warning,
              onTap: () => _goTo(RoleSection.users),
            ),
          if (stats.pendingProducts > 0)
            AttentionItem(
              id: 'products',
              count: stats.pendingProducts,
              label: l10n.adminAttentionProducts(stats.pendingProducts),
              icon: Icons.inventory_2_rounded,
              color: AppColors.warning,
              onTap: () => _goTo(RoleSection.products),
            ),
          if (stats.pendingOrders > 0)
            AttentionItem(
              id: 'orders',
              count: stats.pendingOrders,
              label: l10n.adminAttentionOrders(stats.pendingOrders),
              icon: Icons.receipt_long_rounded,
              color: AppColors.accent,
              onTap: () => _goTo(RoleSection.orders),
            ),
          if (stats.activeDeliveries > 0)
            AttentionItem(
              id: 'deliveries',
              count: stats.activeDeliveries,
              label: l10n.adminAttentionDeliveries(stats.activeDeliveries),
              icon: Icons.local_shipping_rounded,
              color: AppColors.primary,
              onTap: () => _goTo(RoleSection.deliveries),
            ),
        ];

        return AttentionCard(
          title: l10n.adminAttentionTitle,
          items: items,
          emptyTitle: l10n.adminAttentionClearTitle,
          emptyBody: l10n.adminAttentionClearBody,
        );
      },
    );
  }

  // ----------------------------------------------------------- quick actions

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final stats = _stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.adminQuickActionsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        // Every tile below is an admin section the router already serves. The labels
        // are the console's own: the shared section label for products reads
        // "My products", which is a farmer's screen, not an administrator's.
        FutureBuilder<AdminStats>(
          future: stats,
          builder: (context, snapshot) {
            final data = snapshot.data;
            return QuickActionGrid(
              actions: [
                QuickAction(
                  label: l10n.adminQuickActionProducts,
                  icon: Icons.inventory_2_rounded,
                  primary: true,
                  badgeCount: data?.pendingProducts,
                  onTap: () => _goTo(RoleSection.products),
                ),
                QuickAction(
                  label: l10n.adminQuickActionUsers,
                  icon: Icons.people_alt_rounded,
                  badgeCount: data?.pendingUsers,
                  onTap: () => _goTo(RoleSection.users),
                ),
                QuickAction(
                  label: l10n.adminQuickActionDeliveries,
                  icon: Icons.local_shipping_rounded,
                  badgeCount: data?.activeDeliveries,
                  onTap: () => _goTo(RoleSection.deliveries),
                ),
                QuickAction(
                  label: l10n.adminQuickActionAnalytics,
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

  // ------------------------------------------------------------ distribution

  Widget _buildDistribution(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final scheme = theme.colorScheme;

    final ordersCard = FutureBuilder<List<AdminOrder>>(
      future: _orders,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SectionError(
            id: 'distribution.orders',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final orders = snapshot.data;
        if (orders == null) return const _DistributionSkeleton();
        return DistributionCard(
          key: const ValueKey('admin.distribution.orders'),
          title: l10n.adminDistributionOrders,
          segments: [
            for (final status in AdminOrderStatus.values)
              DistributionSegment(
                label: status.label(l10n),
                count: orders.where((o) => o.status == status).length,
                color: status.color(scheme),
              ),
          ],
        );
      },
    );

    final deliveriesCard = FutureBuilder<List<AdminDelivery>>(
      future: _deliveries,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SectionError(
            id: 'distribution.deliveries',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final deliveries = snapshot.data;
        if (deliveries == null) return const _DistributionSkeleton();
        return DistributionCard(
          key: const ValueKey('admin.distribution.deliveries'),
          title: l10n.adminDistributionDeliveries,
          segments: [
            for (final status in AdminDeliveryStatus.values)
              DistributionSegment(
                label: status.label(l10n),
                count: deliveries.where((d) => d.status == status).length,
                color: status.color(scheme),
              ),
          ],
        );
      },
    );

    final usersCard = FutureBuilder<AdminStats>(
      future: _stats,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SectionError(
            id: 'distribution.users',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final stats = snapshot.data;
        if (stats == null) return const _DistributionSkeleton();
        return DistributionCard(
          key: const ValueKey('admin.distribution.users'),
          title: l10n.adminDistributionUsers,
          segments: [
            DistributionSegment(
              label: UserRole.supplier.label(l10n),
              count: stats.farmers,
              color: AppColors.primary,
            ),
            DistributionSegment(
              label: UserRole.buyer.label(l10n),
              count: stats.buyers,
              color: AppColors.accent,
            ),
            DistributionSegment(
              label: UserRole.driver.label(l10n),
              count: stats.drivers,
              color: AppColors.success,
            ),
            DistributionSegment(
              label: UserRole.admin.label(l10n),
              count: stats.admins,
              color: scheme.tertiary,
            ),
          ],
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.adminDistributionTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        // Three cards side by side once there is room for them; stacked on a
        // phone, where three narrow bars would be unreadable anyway.
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            if (constraints.maxWidth >= 760) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: ordersCard),
                  const SizedBox(width: gap),
                  Expanded(child: deliveriesCard),
                  const SizedBox(width: gap),
                  Expanded(child: usersCard),
                ],
              );
            }
            return Column(
              children: [
                ordersCard,
                const SizedBox(height: gap),
                deliveriesCard,
                const SizedBox(height: gap),
                usersCard,
              ],
            );
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------- moderation

  Widget _buildModeration(BuildContext context) {
    return FutureBuilder<List<AdminProduct>>(
      future: _pendingProducts,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SectionError(
            id: 'moderation',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final products = snapshot.data;
        if (products == null) return const _ListSkeleton(rows: 2);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: context.l10n.adminModerationTitle,
              actionLabel: context.l10n.seeAll,
              onAction: () => _goTo(RoleSection.products),
            ),
            const SizedBox(height: 10),
            if (products.isEmpty)
              _InlineEmpty(
                id: 'moderation',
                icon: Icons.verified_rounded,
                label: context.l10n.adminModerationEmpty,
              )
            else
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < products.length && i < 3; i++) ...[
                      if (i > 0)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                      _ModerationRow(product: products[i]),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------ recent orders

  Widget _buildRecentOrders(BuildContext context) {
    return FutureBuilder<List<AdminOrder>>(
      future: _orders,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SectionError(
            id: 'recentOrders',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final orders = snapshot.data;
        if (orders == null) return const _ListSkeleton(rows: 3);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: context.l10n.adminRecentOrdersTitle),
            const SizedBox(height: 10),
            if (orders.isEmpty)
              _InlineEmpty(
                id: 'recentOrders',
                icon: Icons.receipt_long_rounded,
                label: context.l10n.adminRecentOrdersEmpty,
              )
            else
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < orders.length && i < 5; i++) ...[
                      if (i > 0)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                      _RecentOrderRow(order: orders[i]),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  void _goTo(RoleSection section) {
    final prefix = ref.read(authControllerProvider).user?.role.routePrefix;
    if (prefix == null) return;
    context.go('$prefix/${section.routeName}');
  }
}

/// One secondary figure of the overview grid.
class _Figure {
  const _Figure({
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

/// Responsive grid of [_Figure] tiles.
///
/// Two columns on a phone, four once the tiles are wide enough to hold a
/// caption. Rows share their height through [IntrinsicHeight] and every tile
/// sizes itself from its text, so no fixed height can break when a caption wraps
/// or when the reader enlarges the fonts.
class _FigureGrid extends StatelessWidget {
  const _FigureGrid({required this.figures});

  final List<_Figure> figures;

  /// Width needed before four tiles fit on one row.
  static const double _wideBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= _wideBreakpoint ? 4 : 2;
        final rows = <List<_Figure>>[
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

  Widget _tile(_Figure figure) => StatCard(
    key: ValueKey('admin.figure.${figure.id}'),
    icon: figure.icon,
    label: figure.label,
    value: figure.value,
    subtitle: figure.caption,
    onTap: figure.onTap,
    labelMaxLines: 2,
  );
}

/// A product waiting for a moderation decision.
class _ModerationRow extends StatelessWidget {
  const _ModerationRow({required this.product});

  final AdminProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.warning.withValues(alpha: 0.12),
        child: const Icon(
          Icons.inventory_2_rounded,
          size: 19,
          color: AppColors.warning,
        ),
      ),
      title: Text(
        product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      // Owner and category share the metadata line; the price keeps its own
      // space on the right instead of being pushed into an ellipsis.
      subtitle: Text(
        '${product.ownerName} · ${product.category}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        Money.format(product.price.round(), locale: context.localeCode),
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}

/// The latest orders, most recent first.
class _RecentOrderRow extends StatelessWidget {
  const _RecentOrderRow({required this.order});

  final AdminOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final scheme = theme.colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: Icon(
          Icons.receipt_long_rounded,
          size: 19,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        order.orderNumber,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        l10n.adminOrderBuyerCaption(
          order.buyerName,
          Money.format(order.amount.round(), locale: context.localeCode),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // A dense status line: a Material Chip reserves a 48dp tap target this
      // read-only row does not need, and never gives characters back.
      trailing: StatusBadge(
        label: order.status.label(l10n),
        color: order.status.color(scheme),
      ),
    );
  }
}

/// Placeholder for a distribution card.
class _DistributionSkeleton extends StatelessWidget {
  const _DistributionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonBlock(height: 104);
  }
}

/// Placeholder for a recent-items card.
class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton({required this.rows});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < rows - 1 ? 10 : 0),
            child: const _SkeletonBlock(height: 62),
          ),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

/// Section-level failure: the rest of the dashboard stays usable.
///
/// Binds the shared [SectionErrorCard] layout to the Admin wording and key
/// namespace, so this dashboard and the Super Admin console cannot drift apart.
class _SectionError extends StatelessWidget {
  const _SectionError({
    required this.id,
    required this.message,
    required this.onRetry,
  });

  final String id;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectionErrorCard(
      keyPrefix: 'admin',
      id: id,
      title: l10n.adminSectionLoadError,
      detail: l10n.adminSectionLoadErrorDetail(message),
      retryLabel: l10n.retry,
      onRetry: onRetry,
    );
  }
}

/// Inline "nothing here" line, sized for a section rather than a whole page.
class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({
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
      keyPrefix: 'admin',
      id: id,
      icon: icon,
      label: label,
    );
  }
}
