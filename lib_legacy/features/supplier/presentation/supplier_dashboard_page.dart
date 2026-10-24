import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/role_section.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/media/demo_assets.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/supplier/application/supplier_orders_controller.dart';
import 'package:agri_connect/features/supplier/application/supplier_products_controller.dart';
import 'package:agri_connect/features/supplier/presentation/widgets/supplier_welcome_panel.dart';
import 'package:agri_connect/features/supplier/domain/supplier_order.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/product_card.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/stat_card.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Geometry of the "recent products" strip.
///
/// The tiles and their loading skeleton read the same numbers, so the strip
/// keeps its exact height from the skeleton state to the loaded state.
abstract final class _Strip {
  static const double tileWidth = 156;
  static const double tileHeight = 192;
  static const double imageHeight = 126;

  /// Height of a tile for the current system font size.
  ///
  /// The picture keeps [imageHeight] whatever the font, so the whole room the
  /// text needs has to come out of the tile itself. Reserving the flat
  /// [tileHeight] overflowed the name and the price as soon as a reader raised
  /// the font size, which is a setting Android users change often.
  static double tileHeightFor(BuildContext context) =>
      tileHeight * MediaQuery.textScalerOf(context).scale(1);
}

/// Supplier workspace home: a photo-led marketplace overview with live stats,
/// quick actions, recent products and incoming orders.
class SupplierDashboardPage extends ConsumerWidget {
  const SupplierDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    // The shell only exists for a signed-in supplier, but the session can be
    // dropped in the same frame the router is redirecting: rendering nothing
    // beats a null assertion crash on the way out.
    if (user == null) return const SizedBox.shrink();

    final productsState = ref.watch(supplierProductsControllerProvider);
    final ordersState = ref.watch(supplierOrdersControllerProvider);
    final products = productsState.products;
    final orders = ordersState.orders;

    final pendingCount = orders.where((o) => o.isPending).length;
    final confirmed = orders
        .where((o) => o.status == OrderStatus.confirmed)
        .toList();
    final onSaleCount = products
        .where((p) => p.isPublished && p.status == ProductStatus.onSale)
        .length;

    final productsPath =
        '${user.role.routePrefix}/'
        '${RoleSection.products.routeName}';
    final ordersPath =
        '${user.role.routePrefix}/'
        '${RoleSection.orders.routeName}';

