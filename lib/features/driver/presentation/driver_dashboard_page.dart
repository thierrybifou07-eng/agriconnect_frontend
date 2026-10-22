import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/driver/application/driver_deliveries_controller.dart';
import 'package:agri_connect/features/driver/application/driver_trips_controller.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';
import 'package:agri_connect/features/driver/presentation/widgets/driver_content.dart';
import 'package:agri_connect/features/driver/presentation/widgets/driver_hero.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/quick_action_grid.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Driver workspace home: a premium welcome banner, the delivery shortcuts
/// the driver can really reach, a stats overview, recent deliveries and
/// upcoming trips.
///
/// Every figure comes from the deliveries or the trips already held by the
/// driver controllers; the page never computes a statistic of its own, and it
/// never offers a shortcut that no existing route backs.
class DriverDashboardPage extends ConsumerWidget {
  const DriverDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    // The shell only exists for a signed-in driver, but the session can be
    // dropped in the same frame the router is redirecting: rendering nothing
    // beats a null assertion crash on the way out.
    if (user == null) return const SizedBox.shrink();

    final deliveriesState = ref.watch(driverDeliveriesControllerProvider);
    final tripsState = ref.watch(driverTripsControllerProvider);
    final deliveries = deliveriesState.deliveries;

    var pickUpCount = 0;
    var inTransitCount = 0;
    var deliveredCount = 0;
    DriverDelivery? inTransitDelivery;
    DriverDelivery? nextPickUp;
    for (final delivery in deliveries) {
      if (delivery.isDelivered) {
        deliveredCount++;
      } else if (delivery.isInTransit) {
        inTransitCount++;
        inTransitDelivery ??= delivery;
      } else {
        pickUpCount++;
        nextPickUp ??= delivery;
      }
    }
    // The active shortcut opens a delivery that really is open: the one already
    // on the road, else the next one still to be collected.
    final activeDelivery = inTransitDelivery ?? nextPickUp;

