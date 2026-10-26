import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/chat/domain/chat_entities.dart';
import 'package:agri_connect/features/chat/presentation/bindings/chat_bindings.dart';
import 'package:agri_connect/features/chat/presentation/controllers/conversations_controller.dart';

class ConversationsPage extends GetView<ConversationsController> {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final startRequest = Get.arguments is ChatStartRequest
        ? Get.arguments as ChatStartRequest
        : null;
    return Scaffold(
      appBar: AppBar(title: Text(labels.chatTitle)),
      body: Obx(() {
        final state = controller.state.value;
        if (state is Loading<List<Conversation>> ||
            state is Idle<List<Conversation>>) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is Failure<List<Conversation>>) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppNotifier.failureMessage(state.failure, labels)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: controller.loadFirst,
                  child: Text(labels.retry),
                ),
              ],
            ),
          );
        }
        final conversations = controller.sortedConversations;
        if (conversations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels.chatEmptyTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(labels.chatEmptyBody, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _startRequest(context, startRequest),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(labels.chatStartConversation),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadFirst,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 240 &&
                  controller.hasMore) {
                controller.loadMore();
              }
              return false;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: conversations.length + (controller.hasMore ? 1 : 0),
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == conversations.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final conversation = conversations[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.support_agent)),
                  title: Text(
                    conversation.subject ?? labels.chatConversationSubject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(_statusLabel(conversation.status, labels)),
                  trailing: Obx(
                    () => controller.isUnread(conversation.id)
                        ? const CircleAvatar(radius: 5)
                        : const Icon(Icons.chevron_right),
                  ),
                  onTap: () {
                    controller.markSeen(conversation);
                    Get.toNamed(
                      AppRoutes.chatThread,
                      arguments: {
                        'conversationId': conversation.id,
                        'conversation': conversation,
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      }),
      floatingActionButton: startRequest == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _startRequest(context, startRequest),
              icon: const Icon(Icons.edit_outlined),
              label: Text(labels.chatStartConversation),
            ),
    );
  }

  Future<void> _startRequest(
    BuildContext context,
    ChatStartRequest? request,
  ) async {
    final labels = AppLocalizations.of(context);
    final input = TextEditingController(text: request?.prefill ?? '');
    final content = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(labels.chatStartConversation),
        content: TextField(
          controller: input,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          maxLength: 5000,
          decoration: InputDecoration(hintText: labels.chatComposerHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(labels.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(input.text.trim()),
            child: Text(labels.chatSend),
          ),
        ],
      ),
    );
    input.dispose();
    if (content == null || content.isEmpty) return;
    try {
      final conversation = await controller.startConversation(
        listingId: request?.listingId,
        lotId: request?.lotId,
        content: content,
      );
      await Get.toNamed(
        AppRoutes.chatThread,
        arguments: {
          'conversationId': conversation.id,
          'conversation': conversation,
        },
      );
    } on ApiFailure catch (failure) {
      AppNotifier.error(AppNotifier.failureMessage(failure, labels));
    }
  }

  String _statusLabel(ConversationStatus status, AppLocalizations labels) =>
      switch (status) {
        ConversationStatus.open => labels.chatStatusOpen,
        ConversationStatus.waitingCustomer => labels.chatStatusWaiting,
        ConversationStatus.closed => labels.chatStatusClosed,
      };
}

class ChatThreadPage extends GetView<ThreadController> {
  const ChatThreadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final input = controller.composerController;
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.currentConversation.value?.subject ??
                labels.chatConversationSubject,
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(
            () => controller.isConversationClosed
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Text(labels.chatClosedExplanation),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Obx(() {
              final state = controller.state.value;
              if (state is Loading<List<ChatMessage>> ||
                  state is Idle<List<ChatMessage>>) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is Failure<List<ChatMessage>>) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppNotifier.failureMessage(state.failure, labels)),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: controller.reload,
                        child: Text(labels.retry),
                      ),
                    ],
                  ),
                );
              }
              final messages = (state as Success<List<ChatMessage>>).data;
              if (messages.isEmpty) {
                return Center(child: Text(labels.chatThreadEmptyTitle));
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.extentBefore < 80) {
                    controller.loadOlder();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      messages.length + (controller.hasOlder.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (controller.hasOlder.value && index == 0) {
                      return Center(
                        child: TextButton(
                          onPressed: controller.loadOlder,
                          child: Text(labels.chatLoadOlder),
                        ),
                      );
                    }
                    final message =
                        messages[index - (controller.hasOlder.value ? 1 : 0)];
                    return Align(
                      alignment: message.isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.isMine
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!message.isMine)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(message.senderLabel),
                                  if (message.isAi) ...[
                                    const SizedBox(width: 6),
                                    Chip(
                                      label: Text(labels.chatAiBadge),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ],
                              ),
                            Text(message.content),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          Obx(() {
            if (controller.sendFailure.value != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppNotifier.error(
                  AppNotifier.failureMessage(
                    controller.sendFailure.value!,
                    labels,
                  ),
                );
                controller.sendFailure.value = null;
              });
            }
            return const SizedBox.shrink();
          }),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: input,
                        enabled:
                            !controller.isConversationClosed &&
                            !controller.isSending.value,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 5000,
                        decoration: InputDecoration(
                          hintText: labels.chatComposerHint,
                          counterText: '',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed:
                          controller.isConversationClosed ||
                              controller.isSending.value
                          ? null
                          : () {
                              final text = input.text;
                              if (text.trim().isEmpty) return;
                              controller.send(text).then((sent) {
                                if (sent) input.clear();
                              });
                            },
                      tooltip: labels.chatSend,
                      icon: controller.isSending.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
