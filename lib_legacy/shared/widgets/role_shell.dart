import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/notifications/application/notifications_controller.dart';
import 'package:agri_connect/shared/widgets/sign_out_button.dart';

/// Static description of a role workspace: the role it belongs to, its
/// navigation destinations and its entry page.
class RoleShellConfig {
  const RoleShellConfig({
    required this.role,
    required this.sections,
    required this.dashboardBuilder,
  });

  final UserRole role;
  final List<RoleSection> sections;
  final Widget Function() dashboardBuilder;
}

/// App shell rendered for each authenticated role.
///
/// Owns the application bar and the bottom navigation, delegating page
/// switching to [StatefulNavigationShell].
class RoleShell extends ConsumerWidget {
  const RoleShell({
    super.key,
    required this.config,
    required this.navigationShell,
  });

  final RoleShellConfig config;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final capabilities =
        ref.watch(authControllerProvider).user?.capabilities ??
        const <UserCapability>{};

    final width = MediaQuery.sizeOf(context).width;

    // The shell keeps every section as a branch, but the navigation bar only
    // offers the ones the session may open. Each entry remembers the branch it
    // maps to so a tap still switches the underlying shell, not the visible
    // list position.
    final visible = <({RoleSection section, int branchIndex})>[];
    for (
      var branchIndex = 0;
      branchIndex < config.sections.length;
      branchIndex++
    ) {
      final section = config.sections[branchIndex];
      final required = section.requiredCapability;
      if (required == null || capabilities.contains(required)) {
        visible.add((section: section, branchIndex: branchIndex));
      }
    }
    if (visible.isEmpty) {
      // A misconfigured role must still render a reachable surface instead of
      // an empty bar; the dashboard is the natural landing tab.
      visible.add((section: config.sections.first, branchIndex: 0));
    }

    final currentBranch = navigationShell.currentIndex;
    var selectedIndex = visible.indexWhere(
      (entry) => entry.branchIndex == currentBranch,
    );
    if (selectedIndex < 0) selectedIndex = 0;

    final usesCompactNavigation =
        width < 720 || MediaQuery.textScalerOf(context).scale(1) >= 1.3;
    final usesStaffSidebar = config.role.isStaff && !usesCompactNavigation;
    final usesMore =
        usesCompactNavigation && visible.length > 4 && config.role.isStaff;

    final destinations = <_NavDest>[];
    int navSelectedIndex = selectedIndex;
    // Branches hidden from the compact bar remain reachable through More.
    final overflowEntries = <({RoleSection section, int branchIndex})>[];