    return RefreshIndicator(
      onRefresh: () => Future.wait([
        ref.read(driverDeliveriesControllerProvider.notifier).refresh(),
        ref.read(driverTripsControllerProvider.notifier).refresh(),
      ]),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          DriverContent(
            child: DriverHero(
              firstName: user.fullName.split(' ').first,
              fullName: user.fullName,
              activeCount: pickUpCount + inTransitCount,
              // The banner reports the workload it was actually given, and
              // says so when that workload is not known yet.
              isLoading: deliveriesState.isLoading,
            ),
          ),
          const SizedBox(height: 18),
          DriverContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle(context, l10n.dashboardQuickActions),
                const SizedBox(height: 10),
                QuickActionGrid(
                  gridKey: const Key('driverQuickActions'),
                  actions: [
                    QuickAction(
                      label: l10n.driverQuickDeliveries,
                      icon: Icons.local_shipping_rounded,
                      onTap: () => context.go(RoutePaths.driverDeliveries),
                      primary: true,
                      badgeCount: deliveries.isEmpty
                          ? null
                          : pickUpCount + inTransitCount,
                    ),
                    // Only offered when a delivery really is open: a shortcut
                    // with nothing behind it would dead-end on a dashboard
                    // that claims to be actionable.
                    if (activeDelivery != null)
                      QuickAction(
                        label: l10n.driverQuickActiveDelivery,
                        icon: Icons.navigation_rounded,
                        // Pushed like every other detail screen: the route
                        // lives outside the shell, so replacing the shell with
                        // it would drop the back stack under the farmer's
                        // thumb.
                        onTap: () => context.push(
                          RoutePaths.driverDelivery(activeDelivery.id),
                        ),
                      ),
                    QuickAction(
                      label: l10n.driverQuickHistory,
                      icon: Icons.history_rounded,
                      onTap: () => context.go(RoutePaths.driverTrips),
                    ),
                    // Pushed, like the buyer inbox: the chat lives outside the
                    // shell, so replacing the shell with it would make the
                    // platform back gesture leave the app.
                    QuickAction(
                      label: l10n.chatTitle,
                      icon: Icons.forum_rounded,
                      onTap: () => context.push(RoutePaths.driverMessages),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _sectionTitle(context, l10n.dashboardOverview),
                const SizedBox(height: 10),
                _StatsBar(
                  values: [pickUpCount, inTransitCount, deliveredCount],
                  labels: [
                    l10n.driverStatToCollect,
                    l10n.driverStatusInTransit,
                    l10n.driverStatusDelivered,
                  ],
                  onTap: [
                    () => context.go(RoutePaths.driverDeliveries),
                    () => context.go(RoutePaths.driverDeliveries),
                    () => context.go(RoutePaths.driverTrips),
                  ],
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: l10n.driverRecentDeliveries,
                  actionLabel: l10n.seeAll,
                  onAction: () => context.go(RoutePaths.driverDeliveries),
                ),
                const SizedBox(height: 10),
                _recentDeliveries(context, ref, l10n, deliveriesState),
                const SizedBox(height: 24),
                SectionHeader(
                  title: l10n.driverUpcomingTrips,
                  actionLabel: l10n.seeAll,
                  onAction: () => context.go(RoutePaths.driverTrips),
                ),
                const SizedBox(height: 10),
                _upcomingTrips(context, ref, l10n, tripsState, deliveries),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _recentDeliveries(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DriverDeliveriesState state,
  ) {
    final deliveries = state.deliveries;

    if (state.isLoading && deliveries.isEmpty) {
      return const CardListSkeleton(itemCount: 3);
    }
    if (state.failure != null && deliveries.isEmpty) {
      return FailureView(
        failure: state.failure!,
        compact: true,
        onRetry: () =>
            ref.read(driverDeliveriesControllerProvider.notifier).refresh(),
      );
    }
    if (deliveries.isEmpty) {
      return EmptyState(
        icon: Icons.local_shipping_outlined,
        title: l10n.driverDeliveriesEmptyTitle,
        body: l10n.driverDeliveriesEmptyBody,
      );
    }

    return Column(
      children: [
        for (final delivery in deliveries.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CompactDeliveryTile(
              delivery: delivery,
              onTap: () => context.push(RoutePaths.driverDelivery(delivery.id)),
            ),
          ),
      ],
    );
  }

  Widget _upcomingTrips(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DriverTripsState state,
    List<DriverDelivery> deliveries,
  ) {
    final trips = state.trips;

    if (state.isLoading && trips.isEmpty) {
      return const CardListSkeleton(itemCount: 2);
    }
    if (state.failure != null && trips.isEmpty) {
      return FailureView(
        failure: state.failure!,
        compact: true,
        onRetry: () =>
            ref.read(driverTripsControllerProvider.notifier).refresh(),
      );
    }
    // The section promises what is still ahead, so a route whose deliveries are
    // all delivered is left out: it belongs to the history, not to this list.
    // The status is derived from the deliveries, never stored on the trip.
    final ahead = trips
        .where((trip) => trip.statusFrom(deliveries) != TripStatus.completed)
        .toList(growable: false);

    if (ahead.isEmpty) {
      return EmptyState(
        icon: Icons.route_outlined,
        title: l10n.driverNoUpcomingTripTitle,
        body: l10n.driverNoUpcomingTripBody,
      );
    }

    return Column(
      children: [
        for (final trip in ahead.take(2))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CompactTripTile(
              trip: trip,
              onTap: () => context.go(RoutePaths.driverTrips),
            ),
          ),
      ],
    );
  }
}

/// Compact delivery stats: one card, three columns.
class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.values,
    required this.labels,
    required this.onTap,
  });

  final List<int> values;
  final List<String> labels;
  final List<VoidCallback> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0)
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
            Expanded(
              child: InkWell(
                onTap: onTap[i],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${values[i]}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactDeliveryTile extends StatelessWidget {
  const _CompactDeliveryTile({required this.delivery, required this.onTap});

  final DriverDelivery delivery;
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              UserAvatar(name: delivery.customerName, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormats.date(
                        delivery.scheduledAt,
                        locale: context.localeCode,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: delivery.status.label(l10n),
                color: delivery.status.color(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactTripTile extends StatelessWidget {
  const _CompactTripTile({required this.trip, required this.onTap});

  final DeliveryTrip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.route_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.routeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.vehicleLabel,
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
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
