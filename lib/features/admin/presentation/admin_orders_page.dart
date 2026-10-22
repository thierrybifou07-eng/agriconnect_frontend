import 'package:flutter/material.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/domain/admin_order.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/presentation/extensions/admin_status_l10n.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_order_status_badge.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_order_tile.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/section_states.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

/// Administrator — order consultation workspace.
///
/// Read-only on purpose. The committed [AdminRepository] exposes
/// `updateOrderStatus`, but the audit found no transition rules anywhere in the
/// domain, the models, the seeds or the tests: the status names alone do not
/// define a workflow. Rather than invent one, this workspace only reads orders
/// and their detail, and states the missing business decision explicitly. The
/// same discipline applies to the order/delivery link: an order is only shown
/// against a delivery when the order itself carries a non-null `deliveryId`.
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key, required this.repository});

  final AdminRepository repository;

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late Future<List<AdminOrder>> _orders;
  String _query = '';
  AdminOrderStatus? _statusData;

  @override
  void initState() {
    super.initState();
    _orders = widget.repository.fetchOrders();
  }

  void _reload() {
    setState(() {
      _orders = widget.repository.fetchOrders(
        query: _query.trim().isEmpty ? null : _query,
        status: _statusData,
      );
    });
  }

  void _openDetail(AdminOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _AdminOrderDetailPage(
          orderId: order.id,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // The shell already draws the workspace app bar, so this page states its
    // own title inline instead of stacking a second bar under it. The title,
    // the search field and the filters are slivers rather than a rigid Column
    // above an Expanded list, which could not shrink on a short screen.
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _reload();
          try {
            await _orders;
          } on Exception {
            // The list paints the failure card on its own; the gesture must
            // still complete cleanly instead of raising an unhandled error.
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.pagePadding,
                AppSizes.pagePadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(title: RoleSection.orders.label(l10n)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.adminOrdersSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    _query = value;
                    _reload();
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 12),
              sliver: SliverToBoxAdapter(child: _buildStatusFilter()),
            ),
            FutureBuilder<List<AdminOrder>>(
              future: _orders,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: _SectionError(
                        id: 'orders',
                        message: '${snapshot.error}',
                        onRetry: _reload,
                      ),
                    ),
                  );
                }
                final orders = snapshot.data;
                if (orders == null) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: CardListSkeleton(),
                    ),
                  );
                }
                if (orders.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_outlined, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            l10n.adminOrdersEmptyTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.adminOrdersEmptyBody,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList.separated(
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 0),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AdminOrderTile(
                        order: order,
                        onTap: () => _openDetail(order),
                      ),
                    );
                  },
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final l10n = context.l10n;
    final options = <AdminOrderStatus?>[
      null,
      AdminOrderStatus.pending,
      AdminOrderStatus.confirmed,
      AdminOrderStatus.inTransit,
      AdminOrderStatus.delivered,
      AdminOrderStatus.cancelled,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in options)
            ChoiceChip(
              label: Text(
                option == null ? l10n.adminFilterAll : option.label(l10n),
              ),
              selected: _statusData == option,
              onSelected: (_) {
                _statusData = option;
                _reload();
              },
            ),
        ],
      ),
    );
  }
}

/// Single order view for the Administrator.
///
/// Shows every field the committed [AdminOrder] model actually carries. A
/// status change is deliberately not offered: the transition workflow is not
/// defined, so the page explains the missing decision instead of pretending to
/// enforce one. An order is only matched to a delivery through its own
/// `deliveryId`; when that link is absent, no delivery row is drawn.
class _AdminOrderDetailPage extends StatefulWidget {
  const _AdminOrderDetailPage({
    required this.orderId,
    required this.repository,
  });

  final String orderId;
  final AdminRepository repository;

