import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/agent/application/agent_controllers.dart';
import 'package:agri_connect/features/agent/presentation/widgets/agent_content.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/shared/widgets/attention_card.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/quick_action_grid.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

/// Agent workspace home: a welcome banner, the shortcuts the agent can really
/// reach — one per capability actually granted — the backlog that waits for a
/// decision, and an overview of each operational queue.
///
/// The page never shows a queue the session has no capability for, and it never
/// invents a figure: every count is read from the same section controllers the
/// sections themselves use.
class AgentDashboardPage extends ConsumerWidget {
  const AgentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    // The shell only exists for a signed-in agent, but the session can be
    // dropped in the same frame the router is redirecting: rendering nothing
    // beats a null assertion crash on the way out.
    if (user == null) return const SizedBox.shrink();

    final capabilities = user.capabilities;
    final canSupport = capabilities.contains(UserCapability.buyerSupport);
    final canStock = capabilities.contains(UserCapability.stockValidation);
    final canOrders = capabilities.contains(UserCapability.orderProcessing);
    final canPayments = capabilities.contains(UserCapability.paymentFollowup);
    final hasAny = canSupport || canStock || canOrders || canPayments;

    final support = canSupport
        ? ref.watch(agentSupportControllerProvider)
        : null;
    final stock = canStock ? ref.watch(agentStockControllerProvider) : null;
    final orders = canOrders ? ref.watch(agentOrdersControllerProvider) : null;
    final payments = canPayments
        ? ref.watch(agentPaymentsControllerProvider)
        : null;

    final supportPending =
        support?.items.where((r) => !r.isResolved).length ?? 0;
    final stockPending = stock?.items.where((c) => c.isPending).length ?? 0;
    final ordersPending =
        orders?.items.where((o) => !o.isProcessed).length ?? 0;
    final paymentsPending =
        payments?.items.where((p) => !p.isConfirmed).length ?? 0;

    final queues = <_AgentQueueSummary>[
      if (canSupport)
        _AgentQueueSummary(
          id: 'support',
          title: l10n.sectionBuyerSupport,
          icon: Icons.support_agent_outlined,
          pendingCount: supportPending,
          isLoading: support!.isLoading,
          isRefreshing: support.isRefreshing,
          hasItems: support.items.isNotEmpty,
          failure: support.failure,
          caption: l10n.agentStatSupportCaption(supportPending),
          onTap: () => context.go(RoutePaths.agentSupport),
          onRetry: () =>
              ref.read(agentSupportControllerProvider.notifier).refresh(),
        ),
      if (canStock)
        _AgentQueueSummary(
          id: 'stock',
          title: l10n.sectionStockValidation,
          icon: Icons.fact_check_outlined,
          pendingCount: stockPending,
          isLoading: stock!.isLoading,
          isRefreshing: stock.isRefreshing,
          hasItems: stock.items.isNotEmpty,
          failure: stock.failure,
          caption: l10n.agentStatStockCaption(stockPending),
          onTap: () => context.go(RoutePaths.agentStock),
          onRetry: () =>
              ref.read(agentStockControllerProvider.notifier).refresh(),
        ),
      if (canOrders)
        _AgentQueueSummary(
          id: 'orders',
          title: l10n.sectionOrderProcessing,
          icon: Icons.pending_actions_outlined,
          pendingCount: ordersPending,
          isLoading: orders!.isLoading,
          isRefreshing: orders.isRefreshing,
          hasItems: orders.items.isNotEmpty,
          failure: orders.failure,
          caption: l10n.agentStatOrdersCaption(ordersPending),
          onTap: () => context.go(RoutePaths.agentOrderProcessing),
          onRetry: () =>
              ref.read(agentOrdersControllerProvider.notifier).refresh(),
        ),
      if (canPayments)
        _AgentQueueSummary(
          id: 'payments',
          title: l10n.sectionPaymentFollowup,
          icon: Icons.payments_outlined,
          pendingCount: paymentsPending,
          isLoading: payments!.isLoading,
          isRefreshing: payments.isRefreshing,
          hasItems: payments.items.isNotEmpty,
          failure: payments.failure,
          caption: l10n.agentStatPaymentsCaption(paymentsPending),
          onTap: () => context.go(RoutePaths.agentPayments),
          onRetry: () =>
              ref.read(agentPaymentsControllerProvider.notifier).refresh(),
        ),
    ];
    final allQueuesLoaded = queues.every(
      (queue) =>
          !queue.isLoading && !queue.isRefreshing && queue.failure == null,
    );

