import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/admin/domain/admin_account_status.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/domain/admin_user.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/section_states.dart';
import 'package:flutter/material.dart';

/// Administrator — user directory & account moderation.
///
/// Strictly serial wiring, PHASE 08D. This page is the first admin section
/// cabled into the router (users only); every field and every repository
/// method used here was verified against the committed models and the real
/// abstract [AdminRepository] (see demo repository in `data/`).
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key, required this.repository});

  final AdminRepository repository;

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late Future<List<AdminUser>> _users;
  String _query = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _users = widget.repository.fetchUsers();
  }

  void _reload() {
    setState(() {
      _users = widget.repository.fetchUsers(query: _query);
    });
  }

  Future<void> _moderate(Future<void> Function() job) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final updated = context.l10n.adminUsersUpdated;
    final failed = context.l10n.adminActionFailed;
    setState(() => _busy = true);
    try {
      await job();
      messenger.showSnackBar(SnackBar(content: Text(updated)));
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    // No app bar here: the shell already draws one for the whole workspace, and
    // a second one stacked under it ate a fifth of a phone screen for a title
    // that the section header already states.
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.pagePadding,
              AppSizes.pagePadding,
              0,
            ),
            child: SectionHeader(title: RoleSection.users.label(context.l10n)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: context.l10n.adminUsersSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _query = value;
                _reload();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AdminUser>>(
              future: _users,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _SectionError(
                    id: 'users',
                    message: '${snapshot.error}',
                    onRetry: _reload,
                  );
                }
                final users = snapshot.data;
                if (users == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (users.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_search_outlined,
                            size: 44,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.adminUsersEmpty,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _UserTile(
                      user: user,
                      onApprove:
                          user.status == AdminAccountStatus.verificationPending
                          ? () => _moderate(
                              () => widget.repository.approveUser(user.id),
                            )
                          : null,
                      onRestrict: user.status == AdminAccountStatus.active
                          ? () => _moderate(
                              () => widget.repository.restrictUser(user.id),
                            )
                          : null,
                      onReactivate: user.status == AdminAccountStatus.suspended
                          ? () => _moderate(
                              () => widget.repository.reactivateUser(user.id),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Moderation actions offered by a user tile.
///
/// An enum rather than bare strings so the menu cannot send a value no case
/// handles, and so the labels stay free to be translated.
enum _UserAction { approve, restrict, reactivate }

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    this.onApprove,
    this.onRestrict,
    this.onReactivate,
  });

  final AdminUser user;
  final VoidCallback? onApprove;
  final VoidCallback? onRestrict;
  final VoidCallback? onReactivate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
        ),
      ),
      title: Text(user.fullName),
      subtitle: Text(
        '${user.email} — ${l10n.adminUserActivityCaption(user.ordersCount, user.productsCount)}',
      ),
      isThreeLine: true,
      trailing: PopupMenuButton<_UserAction>(
        key: ValueKey('admin.users.menu.${user.id}'),
        onSelected: (action) => switch (action) {
          _UserAction.approve => onApprove?.call(),
          _UserAction.restrict => onRestrict?.call(),
          _UserAction.reactivate => onReactivate?.call(),
        },
        itemBuilder: (context) => [
          if (onApprove != null)
            PopupMenuItem(
              value: _UserAction.approve,
              child: Text(l10n.adminUserApprove),
            ),
          if (onRestrict != null)
            PopupMenuItem(
              value: _UserAction.restrict,
              child: Text(l10n.adminUserRestrict),
            ),
          if (onReactivate != null)
            PopupMenuItem(
              value: _UserAction.reactivate,
              child: Text(l10n.adminUserReactivate),
            ),
        ],
      ),
    );
  }
}

/// Section-level failure of the directory, retryable like the dashboard's.
class _SectionError extends StatelessWidget {
  const _SectionError({
    required this.id,
    required this.message,
    required this.onRetry,
  });

  final String id;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectionErrorCard(
      keyPrefix: 'admin',
      id: id,
      title: l10n.adminSectionLoadError,
      detail: l10n.adminSectionLoadErrorDetail(message),
      retryLabel: l10n.retry,
      onRetry: onRetry,
    );
  }
}
