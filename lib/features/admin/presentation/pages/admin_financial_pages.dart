part of 'admin_operations_page.dart';

class _MoneyPanel extends GetView<AdminOperationsController> {
  const _MoneyPanel({required this.kind});

  final String kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.moneyKind.value != kind) {
        controller.setMoneyKind(kind);
      } else if (controller.moneyState.value is Idle) {
        controller.loadMoney();
      }
    });
    final statuses = switch (kind) {
      'payouts' => const ['ON_HOLD', 'READY', 'PAID', 'CANCELLED'],
      'referrals' => const ['PENDING', 'ELIGIBLE', 'PAID', 'REJECTED'],
      _ => const ['PENDING_APPROVAL', 'APPROVED', 'PAID', 'REJECTED'],
    };
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Obx(
            () => DropdownButtonFormField<String?>(
              initialValue: controller.moneyKind.value == kind
                  ? controller.moneyStatus.value
                  : null,
              decoration: InputDecoration(labelText: l10n.adminStatusFilter),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.adminAll)),
                for (final status in statuses)
                  DropdownMenuItem(value: status, child: Text(status)),
              ],
              onChanged: (value) {
                controller.setMoneyFilter(kind, value);
              },
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.moneyKind.value != kind) {
              return const Center(child: CircularProgressIndicator());
            }
            final state = controller.moneyState.value;
            if (state is Loading<Paginated<AdminOperationRecord>> ||
                state is Idle<Paginated<AdminOperationRecord>>) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is Failure<Paginated<AdminOperationRecord>>) {
              return AdminRetryMessage(
                message: _failureMessage(
                  l10n,
                  state.failure.code,
                  state.failure.message,
                ),
                onRetry: controller.loadMoney,
              );
            }
            final data =
                (state as Success<Paginated<AdminOperationRecord>>).data;
            if (data.items.isEmpty) {
              return Center(child: Text(l10n.adminNoRecords));
            }
            return ListView(
              children: [
                for (final record in data.items)
                  _MoneyRecordTile(
                    record: record,
                    kind: kind,
                    onAction: (action, value) => _performMoneyAction(
                      context,
                      record,
                      kind,
                      action,
                      value,
                    ),
                  ),
                if (data.items.length < data.total)
                  TextButton(
                    onPressed: controller.loadMoreMoney,
                    child: Text(l10n.adminLoadMore),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Future<void> _performMoneyAction(
    BuildContext context,
    AdminOperationRecord record,
    String kind,
    String action,
    String value,
  ) async {
    final l10n = AppLocalizations.of(context);
    var confirmed = true;
    final isPayment = action == 'pay';
    if (isPayment) {
      confirmed =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(l10n.adminConfirmMoneyAction),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.adminCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.adminConfirm),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (!confirmed) return;
    final success = switch (kind) {
      'payouts' => await controller.payPayout(
        record.id,
        value,
        payoutAccountId: _optionalInt(
          record['payoutAccountId'] ??
              (record['payoutAccount'] is Map
                  ? (record['payoutAccount'] as Map)['id']
                  : null),
        ),
      ),
      'referrals' => await controller.referralAction(record.id, action, value),
      _ => await controller.compensationAction(record.id, action, value),
    };
    if (context.mounted) {
      _notify(
        success
            ? l10n.adminOperationSaved
            : _actionError(l10n, controller.actionState.value),
      );
    }
  }
}

class _MoneyRecordTile extends StatefulWidget {
  const _MoneyRecordTile({
    required this.record,
    required this.kind,
    required this.onAction,
  });

  final AdminOperationRecord record;
  final String kind;
  final Future<void> Function(String action, String value) onAction;

  @override
  State<_MoneyRecordTile> createState() => _MoneyRecordTileState();
}

class _MoneyRecordTileState extends State<_MoneyRecordTile> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final record = widget.record;
    final status = '${record['status'] ?? ''}';
    final supplier = record['supplier'] is Map
        ? Map<Object?, Object?>.from(record['supplier'] as Map)
        : const <Object?, Object?>{};
    final account = supplier['payoutAccount'] is Map
        ? Map<Object?, Object?>.from(supplier['payoutAccount'] as Map)
        : record['payoutAccount'] is Map
        ? Map<Object?, Object?>.from(record['payoutAccount'] as Map)
        : const <Object?, Object?>{};
    final accountNumber = account['accountNumber']?.toString();
    final maskedAccountNumber =
        account['accountNumberMasked']?.toString() ??
        (accountNumber == null ? null : maskAccountNumber(accountNumber));
    final isCompensation = widget.kind == 'compensations';
    final canPay = widget.kind == 'payouts'
        ? status == 'READY'
        : widget.kind == 'referrals'
        ? status == 'ELIGIBLE'
        : status == 'APPROVED';
    final canReject = widget.kind == 'referrals'
        ? status == 'PENDING' || status == 'ELIGIBLE'
        : isCompensation && status == 'PENDING_APPROVAL';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record['id']} · $status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${record['amount'] ?? record['netAmount'] ?? record['rewardAmount'] ?? ''}',
            ),
            if (record['reference'] != null) Text('${record['reference']}'),
            if (maskedAccountNumber != null &&
                (isCompensation || widget.kind == 'payouts'))
              if (isCompensation)
                AdminMaskedAccountNumber(
                  label:
                      '${l10n.adminDefaultPayoutAccount}: '
                      '${account['provider'] ?? account['method'] ?? ''}',
                  accountNumber: accountNumber ?? maskedAccountNumber,
                  showLabel: l10n.adminShowAccount,
                  hideLabel: l10n.adminHideAccount,
                )
              else
                Text(
                  '${l10n.adminDefaultPayoutAccount}: '
                  '${account['provider'] ?? account['method'] ?? ''} '
                  '$maskedAccountNumber',
                ),
            Wrap(
              spacing: 8,
              children: [
                if (isCompensation && status == 'PENDING_APPROVAL')
                  TextButton(
                    onPressed: () => widget.onAction('approve', ''),
                    child: Text(l10n.adminApprove),
                  ),
                if (canPay)
                  FilledButton.tonal(
                    onPressed: () => _askAction(
                      context,
                      'pay',
                      l10n.adminPaymentReference,
                      l10n.adminPay,
                    ),
                    child: Text(l10n.adminPay),
                  ),
                if (canReject)
                  TextButton(
                    onPressed: () => _askAction(
                      context,
                      'reject',
                      isCompensation
                          ? l10n.adminRejectReason
                          : l10n.adminRejectReason,
                      l10n.adminReject,
                    ),
                    child: Text(l10n.adminReject),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _askAction(
    BuildContext context,
    String action,
    String label,
    String button,
  ) async {
    final maxLength = action == 'pay'
        ? widget.kind == 'payouts'
              ? 255
              : 100
        : widget.kind == 'compensations'
        ? 500
        : 2000;
    final value = await showDialog<String>(
      context: context,
      builder: (context) =>
          _TextPromptDialog(label: label, button: button, maxLength: maxLength),
    );
    if (value == null) return;
    if (value.trim().isEmpty || value.trim().length > maxLength) {
      if (!context.mounted) return;
      AppNotifier.error(AppLocalizations.of(context).adminReferenceInvalid);
      return;
    }
    await widget.onAction(action, value);
  }
}

String maskAccountNumber(String value) => value.length < 5
    ? '••••'
    : '${'•' * (value.length - 4)}${value.substring(value.length - 4)}';

class AdminMaskedAccountNumber extends StatefulWidget {
  const AdminMaskedAccountNumber({
    required this.label,
    required this.accountNumber,
    required this.showLabel,
    required this.hideLabel,
    super.key,
  });

  final String label;
  final String accountNumber;
  final String showLabel;
  final String hideLabel;

  @override
  State<AdminMaskedAccountNumber> createState() =>
      _AdminMaskedAccountNumberState();
}

class _AdminMaskedAccountNumberState extends State<AdminMaskedAccountNumber> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          '${widget.label}: '
          '${_visible ? widget.accountNumber : maskAccountNumber(widget.accountNumber)}',
        ),
      ),
      TextButton(
        onPressed: () => setState(() => _visible = !_visible),
        child: Text(_visible ? widget.hideLabel : widget.showLabel),
      ),
    ],
  );
}
