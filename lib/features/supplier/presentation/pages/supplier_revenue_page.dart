import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/utils/dates.dart';
import 'package:agri_connect/core/utils/money.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/features/supplier/presentation/controllers/supplier_controllers.dart';

class SupplierRevenuePage extends StatelessWidget {
  const SupplierRevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              tabs: [
                Tab(text: l10n.supplierLotIncomePayouts),
                Tab(text: l10n.supplierLotIncomeCompensations),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SupplierRevenueList<SupplierPayout>(
                  controller:
                      Get.find<SupplierRevenueController<SupplierPayout>>(
                        tag: 'supplier-payouts',
                      ),
                  builder: (item) => _PayoutCard(item: item),
                ),
                SupplierRevenueList<SupplierCompensation>(
                  controller:
                      Get.find<SupplierRevenueController<SupplierCompensation>>(
                        tag: 'supplier-compensations',
                      ),
                  builder: (item) => _CompensationCard(item: item),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SupplierRevenueList<T> extends StatefulWidget {
  const SupplierRevenueList({
    super.key,
    required this.controller,
    required this.builder,
  });

  final SupplierRevenueController<T> controller;
  final Widget Function(T) builder;

  @override
  State<SupplierRevenueList<T>> createState() => _SupplierRevenueListState<T>();
}

class _SupplierRevenueListState<T> extends State<SupplierRevenueList<T>> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 300) {
      unawaited(widget.controller.loadMore());
    }
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final state = widget.controller.state.value;
      if (state is Loading<List<T>> || state is Idle<List<T>>) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is Failure<List<T>>) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppNotifier.failureMessage(state.failure, l10n)),
              TextButton(
                onPressed: widget.controller.loadFirst,
                child: Text(l10n.retry),
              ),
            ],
          ),
        );
      }
      final items = (state as Success<List<T>>).data;
      if (items.isEmpty) return Center(child: Text(l10n.supplierIncomeEmpty));
      return ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, index) => widget.builder(items[index]),
      );
    });
  }
}

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({required this.item});

  final SupplierPayout item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = switch (item.status) {
      'ON_HOLD' => l10n.supplierPayoutStatusOnHold,
      'READY' => l10n.supplierPayoutStatusReady,
      'PAID' => l10n.supplierPayoutStatusPaid,
      'CANCELLED' => l10n.supplierPayoutStatusCancelled,
      _ => item.status,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status, style: Theme.of(context).textTheme.titleMedium),
            if (item.reference?.isNotEmpty == true) Text(item.reference!),
            _MoneyRow(title: l10n.supplierPayoutGross, value: item.grossAmount),
            _MoneyRow(
              title: l10n.supplierPayoutCommission,
              value: item.commissionAmount,
            ),
            _MoneyRow(title: l10n.supplierPayoutNet, value: item.netAmount),
            if (item.paidAt != null) Text(Dates.short(item.paidAt!)),
          ],
        ),
      ),
    );
  }
}

class _CompensationCard extends StatelessWidget {
  const _CompensationCard({required this.item});

  final SupplierCompensation item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = switch (item.status) {
      'PENDING_APPROVAL' => l10n.supplierCompensationStatusPending,
      'APPROVED' => l10n.supplierCompensationStatusApproved,
      'PAID' => l10n.supplierCompensationStatusPaid,
      'REJECTED' => l10n.supplierCompensationStatusRejected,
      _ => item.status,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status, style: Theme.of(context).textTheme.titleMedium),
            Text('${l10n.supplierCompensationReason}: ${item.reason}'),
            Text('${l10n.supplierCompensationQuantity}: ${item.quantity}'),
            _MoneyRow(
              title: l10n.supplierCompensationAmount,
              value: item.amount,
            ),
            if (item.note?.isNotEmpty == true)
              Text('${l10n.supplierCompensationNote}: ${item.note}'),
          ],
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.title, required this.value});

  final String title;
  final double value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), Text(Money.format(value))],
    ),
  );
}
