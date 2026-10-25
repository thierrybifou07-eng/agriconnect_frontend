import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/shared/widgets/email_verification_banner.dart';
import 'package:agri_connect/shared/widgets/verification_banner.dart';

class ShellTab {
  const ShellTab({
    required this.icon,
    required this.label,
    required this.page,
    this.badge,
    this.route,
  });

  final IconData icon;
  final String label;
  final WidgetBuilder page;
  final RxInt? badge;
  final String? route;
}

class RoleShellController extends GetxController {
  final RxInt index = 0.obs;

  void select(int value) => index.value = value;
}

class RoleShell extends StatelessWidget {
  RoleShell({super.key, required this.tabs, this.title})
    : assert(tabs.isNotEmpty),
      controller = RoleShellController();

  final List<ShellTab> tabs;
  final String? title;
  final RoleShellController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'AgriConnect')),
      body: Column(
        children: [
          const EmailVerificationBanner(),
          const VerificationBanner(),
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: controller.index.value,
                children: [for (final tab in tabs) Builder(builder: tab.page)],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Obx(
          () => NavigationBar(
            selectedIndex: controller.index.value,
            onDestinationSelected: (index) {
              final route = tabs[index].route;
              if (route != null) {
                unawaited(Get.toNamed(route));
              } else {
                controller.select(index);
              }
            },
            destinations: [
              for (final tab in tabs)
                NavigationDestination(
                  icon: _tabIcon(tab),
                  selectedIcon: _tabIcon(tab),
                  label: tab.label,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabIcon(ShellTab tab) {
    final badge = tab.badge;
    if (badge == null) return Icon(tab.icon);
    return Obx(() {
      final count = badge.value;
      return Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        backgroundColor: AppColors.danger,
        child: Icon(tab.icon),
      );
    });
  }
}
