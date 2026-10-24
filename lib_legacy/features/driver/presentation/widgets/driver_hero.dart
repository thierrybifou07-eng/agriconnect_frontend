import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Premium welcome banner of the driver workspace.
///
/// A brand gradient carries the agricultural identity — leaf motifs and the
/// profile avatar — with the greeting and a delivery-oriented promise. The
/// workload summary is part of the hero because it is the number a driver
/// checks first, and it is read from the deliveries the controller actually
/// holds, never invented.
///
/// The banner has no fixed height: it grows with the text scale and the content
/// instead of clipping the greeting on a large accessibility font.
class DriverHero extends StatelessWidget {
  const DriverHero({
    super.key,
    required this.firstName,
    required this.fullName,
    required this.activeCount,
    this.isLoading = false,
  });

  final String firstName;
  final String fullName;

  /// Deliveries that are picked up or in transit, counted by the caller.
  final int activeCount;

  /// True while the controller still waits for the repository.
  ///
  /// The banner then admits it is loading instead of announcing an empty
  /// workload: zero and "not answered yet" are two different facts.
  final bool isLoading;

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
                children: const [
                  Positioned(
                    right: -34,
                    top: -46,
                    child: _Leaf(size: 150, rotation: -0.5),
                  ),
                  Positioned(
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
                      UserAvatar(name: fullName, size: 46, online: true),
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
                              l10n.driverHeroSubtitle,
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
                  _WorkloadSummary(
                    activeCount: activeCount,
                    isLoading: isLoading,
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

/// Real workload laid over the hero gradient: the ongoing deliveries and the
/// role the driver holds, so the banner never shows a bare unexplained number.
class _WorkloadSummary extends StatelessWidget {
  const _WorkloadSummary({required this.activeCount, required this.isLoading});

  final int activeCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hasActive = activeCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            Icon(
              hasActive ? Icons.local_shipping_rounded : Icons.task_alt_rounded,
              size: 18,
              color: Colors.white,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              // A pending load is stated as pending: it never passes for an
              // empty workload.
              isLoading
                  ? l10n.driverLoadingDeliveries
                  : hasActive
                  ? l10n.driverActiveDeliveriesCount(activeCount)
                  : l10n.driverNoActiveDelivery,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n.roleDriver,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
