import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/state_views.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/utils/dates.dart';
import 'package:agri_connect/core/utils/money.dart';
import 'package:agri_connect/features/account/domain/account_entities.dart';
import 'package:agri_connect/features/account/presentation/controllers/language_controller.dart';
import 'package:agri_connect/features/account/presentation/controllers/payout_accounts_controller.dart';
import 'package:agri_connect/features/account/presentation/controllers/referral_controller.dart';
import 'package:agri_connect/features/account/presentation/controllers/sessions_controller.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/domain/profile_verification_status.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class PayoutAccountsPage extends GetView<PayoutAccountsController> {
  const PayoutAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountPayoutTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.accountAddPayout),
      ),
      body: Obx(() {
        final state = controller.state.value;
        if (state is Loading<List<PayoutAccount>> ||
            state is Idle<List<PayoutAccount>>) {
          return const LoadingView();
        }
        if (state is Failure<List<PayoutAccount>>) {
          return ErrorView(failure: state.failure, onRetry: controller.load);
        }
        final accounts = (state as Success<List<PayoutAccount>>).data;
        if (accounts.isEmpty) {
          return Center(child: Text(l10n.accountNoPayout));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          itemCount: accounts.length,
          itemBuilder: (context, index) => _PayoutAccountTile(
            account: accounts[index],
            onEdit: () => _showForm(context, accounts[index]),
            onDelete: () => _delete(context, accounts[index]),
          ),
        );
      }),
    );
  }

  Future<void> _showForm(BuildContext context, [PayoutAccount? account]) async {
    final l10n = AppLocalizations.of(context);
    final provider = TextEditingController(text: account?.provider ?? '');
    final number = TextEditingController();
    final name = TextEditingController(text: account?.accountName ?? '');
    final formKey = GlobalKey<FormState>();
    var method = account?.method ?? 'MOBILE_MONEY';
    var isDefault = account?.isDefault ?? false;
    final values = await Get.dialog<Map<String, Object?>>(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            account == null ? l10n.accountAddPayout : l10n.accountEditPayout,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: method,
                    decoration: InputDecoration(
                      labelText: l10n.accountPayoutMethod,
                    ),
                    items: [
                      for (final item in const [
                        ('MOBILE_MONEY', 'Mobile Money'),
                        ('BANK_TRANSFER', 'Bank transfer'),
                        ('CASH', 'Cash'),
                      ])
                        DropdownMenuItem(
                          value: item.$1,
                          child: Text(_payoutMethod(item.$1, l10n)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => method = value);
                    },
                  ),
                  TextFormField(
                    controller: provider,
                    maxLength: 80,
                    decoration: InputDecoration(
                      labelText: l10n.accountProvider,
                    ),
                  ),
                  TextFormField(
                    controller: number,
                    maxLength: 64,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: l10n.accountAccountNumber,
                      helperText: account == null
                          ? null
                          : '${l10n.accountCurrentNumber}: ${account.accountNumberMasked}',
                    ),
                    validator: (value) {
                      if (account != null &&
                          (value == null || value.trim().isEmpty)) {
                        return null;
                      }
                      final length = value?.trim().length ?? 0;
                      return length < 4 || length > 64
                          ? l10n.accountNumberInvalid
                          : null;
                    },
                  ),
                  TextFormField(
                    controller: name,
                    maxLength: 120,
                    decoration: InputDecoration(
                      labelText: l10n.accountAccountName,
                    ),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isDefault,
                    title: Text(l10n.accountDefault),
                    onChanged: (value) =>
                        setState(() => isDefault = value ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: Get.back, child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Get.back(
                  result: <String, Object?>{
                    'method': method,
                    'isDefault': isDefault,
                    if (provider.text.trim().isNotEmpty)
                      'provider': provider.text.trim(),
                    if (name.text.trim().isNotEmpty)
                      'accountName': name.text.trim(),
                    if (number.text.trim().isNotEmpty)
                      'accountNumber': number.text.trim(),
                  },
                );
              },
              child: Text(l10n.profileSaveAction),
            ),
          ],
        ),
      ),
    );
    provider.dispose();
    number.dispose();
    name.dispose();
    if (values == null) return;
    final succeeded = account == null
        ? await controller.create(values)
        : await controller.updateAccount(account.id, values);
    if (succeeded) {
      AppNotifier.success(l10n.accountSaved);
    } else {
      _showActionFailure(l10n);
    }
  }

  Future<void> _delete(BuildContext context, PayoutAccount account) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.accountDeleteTitle),
        content: Text(l10n.accountDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(l10n.accountDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (await controller.delete(account.id)) {
      AppNotifier.success(l10n.accountDeleted);
    } else {
      _showActionFailure(l10n);
    }
  }

  void _showActionFailure(AppLocalizations l10n) {
    final failure = controller.actionFailure.value;
    AppNotifier.error(
      failure == null
          ? l10n.accountSaveFailed
          : AppNotifier.failureMessage(failure, l10n),
    );
  }
}

