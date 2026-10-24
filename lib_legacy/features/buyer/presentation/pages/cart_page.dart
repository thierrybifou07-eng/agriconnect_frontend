import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/buyer/application/buyer_cart_controller.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/category_artwork.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/quantity_stepper.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';

/// Cart screen: adjust quantities and move to checkout.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cart = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cartTitle),
        actions: [
          if (!cart.isEmpty)
            TextButton.icon(
              onPressed: () => _confirmClear(context, ref, cart.itemCount),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(l10n.cartClear),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: l10n.cartEmptyTitle,
              body: l10n.cartEmptyBody,
              actionLabel: l10n.viewCatalog,
              actionIcon: Icons.storefront_outlined,
              onAction: () => context.go(RoutePaths.buyerCatalog),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              itemCount: cart.lines.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == cart.lines.length) {
                  return Center(
                    child: TextButton.icon(
                      onPressed: () => context.go(RoutePaths.buyerCatalog),
                      icon: const Icon(Icons.storefront_outlined, size: 18),
                      label: Text(l10n.cartContinueShopping),
                    ),
                  );
                }
                return _CartLineTile(line: cart.lines[index]);
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.itemsCount(cart.itemCount),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          Money.format(
                            cart.totalAmount,
                            locale: context.localeCode,
                          ),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      label: l10n.checkoutTitleAction,
                      icon: Icons.shopping_cart_checkout_rounded,
                      onPressed: () => context.push(RoutePaths.buyerCheckout),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Clearing the cart cannot be undone, so it asks first.
  Future<void> _confirmClear(
    BuildContext context,
    WidgetRef ref,
    int itemCount,
  ) async {
    final l10n = context.l10n;
    final controller = ref.read(cartControllerProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cartClearTitle),
        content: Text(l10n.cartClearBody(itemCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.cartClearConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) controller.clear();
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final product = line.product;
    final cart = ref.read(cartControllerProvider.notifier);
    // The catalog may have moved since the line was added: never let the
    // stepper promise more than what is left.
    final maxQuantity = product.stockQuantity;
    final atStockLimit = maxQuantity > 0 && line.quantity >= maxQuantity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CategoryArtwork(product: product, compact: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Money.format(product.price, locale: context.localeCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Money.format(line.total, locale: context.localeCode),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      onPressed: () => cart.remove(product.id),
                      tooltip: l10n.removeFromCart,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                QuantityStepper(
                  value: line.quantity,
                  min: 1,
                  max: maxQuantity,
                  onIncrement: () => cart.increment(product.id),
                  onDecrement: () => cart.decrement(product.id),
                ),
                const Spacer(),
                if (atStockLimit)
                  Flexible(
                    child: Text(
                      l10n.cartStockRemaining(maxQuantity),
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            if (maxQuantity == 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.productStatusOutOfStock,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
