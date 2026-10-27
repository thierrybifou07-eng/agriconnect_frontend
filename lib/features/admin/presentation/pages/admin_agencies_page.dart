part of 'admin_operations_page.dart';

class _AgenciesPanel extends GetView<AdminOperationsController> {
  const _AgenciesPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.agencyState.value is Idle) controller.loadAgencies();
    });
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: () => _editAgency(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.adminCreate),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final state = controller.agencyState.value;
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
                onRetry: controller.loadAgencies,
              );
            }
            final data =
                (state as Success<Paginated<AdminOperationRecord>>).data;
            if (data.items.isEmpty) {
              return Center(child: Text(l10n.adminNoRecords));
            }
            return ListView(
              children: [
                for (final agency in data.items)
                  _AgencyTile(
                    agency: agency,
                    onEdit: () => _editAgency(context, agency),
                    onCoverage: () => _editCoverage(context, agency),
                    onDrivers: () async {
                      await controller.loadAgencyDrivers(agency.id);
                      if (!context.mounted) return;
                      await _showDrivers(context, agency);
                    },
                  ),
                if (data.items.length < data.total)
                  TextButton(
                    onPressed: controller.loadMoreAgencies,
                    child: Text(l10n.adminLoadMore),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Future<void> _editAgency(
    BuildContext context, [
    AdminOperationRecord? record,
  ]) async {
    final l10n = AppLocalizations.of(context);
    final fields = [
      _FieldSpec('name', l10n.adminName),
      _FieldSpec('contactName', l10n.adminContactName, optional: true),
      _FieldSpec('phone', l10n.adminPhone),
      _FieldSpec('email', l10n.adminEmail, optional: true),
      _FieldSpec(
        'insuranceProvider',
        l10n.adminInsuranceProvider,
        optional: true,
      ),
      _FieldSpec(
        'insurancePolicyNumber',
        l10n.adminInsurancePolicy,
        optional: true,
      ),
      _FieldSpec(
        'insuranceExpiresAt',
        l10n.adminInsuranceExpiresAt,
        optional: true,
      ),
      _FieldSpec('isActive', l10n.adminIsActive, boolean: true),
    ];
    final result = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (context) => _RecordFormDialog(
        title: record == null ? l10n.adminCreate : l10n.adminEdit,
        fields: fields,
        initial: record?.values ?? const {'isActive': true},
      ),
    );
    if (result == null) return;
    final body = Map<String, Object?>.from(result);
    final expiry = body['insuranceExpiresAt'];
    if (expiry is String && expiry.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(expiry.trim());
      if (parsed == null) {
        _notify(l10n.adminOperationFailed);
        return;
      }
      body['insuranceExpiresAt'] = parsed.toUtc().toIso8601String();
    }
    if (!context.mounted) return;
    final saved = await controller.saveAgency(record?.id, body);
    if (!context.mounted) return;
    _notify(
      saved
          ? l10n.adminOperationSaved
          : _actionError(l10n, controller.actionState.value),
    );
  }

  Future<void> _editCoverage(
    BuildContext context,
    AdminOperationRecord agency,
  ) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (context) => const _CoverageDialog(),
    );
    if (result == null) return;
    final zoneId = result['zoneId'] as int?;
    if (zoneId == null) return;
    if (result['remove'] == true) {
      final removed = await controller.removeCoverage(agency.id, zoneId);
      if (!context.mounted) return;
      _notify(
        removed
            ? l10n.adminOperationSaved
            : _actionError(l10n, controller.actionState.value),
      );
      return;
    }
    final baseFee = result['baseFee'] as double?;
    final perKmFee = result['perKmFee'] as double?;
    if (baseFee == null || perKmFee == null) {
      _notify(l10n.adminOperationFailed);
      return;
    }
    final saved = await controller.saveCoverage(
      agency.id,
      zoneId,
      baseFee,
      perKmFee,
      isActive: result['isActive'] as bool?,
    );
    if (!context.mounted) return;
    _notify(
      saved
          ? l10n.adminOperationSaved
          : _actionError(l10n, controller.actionState.value),
    );
  }

  Future<void> _showDrivers(
    BuildContext context,
    AdminOperationRecord agency,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.adminDrivers} · ${agency['name'] ?? ''}'),
        content: SizedBox(
          width: 400,
          child: Obx(() {
            final state = controller.driversState.value;
            if (state is Loading<List<AdminOperationRecord>>) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is Failure<List<AdminOperationRecord>>) {
              return Text(
                _failureMessage(
                  l10n,
                  state.failure.code,
                  state.failure.message,
                ),
              );
            }
            if (controller.agencyDrivers.isEmpty) {
              return Text(l10n.adminNoRecords);
            }
            return ListView(
              shrinkWrap: true,
              children: [
                for (final driver in controller.agencyDrivers)
                  ListTile(
                    title: Text(
                      '${driver['firstname'] ?? ''} ${driver['lastname'] ?? ''}'
                          .trim(),
                    ),
                    subtitle: Text('${driver['phone'] ?? ''}'),
                  ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(l10n.adminCancel)),
        ],
      ),
    );
  }
}

