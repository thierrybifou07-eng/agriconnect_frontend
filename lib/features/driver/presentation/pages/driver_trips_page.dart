import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/driver/application/driver_deliveries_controller.dart';
import 'package:agri_connect/features/driver/application/driver_trips_controller.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';
import 'package:agri_connect/features/driver/presentation/widgets/driver_content.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// Grouped routes of the driver, with per-trip progress.
class DriverTripsPage extends ConsumerWidget {
  const DriverTripsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tripsState = ref.watch(driverTripsControllerProvider);
    final deliveriesState = ref.watch(driverDeliveriesControllerProvider);
    final trips = tripsState.trips;
    final deliveries = deliveriesState.deliveries;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(driverTripsControllerProvider.notifier).refresh();
          await ref.read(driverDeliveriesControllerProvider.notifier).refresh();
        },
        child: _buildContent(context, ref, l10n, tripsState, trips, deliveries),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DriverTripsState tripsState,
    List<DeliveryTrip> trips,
    List<DriverDelivery> deliveries,
  ) {
    final header = DriverContent(child: _TripsHeader(count: trips.length));

    if (tripsState.isLoading && trips.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          header,
          const SizedBox(height: 12),
          const DriverContent(child: CardListSkeleton(itemCount: 3)),
        ],
      );
    }

    if (tripsState.failure != null && trips.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          header,
          DriverContent(
            child: FailureView(
              failure: tripsState.failure!,
              onRetry: () =>
                  ref.read(driverTripsControllerProvider.notifier).refresh(),
            ),
          ),
        ],
      );
    }

    if (trips.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          header,
          DriverContent(
            child: EmptyState(
              icon: Icons.route_outlined,
              title: l10n.driverTripsEmptyTitle,
              body: l10n.driverTripsEmptyBody,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      itemCount: trips.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) return header;
        final trip = trips[index - 1];
        return DriverContent(
          child: _TripCard(trip: trip, deliveries: deliveries),
        );
      },
    );
  }
}

class _TripsHeader extends StatelessWidget {
  const _TripsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.sectionTrips,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.deliveries});

  final DeliveryTrip trip;
  final List<DriverDelivery> deliveries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    final total = trip.deliveryIds.length;
    final status = trip.statusFrom(deliveries);
    var deliveredCount = 0;
    for (final delivery in deliveries) {
      if (trip.deliveryIds.contains(delivery.id) && delivery.isDelivered) {
        deliveredCount++;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    size: 20,
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
                StatusBadge(
                  label: status.label(l10n),
                  color: status.color(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    AppFormats.date(
                      trip.scheduledAt,
                      locale: context.localeCode,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Both texts give way on a narrow phone rather than pushing the
                // card past its own width.
                Flexible(
                  child: Text(
                    l10n.tripStopsProgress(deliveredCount, total),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
