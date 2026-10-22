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

/// Stock-validation queue of the agent workspace.
class AgentStockPage extends StatelessWidget {
  const AgentStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AgentCapabilityGate(
        capability: UserCapability.stockValidation,
        child: _StockBody(),
      ),
    );
  }
}

class _StockBody extends ConsumerWidget {
  const _StockBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final state = ref.watch(agentStockControllerProvider);

    return AgentListView<StockValidationCase>(
      title: l10n.sectionStockValidation,
      icon: Icons.fact_check_outlined,
      items: state.items,
      isLoading: state.isLoading,
      failure: state.failure,
      actionFailure: state.actionFailure,
      updatingIds: state.updatingIds,
      searchHint: l10n.agentSearchHint,
      searchOf: (caseItem) =>
          '${caseItem.reference} ${caseItem.productName} '
          '${caseItem.supplierName}',
      statusFilters: [
        for (final status in StockValidationStatus.values)
          AgentStatusFilter(value: status.name, label: status.label(l10n)),
      ],
      statusKeyOf: (caseItem) => caseItem.status.name,
      emptyTitle: l10n.agentStockEmptyTitle,
      emptyBody: l10n.agentStockEmptyBody,
      onRefresh: () =>
          ref.read(agentStockControllerProvider.notifier).refresh(),
      itemBuilder: (context, caseItem) => _StockCard(
        caseItem: caseItem,
        locale: locale,
        isUpdating: state.isUpdating(caseItem.id),
        onDecide: (status) => _decide(context, ref, caseItem, status),
      ),
    );
  }

  Future<void> _decide(
    BuildContext context,
    WidgetRef ref,
    StockValidationCase caseItem,
    StockValidationStatus status,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final ok = await ref
        .read(agentStockControllerProvider.notifier)
        .decide(caseItem.id, status);
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.agentStockUpdated)));
    }
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({
    required this.caseItem,
    required this.locale,
    required this.isUpdating,
    required this.onDecide,
  });

  final StockValidationCase caseItem;
  final String locale;
  final bool isUpdating;
  final ValueChanged<StockValidationStatus> onDecide;

  List<AgentFact> _facts(AppLocalizations l10n) => [
    AgentFact(
      icon: Icons.storefront_outlined,
      text: '${l10n.agentStockSupplierLabel} · ${caseItem.supplierName}',
    ),
    AgentFact(
      icon: Icons.scale_outlined,
      text: l10n.agentStockDeclaredQty(
        caseItem.declaredQuantity,
        caseItem.unit,
      ),
    ),
    AgentFact(
      icon: Icons.place_outlined,
      text: '${l10n.agentStockLocationLabel} · ${caseItem.location}',
    ),
    AgentFact(
      icon: Icons.event_outlined,
      text:
          '${l10n.agentReceivedLabel} · '
          '${AppFormats.date(caseItem.submittedAt, locale: locale)}',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final facts = _facts(l10n);

    return AgentCaseCard(
      leading: const AgentIconPlate(icon: Icons.inventory_2_outlined),
      title: caseItem.productName,
      subtitle: caseItem.reference,
      statusLabel: caseItem.status.label(l10n),
      statusColor: caseItem.status.color(context),
      facts: facts,
      isUpdating: isUpdating,
      onTap: () => showAgentDetailSheet(
        context,
        title: caseItem.productName,
        statusLabel: caseItem.status.label(l10n),
        statusColor: caseItem.status.color(context),
        facts: facts,
      ),
      action: caseItem.isPending
          ? Row(
              children: [
                Expanded(
                  child: AgentCaseAction(
                    label: l10n.agentStockValidateAction,
                    icon: Icons.check_circle_outline_rounded,
                    isBusy: isUpdating,
                    onPressed: () => onDecide(StockValidationStatus.validated),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AgentCaseAction(
                    label: l10n.agentStockRejectAction,
                    icon: Icons.cancel_outlined,
                    tonal: true,
                    isBusy: isUpdating,
                    onPressed: () => onDecide(StockValidationStatus.rejected),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
