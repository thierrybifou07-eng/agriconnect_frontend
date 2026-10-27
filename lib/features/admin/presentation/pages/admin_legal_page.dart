part of 'admin_operations_page.dart';

class _LegalPanel extends GetView<AdminOperationsController> {
  const _LegalPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.legalState.value is Idle) controller.loadLegal();
    });
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: () => _createLegal(context),
              child: Text(l10n.adminCreateDraft),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final state = controller.legalState.value;
            if (state is Loading<List<AdminLegalDocument>> ||
                state is Idle<List<AdminLegalDocument>>) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is Failure<List<AdminLegalDocument>>) {
              return AdminRetryMessage(
                message: _failureMessage(
                  l10n,
                  state.failure.code,
                  state.failure.message,
                ),
                onRetry: controller.loadLegal,
              );
            }
            final records = (state as Success<List<AdminLegalDocument>>).data;
            if (records.isEmpty) {
              return Center(child: Text(l10n.adminNoRecords));
            }
            return ListView(
              children: [
                for (final document in records)
                  ListTile(
                    title: Text('${document.code} · ${document.version}'),
                    subtitle: Text(document.title ?? ''),
                    trailing: document.status == 'DRAFT' && document.id != null
                        ? TextButton(
                            onPressed: () async {
                              final success = await controller.publishLegal(
                                document.id!,
                              );
                              if (context.mounted) {
                                _notify(
                                  success
                                      ? l10n.adminOperationSaved
                                      : _actionError(
                                          l10n,
                                          controller.actionState.value,
                                        ),
                                );
                              }
                            },
                            child: Text(l10n.adminPublish),
                          )
                        : Text(
                            document.status == 'PUBLISHED'
                                ? l10n.adminPublished
                                : l10n.adminDraft,
                          ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Future<void> _createLegal(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _LegalEditorDialog(),
    );
    if (result == null) return;
    final success = await controller.createLegalVersion(
      result['code']!,
      result['version']!,
      result['frTitle']!,
      result['frContent']!,
      result['enTitle']!,
      result['enContent']!,
    );
    if (context.mounted) {
      _notify(
        success
            ? l10n.adminOperationSaved
            : _actionError(l10n, controller.actionState.value),
      );
    }
  }
}

class _LegalEditorDialog extends StatefulWidget {
  const _LegalEditorDialog();

  @override
  State<_LegalEditorDialog> createState() => _LegalEditorDialogState();
}

class _LegalEditorDialogState extends State<_LegalEditorDialog> {
  final _version = TextEditingController();
  final _frTitle = TextEditingController();
  final _frContent = TextEditingController();
  final _enTitle = TextEditingController();
  final _enContent = TextEditingController();
  String _code = 'CGU';
  bool _preview = false;

  @override
  void dispose() {
    _version.dispose();
    _frTitle.dispose();
    _frContent.dispose();
    _enTitle.dispose();
    _enContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.adminCreateDraft),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _code,
                decoration: InputDecoration(labelText: l10n.adminLegalCode),
                items: const [
                  DropdownMenuItem(value: 'CGU', child: Text('CGU')),
                  DropdownMenuItem(
                    value: 'BUYER_TERMS',
                    child: Text('BUYER_TERMS'),
                  ),
                  DropdownMenuItem(
                    value: 'SUPPLIER_CONSIGNMENT_TERMS',
                    child: Text('SUPPLIER_CONSIGNMENT_TERMS'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _code = value);
                },
              ),
              _TextInput(controller: _version, label: l10n.adminVersion),
              _TextInput(controller: _frTitle, label: l10n.adminFrenchTitle),
              _TextInput(
                controller: _frContent,
                label: l10n.adminFrenchContent,
                maxLines: 5,
              ),
              _TextInput(controller: _enTitle, label: l10n.adminEnglishTitle),
              _TextInput(
                controller: _enContent,
                label: l10n.adminEnglishContent,
                maxLines: 5,
              ),
              TextButton(
                onPressed: () => setState(() => _preview = !_preview),
                child: Text(l10n.adminPreview),
              ),
              if (_preview)
                SelectableText(
                  '${_frTitle.text}\n\n${_frContent.text}\n\n'
                  '${_enTitle.text}\n\n${_enContent.text}',
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.adminCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            'code': _code,
            'version': _version.text,
            'frTitle': _frTitle.text,
            'frContent': _frContent.text,
            'enTitle': _enTitle.text,
            'enContent': _enContent.text,
          }),
          child: Text(l10n.adminCreateDraft),
        ),
      ],
    );
  }
}
