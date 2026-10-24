import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/super_admin/domain/staff_account.dart';
import 'package:agri_connect/features/super_admin/domain/staff_permission.dart';
import 'package:agri_connect/features/super_admin/presentation/extensions/staff_permission_l10n.dart';

/// Bottom sheet granting or revoking the rights of one staff member.
///
/// Edits a local draft and writes once on save, so cancelling genuinely
/// discards. Rights reserved to the Super Admin are shown as locked switches:
/// the console neither hides them, which would look like a missing right, nor
/// lets them move, which would let a console delegate its own settings.
class StaffPermissionsSheet extends StatefulWidget {
  const StaffPermissionsSheet({
    super.key,
    required this.account,
    required this.onSave,
  });

  final StaffAccount account;

  /// Receives the wanted right set; the caller performs the write and reports
  /// the outcome.
  final Future<void> Function(Set<StaffPermission> permissions) onSave;

  /// Presents the sheet and reports success as a snack bar.
  static Future<void> show(
    BuildContext context, {
    required StaffAccount account,
    required Future<void> Function(Set<StaffPermission> permissions) onSave,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => StaffPermissionsSheet(account: account, onSave: onSave),
    );
  }

  @override
  State<StaffPermissionsSheet> createState() => _StaffPermissionsSheetState();
}

class _StaffPermissionsSheetState extends State<StaffPermissionsSheet> {
  late final Set<StaffPermission> _draft = {...widget.account.permissions};
  bool _saving = false;

  /// Rights the account may not hold, because only a Super Admin may.
  ///
  /// A locked right stays visible on the switch, disabled, so the reader sees
  /// that the platform models it and that this console does not delegate it.
  Set<StaffPermission> get _locked => {
    if (widget.account.role != UserRole.root)
      StaffPermission.managePlatformSettings,
  };

  bool get _changed {
    if (_draft.length != widget.account.permissions.length) return true;
    return _draft.any((p) => !widget.account.permissions.contains(p));
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await widget.onSave(_draft);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.superAdminStaffPermissionsSaved)),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        // Lifts the sheet above the keyboard so a long permission list stays
        // reachable while the user reads it.
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.superAdminStaffPermissionsTitle(widget.account.fullName),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.superAdminStaffPermissionsSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              for (final group in StaffPermissionGroup.values) ...[
                Text(
                  StaffPermissionL10n.groupLabel(group, l10n).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                for (final permission in group.permissions)
                  _PermissionRow(
                    permission: permission,
                    granted: _draft.contains(permission),
                    locked: _locked.contains(permission),
                    onChanged: (value) => setState(() {
                      if (value) {
                        _draft.add(permission);
                      } else {
                        _draft.remove(permission);
                      }
                    }),
                  ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('superAdmin.permissions.save'),
                  onPressed: _saving || !_changed ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(l10n.superAdminStaffPermissionsSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One right, its explanation, and the switch that grants it.
class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.permission,
    required this.granted,
    required this.locked,
    required this.onChanged,
  });

  final StaffPermission permission;
  final bool granted;
  final bool locked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return SwitchListTile(
      key: ValueKey('superAdmin.permission.${permission.keyName()}'),
      value: granted,
      // A reserved right is disabled, not hidden: the reader sees that it
      // exists and that it is not theirs to hand out.
      onChanged: locked ? null : onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(
        permission.label(l10n),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: locked ? scheme.onSurfaceVariant : scheme.onSurface,
        ),
      ),
      subtitle: Text(
        locked
            ? '${permission.body(l10n)} · ${l10n.superAdminPermissionLocked}'
            : permission.body(l10n),
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      secondary: Icon(
        permission.icon,
        size: 20,
        color: locked ? AppColors.accent : scheme.primary,
      ),
    );
  }
}
