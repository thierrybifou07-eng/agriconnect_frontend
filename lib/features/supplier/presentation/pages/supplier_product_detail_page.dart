import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/media/prepared_photo.dart';
import 'package:agri_connect/core/media/product_image.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/supplier/application/supplier_products_controller.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/info_row.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// Read-only sheet of a product declared by the supplier.
///
/// Tapping a product from the catalog or the dashboard lands here; the
/// edition form stays one explicit action away. Being declared does not mean
/// published: the declaration status below is the only source of truth.
class SupplierProductDetailPage extends ConsumerWidget {
  const SupplierProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(supplierProductsControllerProvider);
    final product = _findProduct(state.products);

    if (product == null) {
      return _buildUnresolved(context, l10n, ref, state);
    }

    void edit() => context.push(RoutePaths.supplierProductEdition(product.id));
    void goBack() {
      // The detail is pushed over the products tab, so the back gesture pops
      // it. A deep link lands here with nothing to pop, hence the fallback.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(_productsPath(ref));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: goBack,
        ),
        actions: [
          IconButton(
            tooltip: l10n.editProduct,
            icon: const Icon(Icons.edit_outlined),
            onPressed: edit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSizes.pagePadding),
        children: [
          _PhotoHeader(product: product),
          Padding(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PriceBlock(product: product),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    l10n.productDescriptionLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InfoRow(
                          icon: Icons.straighten_rounded,
                          label: l10n.productUnitLabel,
                          value: product.unit,
                        ),
                        const Divider(height: 20),
                        _DeclarationStatusRow(product: product),
                        const SizedBox(height: 10),
                        Text(
                          l10n.declarationDemoNotice,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (product.createdAt case final createdAt?) ...[
                          const Divider(height: 20),
                          InfoRow(
                            icon: Icons.schedule_rounded,
                            label: l10n.productDeclaredOn,
                            value: AppFormats.date(
                              createdAt,
                              locale: context.localeCode,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePadding,
            8,
            AppSizes.pagePadding,
            12,
          ),
          child: PrimaryButton(
            label: l10n.editProduct,
            icon: Icons.edit_outlined,
            onPressed: edit,
          ),
        ),
      ),
    );
  }

  Product? _findProduct(List<Product> products) {
    for (final product in products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  /// Loading, failure and not-found states while the catalog is unresolved.
  Widget _buildUnresolved(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    SupplierProductsState state,
  ) {
    final appBar = AppBar(
      title: Text(l10n.sectionProducts),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(_productsPath(ref)),
      ),
    );

    final failure = state.failure;
    if (failure != null) {
      return Scaffold(
        appBar: appBar,
        body: FailureView(
          failure: failure,
          onRetry: () =>
              ref.read(supplierProductsControllerProvider.notifier).refresh(),
        ),
      );
    }

    if (state.isLoading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: EmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.productNotFound,
        body: l10n.productNotFoundBody,
      ),
    );
  }

  String _productsPath(WidgetRef ref) {
    final user = ref.read(authControllerProvider).user;
    return '${user?.role.routePrefix ?? '/supplier'}/products';
  }
}

/// Full-bleed product picture with its declaration and availability badges.
///
/// The height is fixed rather than proportional so the sheet keeps its facts
/// above the fold on a short screen, and stays readable on a wide one. Several
/// pictures become a swipeable gallery, since the form accepts up to five.
class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final photos = product.photos;
    final gallery = photos.where((photo) => photo.hasPreview).toList();

    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (gallery.length > 1)
            _PhotoGallery(photos: gallery, heroTag: 'product:${product.id}')
          else
            ProductImage(
              imageUrl: product.imageUrl,
              bytes: gallery.isEmpty ? null : gallery.first.bytes,
              heroTag: 'product:${product.id}',
              fit: BoxFit.cover,
            ),
          Positioned(
            left: AppSizes.pagePadding,
            bottom: AppSizes.pagePadding,
            right: AppSizes.pagePadding,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                StatusBadge(
                  label: product.declaration.label(context.l10n),
                  color: product.declaration.color(context),
                ),
                StatusBadge(
                  label: product.status.label(context.l10n),
                  color: product.status.color(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Swipeable product pictures with a page indicator.
class _PhotoGallery extends StatefulWidget {
  const _PhotoGallery({required this.photos, required this.heroTag});

  final List<PreparedPhoto> photos;

  /// Applied to the first picture only, to pair with the catalog card.
  final Object heroTag;

  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final total = widget.photos.length;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: total,
          onPageChanged: (value) => setState(() => _index = value),
          itemBuilder: (context, index) {
            return ProductImage(
              bytes: widget.photos[index].bytes,
              heroTag: index == 0 ? widget.heroTag : null,
              fit: BoxFit.cover,
            );
          },
        ),
        if (total > 1)
          Positioned(
            right: AppSizes.pagePadding,
            bottom: AppSizes.pagePadding,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_index + 1}/$total',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Price and availability, stacked so no width can squeeze them.
class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isOnSale = product.status == ProductStatus.onSale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Money.format(product.price, locale: context.localeCode),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              isOnSale
                  ? Icons.inventory_2_outlined
                  : Icons.remove_shopping_cart_outlined,
              size: 18,
              color: isOnSale
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isOnSale
                    ? l10n.productInStock(product.stockQuantity, product.unit)
                    : l10n.productStatusOutOfStock,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isOnSale
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.error,
                  fontWeight: isOnSale ? null : FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeclarationStatusRow extends StatelessWidget {
  const _DeclarationStatusRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.declarationStatusSection,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              StatusBadge(
                label: product.declaration.label(l10n),
                color: product.declaration.color(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