class _CoverageDialog extends StatefulWidget {
  const _CoverageDialog();

  @override
  State<_CoverageDialog> createState() => _CoverageDialogState();
}

class _CoverageDialogState extends State<_CoverageDialog> {
  final _zoneId = TextEditingController();
  final _baseFee = TextEditingController();
  final _perKmFee = TextEditingController();
  bool _isActive = true;

  @override
  void dispose() {
    _zoneId.dispose();
    _baseFee.dispose();
    _perKmFee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.adminCoverage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TextInput(
            controller: _zoneId,
            label: l10n.adminZoneId,
            numeric: true,
          ),
          _TextInput(
            controller: _baseFee,
            label: l10n.adminBaseFee,
            numeric: true,
          ),
          _TextInput(
            controller: _perKmFee,
            label: l10n.adminPerKmFee,
            numeric: true,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _isActive,
            title: Text(l10n.adminIsActive),
            onChanged: (value) => setState(() => _isActive = value == true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.adminCancel),
        ),
        TextButton(
          onPressed: () {
            final id = int.tryParse(_zoneId.text.trim());
            if (id != null && id > 0) {
              Navigator.pop(context, {'zoneId': id, 'remove': true});
            }
          },
          child: Text(l10n.adminRemoveCoverage),
        ),
        FilledButton(
          onPressed: () {
            final id = int.tryParse(_zoneId.text.trim());
            final base = double.tryParse(_baseFee.text.trim());
            final perKm = double.tryParse(_perKmFee.text.trim());
            if (id != null && id > 0 && base != null && perKm != null) {
              Navigator.pop(context, {
                'zoneId': id,
                'baseFee': base,
                'perKmFee': perKm,
                'isActive': _isActive,
              });
            }
          },
          child: Text(l10n.adminSaveCoverage),
        ),
      ],
    );
  }
}

class _AgencyTile extends StatelessWidget {
  const _AgencyTile({
    required this.agency,
    required this.onEdit,
    required this.onCoverage,
    required this.onDrivers,
  });

  final AdminOperationRecord agency;
  final VoidCallback onEdit;
  final VoidCallback onCoverage;
  final VoidCallback onDrivers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expiry = DateTime.tryParse('${agency['insuranceExpiresAt'] ?? ''}');
    final expiresSoon =
        expiry != null &&
        expiry.difference(DateTime.now()) < const Duration(days: 30);
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('${agency['name'] ?? ''}'),
            subtitle: Text(
              '${agency['phone'] ?? ''} · ${agency['email'] ?? ''}',
            ),
            trailing: IconButton(
              tooltip: l10n.adminEdit,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
          if (expiresSoon)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.adminInsuranceExpiring,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Wrap(
            children: [
              TextButton(
                onPressed: onCoverage,
                child: Text(l10n.adminCoverage),
              ),
              TextButton(onPressed: onDrivers, child: Text(l10n.adminDrivers)),
            ],
          ),
        ],
      ),
    );
  }
}
