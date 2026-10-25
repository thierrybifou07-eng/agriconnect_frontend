import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/shared/widgets/role_shell.dart';

class RolePlaceholderPage extends StatelessWidget {
  const RolePlaceholderPage({super.key, required this.role});

  final RoleCode role;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final title = switch (role) {
      RoleCode.supplier => localizations.roleSupplier,
      RoleCode.buyer => localizations.roleBuyer,
      RoleCode.driver => localizations.roleDriver,
      RoleCode.agent => localizations.roleAgent,
      RoleCode.admin => localizations.roleAdmin,
      RoleCode.root => localizations.roleRoot,
      RoleCode.unknown => 'AgriConnect',
    };
    return RoleShell(
      title: title,
      tabs: [
        ShellTab(
          icon: Icons.home_outlined,
          label: localizations.roleHomeTab,
          page: (_) => _ComingSoon(message: localizations.roleComingSoon),
        ),
        ShellTab(
          icon: Icons.more_horiz,
          label: localizations.roleComingSoon,
          page: (_) => _ComingSoon(message: localizations.roleComingSoon),
        ),
      ],
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(message, textAlign: TextAlign.center));
}
