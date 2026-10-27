import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_controllers.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_widgets.dart';

class AdminAgentsPanel extends GetView<AdminAgentsController> {
  const AdminAgentsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              labels.adminTabAgents,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final state = controller.state.value;
            if (state is Loading<List<AdminAgent>> ||
                state is Idle<List<AdminAgent>>) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is Failure<List<AdminAgent>>) {
              return AdminRetryMessage(
                message: adminApiFailureMessage(labels, state.failure),
                onRetry: controller.load,
              );
            }
            final agents = (state as Success<List<AdminAgent>>).data;
            if (agents.isEmpty) {
              return Center(child: Text(labels.adminNoAgents));
            }
            return RefreshIndicator(
              onRefresh: controller.load,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: agents.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final agent = agents[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: agent.isAi
                          ? const Icon(Icons.smart_toy_outlined)
                          : const Icon(Icons.person_outline),
                    ),
                    title: Text(agent.displayName),
                    subtitle: Text(
                      '${agent.userName ?? labels.adminHumanAgent} · '
                      '${agent.isActive ? labels.adminActive : labels.adminSuspended}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (agent.isAi)
                          Chip(
                            label: Text(labels.adminAiBadge),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (!agent.isAi)
                          IconButton(
                            tooltip: labels.adminEditAgent,
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (_) => _EditAgentDialog(
                                controller: controller,
                                agent: agent,
                              ),
                            ),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(labels.adminReadOnlyAi),
        ),
      ],
    );
  }
}

class _EditAgentDialog extends StatefulWidget {
  const _EditAgentDialog({required this.controller, required this.agent});

  final AdminAgentsController controller;
  final AdminAgent agent;

  @override
  State<_EditAgentDialog> createState() => _EditAgentDialogState();
}

class _EditAgentDialogState extends State<_EditAgentDialog> {
  late final TextEditingController _displayName = TextEditingController(
    text: widget.agent.displayName,
  );
  late bool _isActive = widget.agent.isActive;
  late final Set<String> _capabilities = widget.agent.capabilities.toSet();
  late String? _autonomy = widget.agent.autonomy;
  bool _saving = false;

  @override
  void dispose() {
    _displayName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(labels.adminEditAgent),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _displayName,
                decoration: InputDecoration(labelText: labels.adminDisplayName),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(labels.adminAgentActive),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              DropdownButtonFormField<String?>(
                initialValue: _autonomy,
                decoration: InputDecoration(labelText: labels.adminAutonomy),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(labels.adminAutonomyNone),
                  ),
                  DropdownMenuItem(
                    value: 'SUGGEST_ONLY',
                    child: Text(labels.adminAutonomySuggest),
                  ),
                  DropdownMenuItem(
                    value: 'ACT_WITH_APPROVAL',
                    child: Text(labels.adminAutonomyApproval),
                  ),
                  DropdownMenuItem(
                    value: 'AUTONOMOUS',
                    child: Text(labels.adminAutonomyFull),
                  ),
                ],
                onChanged: (value) => setState(() => _autonomy = value),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(labels.adminCapabilities),
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
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(labels.adminCancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(labels.adminSave),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final labels = AppLocalizations.of(context);
    if (_displayName.text.trim().isEmpty) {
      AppNotifier.error(labels.adminDisplayName);
      return;
    }
    if (widget.agent.isActive && !_isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(labels.adminConfirmDeactivateTitle),
          content: Text(labels.adminConfirmDeactivateBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(labels.adminCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(labels.adminConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() => _saving = true);
    final updated = await widget.controller.updateAgent(
      widget.agent,
      displayName: _displayName.text,
      isActive: _isActive,
      capabilities: _capabilities,
      autonomy: _autonomy,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (updated) {
      Navigator.pop(context);
      AppNotifier.success(labels.adminAccountUpdated);
    } else {
      final state = widget.controller.actionState.value;
      if (state is Failure<void>) {
        AppNotifier.error(adminApiFailureMessage(labels, state.failure));
      }
    }
  }
}
