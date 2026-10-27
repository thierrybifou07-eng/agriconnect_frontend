import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/ai/domain/ai_entities.dart';
import 'package:agri_connect/features/ai/presentation/controllers/ai_controllers.dart';

class AiEngineCard extends GetView<AiEngineController> {
  const AiEngineCard({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final state = controller.status.value;
          final test = controller.testState.value;
          if (state is Loading<AiEngineStatus> ||
              state is Idle<AiEngineStatus>) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is Failure<AiEngineStatus>) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels.aiEngineTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(labels.aiEngineLoadFailed),
                TextButton(
                  onPressed: controller.load,
                  child: Text(labels.retry),
                ),
              ],
            );
          }
          final status = (state as Success<AiEngineStatus>).data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      labels.aiEngineTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: labels.retry,
                    onPressed: controller.load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              _AiStatusRow(
                label: labels.aiEnabled,
                value: status.enabled ? labels.aiStatusYes : labels.aiStatusNo,
              ),
              _AiStatusRow(
                label: labels.aiReachable,
                value: status.reachable
                    ? labels.aiStatusYes
                    : labels.aiStatusNo,
              ),
              _AiStatusRow(
                label: labels.aiModelInstalled,
                value: status.modelInstalled
                    ? labels.aiStatusYes
                    : labels.aiStatusNo,
              ),
              _AiStatusRow(label: labels.aiProvider, value: status.provider),
              _AiStatusRow(
                label: labels.aiModel,
                value: status.model.isEmpty ? '—' : status.model,
              ),
              if (status.baseUrl != null)
                _AiStatusRow(label: labels.aiBaseUrl, value: status.baseUrl!),
              _AiStatusRow(
                label: labels.aiLatency,
                value: status.lastLatencyMs == null
                    ? '—'
                    : '${status.lastLatencyMs} ms',
              ),
              _AiStatusRow(
                label: labels.aiQueue,
                value: '${status.queuePending} / ${status.queueRunning}',
              ),
              if (status.quota case final quota?)
                _AiStatusRow(
                  label: labels.aiDailyQuota,
                  value: '${quota.usedToday} / ${quota.dailyBudget}',
                ),
              if (!status.reachable) ...[
                const SizedBox(height: 8),
                Text(
                  status.provider == 'ollama'
                      ? labels.aiOllamaUnreachable
                      : labels.aiGeminiUnreachable,
                ),
              ],
              if (status.provider == 'gemini' && status.authenticated == false)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels.aiInvalidKey),
                ),
              if (status.provider == 'gemini' && !status.modelInstalled)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels.aiModelNotFound),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: test is Loading<AiTestResult>
                      ? null
                      : controller.testEngine,
                  icon: test is Loading<AiTestResult>
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(labels.aiTest),
                ),
              ),
              if (test is Success<AiTestResult>)
                ..._testOutput(labels, test.data),
              if (test is Failure<AiTestResult>)
                Text(_aiError(labels, test.failure)),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> _testOutput(AppLocalizations labels, AiTestResult result) {
    final reply = result.output.reply;
    final intent = result.output.intent;
    return [
      Text('${labels.aiTestLatency}: ${result.latencyMs} ms'),
      if (reply != null) Text(reply) else if (intent != null) Text(intent),
    ];
  }
}

class _AiStatusRow extends StatelessWidget {
  const _AiStatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 132,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

String aiFailureMessage(AppLocalizations labels, ApiFailure failure) =>
    _aiError(labels, failure);

String _aiError(AppLocalizations labels, ApiFailure failure) =>
    switch (failure.code) {
      'AI_DISABLED' => labels.aiDisabledMessage,
      'AI_BUSY' => labels.aiBusyMessage,
      'AI_NO_AGENT' => labels.aiNoAgentMessage,
      'AI_RATE_LIMITED' => labels.aiRateLimited,
      'AI_AUTH_FAILED' => labels.aiInvalidKey,
      'AI_UNREACHABLE' => labels.aiGeminiUnreachable,
      'AI_MODEL_MISSING' => labels.aiModelNotFound,
      'AI_INVALID_OUTPUT' => labels.aiInvalidOutput,
      'INVALID_STATE_TRANSITION' => labels.aiClosedApproval,
      _ => failure.message,
    };
