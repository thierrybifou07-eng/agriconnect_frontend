import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_controllers.dart';
import 'package:agri_connect/features/admin/presentation/pages/admin_operations_page.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class AdminPlatformPanel extends StatelessWidget {
  const AdminPlatformPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                labels.adminTabPlatform,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          TabBar(
            tabs: [
              Tab(text: labels.adminSettingsTitle),
              Tab(text: labels.adminAuditTitle),
              Tab(text: labels.adminOpsTab),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _PlatformSettingsPanel(),
                _AuditLogPanel(),
                AdminOperationsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformSettingsPanel extends GetView<AdminPlatformController> {
  const _PlatformSettingsPanel();

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final isRoot = canEditPlatformSettings(
      Get.find<AuthController>().currentUser?.role ?? RoleCode.unknown,
    );
    return Obx(() {
      final state = controller.settingsState.value;
      if (state is Loading<PlatformSettings> ||
          state is Idle<PlatformSettings>) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is Failure<PlatformSettings>) {
        return AdminRetryMessage(
          message: adminApiFailureMessage(labels, state.failure),
          onRetry: controller.loadSettings,
        );
      }
      final settings = (state as Success<PlatformSettings>).data;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!isRoot)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(labels.adminSettingsLocked),
              ),
            ),
          if (settings.supplierCommissionRate == 0)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(labels.adminCommissionWarning),
              ),
            ),
          _SettingsEditor(
            key: ValueKey(settings),
            controller: controller,
            settings: settings,
            enabled: isRoot,
          ),
        ],
      );
    });
  }
}

class _SettingsEditor extends StatefulWidget {
  const _SettingsEditor({
    super.key,
    required this.controller,
    required this.settings,
    required this.enabled,
  });

  final AdminPlatformController controller;
  final PlatformSettings settings;
  final bool enabled;

  @override
  State<_SettingsEditor> createState() => _SettingsEditorState();
}

class _SettingsEditorState extends State<_SettingsEditor> {
  late final _commission = TextEditingController(
    text: '${widget.settings.supplierCommissionRate * 100}',
  );
  late final _buyerFeeValue = TextEditingController(
    text:
        '${widget.settings.buyerFeeType == 'PERCENT' ? widget.settings.buyerFeeValue * 100 : widget.settings.buyerFeeValue}',
  );
  late final _transport = TextEditingController(
    text: '${widget.settings.transportMarkupRate * 100}',
  );
  late final _buyerReward = TextEditingController(
    text: '${widget.settings.referralBuyerReward}',
  );
  late final _supplierReward = TextEditingController(
    text: '${widget.settings.referralSupplierReward}',
  );
  late final _hours = TextEditingController(
    text: '${widget.settings.reservationHours}',
  );
  late final _compensation = TextEditingController(
    text: '${widget.settings.expiryCompensationRate * 100}',
  );
  late String _feeType = widget.settings.buyerFeeType;
  bool _saving = false;

