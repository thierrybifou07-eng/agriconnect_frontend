import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/onboarding/application/welcome_controller.dart';
import 'package:agri_connect/shared/widgets/role_avatar.dart';
import 'package:go_router/go_router.dart';

/// Summary of the role chosen during onboarding, with a shortcut to change
/// it. Renders nothing while no role has been selected yet.
///
/// [title] overrides the default label: the login screen keeps the generic
/// wording while the registration screen states « you are registering as ».
class SelectedRoleBanner extends ConsumerWidget {
  const SelectedRoleBanner({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final role = ref.watch(
      welcomeControllerProvider.select((s) => s.selectedRole),
    );
    if (role == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      // The "change role" action is laid out unconstrained inside a [Row], so on
      // a narrow phone it used to claim every pixel and squeeze the role summary
      // to zero width. Capping it to a share of the banner keeps the summary
      // readable and lets the action label shrink instead of overflowing.
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              RoleAvatar(role: role, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? l10n.loginSelectedRole,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role.label(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.45,
                ),
                child: TextButton(
                  onPressed: () async {
                    await ref
                        .read(welcomeControllerProvider.notifier)
                        .clearSelectedRole();
                    if (context.mounted) context.go(RoutePaths.role);
                  },
                  child: Text(
                    l10n.loginChangeRole,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