  @override
  State<_AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<_AdminOrderDetailPage> {
  late Future<AdminOrder?> _order;

  @override
  void initState() {
    super.initState();
    _order = widget.repository.fetchOrderById(widget.orderId);
  }

  void _reload() {
    setState(() {
      _order = widget.repository.fetchOrderById(widget.orderId);
    });
  }

  Future<void> _refresh() async {
    _reload();
    try {
      await _order;
    } on Exception {
      // The sheet paints its own failure card; the gesture ends cleanly.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('adminOrderDetail'),
      appBar: AppBar(title: Text(context.l10n.adminOrderDetailTitle)),
      body: FutureBuilder<AdminOrder?>(
        future: _order,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: _SectionError(
                id: 'orderDetail',
                message: '${snapshot.error}',
                onRetry: _reload,
              ),
            );
          }
          final order = snapshot.data;
          if (order == null) {
            // A load still running is a spinner; a load that finished without a
            // match is an order that no longer exists, which is a dead end
            // unless the page opens the way back to the list.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return _missing(context);
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _buildSheet(context, order),
          );
        },
      ),
    );
  }

  /// The order requested is not in the repository any more.
  Widget _missing(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: l10n.adminOrdersEmptyTitle,
      body: l10n.adminOrderNotFound,
      actionLabel: l10n.back,
      actionIcon: Icons.arrow_back_rounded,
      onAction: () => Navigator.of(context).maybePop(),
    );
  }

  Widget _buildSheet(BuildContext context, AdminOrder order) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AdminOrderStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 12),
                _labelled(
                  context,
                  Icons.event_outlined,
                  l10n.adminOrderPlacedAt,
                  AppFormats.date(order.placedAt, locale: context.localeCode),
                ),
                const SizedBox(height: 8),
                _labelled(
                  context,
                  Icons.payments_outlined,
                  l10n.adminOrderAmountLabel,
                  Money.format(
                    order.amount.round(),
                    locale: context.localeCode,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(order.buyerName),
                subtitle: Text(
                  '${l10n.adminOrderBuyerLabel} · '
                  '${l10n.adminOrderAccountCaption(order.buyerId)}',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text(order.sellerName),
                subtitle: Text(
                  '${l10n.adminOrderSellerLabel} · '
                  '${l10n.adminOrderAccountCaption(order.sellerId)}',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  l10n.adminOrderItemsTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (order.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Text(
                    l10n.adminOrderItemsEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (final item in order.items)
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(item.name),
                    subtitle: Text('${item.quantity} ${item.unit}'),
                    trailing: Text(
                      Money.format(
                        item.total.round(),
                        locale: context.localeCode,
                      ),
                    ),
                  ),
            ],
          ),
        ),
        if (order.deliveryId != null) ...[
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: Text(l10n.adminOrderLinkedDelivery),
              subtitle: Text(_linkedDeliveryCaption(context, order)),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _statusLocked(context),
      ],
    );
  }

  /// Names the linked delivery and its status in the reader's language.
  ///
  /// The order stores the delivery status as the raw key it was persisted with;
  /// printing that code (`inTransit`) on a French console is the same split the
  /// rest of this page avoids. An unknown key keeps the value it arrived with
  /// rather than inventing a label.
  String _linkedDeliveryCaption(BuildContext context, AdminOrder order) {
    final id = order.deliveryId!;
    final raw = order.deliveryStatus;
    if (raw == null) return id;
    final status = adminDeliveryStatusByKey(raw);
    return status == null
        ? '$id · $raw'
        : '$id · ${status.label(context.l10n)}';
  }

  Widget _labelled(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Both ends share the row: a value that refused to shrink pushed the
        // label into a one-character column and overflowed the card at a large
        // text scale.
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall,
          ),
        ),
      ],
    );
  }

  /// States the missing business decision around order status changes.
  ///
  /// The contract exposes `updateOrderStatus`, but nothing in the domain
  /// defines which transitions are legitimate, so no control is offered rather
  /// than a button that would let an administrator jump a workflow that the
  /// project has not agreed on.
  Widget _statusLocked(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.adminOrderStatusLockedTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.adminOrderStatusLockedBody,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section-level failure of the orders workspace, retryable like the
/// dashboard's.
class _SectionError extends StatelessWidget {
  const _SectionError({
    required this.id,
    required this.message,
    required this.onRetry,
  });

  final String id;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectionErrorCard(
      keyPrefix: 'admin',
      id: id,
      title: l10n.adminSectionLoadError,
      detail: l10n.adminSectionLoadErrorDetail(message),
      retryLabel: l10n.retry,
      onRetry: onRetry,
    );
  }
}
