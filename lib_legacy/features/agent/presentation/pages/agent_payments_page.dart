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

/// Payment follow-up queue of the agent workspace.
class AgentPaymentsPage extends StatelessWidget {
  const AgentPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AgentCapabilityGate(
        capability: UserCapability.paymentFollowup,
        child: _PaymentsBody(),
      ),
    );
  }
}

class _PaymentsBody extends ConsumerWidget {
  const _PaymentsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final state = ref.watch(agentPaymentsControllerProvider);

    return AgentListView<PaymentFollowupCase>(
      title: l10n.sectionPaymentFollowup,
      icon: Icons.payments_outlined,
      items: state.items,
      isLoading: state.isLoading,
      failure: state.failure,
      actionFailure: state.actionFailure,
      updatingIds: state.updatingIds,
      searchHint: l10n.agentSearchHint,
      searchOf: (payment) => '${payment.reference} ${payment.payerName}',
      statusFilters: [
        for (final status in PaymentFollowupStatus.values)
          AgentStatusFilter(value: status.name, label: status.label(l10n)),
      ],
      statusKeyOf: (payment) => payment.status.name,
      emptyTitle: l10n.agentPaymentEmptyTitle,
      emptyBody: l10n.agentPaymentEmptyBody,
      onRefresh: () =>
          ref.read(agentPaymentsControllerProvider.notifier).refresh(),
      itemBuilder: (context, payment) => _PaymentCard(
        payment: payment,
        locale: locale,
        isUpdating: state.isUpdating(payment.id),
        onConfirm: () => _confirm(context, ref, payment),
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    PaymentFollowupCase payment,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final ok = await ref
        .read(agentPaymentsControllerProvider.notifier)
        .confirm(payment.id);
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.agentPaymentUpdated)));
    }
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.locale,
    required this.isUpdating,
    required this.onConfirm,
  });

  final PaymentFollowupCase payment;
  final String locale;
  final bool isUpdating;
  final VoidCallback onConfirm;

  List<AgentFact> _facts(AppLocalizations l10n) => [
    AgentFact(
      icon: Icons.person_outline_rounded,
      text: '${l10n.agentPaymentPayerLabel} · ${payment.payerName}',
    ),
    AgentFact(
      icon: Icons.payments_outlined,
      text:
          '${l10n.agentPaymentAmountLabel} · '
          '${Money.format(payment.amount, locale: locale)}',
    ),
    AgentFact(
      icon: Icons.account_balance_wallet_outlined,
      text: '${l10n.agentPaymentMethodLabel} · ${payment.method}',
    ),
    AgentFact(
      icon: Icons.event_outlined,
      text:
          '${l10n.agentPaymentDueLabel} · '
          '${AppFormats.date(payment.dueAt, locale: locale)}',
    ),
    // A payment is never presented as received before the platform confirms it:
    // until then the card states plainly that it is not confirmed.
    if (!payment.isConfirmed)
      AgentFact(
        icon: Icons.info_outline_rounded,
        text: l10n.agentPaymentNotReceivedNotice,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final facts = _facts(l10n);

    return AgentCaseCard(
      leading: const AgentIconPlate(
        icon: Icons.account_balance_wallet_outlined,
      ),
      title: Money.format(payment.amount, locale: locale),
      subtitle: '${payment.reference} · ${payment.payerName}',
      statusLabel: payment.status.label(l10n),
      statusColor: payment.status.color(context),
      facts: facts,
      isUpdating: isUpdating,
      onTap: () => showAgentDetailSheet(
        context,
        title: Money.format(payment.amount, locale: locale),
        statusLabel: payment.status.label(l10n),
        statusColor: payment.status.color(context),
        facts: facts,
      ),
      action: payment.isConfirmed
          ? null
          : AgentCaseAction(
              label: l10n.agentPaymentConfirmAction,
              icon: Icons.verified_rounded,
              isBusy: isUpdating,
              onPressed: onConfirm,
            ),
    );
  }
}