    Future<void> refresh() => Future.wait([
      ref.read(supplierProductsControllerProvider.notifier).refresh(),
      ref.read(supplierOrdersControllerProvider.notifier).refresh(),
    ]);

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroBanner(
                    firstName: user.fullName.split(' ').first,
                    fullName: user.fullName,
                    onSaleCount: onSaleCount,
                    onRefresh: refresh,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SupplierWelcomePanel(
                    firstName: user.fullName.split(' ').first,
                  ),
                  _SectionHeading(
                    icon: Icons.bolt_rounded,
                    title: l10n.dashboardQuickActions,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _QuickActions(
                    actions: [
                      _QuickAction(
                        label: l10n.dashboardQuickAddProduct,
                        icon: Icons.add_box_rounded,
                        onTap: () =>
                            context.push(RoutePaths.supplierProductNew),
                        primary: true,
                      ),
                      _QuickAction(
                        label: l10n.sectionProducts,
                        icon: Icons.inventory_2_rounded,
                        tint: AppColors.primary,
                        onTap: () => context.go(productsPath),
                      ),
                      _QuickAction(
                        label: l10n.dashboardQuickOrders,
                        icon: Icons.receipt_long_rounded,
                        tint: AppColors.info,
                        onTap: () => context.go(ordersPath),
                      ),
                      _QuickAction(
                        label: l10n.chatTitle,
                        icon: Icons.forum_rounded,
                        tint: AppColors.violet,
                        onTap: () => context.push(RoutePaths.supplierMessages),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionHeading(
                    icon: Icons.insights_rounded,
                    title: l10n.dashboardOverview,
                    caption: confirmed.isEmpty
                        ? null
                        : l10n.ordersConfirmedRevenue(
                            Money.format(
                              confirmed.fold<int>(
                                0,
                                (sum, order) => sum + order.totalAmount,
                              ),
                              locale: context.localeCode,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OverviewPanel(
                    child: StatGrid(
                      values: [
                        '${products.length}',
                        '$pendingCount',
                        '${confirmed.length}',
                      ],
                      labels: [
                        l10n.productsDeclaredStat,
                        l10n.ordersPendingStat,
                        l10n.statConfirmedOrders,
                      ],
                      icons: const [
                        Icons.inventory_2_rounded,
                        Icons.hourglass_top_rounded,
                        Icons.check_circle_rounded,
                      ],
                      accents: const [false, true, false],
                      onTap: [
                        () => context.go(productsPath),
                        () => context.go(ordersPath),
                        () => context.go(ordersPath),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionHeading(
                    icon: Icons.inventory_2_rounded,
                    title: l10n.recentProducts,
                    actionLabel: l10n.seeAll,
                    onAction: () => context.go(productsPath),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (productsState.isLoading && products.isEmpty)
                    SizedBox(
                      height: _Strip.tileHeightFor(context),
                      child: const StripSkeleton(
                        itemCount: 3,
                        tileWidth: _Strip.tileWidth,
                        imageHeight: _Strip.imageHeight,
                      ),
                    )
                  else if (productsState.failure != null && products.isEmpty)
                    FailureView(
                      failure: productsState.failure!,
                      compact: true,
                      onRetry: () => ref
                          .read(supplierProductsControllerProvider.notifier)
                          .refresh(),
                    )
                  else if (products.isEmpty)
                    EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: l10n.productsEmptyTitle,
                      body: l10n.productsEmptyBody,
                      actionLabel: l10n.addProduct,
                      onAction: () =>
                          context.push(RoutePaths.supplierProductNew),
                    )
                  else
                    SizedBox(
                      height: _Strip.tileHeightFor(context),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount: products.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductImageTile(
                            product: product,
                            width: _Strip.tileWidth,
                            height: _Strip.tileHeightFor(context),
                            imageHeight: _Strip.imageHeight,
                            // Its own hero tag: the shell keeps the catalog tab alive
                            // beside this one, and two heroes sharing a tag in a single
                            // route make Flutter throw instead of animate.
                            heroTag: 'supplier-strip:${product.id}',
                            onTap: () => context.push(
                              RoutePaths.supplierProduct(product.id),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionHeading(
                    icon: Icons.receipt_long_rounded,
                    title: l10n.recentOrders,
                    actionLabel: l10n.seeAll,
                    onAction: () => context.go(ordersPath),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (ordersState.isLoading && orders.isEmpty)
                    const CardListSkeleton(itemCount: 3)
                  else if (ordersState.failure != null && orders.isEmpty)
                    FailureView(
                      failure: ordersState.failure!,
                      compact: true,
                      onRetry: () => ref
                          .read(supplierOrdersControllerProvider.notifier)
                          .refresh(),
                    )
                  else if (orders.isEmpty)
                    EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.ordersEmptyTitle,
                      body: l10n.ordersEmptyBody,
                    )
                  else
                    for (final order in orders.take(3))
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: _CompactOrderTile(
                          order: order,
                          onTap: () =>
                              context.push(RoutePaths.supplierOrder(order.id)),
                        ),
                      ),
                  const SizedBox(height: AppSpacing.md),
                  _StorefrontCta(
                    count: products.length,
                    onTap: () => context.go(productsPath),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A shortcut offered under the welcome banner.
class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.tint,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  /// Highlights the main action of the dashboard.
  final bool primary;

  /// Quiet category colour used for the glyph of a secondary shortcut, so the
  /// four actions can be told apart at a glance without any of them shouting.
  final Color? tint;
}

/// Grid of shortcuts, laid out on two columns on a narrow screen and on a
/// single row of four once the tiles are wide enough.
///
/// Tiles share their height inside a row through [IntrinsicHeight] and size
/// themselves from their content: no hard-coded tile height to break when a
/// label wraps or when the text scale changes.
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.actions});

  final List<_QuickAction> actions;

  /// Available width needed before four tiles fit on one row comfortably.
  static const double _fourColumnBreakpoint = 360;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 2 * AppSizes.pagePadding;
    final columns = width >= _fourColumnBreakpoint ? 4 : 2;
    final rows = <List<_QuickAction>>[
      for (var i = 0; i < actions.length; i += columns)
        actions.sublist(
          i,
          i + columns > actions.length ? actions.length : i + columns,
        ),
    ];

    return Column(
      key: const Key('supplierQuickActions'),
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.xs),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < rows[i].length; j++) ...[
                  if (j > 0) const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _QuickActionTile(
                      action: rows[i][j],
                      vertical: columns == 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, required this.vertical});

  final _QuickAction action;

  /// Stacks the icon above the label; the only readable arrangement once the
  /// four shortcuts share one row.
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = action.primary;
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    final tint = action.tint ?? colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: primary ? AppColors.brandGradient : null,
          color: primary ? null : colorScheme.surface,
          borderRadius: radius,
          border: primary
              ? null
              : Border.fromBorderSide(
                  BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
          boxShadow: primary ? AppShadows.card : null,
        ),
        child: InkWell(
          onTap: action.onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 14,
            ),
            child: vertical
                ? _vertical(theme, colorScheme, primary, tint)
                : _row(theme, colorScheme, primary, tint),
          ),
        ),
      ),
    );
  }

  Widget _row(
    ThemeData theme,
    ColorScheme colorScheme,
    bool primary,
    Color tint,
  ) {
    return Row(
      children: [
        _badge(primary, tint, size: 36, iconSize: 20),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _label(
            theme,
            colorScheme,
            primary,
            maxLines: 2,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _vertical(
    ThemeData theme,
    ColorScheme colorScheme,
    bool primary,
    Color tint,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _badge(primary, tint, size: 40, iconSize: 22),
        const SizedBox(height: AppSpacing.xs),
        _label(
          theme,
          colorScheme,
          primary,
          maxLines: 3,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _badge(
    bool primary,
    Color tint, {
    required double size,
    required double iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primary
            ? Colors.white.withValues(alpha: 0.22)
            : tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(
        action.icon,
        size: iconSize,
        color: primary ? Colors.white : Color.lerp(tint, Colors.black, 0.12),
      ),
    );
  }

  Widget _label(
    ThemeData theme,
    ColorScheme colorScheme,
    bool primary, {
    required int maxLines,
    required TextAlign textAlign,
  }) {
    return Text(
      action.label,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style:
          (vertical ? theme.textTheme.labelMedium : theme.textTheme.labelLarge)
              ?.copyWith(
                color: primary ? Colors.white : colorScheme.onSurface,
                fontWeight: primary || vertical
                    ? FontWeight.w700
                    : FontWeight.w600,
                height: 1.2,
              ),
    );
  }
}

/// Section title with an icon badge and an optional trailing action.
///
/// Shorter than the shared [SectionHeader]: the action is a compact text button
/// whose visual height stays close to the label itself while Material keeps a
/// full 48 dp touch target around it. A dashboard stacks four of them, and the
/// saved height is what keeps the product strip on screen on a 320 px phone.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.caption,
  });

  final IconData icon;
  final String title;

  final String? actionLabel;
  final VoidCallback? onAction;

  /// Right-aligned secondary line carrying a real figure, e.g. the revenue of
  /// the confirmed orders. It replaces the action when both are given.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final action = actionLabel != null && onAction != null
        ? TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              // Keeps the heading as short as the plain label was: Material
              // still grows the control to a 48 dp touch target on its own,
              // without the visual height following it.
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: AppSpacing.xxs,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ],
            ),
          )
        : null;

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: AppColors.primaryDark),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ] else if (action != null) ...[
          const SizedBox(width: AppSpacing.xs),
          action,
        ],
      ],
    );
  }
}

