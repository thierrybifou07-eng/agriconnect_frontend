import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/agent/application/agent_controllers.dart';
import 'package:agri_connect/features/agent/domain/agent_case.dart';
import 'package:agri_connect/features/agent/presentation/widgets/agent_capability_gate.dart';
import 'package:agri_connect/features/agent/presentation/widgets/agent_case_card.dart';
import 'package:agri_connect/features/agent/presentation/widgets/agent_list_view.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';

/// Order-processing queue of the agent workspace.
class AgentOrdersPage extends StatelessWidget {
  const AgentOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AgentCapabilityGate(
        capability: UserCapability.orderProcessing,
        child: _OrdersBody(),
      ),
    );
  }
}

class _OrdersBody extends ConsumerWidget {
  const _OrdersBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final state = ref.watch(agentOrdersControllerProvider);

    return AgentListView<OrderProcessingCase>(
      title: l10n.sectionOrderProcessing,
      icon: Icons.pending_actions_outlined,
      items: state.items,
      isLoading: state.isLoading,
      failure: state.failure,
      actionFailure: state.actionFailure,
      updatingIds: state.updatingIds,
      searchHint: l10n.agentSearchHint,
      searchOf: (order) =>
          '${order.reference} ${order.buyerName} ${order.sellerName}',
      statusFilters: [
        for (final status in OrderProcessingStatus.values)
          AgentStatusFilter(value: status.name, label: status.label(l10n)),
      ],
      statusKeyOf: (order) => order.status.name,
      emptyTitle: l10n.agentOrderEmptyTitle,
      emptyBody: l10n.agentOrderEmptyBody,
      onRefresh: () =>
          ref.read(agentOrdersControllerProvider.notifier).refresh(),
      itemBuilder: (context, order) => _OrderCard(
        order: order,
        locale: locale,
        isUpdating: state.isUpdating(order.id),
        onAdvance: () => _advance(context, ref, order),
      ),
    );
  }

  Future<void> _advance(
    BuildContext context,
    WidgetRef ref,
    OrderProcessingCase order,
  ) async {
    final next = order.nextStatus;
    if (next == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final ok = await ref
        .read(agentOrdersControllerProvider.notifier)
        .advance(order.id, next);
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.agentOrderUpdated)));
    }
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.locale,
    required this.isUpdating,
    required this.onAdvance,
  });

  final OrderProcessingCase order;
  final String locale;
  final bool isUpdating;
  final VoidCallback onAdvance;

  List<AgentFact> _facts(AppLocalizations l10n) => [
    AgentFact(
      icon: Icons.person_outline_rounded,
      text: '${l10n.agentOrderBuyerLabel} · ${order.buyerName}',
    ),
    AgentFact(
      icon: Icons.storefront_outlined,
      text: '${l10n.agentOrderSellerLabel} · ${order.sellerName}',
    ),
    AgentFact(
      icon: Icons.inventory_2_outlined,
      text:
          '${l10n.agentOrderItemsLabel} · '
          '${l10n.itemsCount(order.itemCount)}',
    ),
    AgentFact(
      icon: Icons.payments_outlined,
      text:
          '${l10n.agentOrderAmountLabel} · '
          '${Money.format(order.amount, locale: locale)}',
    ),
    AgentFact(
      icon: Icons.event_outlined,
      text:
          '${l10n.agentReceivedLabel} · '
          '${AppFormats.date(order.placedAt, locale: locale)}',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = order.nextStatus;
    final facts = _facts(l10n);

    return AgentCaseCard(
      leading: const AgentIconPlate(icon: Icons.receipt_long_outlined),
      title: l10n.orderNumber(order.reference),
      subtitle: order.buyerName,
      statusLabel: order.status.label(l10n),
      statusColor: order.status.color(context),
      facts: facts,
      isUpdating: isUpdating,
      onTap: () => showAgentDetailSheet(
        context,
        title: l10n.orderNumber(order.reference),
        statusLabel: order.status.label(l10n),
        statusColor: order.status.color(context),
        facts: facts,
      ),
      action: next == null
          ? null
          : AgentCaseAction(
              label: order.status == OrderProcessingStatus.awaiting
                  ? l10n.agentOrderStartAction
                  : l10n.agentOrderCompleteAction,
              icon: order.status == OrderProcessingStatus.awaiting
                  ? Icons.play_arrow_rounded
                  : Icons.check_circle_outline_rounded,
              isBusy: isUpdating,
              onPressed: onAdvance,
            ),
    );
  }
}