  @override
  void dispose() {
    _commission.dispose();
    _buyerFeeValue.dispose();
    _transport.dispose();
    _buyerReward.dispose();
    _supplierReward.dispose();
    _hours.dispose();
    _compensation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Form(
      child: Column(
        children: [
          _numberField(_commission, labels.adminCommission),
          DropdownButtonFormField<String>(
            initialValue: _feeType,
            decoration: InputDecoration(labelText: labels.adminBuyerFeeType),
            items: [
              DropdownMenuItem(value: 'NONE', child: Text(labels.adminFeeNone)),
              DropdownMenuItem(
                value: 'FIXED',
                child: Text(labels.adminFeeFixed),
              ),
              DropdownMenuItem(
                value: 'PERCENT',
                child: Text(labels.adminFeePercent),
              ),
            ],
            onChanged: widget.enabled
                ? (value) {
                    if (value != null) setState(() => _feeType = value);
                  }
                : null,
          ),
          _numberField(_buyerFeeValue, labels.adminBuyerFeeValue),
          _numberField(_transport, labels.adminTransportMarkup),
          _numberField(_buyerReward, labels.adminBuyerReward),
          _numberField(_supplierReward, labels.adminSupplierReward),
          _numberField(_hours, labels.adminReservationHours),
          _numberField(_compensation, labels.adminExpiryCompensation),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(labels.adminCurrency),
            trailing: Text(widget.settings.currency),
          ),
          if (!widget.enabled)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(labels.adminRootOnly),
            ),
          FilledButton(
            onPressed: widget.enabled && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(labels.adminSave),
          ),
        ],
      ),
    );
  }

  Widget _numberField(TextEditingController textController, String label) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          controller: textController,
          enabled: widget.enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label),
        ),
      );

  Future<void> _save() async {
    final labels = AppLocalizations.of(context);
    final commission = double.tryParse(_commission.text.trim());
    final feeValue = double.tryParse(_buyerFeeValue.text.trim());
    final transport = double.tryParse(_transport.text.trim());
    final buyerReward = double.tryParse(_buyerReward.text.trim());
    final supplierReward = double.tryParse(_supplierReward.text.trim());
    final hours = int.tryParse(_hours.text.trim());
    final compensation = double.tryParse(_compensation.text.trim());
    if (commission == null ||
        commission < 0 ||
        commission > 50 ||
        feeValue == null ||
        feeValue < 0 ||
        transport == null ||
        transport < 0 ||
        transport > 100 ||
        buyerReward == null ||
        buyerReward < 0 ||
        supplierReward == null ||
        supplierReward < 0 ||
        hours == null ||
        hours < 1 ||
        hours > 168 ||
        compensation == null ||
        compensation < 0 ||
        compensation > 100) {
      AppNotifier.error(labels.adminInvalidSettings);
      return;
    }
    final fields = platformSettingsPatch(
      supplierCommissionPercent: commission,
      buyerFeeType: _feeType,
      buyerFeeValue: feeValue,
      transportMarkupPercent: transport,
      referralBuyerReward: buyerReward,
      referralSupplierReward: supplierReward,
      reservationHours: hours,
      expiryCompensationPercent: compensation,
    );
    setState(() => _saving = true);
    final saved = await widget.controller.saveSettings(fields);
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) {
      AppNotifier.success(labels.adminSettingsSaved);
    } else {
      final state = widget.controller.actionState.value;
      if (state is Failure<void>) {
        AppNotifier.error(adminApiFailureMessage(labels, state.failure));
      }
    }
  }
}

