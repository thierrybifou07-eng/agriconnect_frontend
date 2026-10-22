import 'package:flutter/material.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/admin/domain/admin_delivery.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_delivery_tile.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/section_states.dart';

/// Administrator — delivery supervision workspace.
///
/// Strictly serial wiring, PHASE 08G. Mirrors [AdminProductsPage] and
/// [AdminUsersPage]: every field and every repository method used here is
/// verified against the committed [AdminDelivery] model and the real abstract
/// [AdminRepository]. The administrator supervises explicitly — a delivery is
/// never auto-assigned to a driver (per the contract: pull mode, explicit
/// actions only).
class AdminDeliveriesPage extends StatefulWidget {
  const AdminDeliveriesPage({super.key, required this.repository});

  final AdminRepository repository;

  @override
  State<AdminDeliveriesPage> createState() => _AdminDeliveriesPageState();
}

class _AdminDeliveriesPageState extends State<AdminDeliveriesPage> {
  late Future<List<AdminDelivery>> _deliveries;
  String _query = '';
  AdminDeliveryStatus? _statusData;

  @override
  void initState() {
    super.initState();
    _deliveries = widget.repository.fetchDeliveries();
  }

  void _reload() {
    setState(() {
      _deliveries = widget.repository.fetchDeliveries(
        query: _query.trim().isEmpty ? null : _query,
        status: _statusData,
      );
    });
  }

  void _openDetail(AdminDelivery delivery) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _AdminDeliveryDetailPage(
          deliveryId: delivery.id,
          repository: widget.repository,
          onChanged: _reload,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // The shell already draws the workspace app bar, so this page states its
    // own title inline instead of stacking a second bar under it.
    //
    // The title, the search field and the filters are slivers rather than a
    // rigid Column above an Expanded list: that stack could not shrink, so a
    // short screen with large fonts pushed the list off the bottom.
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _reload();
          try {
            await _deliveries;
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
                child: SectionHeader(title: l10n.adminDeliveriesTitle),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.adminDeliveriesSearch,
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
            FutureBuilder<List<AdminDelivery>>(
              future: _deliveries,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: _SectionError(
                        id: 'deliveries',
                        message: '${snapshot.error}',
                        onRetry: _reload,
                      ),
                    ),
                  );
                }
                final deliveries = snapshot.data;
                if (deliveries == null) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (deliveries.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_shipping_outlined, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            l10n.adminDeliveriesEmptyTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.adminDeliveriesEmptyBody,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList.separated(
                  itemCount: deliveries.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final delivery = deliveries[index];
                    return AdminDeliveryTile(
                      delivery: delivery,
                      onTap: () => _openDetail(delivery),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final l10n = context.l10n;
    final options = <AdminDeliveryStatus?>[
      null,
      AdminDeliveryStatus.pickUp,
      AdminDeliveryStatus.inTransit,
      AdminDeliveryStatus.delivered,
      AdminDeliveryStatus.cancelled,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        children: [
          for (final option in options)
            ChoiceChip(
              label: Text(switch (option) {
                null => l10n.adminFilterAll,
                AdminDeliveryStatus.pickUp => l10n.adminStatusPickUp,
                AdminDeliveryStatus.inTransit => l10n.adminStatusInTransit,
                AdminDeliveryStatus.delivered => l10n.adminStatusDelivered,
                AdminDeliveryStatus.cancelled => l10n.adminStatusCancelled,
              }),
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

/// Single delivery tracking view for the Administrator.
///
/// Shows the pickup/destination legs, the fee split, the assigned driver and an
/// explicit action row (mark in transit → mark delivered, or assign driver).
/// No auto-assignment: every status change is an explicit supervisor action.
class _AdminDeliveryDetailPage extends StatefulWidget {
  const _AdminDeliveryDetailPage({
    required this.deliveryId,
    required this.repository,
    this.onChanged,
  });

  final String deliveryId;
  final AdminRepository repository;
  final VoidCallback? onChanged;

  @override
  State<_AdminDeliveryDetailPage> createState() =>
      _AdminDeliveryDetailPageState();
}

class _AdminDeliveryDetailPageState extends State<_AdminDeliveryDetailPage> {
  late Future<AdminDelivery?> _delivery;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _delivery = widget.repository.fetchDeliveryById(widget.deliveryId);
  }

  void _reload() {
    setState(() {
      _delivery = widget.repository.fetchDeliveryById(widget.deliveryId);
    });
  }

  Future<void> _refresh() async {
    _reload();
    try {
      await _delivery;
    } on Exception {
      // The sheet paints its own failure card; the gesture ends cleanly.
    }
  }

  Future<void> _mark(AdminDeliveryStatus to) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final updated = context.l10n.adminDeliveryUpdated;
    final failed = context.l10n.adminActionFailed;
    setState(() => _busy = true);
    try {
      await widget.repository.updateDeliveryStatus(widget.deliveryId, to);
      messenger.showSnackBar(SnackBar(content: Text(updated)));
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    _reload();
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminDeliveryTracking)),
      body: FutureBuilder<AdminDelivery?>(
        future: _delivery,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: _SectionError(
                id: 'deliveryDetail',
                message: '${snapshot.error}',
                onRetry: _reload,
              ),
            );
          }
          final delivery = snapshot.data;
          if (delivery == null) {
            // A load still running is a spinner; a load that finished without a
            // match is a delivery that no longer exists, which is a dead end
            // unless the page opens the way back to the list.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return _missing(context);
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _buildSheet(context, delivery),
          );
        },
      ),
    );
  }

