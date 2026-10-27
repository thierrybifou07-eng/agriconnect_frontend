import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/ai/domain/ai_entities.dart';
import 'package:agri_connect/features/ai/presentation/controllers/ai_controllers.dart';
import 'package:agri_connect/features/ai/presentation/widgets/ai_engine_card.dart';

class AiSuggestionPanel extends StatefulWidget {
  const AiSuggestionPanel({
    required this.conversationId,
    required this.messageText,
    required this.closed,
    this.onEscalate,
    super.key,
  });

  final int conversationId;
  final TextEditingController messageText;
  final bool closed;
  final VoidCallback? onEscalate;

  @override
  State<AiSuggestionPanel> createState() => _AiSuggestionPanelState();
}

class _AiSuggestionPanelState extends State<AiSuggestionPanel> {
  final AiSuggestionController _controller = Get.find<AiSuggestionController>();
  final TextEditingController _reply = TextEditingController();
  int? _loadedSuggestionId;
  bool _loadedPayload = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Obx(() {
      final item = _controller.current.value;
      final suggestion = item?.conversationId == widget.conversationId
          ? item
          : null;
      final actionState = _controller.actionState.value;
      if (suggestion == null) {
        final code = _controller.lastErrorCode.value;
        if (code == 'AI_DISABLED') {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              labels.aiDisabledMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        if (code == 'AI_BUSY' || code == 'AI_NO_AGENT') {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_failureText(labels, code, null)),
          );
        }
        if (actionState is Loading<void>) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.closed
                      ? null
                      : () => _controller.suggestReply(widget.conversationId),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: Text(labels.aiSuggestReply),
                ),
              ),
              if (actionState is Failure<void>) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_failureText(labels, code, actionState.failure)),
                ),
              ],
            ],
          ),
        );
      }

      if (_loadedSuggestionId != suggestion.id) {
        _loadedSuggestionId = suggestion.id;
        _loadedPayload = suggestion.payload != null;
        _reply.text = suggestion.payload?.reply ?? '';
      } else if (!_loadedPayload && suggestion.payload != null) {
        _loadedPayload = true;
        _reply.text = suggestion.payload?.reply ?? '';
      }

      if (suggestion.isGenerating) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${labels.aiGenerating} ${labels.aiGenerationExplanation}',
                ),
              ),
            ],
          ),
        );
      }

      final payload = suggestion.payload;
      if (suggestion.status == AiSuggestionStatus.failed ||
          suggestion.status == AiSuggestionStatus.expired) {
        final message = _failureText(labels, suggestion.error, null);
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              TextButton.icon(
                onPressed: _controller.retry,
                icon: const Icon(Icons.refresh),
                label: Text(labels.aiRetry),
              ),
            ],
          ),
        );
      }
      if (!suggestion.isReady || payload == null) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Text(_statusLabel(labels, suggestion.status)),
        );
      }
      if (suggestion.kind == AiSuggestionKind.triage) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (payload.intent != null)
                Chip(label: Text(_intentLabel(labels, payload.intent!))),
              if (payload.urgency != null)
                Chip(label: Text(_urgencyLabel(labels, payload.urgency!))),
              if (payload.needsHuman == true)
                ActionChip(
                  label: Text(labels.aiEscalate),
                  onPressed: widget.onEscalate,
                ),
            ],
          ),
        );
      }
      if (suggestion.kind == AiSuggestionKind.listingDraft) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            payload.listing == null
                ? labels.aiDraftGenerating
                : '${payload.listing!.title}\n${payload.listing!.description}',
          ),
        );
      }

      final originalReply = payload.reply ?? '';
      final hasNumberWarning = payload.reasons.contains('UNVERIFIED_NUMBER');
      return Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (payload.intent != null)
                    Chip(label: Text(_intentLabel(labels, payload.intent!))),
                  if (payload.language != null)
                    Chip(
                      label: Text('${labels.aiLanguage}: ${payload.language}'),
                    ),
                  if (payload.needsHuman == true)
                    Chip(label: Text(labels.aiHumanNeeded)),
                  if (hasNumberWarning)
                    Chip(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.errorContainer,
                      label: Text(labels.aiVerifyNumbers),
                    ),
                ],
              ),
              if (payload.confidence case final confidence?)
                Row(
                  children: [
                    SizedBox(width: 100, child: Text(labels.aiConfidence)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: confidence.clamp(0, 1),
                        semanticsLabel: labels.aiConfidence,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(confidence * 100).round()}%'),
                  ],
                ),
              for (final reason in payload.reasons.where(
                (reason) => reason != 'UNVERIFIED_NUMBER',
              ))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(reason),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _reply,
                minLines: 2,
                maxLines: 6,
                maxLength: 2000,
                decoration: InputDecoration(
                  labelText: labels.aiSuggestionReady,
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (hasNumberWarning)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _HighlightedNumbers(text: _reply.text),
                ),
              Text(
                suggestion.agent.autonomy == 'ACT_WITH_APPROVAL'
                    ? labels.aiApprovalExplanation
                    : labels.aiSuggestOnlyExplanation,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      widget.messageText.text = _reply.text;
                      widget.messageText.selection = TextSelection.collapsed(
                        offset: widget.messageText.text.length,
                      );
                      AppNotifier.info(labels.aiUse);
                    },
                    child: Text(labels.aiUse),
                  ),
                  FilledButton(
                    onPressed: actionState is Loading<void>
                        ? null
                        : () => _send(originalReply, labels),
                    child: Text(labels.aiSend),
                  ),
                  TextButton(
                    onPressed: actionState is Loading<void>
                        ? null
                        : () => _reject(labels),
                    child: Text(labels.aiReject),
                  ),
                ],
              ),
              if (widget.closed)
                Text(
                  labels.aiClosedApproval,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (actionState is Failure<void>)
                Text(
                  _failureText(
                    labels,
                    actionState.failure.code,
                    actionState.failure,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _send(String originalReply, AppLocalizations labels) async {
    final edited = _reply.text.trim();
    final sent = await _controller.approve(
      editedContent: edited == originalReply.trim() ? null : edited,
    );
    if (sent) AppNotifier.success(labels.aiSend);
  }

  Future<void> _reject(AppLocalizations labels) async {
    final reason = TextEditingController();
    final value = await Get.dialog<String>(
      AlertDialog(
        title: Text(labels.aiReject),
        content: TextField(
          controller: reason,
          maxLength: 500,
          decoration: InputDecoration(labelText: labels.aiRejectReason),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(labels.adminCancel)),
          FilledButton(
            onPressed: () => Get.back(result: reason.text),
            child: Text(labels.aiReject),
          ),
        ],
      ),
    );
    reason.dispose();
    if (value == null) return;
    await _controller.reject(reason: value);
  }
}

class AiSuggestionQueuePanel extends GetView<AiSuggestionController> {
  const AiSuggestionQueuePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: controller.statusFilter.value,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(labels.staffInboxAll),
                    ),
                    for (final status in const [
                      'PENDING',
                      'EXECUTED',
                      'FAILED',
                      'EXPIRED',
                      'REJECTED',
                      'APPROVED',
                    ])
                      DropdownMenuItem(
                        value: status,
                        child: Text(_statusName(labels, status)),
                      ),
                  ],
                  onChanged: (value) =>
                      controller.setQueueFilters(status: value ?? ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: controller.kindFilter.value,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(labels.aiKindFilter),
                    ),
                    for (final kind in const [
                      'REPLY',
                      'TRIAGE',
                      'LISTING_DRAFT',
                    ])
                      DropdownMenuItem(
                        value: kind,
                        child: Text(_kindName(labels, kind)),
                      ),
                  ],
                  onChanged: (value) =>
                      controller.setQueueFilters(kind: value ?? ''),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final state = controller.queueState.value;
            if (state is Loading<Paginated<AiSuggestion>> ||
                state is Idle<Paginated<AiSuggestion>>) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is Failure<Paginated<AiSuggestion>>) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(aiFailureMessage(labels, state.failure)),
                    TextButton(
                      onPressed: controller.loadQueue,
                      child: Text(labels.retry),
                    ),
                  ],
                ),
              );
            }
            final page = (state as Success<Paginated<AiSuggestion>>).data;
            if (page.items.isEmpty) {
              return Center(child: Text(labels.aiNoSuggestions));
            }
            return RefreshIndicator(
              onRefresh: controller.loadQueue,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.extentAfter < 180 &&
                      page.page * page.limit < page.total) {
                    unawaited(controller.loadQueue(append: true));
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: page.items.length,
                  itemBuilder: (_, index) {
                    final item = page.items[index];
                    return ListTile(
                      leading: const Icon(Icons.auto_awesome_outlined),
                      title: Text(_kindName(labels, _kindCode(item.kind))),
                      subtitle: Text(
                        '${item.isGenerating ? labels.aiStatusGenerating : _statusLabel(labels, item.status)} · ${item.agent.displayName}'
                        '${item.conversationId == null ? '' : ' · #${item.conversationId}'}',
                      ),
                      trailing: item.isReady
                          ? const Icon(Icons.circle, size: 10)
                          : null,
                      onTap: item.conversationId == null
                          ? null
                          : () => Get.toNamed(
                              AppRoutes.staffConversation(item.conversationId!),
                            ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _HighlightedNumbers extends StatelessWidget {
  const _HighlightedNumbers({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final number = RegExp(r'\b\d+(?:[.,]\d+)*\b');
    final spans = <TextSpan>[];
    var offset = 0;
    for (final match in number.allMatches(text)) {
      if (match.start > offset) {
        spans.add(TextSpan(text: text.substring(offset, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            color: Theme.of(context).colorScheme.onErrorContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      offset = match.end;
    }
    if (offset < text.length) spans.add(TextSpan(text: text.substring(offset)));
    if (spans.isEmpty) spans.add(TextSpan(text: text));
    return SelectableText.rich(TextSpan(children: spans));
  }
}

String _kindCode(AiSuggestionKind kind) => switch (kind) {
  AiSuggestionKind.reply => 'REPLY',
  AiSuggestionKind.triage => 'TRIAGE',
  AiSuggestionKind.listingDraft => 'LISTING_DRAFT',
};

String _kindName(AppLocalizations labels, String kind) => switch (kind) {
  'REPLY' => labels.aiKindReply,
  'TRIAGE' => labels.aiKindTriage,
  'LISTING_DRAFT' => labels.aiKindListingDraft,
  _ => kind,
};

String _statusName(AppLocalizations labels, String status) => switch (status) {
  'PENDING' => labels.aiStatusPending,
  'EXECUTED' => labels.aiSend,
  'FAILED' => labels.aiStatusFailed,
  'EXPIRED' => labels.aiStatusExpired,
  'REJECTED' => labels.aiReject,
  'APPROVED' => labels.aiSend,
  _ => status,
};

String _statusLabel(AppLocalizations labels, AiSuggestionStatus status) =>
    switch (status) {
      AiSuggestionStatus.pending => labels.aiStatusReady,
      AiSuggestionStatus.failed => labels.aiStatusFailed,
      AiSuggestionStatus.expired => labels.aiStatusExpired,
      AiSuggestionStatus.approved ||
      AiSuggestionStatus.executed => labels.aiSend,
      AiSuggestionStatus.rejected => labels.aiReject,
    };

String _intentLabel(AppLocalizations labels, String intent) => switch (intent) {
  'PRODUCT_QUESTION' => labels.aiIntentProductQuestion,
  'PRICE_QUOTE_REQUEST' => labels.aiIntentPriceQuote,
  'DELIVERY_QUESTION' => labels.aiIntentDeliveryQuestion,
  'VERIFICATION_STATUS' => labels.aiIntentVerification,
  'COMPLAINT' => labels.aiIntentComplaint,
  'OTHER' => labels.aiIntentOther,
  _ => intent,
};

String _urgencyLabel(AppLocalizations labels, String urgency) =>
    switch (urgency.toUpperCase()) {
      'LOW' => labels.aiUrgencyLow,
      'MEDIUM' => labels.aiUrgencyMedium,
      'HIGH' => labels.aiUrgencyHigh,
      'URGENT' => labels.aiUrgencyUrgent,
      _ => urgency,
    };

String _failureText(
  AppLocalizations labels,
  String? code,
  ApiFailure? failure,
) => switch (code) {
  'AI_DISABLED' => labels.aiDisabledMessage,
  'AI_BUSY' => labels.aiBusyMessage,
  'AI_NO_AGENT' => labels.aiNoAgentMessage,
  'AI_RATE_LIMITED' => labels.aiRateLimited,
  'AI_AUTH_FAILED' => labels.aiInvalidKey,
  'AI_UNREACHABLE' => labels.aiGeminiUnreachable,
  'AI_MODEL_MISSING' => labels.aiModelNotFound,
  'AI_INVALID_OUTPUT' => labels.aiInvalidOutput,
  'INVALID_STATE_TRANSITION' => labels.aiClosedApproval,
  _ => failure?.message ?? code ?? labels.aiInvalidOutput,
};
