import 'package:flutter/material.dart';

import 'package:agri_connect/features/auth/domain/user_role.dart';

/// Rounded tile displaying the icon of [role].
class RoleAvatar extends StatelessWidget {
  const RoleAvatar({super.key, required this.role, this.size = 48});

  final UserRole role;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        role.icon,
        size: size * 0.52,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}

extension UserRoleIconX on UserRole {
  IconData get icon => switch (this) {
    UserRole.buyer => Icons.storefront_rounded,
    UserRole.supplier => Icons.spa_rounded,
    UserRole.driver => Icons.local_shipping_rounded,
    UserRole.agent => Icons.support_agent_rounded,
    UserRole.admin => Icons.admin_panel_settings_rounded,
    UserRole.root => Icons.verified_user_rounded,
  };
}
