part of 'admin_operations_page.dart';

class _RecordFormDialog extends StatefulWidget {
  const _RecordFormDialog({
    required this.title,
    required this.fields,
    this.initial = const {},
  });

  final String title;
  final List<_FieldSpec> fields;
  final Map<String, Object?> initial;

  @override
  State<_RecordFormDialog> createState() => _RecordFormDialogState();
}

class _RecordFormDialogState extends State<_RecordFormDialog> {
  late final Map<String, TextEditingController> _controllers = {
    for (final field in widget.fields.where((field) => !field.boolean))
      field.key: TextEditingController(
        text: _fieldInitial(widget.initial, field.key),
      ),
  };
  late final Map<String, bool> _booleans = {
    for (final field in widget.fields.where((field) => field.boolean))
      field.key: widget.initial[field.key] == true,
  };

  @override
  void dispose() {
    for (final text in _controllers.values) {
      text.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final field in widget.fields)
                if (field.boolean)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _booleans[field.key],
                    title: Text(field.label),
                    onChanged: (value) =>
                        setState(() => _booleans[field.key] = value == true),
                  )
                else
                  _TextInput(
                    controller: _controllers[field.key]!,
                    label: field.label,
                    optional: field.optional,
                    numeric: field.number,
                    maxLength: field.maxLength,
                    maxLines: field.maxLines,
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
          onPressed: () {
            final values = <String, Object?>{..._booleans};
            for (final field in widget.fields.where(
              (field) => !field.boolean,
            )) {
              final text = _controllers[field.key]!.text.trim();
              if (text.isEmpty && field.optional) {
                values[field.key] = null;
              } else if (field.number) {
                values[field.key] = field.integer
                    ? int.tryParse(text)
                    : double.tryParse(text);
              } else {
                values[field.key] = text;
              }
            }
            Navigator.pop(context, values);
          },
          child: Text(l10n.adminSaveChanges),
        ),
      ],
    );
  }
}

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.label,
    required this.button,
    required this.maxLength,
  });

  final String label;
  final String button;
  final int maxLength;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.button),
      content: TextField(
        controller: _controller,
        maxLength: widget.maxLength,
        decoration: InputDecoration(labelText: widget.label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.adminCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(widget.button),
        ),
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.label,
    this.optional = false,
    this.numeric = false,
    this.maxLength,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final bool optional;
  final bool numeric;
  final int? maxLength;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class ReferentialListPage<T> extends StatelessWidget {
  const ReferentialListPage({
    required this.items,
    required this.total,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.loadMoreLabel,
    super.key,
  });

  final List<T> items;
  final int total;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onLoadMore;
  final String loadMoreLabel;

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      for (final item in items) itemBuilder(context, item),
      if (items.length < total)
        TextButton(onPressed: onLoadMore, child: Text(loadMoreLabel)),
    ],
  );
}

class _FieldSpec {
  const _FieldSpec(
    this.key,
    this.label, {
    this.optional = false,
    this.boolean = false,
    this.number = false,
    this.integer = false,
    this.maxLength,
    this.maxLines = 1,
  });

  final String key;
  final String label;
  final bool optional;
  final bool boolean;
  final bool number;
  final bool integer;
  final int? maxLength;
  final int maxLines;
}

List<_FieldSpec> _referentialFields(
  String kind,
  AppLocalizations l10n,
) => switch (kind) {
  'categories' || 'units' => [
    _FieldSpec('code', l10n.adminCode, maxLength: 20),
    _FieldSpec('label', l10n.adminLabel, maxLength: 80),
    if (kind == 'categories')
      _FieldSpec('isActive', l10n.adminIsActive, boolean: true),
  ],
  'products' => [
    _FieldSpec('categoryId', l10n.adminCategoryId, number: true, integer: true),
    _FieldSpec('unitId', l10n.adminUnitId, number: true, integer: true),
    _FieldSpec('name', l10n.adminName, maxLength: 120),
    _FieldSpec(
      'description',
      l10n.adminDescription,
      optional: true,
      maxLength: 500,
      maxLines: 3,
    ),
    _FieldSpec('imageUrl', l10n.adminImageUrl, optional: true, maxLength: 500),
    _FieldSpec('isPerishable', l10n.adminIsPerishable, boolean: true),
    _FieldSpec('isActive', l10n.adminIsActive, boolean: true),
  ],
  'zones' => [
    _FieldSpec('name', l10n.adminName, maxLength: 120),
    _FieldSpec('city', l10n.adminCity, optional: true, maxLength: 80),
    _FieldSpec('region', l10n.adminRegion, optional: true, maxLength: 80),
    _FieldSpec('isActive', l10n.adminIsActive, boolean: true),
  ],
  _ => [
    _FieldSpec('name', l10n.adminName, maxLength: 120),
    _FieldSpec('address', l10n.adminAddress, maxLength: 500),
    _FieldSpec('city', l10n.adminCity, optional: true, maxLength: 80),
    _FieldSpec('latitude', l10n.adminLatitude, number: true),
    _FieldSpec('longitude', l10n.adminLongitude, number: true),
    _FieldSpec('zoneId', l10n.adminZoneId, number: true, integer: true),
    _FieldSpec('acceptsDropoff', l10n.adminAcceptsDropoff, boolean: true),
    _FieldSpec('acceptsPickup', l10n.adminAcceptsPickup, boolean: true),
    _FieldSpec('isActive', l10n.adminIsActive, boolean: true),
  ],
};

String _fieldInitial(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value != null) return value.toString();
  final nested = values[key.replaceAll('Id', '')];
  if (nested is Map) return '${nested['id'] ?? ''}';
  return '';
}

String _recordTitle(String kind, AdminOperationRecord record) =>
    '${record[kind == 'categories' || kind == 'units' ? 'label' : 'name'] ?? record['code'] ?? ''}';

String _recordSubtitle(
  AppLocalizations labels,
  String kind,
  AdminOperationRecord record,
) => kind == 'products'
    ? '${record['category'] is Map ? (record['category'] as Map)['label'] ?? '' : ''}'
          ' · ${record['unit'] is Map ? (record['unit'] as Map)['label'] ?? '' : ''}'
    : '${record['code'] ?? record['status'] ?? ''}'
          '${record['isActive'] == null ? '' : ' · ${record['isActive'] == true ? labels.adminActive : labels.adminInactive}'}';

int? _optionalInt(Object? value) =>
    value is num && value == value.toInt() && value > 0 ? value.toInt() : null;

String _failureMessage(AppLocalizations labels, String? code, String message) =>
    code == 'HUMAN_ACTOR_REQUIRED' ? labels.adminHumanActorRequired : message;

String _actionError(AppLocalizations labels, UiState<void> state) {
  if (state is Failure<void>) {
    return _failureMessage(labels, state.failure.code, state.failure.message);
  }
  return labels.adminOperationFailed;
}

void _notify(String message) => AppNotifier.info(message);