  /// The delivery requested is not in the repository any more.
  Widget _missing(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: Icons.local_shipping_outlined,
      title: l10n.adminDeliveriesEmptyTitle,
      body: l10n.adminDeliveryNotFound,
      actionLabel: l10n.back,
      actionIcon: Icons.arrow_back_rounded,
      onAction: () => Navigator.of(context).maybePop(),
    );
  }

  Widget _buildSheet(BuildContext context, AdminDelivery delivery) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: Text(delivery.pickupLabel),
                subtitle: Text(context.l10n.adminDeliveryPickup),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(delivery.destinationLabel),
                subtitle: Text(context.l10n.adminDeliveryDestination),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.route_outlined),
                title: Text('${delivery.distanceKm.toStringAsFixed(1)} km'),
                subtitle: Text(context.l10n.adminDeliveryDistance),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.receipt_outlined),
                title: Text(context.l10n.adminDeliveryBaseFee),
                trailing: Text(
                  Money.format(
                    delivery.baseFee.round(),
                    locale: context.localeCode,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(context.l10n.adminDeliveryTotalFee),
                trailing: Text(
                  Money.format(
                    delivery.totalFee.round(),
                    locale: context.localeCode,
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(
              delivery.driverId.isEmpty
                  ? context.l10n.adminDeliveryNoDriver
                  : delivery.driverName,
            ),
            subtitle: Text(
              delivery.driverId.isEmpty
                  ? context.l10n.adminDeliveryAssignHint
                  : context.l10n.adminDeliveryDriverCaption(delivery.driverId),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.assignment_outlined),
              tooltip: context.l10n.adminDeliveryAssignDriver,
              onPressed: _busy ? null : () => _openAssign(delivery),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            if (delivery.status == AdminDeliveryStatus.pickUp) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _mark(AdminDeliveryStatus.inTransit),
                  icon: const Icon(Icons.directions_car_outlined),
                  label: Text(context.l10n.adminDeliveryMarkInTransit),
                ),
              ),
            ] else if (delivery.status == AdminDeliveryStatus.inTransit) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _mark(AdminDeliveryStatus.delivered),
                  icon: const Icon(Icons.check),
                  label: Text(context.l10n.adminDeliveryMarkDelivered),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _openAssign(AdminDelivery delivery) async {
    if (_busy) return;
    final controller = TextEditingController(text: delivery.driverName);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final assigned = l10n.adminDeliveryAssigned;
    final failed = l10n.adminActionFailed;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        // Without this the field is pushed under the Android keyboard, which
        // cannot scroll the dialog out of the way.
        scrollable: true,
        title: Text(l10n.adminDeliveryAssignDriver),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.adminDeliveryDriverNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.adminDeliveryAssignAction),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    setState(() => _busy = true);
    try {
      await widget.repository.assignDriver(widget.deliveryId, name);
      messenger.showSnackBar(SnackBar(content: Text(assigned)));
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    _reload();
    widget.onChanged?.call();
  }
}

/// Section-level failure of the delivery workspace, retryable like the
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
