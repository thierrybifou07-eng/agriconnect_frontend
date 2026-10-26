import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/shared/widgets/role_shell.dart';
import 'package:agri_connect/features/chat/presentation/controllers/conversations_controller.dart';
import 'package:agri_connect/features/chat/presentation/pages/chat_pages.dart';
import 'package:agri_connect/features/buyer/presentation/controllers/orders_controller.dart';
import 'package:agri_connect/features/buyer/presentation/pages/buyer_pages.dart';

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
    final tabs = <ShellTab>[
      if (role == RoleCode.buyer)
        ShellTab(
          icon: Icons.storefront_outlined,
          label: localizations.buyerCatalogTab,
          page: (_) => const CatalogPage(),
        )
      else
        ShellTab(
          icon: Icons.home_outlined,
          label: localizations.roleHomeTab,
          page: (_) => _ComingSoon(message: localizations.roleComingSoon),
        ),
      if (role == RoleCode.buyer || role == RoleCode.supplier)
        ShellTab(
          icon: Icons.forum_outlined,
          label: localizations.chatTitle,
          badge: Get.find<ConversationsController>().unreadCount,
          page: (_) => const ConversationsPage(),
        ),
      if (role == RoleCode.buyer)
        ShellTab(
          icon: Icons.receipt_long_outlined,
          label: localizations.buyerOrdersTab,
          badge: Get.find<BuyerOrdersController>().quotedCount,
          page: (_) => const BuyerOrdersPage(),
        ),
      ShellTab(
        icon: Icons.person_outline,
        label: localizations.accountTab,
        page: (_) => _ComingSoon(message: localizations.roleComingSoon),
        route: AppRoutes.profile,
      ),
    ];
    return RoleShell(title: title, tabs: tabs);
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(message, textAlign: TextAlign.center));
}