/// Tray that groups the three metrics, so the overview reads as one panel
/// instead of three tiles floating on the canvas.
class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primarySoft, AppColors.surfaceElevated],
          stops: [0, 1],
        ),
        borderRadius: BorderRadius.circular(AppSizes.imageRadius),
        border: Border.all(
          color: AppColors.primarySoftStrong.withValues(alpha: 0.85),
        ),
        boxShadow: AppShadows.card,
      ),
      key: const Key('supplierOverview'),
      child: child,
    );
  }
}

/// Large photo banner with the supplier profile and a market picture.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.firstName,
    required this.fullName,
    required this.onSaleCount,
    required this.onRefresh,
  });

  final String firstName;
  final String fullName;
  final int onSaleCount;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      key: const Key('supplierHero'),
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.imageRadius),
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage(DemoAssets.dashboardHero),
            fit: BoxFit.cover,
          ),
          // Clear in the middle so the picture still leads, darkened at both
          // ends so the greeting and the metric stay readable whatever the
          // photograph shows.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryDeep,
                  Colors.transparent,
                  AppColors.imageScrim,
                ],
                stops: [0.0, 0.42, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      name: fullName,
                      photoUrl: DemoAssets.supplierProfilePhoto,
                      size: 46,
                      online: true,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dashboardWelcome(firstName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.dashboardSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    _HeroIconButton(
                      icon: Icons.refresh_rounded,
                      tooltip: l10n.dashboardRefreshTooltip,
                      onTap: onRefresh,
                    ),
                  ],
                ),
                const Spacer(),
                _HeroMetric(
                  icon: Icons.storefront_rounded,
                  value: '$onSaleCount',
                  label: l10n.supplierProductsOnSaleTitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Round glass control laid over the hero picture.
class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // A real [IconButton] rather than a bare [InkWell]: Material already grows
    // its touch target to 48 dp, so the glass circle stays compact while the
    // control remains reachable with a thumb.
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon),
      iconSize: 20,
      color: Colors.white,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.18),
        minimumSize: const Size(48, 48),
        shape: const CircleBorder(side: BorderSide(color: Colors.white38)),
      ),
    );
  }
}

/// Translucent metric card laid over the hero picture.
///
/// The figure leads and the label sits under it, so a supplier reads the count
/// before the wording, whatever the width of the banner.
class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('supplierOnSaleMetric'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Closing call to action driving the supplier back to the catalog.
class _StorefrontCta extends StatelessWidget {
  const _StorefrontCta({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      key: const Key('supplierCatalogCta'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                width: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.brandGradient),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.dashboardManageProducts,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.catalogTotalProducts(count),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactOrderTile extends StatelessWidget {
  const _CompactOrderTile({required this.order, required this.onTap});

  final SupplierOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              UserAvatar(name: order.buyerName, size: 44),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.buyerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${AppFormats.date(order.createdAt, locale: context.localeCode)}'
                      ' · ${l10n.orderNumberItems(order.items.length)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Money.format(order.totalAmount, locale: context.localeCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  StatusBadge(
                    label: order.status.label(l10n),
                    color: order.status.color(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
