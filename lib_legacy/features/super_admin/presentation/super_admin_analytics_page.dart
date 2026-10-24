import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/super_admin/application/super_admin_providers.dart';
import 'package:agri_connect/features/super_admin/domain/staff_account.dart';
import 'package:agri_connect/features/super_admin/domain/staff_permission.dart';
import 'package:agri_connect/features/super_admin/domain/super_admin_repository.dart';
import 'package:agri_connect/features/super_admin/domain/system_event.dart';
import 'package:agri_connect/features/super_admin/presentation/extensions/staff_permission_l10n.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/super_admin_activity_card.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/super_admin_states.dart';
import 'package:agri_connect/shared/widgets/distribution_card.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';

/// Platform analytics.
///
/// Everything on this screen is counted from what the repository returns: the
/// account split from the overview aggregate, the staff split from the
/// directory, and the rights distribution from the permissions those members
/// hold. There is deliberately no time series — the repository keeps no history,
/// so a chart here would be an invention.
class SuperAdminAnalyticsPage extends ConsumerStatefulWidget {
  const SuperAdminAnalyticsPage({super.key, this.repository});

  /// Injected in tests; defaults to the production provider.
  final SuperAdminRepository? repository;

  @override
  ConsumerState<SuperAdminAnalyticsPage> createState() =>
      _SuperAdminAnalyticsPageState();
}

class _SuperAdminAnalyticsPageState
    extends ConsumerState<SuperAdminAnalyticsPage> {
  late Future<PlatformOverview> _overview;
  late Future<List<StaffAccount>> _staff;
  late Future<List<SystemEvent>> _events;

  SuperAdminRepository get _repository =>
      widget.repository ?? ref.read(superAdminRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _overview = _repository.fetchOverview();
    _staff = _repository.fetchStaff();
    _events = _repository.fetchRecentEvents();
  }

  void _reload() => setState(_load);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePadding,
                  AppSizes.pagePadding,
                  AppSizes.pagePadding,
                  28,
                ),
                children: [
                  SectionHeader(title: l10n.superAdminAnalyticsTitle),
                  const SizedBox(height: 4),
                  Text(
                    l10n.superAdminAnalyticsSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FutureBuilder<PlatformOverview>(
                    future: _overview,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return SuperAdminSectionError(
                          id: 'overview',
                          message: '${snapshot.error}',
                          onRetry: _reload,
                        );
                      }
                      final overview = snapshot.data;
                      if (overview == null) {
                        return const _AnalyticsSkeleton();
                      }
                      return _buildFigures(context, overview);
                    },
                  ),
                  const SizedBox(height: 22),
                  FutureBuilder<List<StaffAccount>>(
                    future: _staff,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return SuperAdminSectionError(
                          id: 'staff',
                          message: '${snapshot.error}',
                          onRetry: _reload,
                        );
                      }
                      final staff = snapshot.data;
                      if (staff == null) {
                        return const SkeletonBox(height: 170, radius: 16);
                      }
                      return _buildStaff(context, staff);
                    },
                  ),
                  const SizedBox(height: 22),
                  FutureBuilder<List<SystemEvent>>(
                    future: _events,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return SuperAdminSectionError(
                          id: 'activity',
                          message: '${snapshot.error}',
                          onRetry: _reload,
                        );
                      }
                      return SuperAdminActivityCard(
                        title: l10n.superAdminActivityTitle,
                        events: snapshot.data ?? const <SystemEvent>[],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFigures(BuildContext context, PlatformOverview overview) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatCard(
          key: const ValueKey('superAdmin.analytics.gmv'),
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
        LayoutBuilder(
          builder: (context, constraints) {
            final figures = [
              StatCard(
                key: const ValueKey('superAdmin.analytics.orders'),
                icon: Icons.receipt_long_rounded,
                label: l10n.superAdminStatOrders,
                value: '${overview.totalOrders}',
                subtitle: l10n.superAdminAnalyticsOrdersCaption(
                  overview.totalOrders,
                ),
                labelMaxLines: 2,
              ),
              StatCard(
                key: const ValueKey('superAdmin.analytics.openOrders'),
                icon: Icons.pending_actions_rounded,
                label: l10n.superAdminAnalyticsOpenOrders,
                value: '${overview.openOrders}',
                subtitle: l10n.superAdminAnalyticsOpenOrdersCaption(
                  overview.openOrders,
                ),
                labelMaxLines: 2,
              ),
              StatCard(
                key: const ValueKey('superAdmin.analytics.published'),
                icon: Icons.inventory_2_rounded,
                label: l10n.superAdminStatProducts,
                value: '${overview.publishedProducts}',
                subtitle: l10n.superAdminAnalyticsPublishedCaption(
                  overview.publishedProducts,
                ),
                labelMaxLines: 2,
              ),
              StatCard(
                key: const ValueKey('superAdmin.analytics.staff'),
                icon: Icons.admin_panel_settings_rounded,
                label: l10n.superAdminStatStaff,
                value: '${overview.staff}',
                subtitle: l10n.superAdminAnalyticsStaffCaption,
                labelMaxLines: 2,
              ),
            ];

            final columns = constraints.maxWidth >= 860 ? 4 : 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final figure in figures)
                  SizedBox(
                    width: columns == 4
                        ? (constraints.maxWidth - 12 * (columns - 1)) / columns
                        : (constraints.maxWidth - 12) / 2,
                    child: figure,
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        // Stated rather than drawn: an empty chart frame would suggest the data
        // is missing, while the sentence says plainly that this build has none.
        Text(
          l10n.superAdminAnalyticsNoTrend,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStaff(BuildContext context, List<StaffAccount> staff) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    int countWhere(StaffAccessLevel level) =>
        staff.where((s) => s.accessLevel == level).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.superAdminAnalyticsAudience,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        DistributionCard(
          key: const ValueKey('superAdmin.analytics.accessLevels'),
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
        const SizedBox(height: 12),
        // Counted per right, so the reader can see who actually holds each
        // capability rather than inferring it from the access level. The legend
        // names the right and the caption states how many members hold it.
        DistributionCard(
          key: const ValueKey('superAdmin.analytics.permissions'),
          title: l10n.superAdminAnalyticsStaffShare,
          segments: [
            for (final permission in StaffPermission.values)
              DistributionSegment(
                label: permission.label(l10n),
                count: staff.where((s) => s.hasPermission(permission)).length,
                color: permission.isSuperAdminOnly
                    ? AppColors.accent
                    : scheme.primary,
              ),
          ],
        ),
      ],
    );
  }
}

class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SkeletonBox(height: 84, radius: 18),
        SizedBox(height: 12),
        SkeletonBox(height: 104, radius: 18),
        SizedBox(height: 12),
        SkeletonBox(height: 104, radius: 18),
      ],
    );
  }
}
