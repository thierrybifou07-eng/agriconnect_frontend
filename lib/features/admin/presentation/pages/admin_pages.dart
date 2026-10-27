import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/utils/money.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_controllers.dart';
import 'package:agri_connect/features/admin/presentation/pages/admin_agents_page.dart';
import 'package:agri_connect/features/admin/presentation/pages/admin_platform_page.dart';
import 'package:agri_connect/features/admin/presentation/pages/admin_users_page.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:agri_connect/features/ai/presentation/widgets/ai_engine_card.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/shared/widgets/role_shell.dart';

class AdminShellPage extends StatelessWidget {
  const AdminShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return RoleShell(
      title: labels.adminTitle,
      tabs: [
        ShellTab(
          icon: Icons.dashboard_outlined,
          label: labels.adminTabDashboard,
          page: (_) => const AdminDashboardPanel(),
        ),
        ShellTab(
          icon: Icons.people_outline,
          label: labels.adminTabUsers,
          page: (_) => const AdminUsersPanel(),
        ),
        ShellTab(
          icon: Icons.groups_outlined,
          label: labels.adminTabAgents,
          page: (_) => const AdminAgentsPanel(),
        ),
        ShellTab(
          icon: Icons.tune_outlined,
          label: labels.adminTabPlatform,
          page: (_) => const AdminPlatformPanel(),
        ),
        ShellTab(
          icon: Icons.account_circle_outlined,
          label: labels.adminTabAccount,
          page: (_) => const _AdminAccountPanel(),
        ),
      ],
    );
  }
}

class AdminDashboardPanel extends GetView<AdminDashboardController> {
  const AdminDashboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Obx(() {
      final state = controller.state.value;
      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    labels.adminTabDashboard,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: labels.adminPeriod,
                  onPressed: () => _selectPeriod(context),
                  icon: const Icon(Icons.date_range_outlined),
                ),
              ],
            ),
            Text(
              '${labels.adminFrom} ${adminShortDate(context, controller.from.value)} · '
              '${labels.adminTo} ${adminShortDate(context, controller.to.value)}',
            ),
            const AiEngineCard(),
            const SizedBox(height: 12),
            if (state is Loading<AdminStats> || state is Idle<AdminStats>)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state is Failure<AdminStats>)
              AdminRetryMessage(
                message: adminApiFailureMessage(labels, state.failure),
                onRetry: controller.load,
              )
            else if (state is Success<AdminStats>)
              _DashboardStats(stats: state.data),
          ],
        ),
      );
    });
  }

  Future<void> _selectPeriod(BuildContext context) async {
    final labels = AppLocalizations.of(context);
    final fromDate = await showDatePicker(
      context: context,
      initialDate: controller.from.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: labels.adminFrom,
    );
    if (fromDate == null || !context.mounted) return;
    final toDate = await showDatePicker(
      context: context,
      initialDate: controller.to.value,
      firstDate: fromDate,
      lastDate: DateTime.now(),
      helpText: labels.adminTo,
    );
    if (toDate == null) return;
    if (toDate.isBefore(fromDate)) {
      AppNotifier.error(labels.adminDateRangeInvalid);
      return;
    }
    await controller.setPeriod(fromDate, toDate);
  }
}

class _DashboardStats extends StatelessWidget {
  const _DashboardStats({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final totalUsers = stats.usersByRole.values.fold<int>(0, (a, b) => a + b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _KpiCard(labels.adminKpiUsers, '$totalUsers'),
            _KpiCard(
              labels.adminKpiReceivables,
              Money.format(stats.receivables),
              detail: '${stats.receivablesCount}',
            ),
            _KpiCard(
              labels.adminKpiPendingPayouts,
              Money.format(stats.pendingPayouts),
            ),
            _KpiCard(
              labels.adminKpiGrossRevenue,
              Money.format(stats.grossRevenue),
            ),
            _KpiCard(
              labels.adminKpiPendingCompensations,
              Money.format(stats.pendingCompensationsAmount),
              detail: '${stats.pendingCompensationsCount}',
            ),
            _KpiCard(
              labels.adminKpiEligibleReferrals,
              Money.format(stats.eligibleReferralsAmount),
              detail: '${stats.eligibleReferralsCount}',
            ),
            _KpiCard(
              labels.adminKpiStock,
              '${stats.availableStock} / ${stats.reservedStock} / '
              '${stats.soldStock} / ${stats.lostStock}',
            ),
          ],
        ),
        const SizedBox(height: 20),
        _StatusDistribution(
          title: labels.adminByRole,
          values: stats.usersByRole,
        ),
        _StatusDistribution(
          title: labels.adminLotsByStatus,
          values: stats.lotsByStatus,
        ),
        _StatusDistribution(
          title: labels.adminOrdersByStatus,
          values: stats.ordersByStatus,
        ),
        _StatusDistribution(
          title: labels.adminDeliveriesByStatus,
          values: stats.deliveriesByStatus,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.label, this.value, {this.detail});

  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            if (detail != null) Text(detail!),
          ],
        ),
      ),
    ),
  );
}

class _StatusDistribution extends StatelessWidget {
  const _StatusDistribution({required this.title, required this.values});

  final String title;
  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final max = values.values.fold<int>(0, (a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (values.isEmpty)
              Text(labels.adminNoData)
            else
              for (final entry in values.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(width: 132, child: Text(entry.key)),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: max == 0 ? 0 : entry.value / max,
                          minHeight: 8,
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text('${entry.value}', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _AdminAccountPanel extends StatelessWidget {
  const _AdminAccountPanel();

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final user = Get.find<AuthController>().currentUser;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_circle_outlined, size: 56),
          const SizedBox(height: 8),
          Text('${user?.firstname ?? ''} ${user?.lastname ?? ''}'.trim()),
          Text(user?.email ?? ''),
          Text(user?.role == RoleCode.root ? 'ROOT' : 'ADMIN'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            child: Text(labels.adminTabAccount),
          ),
        ],
      ),
    );
  }
}
