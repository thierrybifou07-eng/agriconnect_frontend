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
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Buyer-support queue of the agent workspace.
class AgentSupportPage extends StatelessWidget {
  const AgentSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AgentCapabilityGate(
        capability: UserCapability.buyerSupport,
        child: _SupportBody(),
      ),
    );
  }
}

class _SupportBody extends ConsumerWidget {
  const _SupportBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final state = ref.watch(agentSupportControllerProvider);

    return AgentListView<SupportRequest>(
      title: l10n.sectionBuyerSupport,
      icon: Icons.support_agent_outlined,
      items: state.items,
      isLoading: state.isLoading,
      failure: state.failure,
      actionFailure: state.actionFailure,
      updatingIds: state.updatingIds,
      searchHint: l10n.agentSearchHint,
      searchOf: (request) =>
          '${request.reference} ${request.buyerName} ${request.subject}',
      statusFilters: [
        for (final status in SupportRequestStatus.values)
          AgentStatusFilter(value: status.name, label: status.label(l10n)),
      ],
      statusKeyOf: (request) => request.status.name,
      emptyTitle: l10n.agentSupportEmptyTitle,
      emptyBody: l10n.agentSupportEmptyBody,
      onRefresh: () =>
          ref.read(agentSupportControllerProvider.notifier).refresh(),
      itemBuilder: (context, request) => _SupportCard(
        request: request,
        locale: locale,
        isUpdating: state.isUpdating(request.id),
        onAdvance: () => _advance(context, ref, request),
      ),
    );
  }

  Future<void> _advance(
    BuildContext context,
    WidgetRef ref,
    SupportRequest request,
  ) async {
    final next = request.nextStatus;
    if (next == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final ok = await ref
        .read(agentSupportControllerProvider.notifier)
        .updateStatus(request.id, next);
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.agentSupportUpdated)));
    }
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.request,
    required this.locale,
    required this.isUpdating,
    required this.onAdvance,
  });

  final SupportRequest request;
  final String locale;
  final bool isUpdating;
  final VoidCallback onAdvance;

  List<AgentFact> _facts(AppLocalizations l10n) => [
    AgentFact(
      icon: Icons.person_outline_rounded,
      text: '${l10n.agentSupportBuyerLabel} · ${request.buyerName}',
    ),
    AgentFact(
      icon: Icons.flag_outlined,
      text:
          '${l10n.agentSupportPriorityLabel} · ${request.priority.label(l10n)}',
    ),
    AgentFact(
      icon: Icons.event_outlined,
      text:
          '${l10n.agentReceivedLabel} · '
          '${AppFormats.date(request.createdAt, locale: locale)}',
    ),
    AgentFact(icon: Icons.notes_rounded, text: request.summary),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = request.nextStatus;
    final facts = _facts(l10n);

    return AgentCaseCard(
      leading: UserAvatar(name: request.buyerName, size: 40),
      title: request.subject,
      subtitle: request.reference,
      statusLabel: request.status.label(l10n),
      statusColor: request.status.color(context),
      facts: facts,
      isUpdating: isUpdating,
      onTap: () => showAgentDetailSheet(
        context,
        title: request.subject,
        statusLabel: request.status.label(l10n),
        statusColor: request.status.color(context),
        facts: facts,
      ),
      action: next == null
          ? null
          : AgentCaseAction(
              label: request.isOpen
                  ? l10n.agentSupportTakeAction
                  : l10n.agentSupportResolveAction,
              icon: request.isOpen
                  ? Icons.support_agent_rounded
                  : Icons.check_circle_outline_rounded,
              isBusy: isUpdating,
              onPressed: onAdvance,
            ),
    );
  }
}
