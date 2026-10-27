import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_controllers.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_widgets.dart';

class CreateStaffDialog extends StatefulWidget {
  const CreateStaffDialog({
    super.key,
    required this.controller,
    required this.isRoot,
  });

  final AdminUsersController controller;
  final bool isRoot;

  @override
  State<CreateStaffDialog> createState() => _CreateStaffDialogState();
}

class _CreateStaffDialogState extends State<CreateStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  final _vehicleType = TextEditingController();
  final _plateNumber = TextEditingController();
  Future<List<AdminAgency>>? _agencies;
  String _role = 'AGENT';
  int? _agencyId;
  final Set<String> _capabilities = {};
  bool _busy = false;

  @override
  void initState() => super.initState();

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _displayName.dispose();
    _vehicleType.dispose();
    _plateNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(labels.adminCreateStaff),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_first, labels.adminFirstName),
                _field(_last, labels.adminLastName),
                _field(
                  _email,
                  labels.adminEmail,
                  keyboard: TextInputType.emailAddress,
                ),
                _field(
                  _phone,
                  labels.adminPhone,
                  keyboard: TextInputType.phone,
                ),
                _field(_password, labels.adminPassword, obscure: true),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    labels.adminStaffPasswordHelp,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: InputDecoration(labelText: labels.adminStaffRole),
                  items: [
                    const DropdownMenuItem(
                      value: 'AGENT',
                      child: Text('AGENT'),
                    ),
                    const DropdownMenuItem(
                      value: 'DRIVER',
                      child: Text('DRIVER'),
                    ),
                    DropdownMenuItem(
                      value: 'ADMIN',
                      enabled: widget.isRoot,
                      child: Text(
                        widget.isRoot
                            ? 'ADMIN'
                            : 'ADMIN · ${labels.adminRootOnly}',
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _role = value;
                        if (value == 'DRIVER') {
                          _agencies ??= widget.controller.repository.agencies();
                        }
                      });
                    }
                  },
                ),
                if (!widget.isRoot)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(labels.adminRootOnly),
                    ),
                  ),
                if (_role == 'AGENT') ...[
                  _field(_displayName, labels.adminAgentName),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        labels.adminCapabilities,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  for (final capability in adminCapabilities)
                    adminCapabilityCheckbox(
                      labels,
                      capability,
                      _capabilities,
                      (value) => setState(() {
                        if (value) {
                          _capabilities.add(capability);
                        } else {
                          _capabilities.remove(capability);
                        }
                      }),
                    ),
                ],
                if (_role == 'DRIVER') ...[
                  FutureBuilder<List<AdminAgency>>(
                    future: _agencies,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(labels.adminLoadAgenciesError),
                        );
                      }
                      final agencies = snapshot.data;
                      if (agencies == null) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        );
                      }
                      return DropdownButtonFormField<int>(
                        initialValue: _agencyId,
                        decoration: InputDecoration(
                          labelText: labels.adminAgency,
                          hintText: labels.adminChooseAgency,
                        ),
                        items: [
                          for (final agency in agencies)
                            DropdownMenuItem(
                              value: agency.id,
                              child: Text(agency.name),
                            ),
                        ],
                        validator: (value) =>
                            value == null ? labels.adminChooseAgency : null,
                        onChanged: (value) => setState(() => _agencyId = value),
                      );
                    },
                  ),
                  _field(_vehicleType, labels.adminVehicleType),
                  _field(_plateNumber, labels.adminPlateNumber),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(labels.adminCancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(labels.adminCreateAccount),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController textController,
    String label, {
    TextInputType? keyboard,
    bool obscure = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: TextFormField(
      controller: textController,
      keyboardType: keyboard,
      obscureText: obscure,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty ||
            ((label == AppLocalizations.of(context).adminFirstName ||
                    label == AppLocalizations.of(context).adminLastName) &&
                text.length < 2)) {
          return label;
        }
        return null;
      },
    ),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final labels = AppLocalizations.of(context);
    final passwordPattern = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])(?!.*(.)\1\1\1)[A-Za-z\d@$!%*?&]{8,}$',
    );
    final phonePattern = RegExp(r'^\+?[0-9]{8,15}$');
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!passwordPattern.hasMatch(_password.text) ||
        !phonePattern.hasMatch(_phone.text.trim()) ||
        !emailPattern.hasMatch(_email.text.trim())) {
      final message = !passwordPattern.hasMatch(_password.text)
          ? labels.adminInvalidPassword
          : !phonePattern.hasMatch(_phone.text.trim())
          ? labels.adminInvalidPhone
          : labels.adminInvalidEmail;
      AppNotifier.error(message);
      return;
    }
    if (_role == 'ADMIN' && !widget.isRoot) {
      AppNotifier.error(labels.adminRootOnly);
      return;
    }
    final fullName = '${_first.text.trim()} ${_last.text.trim()}'.trim();
    final body = <String, Object?>{
      'firstname': _first.text.trim(),
      'lastname': _last.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
      'role': _role,
      if (_role == 'AGENT')
        'agent': {
          'displayName': _displayName.text.trim().isEmpty
              ? fullName
              : _displayName.text.trim(),
          'capabilities': _capabilities.toList(),
        },
      if (_role == 'DRIVER')
        'driver': {
          'agencyId': _agencyId,
          if (_vehicleType.text.trim().isNotEmpty)
            'vehicleType': _vehicleType.text.trim(),
          if (_plateNumber.text.trim().isNotEmpty)
            'plateNumber': _plateNumber.text.trim(),
        },
    };
    setState(() => _busy = true);
    final created = await widget.controller.createStaff(body);
    if (!mounted) return;
    setState(() => _busy = false);
    if (created) {
      Navigator.pop(context);
      AppNotifier.success(labels.adminStaffCreated);
    } else {
      final state = widget.controller.actionState.value;
      if (state is Failure<void>) {
        AppNotifier.error(adminApiFailureMessage(labels, state.failure));
      }
    }
  }
}