    final firstName = user.fullName.split(' ').first;

    return RefreshIndicator(
      onRefresh: () => Future.wait([
        if (canSupport)
          ref.read(agentSupportControllerProvider.notifier).refresh(),
        if (canStock) ref.read(agentStockControllerProvider.notifier).refresh(),
        if (canOrders)
          ref.read(agentOrdersControllerProvider.notifier).refresh(),
        if (canPayments)
          ref.read(agentPaymentsControllerProvider.notifier).refresh(),
      ]),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          AgentContent(
            child: _Hero(
              greeting: l10n.dashboardWelcome(firstName),
              subtitle: l10n.agentConsoleSubtitle,
            ),
          ),
          const SizedBox(height: 20),
          if (!hasAny)
            AgentContent(
              child: EmptyState(
                icon: Icons.lock_outline_rounded,
                title: l10n.agentNoCapabilitiesTitle,
                body: l10n.agentNoCapabilitiesBody,
              ),
            )
          else ...[
            AgentContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(title: l10n.agentOverviewTitle),
                  const SizedBox(height: 10),
                  _OverviewGrid(
                    tiles: [
                      for (final queue in queues)
                        _QueueSummaryCard(queue: queue),
                    ],
                  ),
                  if (allQueuesLoaded) ...[
                    const SizedBox(height: 12),
                    AttentionCard(
                      title: l10n.agentAttentionTitle,
                      emptyTitle: l10n.agentAttentionClearTitle,
                      emptyBody: l10n.agentAttentionClearBody,
                      items: [
                        if (supportPending > 0)
                          AttentionItem(
                            id: 'support',
                            count: supportPending,
                            label: l10n.agentAttentionSupport(supportPending),
                            icon: Icons.support_agent_rounded,
                            color: AppColors.warning,
                            onTap: () => context.go(RoutePaths.agentSupport),
                          ),
                        if (stockPending > 0)
                          AttentionItem(
                            id: 'stock',
                            count: stockPending,
                            label: l10n.agentAttentionStock(stockPending),
                            icon: Icons.fact_check_rounded,
                            color: AppColors.accent,
                            onTap: () => context.go(RoutePaths.agentStock),
                          ),
                        if (ordersPending > 0)
                          AttentionItem(
                            id: 'orders',
                            count: ordersPending,
                            label: l10n.agentAttentionOrders(ordersPending),
                            icon: Icons.pending_actions_rounded,
                            color: AppColors.primary,
                            onTap: () =>
                                context.go(RoutePaths.agentOrderProcessing),
                          ),
                        if (paymentsPending > 0)
                          AttentionItem(
                            id: 'payments',
                            count: paymentsPending,
                            label: l10n.agentAttentionPayments(paymentsPending),
                            icon: Icons.payments_rounded,
                            color: AppColors.danger,
                            onTap: () => context.go(RoutePaths.agentPayments),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            AgentContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(context, l10n.dashboardQuickActions),
                  const SizedBox(height: 10),
                  QuickActionGrid(
                    gridKey: const Key('agentQuickActions'),
                    actions: [
                      if (canSupport)
                        QuickAction(
                          label: l10n.agentQuickSupport,
                          icon: Icons.support_agent_rounded,
                          primary: true,
                          badgeCount: _knownCount(
                            allowed: canSupport,
                            isLoading: support!.isLoading,
                            isRefreshing: support.isRefreshing,
                            failure: support.failure,
                            count: supportPending,
                          ),
                          onTap: () => context.go(RoutePaths.agentSupport),
                        ),
                      if (canStock)
                        QuickAction(
                          label: l10n.agentQuickStock,
                          icon: Icons.fact_check_rounded,
                          badgeCount: _knownCount(
                            allowed: canStock,
                            isLoading: stock!.isLoading,
                            isRefreshing: stock.isRefreshing,
                            failure: stock.failure,
                            count: stockPending,
                          ),
                          onTap: () => context.go(RoutePaths.agentStock),
                        ),
                      if (canOrders)
                        QuickAction(
                          label: l10n.agentQuickOrders,
                          icon: Icons.pending_actions_rounded,
                          badgeCount: _knownCount(
                            allowed: canOrders,
                            isLoading: orders!.isLoading,
                            isRefreshing: orders.isRefreshing,
                            failure: orders.failure,
                            count: ordersPending,
                          ),
                          onTap: () =>
                              context.go(RoutePaths.agentOrderProcessing),
                        ),
                      if (canPayments)
                        QuickAction(
                          label: l10n.agentQuickPayments,
                          icon: Icons.payments_rounded,
                          badgeCount: _knownCount(
                            allowed: canPayments,
                            isLoading: payments!.isLoading,
                            isRefreshing: payments.isRefreshing,
                            failure: payments.failure,
                            count: paymentsPending,
                          ),
                          onTap: () => context.go(RoutePaths.agentPayments),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

/// Branded welcome banner.
class _Hero extends StatelessWidget {
  const _Hero({required this.greeting, required this.subtitle});

  final String greeting;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppSizes.imageRadius),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overview tiles of the agent dashboard.
///
/// Two columns once the content is wide enough, one below: a metric tile is
/// never squeezed so small that its label and its caption collide.
class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppBreakpoints.compactWidth
            ? 2
            : 1;
        const spacing = 12.0;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final tile in tiles) SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }
}

int? _knownCount({
  required bool allowed,
  required bool isLoading,
  required bool isRefreshing,
  required Failure? failure,
  required int count,
}) {
  if (!allowed || isLoading || isRefreshing || failure != null || count == 0) {
    return null;
  }
  return count;
}

class _AgentQueueSummary {
  const _AgentQueueSummary({
    required this.id,
    required this.title,
    required this.icon,
    required this.pendingCount,
    required this.isLoading,
    required this.isRefreshing,
    required this.hasItems,
    required this.failure,
    required this.caption,
    required this.onTap,
    required this.onRetry,
  });

  final String id;
  final String title;
  final IconData icon;
  final int pendingCount;
  final bool isLoading;
  final bool isRefreshing;
  final bool hasItems;
  final Failure? failure;
  final String caption;
  final VoidCallback onTap;
  final VoidCallback onRetry;
}

class _QueueSummaryCard extends StatelessWidget {
  const _QueueSummaryCard({required this.queue});

  final _AgentQueueSummary queue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: Key('agentQueue_${queue.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: queue.onTap,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    Icon(queue.icon, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        queue.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (queue.isLoading) ...[
              const SkeletonBox(width: 64, height: 28),
              const SizedBox(height: 8),
              Text(context.l10n.agentLoading),
            ] else if (queue.isRefreshing) ...[
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(context.l10n.agentRefreshing)),
                ],
              ),
              if (queue.hasItems) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.agentStaleQueueCount(
                    queue.pendingCount.toString(),
                  ),
                ),
                Text(queue.caption, style: theme.textTheme.bodySmall),
              ],
            ] else if (queue.failure case final failure?) ...[
              if (queue.hasItems) ...[
                Text(
                  context.l10n.agentStaleQueueCount(
                    queue.pendingCount.toString(),
                  ),
                ),
                Text(queue.caption, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
              ],
              Text(
                context.l10n.agentSectionLoadError,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              FailureView(
                failure: failure,
                onRetry: queue.onRetry,
                compact: true,
              ),
            ] else ...[
              Text(
                '${queue.pendingCount}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(queue.caption, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
