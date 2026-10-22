import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/onboarding/application/welcome_controller.dart';
import 'package:agri_connect/shared/widgets/role_avatar.dart';
import 'package:agri_connect/shared/widgets/welcome_page_layout.dart';

class RolePage extends ConsumerWidget {
  const RolePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(
      welcomeControllerProvider.select((s) => s.selectedRole),
    );

    return WelcomePageLayout(
      title: l10n.roleTitle,
      subtitle: l10n.roleSubtitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Staff roles are provisioned by the platform and are never offered at
          // signup; only the self-registerable roles are selectable.
          for (var index = 0; index < UserRole.onboardingRoles.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == UserRole.onboardingRoles.length - 1 ? 0 : 10,
              ),
              child: _RoleCard(
                role: UserRole.onboardingRoles[index],
                selected: selected == UserRole.onboardingRoles[index],
                onTap: () => ref
                    .read(welcomeControllerProvider.notifier)
                    .selectRole(UserRole.onboardingRoles[index]),
              ),
            ),
        ],
      ),
      footer: TextButton(
        onPressed: () => context.go(RoutePaths.login),
        child: Text(l10n.signIn),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.55)
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              RoleAvatar(role: role, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role.label(l10n), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      role.description(l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 22,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