    if (usesMore) {
      final primaryEntries = switch (config.role) {
        UserRole.admin =>
          visible
              .where(
                (entry) => const {
                  RoleSection.dashboard,
                  RoleSection.products,
                  RoleSection.users,
                }.contains(entry.section),
              )
              .toList(),
        UserRole.agent => _agentPrimaryEntries(visible),
        UserRole.root =>
          visible
              .where(
                (entry) => const {
                  RoleSection.dashboard,
                  RoleSection.users,
                  RoleSection.platform,
                }.contains(entry.section),
              )
              .toList(),
        _ => visible,
      };
      final primaryBranchIndices = primaryEntries
          .map((entry) => entry.branchIndex)
          .toSet();

      for (final entry in visible) {
        if (primaryBranchIndices.contains(entry.branchIndex)) {
          destinations.add(
            _NavDest.entry(
              entry,
              l10n,
              compactAgent: config.role == UserRole.agent,
            ),
          );
        } else {
          overflowEntries.add(entry);
        }
      }
      if (overflowEntries.any((entry) => entry.branchIndex == currentBranch)) {
        // A hidden section lights up the "More" tab, the only tab that owns it.
        navSelectedIndex = destinations.length;
      } else {
        navSelectedIndex = destinations.indexWhere(
          (d) => d.entry?.branchIndex == currentBranch,
        );
      }
      destinations.add(_NavDest.more(l10n));
    } else {
      for (final entry in visible) {
        destinations.add(_NavDest.entry(entry, l10n));
      }
      navSelectedIndex = selectedIndex;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                config.role.label(l10n),
                // A staff role ships both a long label and a badge, and the app
                // bar only owns what is left after the actions. The label gives
                // way instead of pushing the badge out of the bar on a phone.
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 10),
            if (config.role.isStaff)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.roleStaffBadge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          _NotificationsAction(role: config.role),
          const SignOutButton(compact: true),
          const SizedBox(width: 4),
        ],
      ),
      body: usesStaffSidebar
          ? Row(
              children: [
                _StaffSidebar(
                  role: config.role,
                  entries: config.role == UserRole.agent
                      ? _agentSidebarEntries(visible)
                      : visible,
                  currentBranch: currentBranch,
                  onSelect: (entry) => _goToBranch(entry, currentBranch),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: navigationShell),
              ],
            )
          : navigationShell,
      bottomNavigationBar: usesStaffSidebar
          ? null
          : _buildBottomNavigation(
              context: context,
              destinations: destinations,
              selectedIndex: navSelectedIndex,
              onSelect: (idx) async {
                if (usesMore && idx == destinations.length - 1) {
                  final choice = await _showMoreSheet(
                    context,
                    overflowEntries,
                    l10n,
                    currentBranch,
                  );
                  if (choice != null && context.mounted) {
                    _goToBranch(choice, currentBranch);
                  }
                  return;
                }
                _goToBranch(destinations[idx].entry!, currentBranch);
              },
            ),
    );
  }

  void _goToBranch(
    ({RoleSection section, int branchIndex}) entry,
    int currentBranch,
  ) {
    navigationShell.goBranch(
      entry.branchIndex,
      initialLocation: entry.branchIndex == currentBranch,
    );
  }

  static List<({RoleSection section, int branchIndex})> _agentPrimaryEntries(
    List<({RoleSection section, int branchIndex})> visible,
  ) {
    const priorities = [
      RoleSection.dashboard,
      RoleSection.buyerSupport,
      RoleSection.orderProcessing,
    ];
    return [
      for (final section in priorities)
        for (final entry in visible)
          if (entry.section == section) entry,
    ];
  }

  static List<({RoleSection section, int branchIndex})> _agentSidebarEntries(
    List<({RoleSection section, int branchIndex})> visible,
  ) {
    const priorities = [
      RoleSection.dashboard,
      RoleSection.orderProcessing,
      RoleSection.stockValidation,
      RoleSection.buyerSupport,
      RoleSection.paymentFollowup,
      RoleSection.profile,
    ];
    return [
      for (final section in priorities)
        for (final entry in visible)
          if (entry.section == section) entry,
    ];
  }

  Widget _buildBottomNavigation({
    required BuildContext context,
    required List<_NavDest> destinations,
    required int selectedIndex,
    required ValueChanged<int> onSelect,
  }) {
    final staff = config.role.isStaff;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: NavigationBarTheme(
        data: staff
            ? NavigationBarThemeData(
                elevation: 0,
                height: config.role == UserRole.agent ? 76 : 68,
                labelBehavior: config.role == UserRole.agent
                    ? NavigationDestinationLabelBehavior.alwaysShow
                    : NavigationDestinationLabelBehavior.onlyShowSelected,
                indicatorColor: AppColors.primarySoft,
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              )
            : const NavigationBarThemeData(),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelect,
          destinations: [
            for (final dest in destinations)
              NavigationDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon),
                label: dest.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _StaffSidebar extends StatelessWidget {
  const _StaffSidebar({
    required this.role,
    required this.entries,
    required this.currentBranch,
    required this.onSelect,
  });

  final UserRole role;
  final List<({RoleSection section, int branchIndex})> entries;
  final int currentBranch;
  final ValueChanged<({RoleSection section, int branchIndex})> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      key: const ValueKey('roleShellSidebar'),
      width: 248,
      child: Material(
        color: colors.surface,
        child: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                if (role == UserRole.agent &&
                    _isAgentGroupStart(entries[i].section))
                  _SidebarGroupLabel(
                    label: _agentGroupLabel(entries[i].section, context.l10n),
                    isFirst: i == 0,
                  )
                else if (_startsGroup(entries[i].section) && i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Divider(height: 1),
                  ),
                _SidebarItem(
                  entry: entries[i],
                  selected: entries[i].branchIndex == currentBranch,
                  onTap: () => onSelect(entries[i]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isAgentGroupStart(RoleSection section) => const {
    RoleSection.orderProcessing,
    RoleSection.buyerSupport,
    RoleSection.paymentFollowup,
  }.contains(section);

  String _agentGroupLabel(RoleSection section, AppLocalizations l10n) =>
      switch (section) {
        RoleSection.orderProcessing => l10n.agentNavigationGroupOperations,
        RoleSection.buyerSupport => l10n.agentNavigationGroupSupport,
        RoleSection.paymentFollowup => l10n.agentNavigationGroupFollowup,
        _ => section.label(l10n),
      };

  bool _startsGroup(RoleSection section) => switch (role) {
    UserRole.admin =>
      section == RoleSection.analytics || section == RoleSection.profile,
    UserRole.agent =>
      section == RoleSection.paymentFollowup || section == RoleSection.profile,
    UserRole.root =>
      section == RoleSection.analytics || section == RoleSection.profile,
    _ => false,
  };
}

class _SidebarGroupLabel extends StatelessWidget {
  const _SidebarGroupLabel({required this.label, required this.isFirst});

  final String label;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, isFirst ? 4 : 16, 12, 6),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final ({RoleSection section, int branchIndex}) entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        selected: selected,
        onTap: onTap,
        minTileHeight: 52,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        selectedTileColor: AppColors.primarySoft,
        selectedColor: AppColors.primaryDark,
        iconColor: selected ? AppColors.primaryDark : colors.onSurfaceVariant,
        leading: Icon(
          selected ? entry.section.activeIcon : entry.section.icon,
          size: 22,
        ),
        title: Text(
          entry.section.navLabel(context.l10n),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _NotificationsAction extends ConsumerWidget {
  const _NotificationsAction({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount =
        ref
            .watch(notificationsControllerProvider)
            .asData
            ?.value
            .where((item) => !item.isRead)
            .length ??
        0;
    final l10n = context.l10n;
    return IconButton(
      tooltip: l10n.notificationsTitle,
      onPressed: () => context.push('${role.routePrefix}/notifications'),
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

class _NavDest {
  const _NavDest._({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.isMore = false,
    this.entry,
  });

  factory _NavDest.entry(
    ({RoleSection section, int branchIndex}) entry,
    AppLocalizations l10n, {
    bool compactAgent = false,
  }) => _NavDest._(
    icon: entry.section.icon,
    selectedIcon: entry.section.activeIcon,
    label: compactAgent
        ? switch (entry.section) {
            RoleSection.buyerSupport => l10n.notificationsCategorySupport,
            RoleSection.orderProcessing => l10n.sectionOrders,
            _ => entry.section.navLabel(l10n),
          }
        : entry.section.navLabel(l10n),
    entry: entry,
  );

  factory _NavDest.more(AppLocalizations l10n) => _NavDest._(
    icon: Icons.more_horiz,
    selectedIcon: Icons.more_horiz,
    label: l10n.navMore,
    isMore: true,
  );

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isMore;
  final ({RoleSection section, int branchIndex})? entry;
}

Future<({RoleSection section, int branchIndex})?> _showMoreSheet(
  BuildContext context,
  List<({RoleSection section, int branchIndex})> items,
  AppLocalizations l10n,
  int currentBranchIndex,
) async {
  return showModalBottomSheet<({RoleSection section, int branchIndex})>(
    context: context,
    useSafeArea: true,
    builder: (ctx) {
      return SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            return ListTile(
              leading: Icon(item.section.icon),
              title: Text(item.section.navLabel(l10n)),
              selected: item.branchIndex == currentBranchIndex,
              onTap: () => Navigator.of(ctx).pop(item),
            );
          },
        ),
      );
    },
  );
}
