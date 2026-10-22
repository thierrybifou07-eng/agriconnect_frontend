import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/chat/application/chat_inbox_controller.dart';
import 'package:agri_connect/features/chat/domain/chat_conversation.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Inbox of the signed-in user, shared by every role workspace.
///
/// The counterpart and the unread state come from the session-scoped
/// repository, so the page needs no role knowledge of its own.
class ChatInboxPage extends ConsumerWidget {
  const ChatInboxPage({super.key, this.threadPathBuilder, this.backPath});

  /// Builds the thread location of [conversationId].
  ///
  /// Defaults to the supplier path; other workspaces pass their own builder so
  /// one page serves every role.
  final String Function(String conversationId)? threadPathBuilder;

  /// Where the back button returns, the dashboard the page was opened from.
  /// `null` keeps the router default, for deep links.
  final String? backPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(chatInboxControllerProvider);
    final back = backPath;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatTitle),
        // The inbox is reached from a quick action, outside the shell: without
        // an explicit back button the user cannot return to the dashboard.
        leading: back == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: l10n.back,
                // Popped when the inbox was pushed over the dashboard, and
                // jumped to the dashboard when it was reached by a deep link
                // and there is nothing to pop.
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go(back),
              ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(chatInboxControllerProvider.notifier).refresh(),
        child: _buildContent(context, ref, l10n, state),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ChatInboxState state,
  ) {
    final conversations = state.conversations;

    if (state.isLoading && conversations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: const [CardListSkeleton(itemCount: 4)],
      );
    }

    if (state.failure != null && conversations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          FailureView(
            failure: state.failure!,
            onRetry: () =>
                ref.read(chatInboxControllerProvider.notifier).refresh(),
          ),
        ],
      );
    }

    if (conversations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          EmptyState(
            icon: Icons.forum_outlined,
            title: l10n.chatEmptyTitle,
            body: l10n.chatEmptyBody,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      itemCount: conversations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _ConversationTile(
        conversation: conversations[index],
        // Pushed, so the platform back gesture walks the buyer out of the
        // thread and into the inbox instead of out of the app.
        onTap: () => context.push(
          threadPathBuilder?.call(conversations[index].id) ??
              RoutePaths.supplierMessageThread(conversations[index].id),
        ),
      ),
    );
  }
}

/// One conversation preview: counterpart, role, last message and unread badge.
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final participant = conversation.participant;
    final isUnread = conversation.unreadByMe;
    final timestamp = AppFormats.chatTimestamp(
      conversation.lastMessageAt,
      locale: context.localeCode,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isUnread ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(name: participant.fullName, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isUnread
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: isUnread ? colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      participant.role.label(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isUnread
                            ? colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.75,
                              )
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      conversation.lastMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.35,
                        color: isUnread
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isUnread ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timestamp,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isUnread
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isUnread ? FontWeight.w700 : null,
                    ),
                  ),
                  if (conversation.unreadCount > 0) ...[
                    const SizedBox(height: 8),
                    _UnreadBadge(count: conversation.unreadCount),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Count pill shown next to the timestamp of an unread conversation.
class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOnTint = colorScheme.brightness != Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isOnTint ? colorScheme.primary : colorScheme.tertiary,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isOnTint ? colorScheme.onPrimary : colorScheme.onTertiary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
