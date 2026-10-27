part of 'admin_operations_page.dart';

class _ReferentialsPanel extends GetView<AdminOperationsController> {
  const _ReferentialsPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: controller.referentialKind.value,
                    decoration: InputDecoration(
                      labelText: l10n.adminReferentials,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'categories',
                        child: Text(l10n.adminCategories),
                      ),
                      DropdownMenuItem(
                        value: 'units',
                        child: Text(l10n.adminUnits),
                      ),
                      DropdownMenuItem(
                        value: 'products',
                        child: Text(l10n.adminProducts),
                      ),
                      DropdownMenuItem(
                        value: 'zones',
                        child: Text(l10n.adminZones),
                      ),
                      DropdownMenuItem(
                        value: 'hubs',
                        child: Text(l10n.adminHubs),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setReferentialKind(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => DropdownButton<bool?>(
                  value: controller.referentialKind.value == 'units'
                      ? null
                      : controller.activeFilter.value,
                  hint: Text(l10n.adminActiveFilter),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.adminAll)),
                    DropdownMenuItem(
                      value: true,
                      child: Text(l10n.adminActive),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text(l10n.adminInactive),
                    ),
                  ],
                  onChanged: controller.referentialKind.value == 'units'
                      ? null
                      : controller.setActiveFilter,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final state = controller.referentialState.value;
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
                onRetry: controller.loadReferentials,
              );
            }
            final records =
                (state as Success<Paginated<AdminOperationRecord>>).data.items;
            return Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: FilledButton.icon(
                      onPressed: () => _editReferential(context),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.adminCreate),
                    ),
                  ),
                ),
                Expanded(
                  child: records.isEmpty
                      ? Center(child: Text(l10n.adminNoRecords))
                      : ReferentialListPage<AdminOperationRecord>(
                          items: records,
                          total: state.data.total,
                          itemBuilder: (context, record) => ListTile(
                            title: Text(
                              _recordTitle(
                                controller.referentialKind.value,
                                record,
                              ),
                            ),
                            subtitle: Text(
                              _recordSubtitle(
                                l10n,
                                controller.referentialKind.value,
                                record,
                              ),
                            ),
                            trailing: IconButton(
                              tooltip: l10n.adminEdit,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () =>
                                  _editReferential(context, record),
                            ),
                          ),
                          onLoadMore: controller.loadMoreReferentials,
                          loadMoreLabel: l10n.adminLoadMore,
                        ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Future<void> _editReferential(
    BuildContext context, [
    AdminOperationRecord? record,
  ]) async {
    final kind = controller.referentialKind.value;
    final l10n = AppLocalizations.of(context);
    final schema = _referentialFields(kind, l10n);
    final result = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (context) => _RecordFormDialog(
        title: record == null ? l10n.adminCreate : l10n.adminEdit,
        fields: schema,
        initial:
            record?.values ??
            switch (kind) {
              'categories' ||
              'products' ||
              'zones' ||
              'hubs' => const {'isActive': true},
              _ => const {},
            },
      ),
    );
    if (result == null) return;
    final invalid = validateAdminReferential(kind, result);
    if (invalid != null) {
      _notify(l10n.adminOperationFailed);
      return;
    }
    if (!context.mounted) return;
    final saved = await controller.saveReferential(
      id: record?.id,
      values: result,
    );
    if (!context.mounted) return;
    _notify(
      saved
          ? l10n.adminOperationSaved
          : _actionError(l10n, controller.actionState.value),
    );
  }
}
