import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/buyer/application/buyer_orders_controller.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/fact_row.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';

/// Terminal screen of the purchase funnel: the order exists, now tell the buyer
/// what happened and what comes next.
///
/// A back arrow would be a lie here: the step before is the checkout, which is
/// now empty. The screen is closed explicitly instead.
class OrderConfirmationPage extends ConsumerWidget {
  const OrderConfirmationPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(buyerOrdersControllerProvider);
    final order = _findOrder(state.orders);

    if (order == null) {
      final loading = state.isLoading && state.orders.isEmpty;
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l10n.confirmationTitle),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : state.failure != null
            ? FailureView(
                failure: state.failure!,
                onRetry: () =>
                    ref.read(buyerOrdersControllerProvider.notifier).refresh(),
              )
            : EmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.orderNotFound,
                body: l10n.buyerOrdersEmptyBody,
                actionLabel: l10n.sectionOrders,
                actionIcon: Icons.receipt_long_rounded,
                onAction: () => context.go(RoutePaths.buyerOrders),
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.confirmationTitle),
        actions: [
          IconButton(
            onPressed: () => context.go(RoutePaths.buyerHome),
            icon: const Icon(Icons.close_rounded),
            tooltip: l10n.confirmationContinueShopping,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePadding,
                  AppSizes.pagePadding,
                  AppSizes.pagePadding,
                  8,
                ),
                children: [
                  const _SuccessHero(),
                  const SizedBox(height: 24),
                  _RecapCard(order: order),
                  const SizedBox(height: 20),
                  Text(
                    l10n.confirmationNextTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _NextSteps(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                8,
                AppSizes.pagePadding,
                AppSizes.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    label: l10n.confirmationTrackOrder,
                    icon: Icons.local_shipping_outlined,
                    onPressed: () =>
                        context.push(RoutePaths.buyerOrder(order.id)),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(RoutePaths.buyerCatalog),
                      icon: const Icon(Icons.storefront_outlined),
                      label: Text(l10n.confirmationContinueShopping),
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

  BuyerOrder? _findOrder(List<BuyerOrder> orders) {
    for (final order in orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }
}

class _SuccessHero extends StatelessWidget {
  const _SuccessHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowGlow,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.confirmationHeadline,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.confirmationBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.order});

  final BuyerOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderNumber(order.id),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.placedOn} ${AppFormats.date(order.createdAt, locale: context.localeCode)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    Money.format(order.totalAmount, locale: context.localeCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  Icons.shopping_basket_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.itemsCount(order.itemCount),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FactRow(
              icon: Icons.place_outlined,
              label: l10n.deliveryAddressLabel,
              value: order.deliveryAddress,
            ),
            const SizedBox(height: 10),
            FactRow(
              icon: Icons.phone_outlined,
              label: l10n.phoneLabel,
              value: order.buyerPhone,
            ),
            if (order.deliveryNote != null &&
                order.deliveryNote!.isNotEmpty) ...[
              const SizedBox(height: 10),
              FactRow(
                icon: Icons.notes_rounded,
                label: l10n.noteLabel,
                value: order.deliveryNote!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NextSteps extends StatelessWidget {
  const _NextSteps();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final steps = <(String, IconData)>[
      (l10n.confirmationStepSeller, Icons.inventory_2_outlined),
      (l10n.confirmationStepDriver, Icons.local_shipping_outlined),
      (l10n.confirmationStepDelivered, Icons.home_work_outlined),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          children: [
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          steps[i].$1,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      steps[i].$2,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
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
