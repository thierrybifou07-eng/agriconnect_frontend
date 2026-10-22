import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';

/// Signs the current user out, after a confirmation when needed.
class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key, this.compact = false});

  final bool compact;

  Future<void> _confirm(WidgetRef ref, BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (compact) {
      return IconButton(
        onPressed: () => _confirm(ref, context),
        tooltip: l10n.signOut,
        icon: const Icon(Icons.logout_rounded),
      );
    }
    return OutlinedButton.icon(
      onPressed: () => _confirm(ref, context),
      icon: const Icon(Icons.logout_rounded),
      label: Text(l10n.signOut),
    );
  }
}
