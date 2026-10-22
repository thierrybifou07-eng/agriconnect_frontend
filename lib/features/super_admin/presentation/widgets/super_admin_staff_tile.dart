import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/super_admin/domain/staff_account.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// One line of the staff directory.
///
/// Everything shown comes from the record: no action is offered that the
/// repository would refuse, so the row never advertises a write the console
/// cannot perform.
class SuperAdminStaffTile extends StatelessWidget {
  const SuperAdminStaffTile({
    super.key,
    required this.account,
    this.onEditPermissions,
    this.onSuspend,
    this.onRestore,
    this.enabled = true,
  });

  final StaffAccount account;

  /// Null for an account the console may not touch, which is what turns the row
  /// into a protected, read-only line.
  final VoidCallback? onEditPermissions;

  final VoidCallback? onSuspend;
  final VoidCallback? onRestore;

  /// False while a write is in flight, which greys the actions instead of
  /// letting the reader queue conflicting changes on the same account.
  final bool enabled;

  /// The console cannot touch a Super Admin or the account in use, and says so
  /// instead of showing actions that would fail.
  bool get _isProtected => onEditPermissions == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      key: ValueKey('superAdmin.staff.${account.id}'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _isSuspended
                      ? scheme.surfaceContainerHighest
                      : scheme.primaryContainer,
                  child: Text(
                    account.initials,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _isSuspended
                          ? scheme.onSurfaceVariant
                          : scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The name takes the room it needs; the badges below keep
                      // their own line instead of being squeezed by a long name.
                      Text(
                        account.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Wrap, and the access level among the badges: a rigid badge beside
            // the name is the first thing to overflow once the reader enlarges
            // the system font.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AccessBadge(level: account.accessLevel),
                StatusBadge(
                  label: account.role.label(l10n),
                  color: account.role == UserRole.root
                      ? AppColors.accent
                      : scheme.primary,
                  icon: account.role == UserRole.root
                      ? Icons.shield_rounded
                      : Icons.admin_panel_settings_rounded,
                ),
                StatusBadge(
                  label: l10n.superAdminStaffPermissionCount(
                    account.permissions.length,
                  ),
                  color: scheme.primary,
                  icon: Icons.key_rounded,
                ),
                StatusBadge(
                  label: l10n.superAdminStaffLastActive(
                    AppFormats.date(
                      account.lastActiveAt,
                      locale: context.localeCode,
                    ),
                  ),
                  color: scheme.onSurfaceVariant,
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isProtected)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.superAdminStaffProtectedNotice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              )
            else
              // Wrap, not Row: at a large font size the two actions no longer
              // fit side by side, and a Row would overflow instead of wrapping.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: ValueKey('superAdmin.staff.permissions.${account.id}'),
                    onPressed: enabled ? onEditPermissions : null,
                    icon: const Icon(Icons.key_rounded, size: 18),
                    label: Text(l10n.superAdminPermissionManageSettings),
                  ),
                  if (onSuspend != null)
                    TextButton.icon(
                      key: ValueKey('superAdmin.staff.suspend.${account.id}'),
                      onPressed: enabled ? onSuspend : null,
                      icon: const Icon(Icons.block_rounded, size: 18),
                      label: Text(l10n.superAdminStaffSuspend),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.error,
                      ),
                    ),
                  if (onRestore != null)
                    TextButton.icon(
                      key: ValueKey('superAdmin.staff.restore.${account.id}'),
                      onPressed: enabled ? onRestore : null,
                      icon: const Icon(Icons.lock_open_rounded, size: 18),
                      label: Text(l10n.superAdminStaffRestore),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool get _isSuspended => account.accessLevel == StaffAccessLevel.suspended;
}

/// Access level of a staff member, colored by how much it can do.
class _AccessBadge extends StatelessWidget {
  const _AccessBadge({required this.level});

  final StaffAccessLevel level;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return switch (level) {
      StaffAccessLevel.fullAccess => StatusBadge(
        label: l10n.superAdminStaffAccessFull,
        color: AppColors.success,
        icon: Icons.verified_user_rounded,
      ),
      StaffAccessLevel.readOnly => StatusBadge(
        label: l10n.superAdminStaffAccessReadOnly,
        color: scheme.primary,
        icon: Icons.visibility_rounded,
      ),
      StaffAccessLevel.suspended => StatusBadge(
        label: l10n.superAdminStaffAccessSuspended,
        color: scheme.error,
        icon: Icons.block_rounded,
      ),
    };
  }
}