class _PayoutAccountTile extends StatelessWidget {
  const _PayoutAccountTile({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  final PayoutAccount account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet_outlined),
        title: Text(
          account.accountName?.isNotEmpty == true
              ? account.accountName!
              : account.accountNumberMasked,
        ),
        subtitle: Text(
          [
            _payoutMethod(account.method, l10n),
            if (account.provider != null && account.provider!.isNotEmpty)
              account.provider!,
            account.accountNumberMasked,
            if (account.isDefault) l10n.accountDefault,
          ].join(' · '),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (choice) {
            if (choice == 'edit') onEdit();
            if (choice == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text(l10n.accountEdit)),
            PopupMenuItem(value: 'delete', child: Text(l10n.accountDelete)),
          ],
        ),
      ),
    );
  }
}

String _payoutMethod(String method, AppLocalizations l10n) => switch (method) {
  'MOBILE_MONEY' => l10n.accountMobileMoney,
  'BANK_TRANSFER' => l10n.accountBankTransfer,
  'CASH' => l10n.accountCash,
  _ => method,
};

String _referralKind(String kind, AppLocalizations l10n) => switch (kind) {
  'BUYER' => l10n.accountReferralBuyer,
  'SUPPLIER' => l10n.accountReferralSupplier,
  _ => kind,
};

String _referralStatus(String status, AppLocalizations l10n) =>
    switch (status) {
      'PENDING' => l10n.accountStatusPending,
      'ELIGIBLE' => l10n.accountStatusEligible,
      'PAID' => l10n.accountStatusPaid,
      'REJECTED' => l10n.accountStatusRejected,
      _ => status,
    };

class ReferralPage extends GetView<ReferralController> {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountReferralTitle)),
      body: Obx(() {
        final state = controller.state.value;
        if (state is Loading<ReferralSummary> ||
            state is Idle<ReferralSummary>) {
          return const LoadingView();
        }
        if (state is Failure<ReferralSummary>) {
          return ErrorView(failure: state.failure, onRetry: controller.load);
        }
        final summary = (state as Success<ReferralSummary>).data;
        final user = Get.find<AuthController>().currentUser;
        final verified =
            user?.profileVerificationStatus ==
            ProfileVerificationStatus.verified;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!verified)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.accountReferralNotVerified),
                ),
              ),
            Text(
              l10n.accountReferralCode,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: SelectableText(summary.code ?? '—'),
                trailing: IconButton(
                  tooltip: l10n.accountCopyCode,
                  icon: const Icon(Icons.copy),
                  onPressed: summary.code == null
                      ? null
                      : () async {
                          await Clipboard.setData(
                            ClipboardData(text: summary.code!),
                          );
                          AppNotifier.success(l10n.accountCopied);
                        },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TotalCard(
                  label: l10n.accountPending,
                  count: summary.totals.pending,
                ),
                _TotalCard(
                  label: l10n.accountEligible,
                  count: summary.totals.eligible,
                ),
                _TotalCard(label: l10n.accountPaid, count: summary.totals.paid),
              ],
            ),
            const SizedBox(height: 16),
            if (summary.referrals.isEmpty)
              Text(l10n.accountNoReferrals)
            else
              for (final referral in summary.referrals)
                Card(
                  child: ListTile(
                    title: Text(referral.referredFirstname ?? '—'),
                    subtitle: Text(
                      '${_referralKind(referral.kind, l10n)} · '
                      '${_referralStatus(referral.status, l10n)} · '
                      '${referral.createdAt == null ? '' : Dates.short(referral.createdAt!)}',
                    ),
                    trailing: Text(Money.format(referral.rewardAmount)),
                  ),
                ),
          ],
        );
      }),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 4),
          Text('$count', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    ),
  );
}

