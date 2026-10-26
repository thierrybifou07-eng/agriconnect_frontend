import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/media/media_url.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/chat/presentation/controllers/conversations_controller.dart';
import 'package:agri_connect/features/chat/presentation/pages/chat_pages.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/features/supplier/presentation/controllers/supplier_controllers.dart';
import 'package:agri_connect/features/supplier/presentation/pages/supplier_revenue_page.dart';
import 'package:agri_connect/features/supplier/presentation/widgets/supplier_widgets.dart';
import 'package:agri_connect/shared/widgets/role_shell.dart';

class SupplierHomePage extends StatelessWidget {
  const SupplierHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unread = Get.find<ConversationsController>().unreadCount;
    return RoleShell(
      title: 'AgriConnect',
      tabs: [
        ShellTab(
          icon: Icons.inventory_2_outlined,
          label: l10n.supplierLotsTab,
          page: (_) => const SupplierLotsPage(),
        ),
        ShellTab(
          icon: Icons.forum_outlined,
          label: l10n.chatTitle,
          badge: unread,
          page: (_) => const ConversationsPage(),
        ),
        ShellTab(
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.supplierRevenueTab,
          page: (_) => const SupplierRevenuePage(),
        ),
        ShellTab(
          icon: Icons.person_outline,
          label: l10n.accountTab,
          page: (_) => const SizedBox.shrink(),
          route: AppRoutes.profile,
        ),
      ],
    );
  }
}

class SupplierLotsPage extends StatefulWidget {
  const SupplierLotsPage({super.key});

  @override
  State<SupplierLotsPage> createState() => _SupplierLotsPageState();
}

class _SupplierLotsPageState extends State<SupplierLotsPage> {
  late final SupplierLotsController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<SupplierLotsController>();
    _scrollController.addListener(_loadMore);
  }

  void _loadMore() {
    if (_scrollController.position.extentAfter < 400) {
      unawaited(controller.loadMore());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMore)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([controller.loadCounts(), controller.loadFirst()]);
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.supplierLotDashboard,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _LotCounts(controller: controller),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await Get.toNamed(
                        AppRoutes.supplierLotNew,
                      );
                      if (result == true) {
                        unawaited(controller.loadFirst());
                        unawaited(controller.loadCounts());
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.supplierDeclareLot),
                  ),
                  const SizedBox(height: 18),
                  _LotFilters(controller: controller),
                ],
              ),
            ),
          ),
          Obx(() {
            final state = controller.state.value;
            if (state is Loading<List<SupplierLot>> ||
                state is Idle<List<SupplierLot>>) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is Failure<List<SupplierLot>>) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: _LotLoadFailure(
                  failure: state.failure,
                  retry: controller.loadFirst,
                ),
              );
            }
            final lots = (state as Success<List<SupplierLot>>).data;
            if (lots.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(l10n.supplierLotEmpty)),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.separated(
                itemCount: lots.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _SupplierLotCard(
                  lot: lots[index],
                  onTap: () =>
                      Get.toNamed(AppRoutes.supplierLotDetail(lots[index].id)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LotCounts extends StatelessWidget {
  const _LotCounts({required this.controller});

  final SupplierLotsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const keys = [
      'PENDING_VALIDATION',
      'AVAILABLE',
      'FULLY_RESERVED',
      'SOLD_OUT',
    ];
    final labels = [
      l10n.supplierLotPendingCount,
      l10n.supplierLotAvailableCount,
      l10n.supplierLotReservedCount,
      l10n.supplierLotSoldCount,
    ];
    return Obx(() {
      final state = controller.counts.value;
      if (state is Failure<Map<String, int>>) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppNotifier.failureMessage(state.failure, l10n)),
            TextButton(
              onPressed: controller.loadCounts,
              child: Text(l10n.retry),
            ),
          ],
        );
      }
      if (state is Loading<Map<String, int>> ||
          state is Idle<Map<String, int>>) {
        return const LinearProgressIndicator();
      }
      final counts = (state as Success<Map<String, int>>).data;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var index = 0; index < keys.length; index++)
            _CountTile(label: labels[index], value: counts[keys[index]] ?? 0),
        ],
      );
    });
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 140),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
  );
}

class _LotFilters extends StatelessWidget {
  const _LotFilters({required this.controller});

  final SupplierLotsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final values = <String?, String>{
      null: l10n.supplierAllStatuses,
      'PENDING_VALIDATION': l10n.supplierLotStatusPending,
      'AVAILABLE': l10n.supplierLotStatusAvailable,
      'FULLY_RESERVED': l10n.supplierLotStatusReserved,
      'SOLD_OUT': l10n.supplierLotStatusSold,
      'EXPIRED': l10n.supplierLotStatusExpired,
      'RETURNED': l10n.supplierLotStatusReturned,
      'REJECTED': l10n.supplierLotStatusRejected,
      'WITHDRAWN': l10n.supplierLotStatusWithdrawn,
    };
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final entry in values.entries)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(entry.value),
                  selected: controller.statusFilter.value == entry.key,
                  onSelected: (_) => controller.filterBy(entry.key),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SupplierLotCard extends StatelessWidget {
  const _SupplierLotCard({required this.lot, required this.onTap});

  final SupplierLot lot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final imageUrl = MediaUrl.resolve(
      lot.images.isEmpty ? null : lot.images.first.url,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 82,
                height: 82,
                child: imageUrl == null
                    ? const ColoredBox(
                        color: Color(0xFFE8EDE8),
                        child: Icon(Icons.inventory_2_outlined),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xFFE8EDE8),
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(lot.lotCode),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.supplierLotAvailable}: ${lot.quantityAvailable} · '
                      '${l10n.supplierLotReserved}: ${lot.quantityReserved} · '
                      '${l10n.supplierLotSold}: ${lot.quantitySold}',
                    ),
                    const SizedBox(height: 6),
                    SupplierLotStatusBadge(status: lot.status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _LotLoadFailure extends StatelessWidget {
  const _LotLoadFailure({required this.failure, required this.retry});

  final ApiFailure failure;
  final Future<void> Function() retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppNotifier.failureMessage(failure, AppLocalizations.of(context)),
          textAlign: TextAlign.center,
        ),
        TextButton(
          onPressed: retry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      ],
    ),
  );
}