class _AuditLogPanel extends GetView<AdminPlatformController> {
  const _AuditLogPanel();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _AuditFilters(controller: controller),
      Expanded(
        child: Obx(() {
          final labels = AppLocalizations.of(context);
          final state = controller.auditState.value;
          if (state is Loading<Paginated<AdminAuditLog>> ||
              state is Idle<Paginated<AdminAuditLog>>) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is Failure<Paginated<AdminAuditLog>>) {
            return AdminRetryMessage(
              message: adminApiFailureMessage(labels, state.failure),
              onRetry: controller.loadAudit,
            );
          }
          final page = (state as Success<Paginated<AdminAuditLog>>).data;
          return Column(
            children: [
              Expanded(
                child: page.items.isEmpty
                    ? Center(child: Text(labels.adminAuditEmpty))
                    : ListView.separated(
                        itemCount: page.items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = page.items[index];
                          return ListTile(
                            title: Text(entry.action),
                            subtitle: Text(
                              '${entry.entityType} #${entry.entityId ?? '—'} · '
                              '${adminAuditActor(labels, entry)} · '
                              '${entry.createdAt == null ? '—' : DateFormat.yMd(labels.localeName).add_Hm().format(entry.createdAt!)}',
                            ),
                            trailing: IconButton(
                              tooltip: labels.adminAuditMetadata,
                              onPressed: () => _showMetadata(context, entry),
                              icon: const Icon(Icons.data_object),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: page.page > 1
                          ? () => controller.loadAudit(page: page.page - 1)
                          : null,
                      child: Text(labels.adminPrevious),
                    ),
                    Text(
                      '${page.page} / ${_pageCount(page.total, page.limit)}',
                    ),
                    TextButton(
                      onPressed: page.hasMore
                          ? () => controller.loadAudit(page: page.page + 1)
                          : null,
                      child: Text(labels.adminNext),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    ],
  );

  void _showMetadata(BuildContext context, AdminAuditLog entry) {
    final labels = AppLocalizations.of(context);
    final formatted = const JsonEncoder.withIndent(
      '  ',
    ).convert(entry.metadata);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(labels.adminAuditMetadata),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(child: SelectableText(formatted)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(labels.adminCancel),
          ),
        ],
      ),
    );
  }
}

class _AuditFilters extends StatefulWidget {
  const _AuditFilters({required this.controller});

  final AdminPlatformController controller;

  @override
  State<_AuditFilters> createState() => _AuditFiltersState();
}

class _AuditFiltersState extends State<_AuditFilters> {
  late final _entityType = TextEditingController(
    text: widget.controller.entityType.value,
  );
  late final _entityId = TextEditingController(
    text: '${widget.controller.entityId.value ?? ''}',
  );
  late final _actorUserId = TextEditingController(
    text: '${widget.controller.actorUserId.value ?? ''}',
  );
  late final _actorAgentId = TextEditingController(
    text: '${widget.controller.actorAgentId.value ?? ''}',
  );
  DateTime? _from;
  DateTime? _to;

  @override
  void dispose() {
    _entityType.dispose();
    _entityId.dispose();
    _actorUserId.dispose();
    _actorAgentId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _entityType,
                  decoration: InputDecoration(
                    labelText: labels.adminAuditEntityType,
                    isDense: true,
                  ),
                ),
              ),
              _idField(_entityId, labels.adminAuditEntityId),
              _idField(_actorUserId, labels.adminAuditActorUserId),
              _idField(_actorAgentId, labels.adminAuditActorAgentId),
              OutlinedButton(
                onPressed: () => _pickDate(isFrom: true),
                child: Text(
                  '${labels.adminFrom}: ${_from == null ? labels.adminAll : adminShortDate(context, _from!)}',
                ),
              ),
              OutlinedButton(
                onPressed: () => _pickDate(isFrom: false),
                child: Text(
                  '${labels.adminTo}: ${_to == null ? labels.adminAll : adminShortDate(context, _to!)}',
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                widget.controller.entityType.value = _entityType.text.trim();
                widget.controller.entityId.value = int.tryParse(
                  _entityId.text.trim(),
                );
                widget.controller.actorUserId.value = int.tryParse(
                  _actorUserId.text.trim(),
                );
                widget.controller.actorAgentId.value = int.tryParse(
                  _actorAgentId.text.trim(),
                );
                widget.controller.auditFrom.value = _from;
                widget.controller.auditTo.value = _to;
                widget.controller.loadAudit(page: 1);
              },
              child: Text(labels.adminRefresh),
            ),
          ),
        ],
      ),
    );
  }

  Widget _idField(TextEditingController textController, String label) =>
      SizedBox(
        width: 150,
        child: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      );

  Future<void> _pickDate({required bool isFrom}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from ?? DateTime.now() : _to ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected == null) return;
    setState(() {
      if (isFrom) {
        _from = selected;
      } else {
        _to = DateTime(selected.year, selected.month, selected.day, 23, 59, 59);
      }
    });
  }
}

int _pageCount(int total, int limit) {
  if (limit <= 0) return 1;
  final count = (total / limit).ceil();
  return count < 1 ? 1 : count;
}
