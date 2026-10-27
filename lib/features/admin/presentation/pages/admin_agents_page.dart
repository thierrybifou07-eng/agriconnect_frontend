import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_controllers.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:agri_connect/features/ai/domain/ai_entities.dart';
import 'package:agri_connect/features/ai/presentation/controllers/ai_controllers.dart';
import 'package:agri_connect/features/ai/presentation/widgets/ai_engine_card.dart';

class AdminAgentsPanel extends GetView<AdminAgentsController> {
  const AdminAgentsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  labels.adminTabAgents,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _CreateAiAgentDialog(controller: controller),
                ),
                icon: const Icon(Icons.add),
                label: Text(labels.aiAgentCreate),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: AiEngineCard(),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${agent.userName ?? labels.adminHumanAgent} · '
                          '${agent.isActive ? labels.adminActive : labels.adminSuspended}',
                        ),
                        if (agent.isAi)
                          Obx(() {
                            final engineState =
                                Get.find<AiEngineController>().status.value;
                            if (engineState is! Success<AiEngineStatus> ||
                                agent.aiModel == null ||
                                agent.aiModel == engineState.data.model) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                labels.aiModelMismatch,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (agent.isAi)
                          Chip(
                            label: Text(labels.adminAiBadge),
                            visualDensity: VisualDensity.compact,
                          ),
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
  late final Set<String> _capabilities = widget.agent.capabilities
      .where(
        (capability) =>
            !widget.agent.isAi || aiAgentCapabilities.contains(capability),
      )
      .toSet();
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
                    child: Text(labels.aiAutonomySuggest),
                  ),
                  DropdownMenuItem(
                    value: 'ACT_WITH_APPROVAL',
                    child: Text(labels.aiAutonomyApproval),
                  ),
                  DropdownMenuItem(
                    value: 'AUTONOMOUS',
                    enabled: !widget.agent.isAi || _autonomousEnabled,
                    child: Text(labels.aiAutonomyAutonomous),
                  ),
                ],
                onChanged: _chooseAutonomy,
              ),
              if (widget.agent.isAi && !_autonomousEnabled)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(labels.aiAutonomousDisabled),
                ),
              if (widget.agent.isAi)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(labels.aiNoMoney),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(labels.adminCapabilities),
                ),
              ),
              for (final capability
                  in widget.agent.isAi
                      ? aiAgentCapabilities
                      : adminCapabilities)
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
      autonomousEnabled: _autonomousEnabled,
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

  bool get _autonomousEnabled {
    final state = Get.find<AiEngineController>().status.value;
    return state is Success<AiEngineStatus> && state.data.autonomousEnabled;
  }

  Future<void> _chooseAutonomy(String? value) async {
    if (value == 'AUTONOMOUS') {
      if (!_autonomousEnabled) return;
      final labels = AppLocalizations.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(labels.aiAutonomousWarning),
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
    if (mounted) setState(() => _autonomy = value);
  }
}

class _CreateAiAgentDialog extends StatefulWidget {
  const _CreateAiAgentDialog({required this.controller});

  final AdminAgentsController controller;

  @override
  State<_CreateAiAgentDialog> createState() => _CreateAiAgentDialogState();
}

class _CreateAiAgentDialogState extends State<_CreateAiAgentDialog> {
  late final TextEditingController _displayName = TextEditingController();
  late final TextEditingController _model = TextEditingController(
    text: _engine?.model ?? '',
  );
  final AiEngineStatus? _engine = _loadedEngine();
  late String _provider = _engine?.provider == 'gemini' ? 'gemini' : 'ollama';
  String _autonomy = 'SUGGEST_ONLY';
  bool _saving = false;

  static AiEngineStatus? _loadedEngine() {
    if (!Get.isRegistered<AiEngineController>()) return null;
    final state = Get.find<AiEngineController>().status.value;
    return state is Success<AiEngineStatus> ? state.data : null;
  }

  bool get _autonomousEnabled => _engine?.autonomousEnabled == true;

  @override
  void dispose() {
    _displayName.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(labels.aiAgentCreate),
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
              DropdownButtonFormField<String>(
                initialValue: _provider,
                decoration: InputDecoration(labelText: labels.aiProvider),
                items: [
                  DropdownMenuItem(
                    value: 'ollama',
                    child: Text(labels.aiProviderOllama),
                  ),
                  DropdownMenuItem(
                    value: 'gemini',
                    child: Text(labels.aiProviderGemini),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _provider = value);
                },
              ),
              TextField(
                controller: _model,
                decoration: InputDecoration(labelText: labels.aiModel),
                onChanged: (_) => setState(() {}),
              ),
              DropdownButtonFormField<String>(
                initialValue: _autonomy,
                decoration: InputDecoration(labelText: labels.adminAutonomy),
                items: [
                  DropdownMenuItem(
                    value: 'SUGGEST_ONLY',
                    child: Text(labels.aiAutonomySuggest),
                  ),
                  DropdownMenuItem(
                    value: 'ACT_WITH_APPROVAL',
                    child: Text(labels.aiAutonomyApproval),
                  ),
                  DropdownMenuItem(
                    value: 'AUTONOMOUS',
                    enabled: _autonomousEnabled,
                    child: Text(labels.aiAutonomyAutonomous),
                  ),
                ],
                onChanged: _chooseAutonomy,
              ),
              if (!_autonomousEnabled)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(labels.aiAutonomousDisabled),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(labels.aiNoMoney),
              ),
              if (_engine != null &&
                  _model.text.trim().isNotEmpty &&
                  _model.text.trim() != _engine.model)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(labels.aiModelMismatch),
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
          onPressed: _saving ? null : _create,
          child: Text(labels.aiAgentCreate),
        ),
      ],
    );
  }

  Future<void> _chooseAutonomy(String? value) async {
    if (value == null) return;
    if (value == 'AUTONOMOUS') {
      if (!_autonomousEnabled) return;
      final labels = AppLocalizations.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(labels.aiAutonomousWarning),
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
    if (mounted) setState(() => _autonomy = value);
  }

  Future<void> _create() async {
    final labels = AppLocalizations.of(context);
    if (_displayName.text.trim().isEmpty || _model.text.trim().isEmpty) {
      AppNotifier.error(labels.adminDisplayName);
      return;
    }
    setState(() => _saving = true);
    final created = await widget.controller.createAiAgent(
      displayName: _displayName.text,
      aiProvider: _provider,
      aiModel: _model.text,
      autonomy: _autonomy,
      autonomousEnabled: _autonomousEnabled,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (created) {
      Navigator.pop(context);
      AppNotifier.success(labels.aiAgentCreated);
    } else {
      final state = widget.controller.actionState.value;
      if (state is Failure<void>) {
        AppNotifier.error(adminApiFailureMessage(labels, state.failure));
      }
    }
  }
}
