import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/buyer/application/buyer_cart_controller.dart';
import 'package:agri_connect/features/buyer/application/buyer_catalog_controller.dart';
import 'package:agri_connect/features/buyer/domain/catalog_product.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/category_artwork.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/quantity_stepper.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Catalog product detail with quantity selection and cart actions.
class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _quantity = 1;

  @override
  void didUpdateWidget(covariant ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The same page can be reused for another product: never carry a quantity
    // over to a product the buyer did not choose.
    if (oldWidget.productId != widget.productId) _quantity = 1;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(buyerCatalogControllerProvider);
    final product = _findProduct(state.products);

    if (product == null) {
      final loading = state.isLoading && state.products.isEmpty;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sectionCatalog)),
        body: loading
            ? const FormSkeleton()
            : EmptyState(
                icon: Icons.inventory_2_outlined,
                title: l10n.catalogEmptyTitle,
                body: l10n.productNotFound,
                actionLabel: l10n.viewCatalog,
                actionIcon: Icons.storefront_outlined,
                onAction: () => context.go(RoutePaths.buyerCatalog),
              ),
      );
    }

    // Clamped for rendering only: the state itself is corrected on the next
    // interaction, so build never writes into it.
    final quantity = _quantity.clamp(
      1,
      product.inStock ? product.stockQuantity : 1,
    );
    final inCart = ref.watch(cartControllerProvider).quantityOf(product.id);

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: _buildBody(context, l10n, product, inCart),
      bottomNavigationBar: _CartBar(
        product: product,
        quantity: quantity,
        onQuantityChanged: (value) => setState(() => _quantity = value),
        onAddToCart: () => _addToCart(product, quantity),
        onOrder: () => _order(product, quantity),
      ),
    );
  }

  BuyerProduct? _findProduct(List<BuyerProduct> products) {
    for (final product in products) {
      if (product.id == widget.productId) return product;
    }
    return null;
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    BuyerProduct product,
    int inCart,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      children: [
        // Capped against the viewport: on a short window a 1.4 ratio artwork
        // alone is taller than the body, and every price, hint and description
        // ends up below the fold.
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.34,
          ),
          child: AspectRatio(
            aspectRatio: 1.4,
            child: CategoryArtwork(product: product),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category.label(l10n),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      product.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      Money.format(product.price, locale: context.localeCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      l10n.productPricePerUnit(product.unit),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (product.inStock)
                Text(
                  l10n.productInStock(product.stockQuantity, product.unit),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Text(
                  l10n.productStatusOutOfStock,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (inCart > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.productAlreadyInCart(inCart),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (product.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(product.description, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      UserAvatar(name: product.sellerName, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sellerLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.sellerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addToCart(BuyerProduct product, int quantity) {
    ref.read(cartControllerProvider.notifier).add(product, quantity: quantity);
    // No snackbar here: it would float over the sticky bar, swallow the taps
    // meant for "Commander" and squeeze its action at a large text scale. The
    // page itself already reports the new quantity in the cart, right above.
  }

  void _order(BuyerProduct product, int quantity) {
    // Ordering is navigation, not another addition: a line already in the cart
    // keeps its quantity, "Ajouter au panier" is what grows it.
    final inCart = ref.read(cartControllerProvider).quantityOf(product.id);
    if (inCart == 0) {
      ref
          .read(cartControllerProvider.notifier)
          .add(product, quantity: quantity);
    }
    context.push(RoutePaths.buyerCart);
  }
}

/// Sticky action bar: quantity, running total and the two cart actions.
///
/// The actions stack instead of sharing a row, so a 320 px screen or a large
/// text scale never squeezes a label into an ellipsis.
class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.onOrder,
  });

  final BuyerProduct product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final enabled = product.inStock;
    final maxQuantity = enabled ? product.stockQuantity : 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.quantityLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Money.format(
                          product.price * quantity,
                          locale: context.localeCode,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                QuantityStepper(
                  value: quantity,
                  min: 1,
                  max: maxQuantity,
                  onIncrement: () => onQuantityChanged(quantity + 1),
                  onDecrement: () => onQuantityChanged(quantity - 1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: enabled ? onOrder : null,
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: Text(l10n.goToCart),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: enabled ? onAddToCart : null,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(l10n.addToCart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