class SessionsPage extends GetView<SessionsController> {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountSessionsTitle)),
      body: Obx(() {
        final state = controller.state.value;
        if (state is Loading<List<AuthSession>> ||
            state is Idle<List<AuthSession>>) {
          return const LoadingView();
        }
        if (state is Failure<List<AuthSession>>) {
          return ErrorView(failure: state.failure, onRetry: controller.load);
        }
        final sessions = (state as Success<List<AuthSession>>).data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final session in sessions)
              Card(
                child: ListTile(
                  leading: Icon(
                    session.isCurrent ? Icons.phone_android : Icons.devices,
                  ),
                  title: Text(
                    session.isCurrent
                        ? l10n.accountCurrentSession
                        : session.userAgent ?? l10n.accountUnknownDevice,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (session.ip != null)
                        Text('${l10n.accountSessionIp}: ${session.ip}'),
                      if (session.lastActivityAt != null)
                        Text(
                          '${l10n.accountSessionLastActive}: '
                          '${Dates.short(session.lastActivityAt!)}',
                        ),
                      if (session.expiresAt != null)
                        Text(
                          '${l10n.accountSessionExpires}: '
                          '${Dates.short(session.expiresAt!)}',
                        ),
                    ],
                  ),
                  trailing: session.isCurrent
                      ? null
                      : IconButton(
                          tooltip: l10n.accountCloseSession,
                          icon: const Icon(Icons.logout),
                          onPressed: controller.actionLoading.value
                              ? null
                              : () => _closeSession(context, session),
                        ),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.actionLoading.value
                  ? null
                  : () => _logoutOthers(context),
              icon: const Icon(Icons.devices_other),
              label: Text(l10n.accountLogoutOthers),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _closeSession(BuildContext context, AuthSession session) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.accountCloseSession),
        content: Text(l10n.accountCloseSessionConfirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(l10n.accountCloseSession),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (await controller.closeSession(session.id)) {
      AppNotifier.success(l10n.accountSessionClosed);
    } else {
      _showSessionFailure(l10n);
    }
  }

  Future<void> _logoutOthers(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.accountLogoutOthers),
        content: Text(l10n.accountLogoutOthersConfirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(l10n.accountLogoutOthers),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (await controller.logoutOtherSessions()) {
      AppNotifier.success(l10n.accountLogoutOthersDone);
    } else {
      _showSessionFailure(l10n);
    }
  }

  void _showSessionFailure(AppLocalizations l10n) {
    final failure = controller.actionFailure.value;
    AppNotifier.error(
      failure == null
          ? l10n.accountSaveFailed
          : AppNotifier.failureMessage(failure, l10n),
    );
  }
}

class AccountLanguagePage extends GetView<AccountLanguageController> {
  const AccountLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountLanguageTitle)),
      body: Obx(
        () => Column(
          children: [
            RadioGroup<String>(
              groupValue: controller.language,
              onChanged: (value) {
                if (value != null) controller.select(value);
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'fr',
                    title: Text(l10n.languageFrench),
                  ),
                  RadioListTile<String>(
                    value: 'en',
                    title: Text(l10n.languageEnglish),
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
