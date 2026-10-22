import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/chat/application/chat_thread_controller.dart';
import 'package:agri_connect/features/chat/domain/chat_message.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';

/// One conversation of the signed-in user with a marketplace counterpart.
///
/// Message history and sending are owned by [ChatThreadController]; the page
/// only renders the thread and keeps the composer honest about the
/// single-submission gate.
class ChatThreadPage extends ConsumerStatefulWidget {
  const ChatThreadPage({
    super.key,
    required this.conversationId,
    this.backPath,
  });

  final String conversationId;

  /// Where the back button returns, normally the inbox. `null` keeps the
  /// router default, for deep links.
  final String? backPath;

  @override
  ConsumerState<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends ConsumerState<ChatThreadPage> {
  final _composer = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  ChatThreadController get _controller =>
      ref.read(chatThreadControllerProvider(widget.conversationId).notifier);

  void _scrollToLatest() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    final text = _composer.text;
    if (text.trim().isEmpty) return;
    _composer.clear();
    await _controller.sendMessage(text);
    if (mounted) _scrollToLatest();
  }

  void _retry() {
    final failed = ref
        .read(chatThreadControllerProvider(widget.conversationId))
        .failedMessageText;
    if (failed == null) return;
    _controller.sendMessage(failed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = chatThreadControllerProvider(widget.conversationId);
    final state = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_counterpartName(state.messages, l10n.chatTitle)),
        // The thread is pushed over the inbox, so the platform back gesture
        // already returns to it. A deep link has nothing to pop, and the
        // explicit back button then falls back to the path the route was given.
        leading: widget.backPath == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: l10n.back,
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(widget.backPath!),
              ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: _buildThread(context, ref, l10n, state)),
            if (state.actionFailure != null)
              _SendFailureBanner(
                message: state.actionFailure!.message(l10n),
                onRetry: state.isSendingAny ? null : _retry,
                retryLabel: l10n.retry,
              ),
            _Composer(
              controller: _composer,
              enabled: !state.isSendingAny,
              hint: l10n.chatComposerHint,
              sendLabel: l10n.chatSend,
              onSend: state.isSendingAny ? null : _send,
            ),
          ],
        ),
      ),
    );
  }

  /// Counterpart inferred from the thread history, [fallback] while loading.
  String _counterpartName(List<ChatMessage> messages, String fallback) {
    for (final message in messages) {
      if (!message.isMine) return message.sender.fullName;
    }
    return fallback;
  }

  Widget _buildThread(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ChatThreadState state,
  ) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.failure != null && state.messages.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: FailureView(
          failure: state.failure!,
          onRetry: _controller.refresh,
        ),
      );
    }

    if (state.messages.isEmpty) {
      return EmptyState(
        icon: Icons.waving_hand_outlined,
        title: l10n.chatThreadEmptyTitle,
        body: l10n.chatThreadEmptyBody,
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return _MessageBubble(
          message: message,
          timestamp: AppFormats.chatTimestamp(
            message.sentAt,
            locale: context.localeCode,
          ),
        );
      },
    );
  }
}

/// Single message, aligned by ownership and timestamped.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.timestamp});

  final ChatMessage message;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMine ? colorScheme.onPrimary : colorScheme.onSurface,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timestamp,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isMine
                    ? colorScheme.onPrimary.withValues(alpha: 0.75)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline banner offering a manual retry after a failed send.
class _SendFailureBanner extends StatelessWidget {
  const _SendFailureBanner({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

/// Draft field with its send button; disabled during a submission.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.hint,
    required this.sendLabel,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hint;
  final String sendLabel;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => onSend?.call(),
                decoration: InputDecoration(
                  hintText: hint,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onSend,
              iconSize: 22,
              padding: const EdgeInsets.all(12),
              tooltip: sendLabel,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
