import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/admin/application/admin_providers.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/domain/admin_moderation_status.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/domain/admin_product.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/domain/admin_stats.dart';
import 'package:agri_connect/features/admin/presentation/extensions/admin_moderation_status_l10n.dart';
import 'package:agri_connect/features/admin/presentation/extensions/admin_status_l10n.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/shared/widgets/distribution_card.dart';
import 'package:agri_connect/shared/widgets/section_states.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';

/// Administrator — platform analytics.
///
/// Everything on this screen is counted from what the [AdminRepository]
/// returns: the platform volume and the role split from [AdminStats], and the
/// status distributions from the product, order and delivery lists the same
/// contract serves. There is deliberately no time series — the repository keeps
/// no history, so a chart here would be an invention.
///
/// The figures [AdminStats] already aggregates are read as-is rather than
/// recomputed: [AdminStats.publishedProducts], [AdminStats.activeOrders] and
/// [AdminStats.completedDeliveries] surface indicators that the dashboard left
/// dormant, without a second, drifting definition of each count.
class AdminAnalyticsPage extends ConsumerStatefulWidget {
  const AdminAnalyticsPage({super.key, this.repository});

  /// Injected in tests; defaults to the production provider.
  final AdminRepository? repository;

  @override
  ConsumerState<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends ConsumerState<AdminAnalyticsPage> {
  late Future<AdminStats> _stats;
  late Future<List<AdminProduct>> _products;
  late Future<List<AdminOrder>> _orders;
  late Future<List<AdminDelivery>> _deliveries;

  AdminRepository get _repository =>
      widget.repository ?? ref.read(adminRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _stats = _repository.fetchStats();
    // Unfiltered on purpose: the distributions need every status, not only the
    // active slice.
    _products = _repository.fetchProducts();
    _orders = _repository.fetchOrders();
    _deliveries = _repository.fetchDeliveries();
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_stats, _products, _orders, _deliveries]);
  }

  /// Reloads the page after a section failed.
  ///
  /// The four calls are cheap and interdependent enough (a figure and its
  /// distribution come from the same state) that reloading them together is
  /// simpler than tracking, per section, which one is stale.
  void _retry(VoidCallback reload) => setState(reload);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(title: l10n.adminAnalyticsTitle),
                    const SizedBox(height: 4),
                    Text(
                      l10n.adminAnalyticsSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildFigures(context),
                    const SizedBox(height: 22),
                    _buildDistributions(context),
                    const SizedBox(height: 18),
                    // Stated rather than drawn: an empty chart frame would
                    // suggest the data is missing, while the sentence says
                    // plainly that this build has none.
                    Text(
                      l10n.adminAnalyticsNoHistory,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ figures

  Widget _buildFigures(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<AdminStats>(
      future: _stats,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SectionError(
            id: 'figures',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final stats = snapshot.data;
        if (stats == null) return const _AnalyticsSkeleton();

        // An empty platform is said in words: a grid of zeroes would look like
        // real figures, while there is nothing to analyse yet.
        if (stats.totalUsers == 0 &&
            stats.totalProducts == 0 &&
            stats.totalOrders == 0 &&
            stats.totalDeliveries == 0) {
          return _InlineEmpty(
            id: 'figures',
            icon: Icons.insights_rounded,
            label: l10n.adminAnalyticsEmpty,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionTitle(l10n.adminAnalyticsVolumeTitle),
            const SizedBox(height: 10),
            _FigureGrid(
              figures: [
                _figure(
                  id: 'users',
                  icon: Icons.group_rounded,
                  label: l10n.adminStatUsers,
                  value: stats.totalUsers,
                ),
                _figure(
                  id: 'products',
                  icon: Icons.inventory_2_rounded,
                  label: l10n.adminStatProducts,
                  value: stats.totalProducts,
                ),
                _figure(
                  id: 'orders',
                  icon: Icons.receipt_long_rounded,
                  label: l10n.adminStatOrders,
                  value: stats.totalOrders,
                ),
                _figure(
                  id: 'deliveries',
                  icon: Icons.local_shipping_rounded,
                  label: l10n.adminStatDeliveries,
                  value: stats.totalDeliveries,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle(l10n.adminAnalyticsIndicatorsTitle),
            const SizedBox(height: 10),
            _FigureGrid(
              figures: [
                _figure(
                  id: 'published',
                  icon: Icons.storefront_rounded,
                  label: l10n.adminAnalyticsPublished,
                  value: stats.publishedProducts,
                  accent: true,
                ),
                _figure(
                  id: 'activeOrders',
                  icon: Icons.pending_actions_rounded,
                  label: l10n.adminAnalyticsActiveOrders,
                  value: stats.activeOrders,
                ),
                _figure(
                  id: 'completedDeliveries',
                  icon: Icons.task_alt_rounded,
                  label: l10n.adminAnalyticsCompletedDeliveries,
                  value: stats.completedDeliveries,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  StatCard _figure({
    required String id,
    required IconData icon,
    required String label,
    required int value,
    bool accent = false,
  }) {
    return StatCard(
      key: ValueKey('admin.analytics.figure.$id'),
      icon: icon,
      label: label,
      value: '$value',
      accent: accent,
      labelMaxLines: 2,
    );
  }

  // ------------------------------------------------------------ distributions

  Widget _buildDistributions(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

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
          key: const ValueKey('admin.analytics.distribution.users'),
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

    final productsCard = FutureBuilder<List<AdminProduct>>(
      future: _products,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SectionError(
            id: 'distribution.products',
            message: '${snapshot.error}',
            onRetry: () => _retry(_load),
          );
        }
        final products = snapshot.data;
        if (products == null) return const _DistributionSkeleton();
        return DistributionCard(
          key: const ValueKey('admin.analytics.distribution.products'),
          title: l10n.adminDistributionProducts,
          segments: [
            for (final status in AdminModerationStatus.values)
              DistributionSegment(
                label: status.label(l10n),
                count: products.where((p) => p.moderation == status).length,
                color: status.color(),
              ),
          ],
        );
      },
    );

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
          key: const ValueKey('admin.analytics.distribution.orders'),
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
          key: const ValueKey('admin.analytics.distribution.deliveries'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(l10n.adminDistributionTitle),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            final columns = constraints.maxWidth >= 760 ? 2 : 1;
            final tileWidth = columns == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                for (final card in [
                  usersCard,
                  productsCard,
                  ordersCard,
                  deliveriesCard,
                ])
                  SizedBox(width: tileWidth, child: card),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Section heading used inside the analytics page.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

/// Responsive grid of analytics tiles.
///
/// Two columns on a phone, up to four on a wide window; a group of three fills
/// its own row without leaving a hole. Every tile sizes itself from its text,
/// so no fixed height can break when a label wraps or the reader enlarges the
/// fonts.
class _FigureGrid extends StatelessWidget {
  const _FigureGrid({required this.figures});

  final List<StatCard> figures;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final maxColumns = constraints.maxWidth >= 900 ? 4 : 2;
        final columns = figures.length < maxColumns
            ? figures.length
            : maxColumns;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final figure in figures)
              SizedBox(width: tileWidth, child: figure),
          ],
        );
      },
    );
  }
}

/// Placeholder for a distribution card.
class _DistributionSkeleton extends StatelessWidget {
  const _DistributionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonBox(height: 104, radius: 16);
  }
}

/// Placeholder for the figures while the aggregate is loading.
class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SkeletonBox(width: 160, height: 14, radius: 6),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 96, radius: 18)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 96, radius: 18)),
          ],
        ),
        SizedBox(height: 18),
        SkeletonBox(width: 160, height: 14, radius: 6),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 96, radius: 18)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 96, radius: 18)),
          ],
        ),
      ],
    );
  }
}

/// Section-level failure: the rest of the page stays usable.
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
