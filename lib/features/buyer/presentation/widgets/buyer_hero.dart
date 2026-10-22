import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/buyer/application/buyer_cart_controller.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Premium welcome banner of the buyer workspace.
///
/// A brand gradient carries the agricultural identity — leaf motifs, off-white
/// ornament and the profile avatar — with the greeting and a purchase-oriented
/// promise. The cart summary is part of the hero because it is the one number a
/// buyer checks first, and it is read from the real cart, never invented.
///
/// The banner has no fixed height: it grows with the text scale and the content
/// instead of clipping the greeting on a large accessibility font.
class BuyerHero extends StatelessWidget {
  const BuyerHero({
    super.key,
    required this.firstName,
    required this.fullName,
    required this.cart,
  });

  final String firstName;
  final String fullName;
  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.imageRadius),
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        children: [
          // Brand layer: gradient plus soft botanical ornaments, clipped by the
          // banner so the decoration never leaks into the page.
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
              ),
              child: Stack(
                children: [
                  const Positioned(
                    right: -34,
                    top: -46,
                    child: _Leaf(size: 150, rotation: -0.5),
                  ),
                  const Positioned(
                    right: 44,
                    bottom: -58,
                    child: _Leaf(size: 116, rotation: 0.35, opacity: 0.07),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 150),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      UserAvatar(name: fullName, size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.dashboardWelcome(firstName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.buyerHeroSubtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CartSummary(cart: cart),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cart state laid over the hero gradient: the real item count and amount.
class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});

  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isEmpty = cart.isEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_basket_outlined,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              isEmpty
                  ? l10n.dashboardCartEmpty
                  : l10n.itemsCount(cart.itemCount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (!isEmpty) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                Money.format(cart.totalAmount, locale: context.localeCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Translucent leaf ornament giving the banner its agricultural identity.
class _Leaf extends StatelessWidget {
  const _Leaf({required this.size, required this.rotation, this.opacity = 0.1});

  final double size;
  final double rotation;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Icon(
        Icons.eco_rounded,
        size: size,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
