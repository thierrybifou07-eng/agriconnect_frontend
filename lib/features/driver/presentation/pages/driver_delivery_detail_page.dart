import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/driver/application/driver_deliveries_controller.dart';
import 'package:agri_connect/features/driver/application/driver_trips_controller.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';
import 'package:agri_connect/features/driver/presentation/widgets/driver_content.dart';
import 'package:agri_connect/features/driver/presentation/widgets/delivery_progress.dart';
import 'package:agri_connect/features/driver/presentation/widgets/delivery_sections.dart';
import 'package:agri_connect/features/driver/presentation/widgets/delivery_summary.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

/// Full sheet of one delivery in the driver workspace.
///
/// Reads only what the driver repository really holds: the order it fulfils, the
/// route, the carried items, the customer contact, the trips carrying it and the
/// progression of its status. No distance, no fee and no ETA appear here — the
/// driver contract has never carried them, and a figure invented on the fly is
/// a number nobody could check.
class DriverDeliveryDetailPage extends ConsumerWidget {
  const DriverDeliveryDetailPage({super.key, required this.deliveryId});

  final String deliveryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(driverDeliveriesControllerProvider);
    final delivery = findDelivery(state.deliveries);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.driverDetailTitle)),
      body: delivery == null
          ? _buildMissing(context, ref, l10n, state)
          : _buildSheet(context, ref, l10n, state, delivery),
      // The one action of the sheet stays in reach instead of being buried at
      // the bottom of a scroll a driver has to reach the end of.
      bottomNavigationBar: delivery != null && delivery.nextStatus != null
          ? DeliveryActionBar(
              delivery: delivery,
              isUpdating: state.isUpdating(delivery.id),
            )
          : null,
    );
  }

  DriverDelivery? findDelivery(List<DriverDelivery> deliveries) {
    for (final delivery in deliveries) {
      if (delivery.id == deliveryId) return delivery;
    }
    return null;
  }

  /// The delivery is not on screen. A failed load, a load still running and a
  /// delivery that genuinely does not exist are three different facts, and only
  /// the last one is a dead end.
  Widget _buildMissing(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DriverDeliveriesState state,
  ) {
    if (state.failure != null && state.deliveries.isEmpty) {
      return FailureView(
        failure: state.failure!,
        onRetry: () =>
            ref.read(driverDeliveriesControllerProvider.notifier).refresh(),
      );
    }
    if (state.isLoading && state.deliveries.isEmpty) {
      return const DetailSkeleton();
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        EmptyState(
          icon: Icons.local_shipping_outlined,
          title: l10n.driverDeliveriesEmptyTitle,
          body: l10n.driverDeliveryNotFound,
          // A delivery that cannot be found is a dead end unless the page
          // offers a way out: the list it came from.
          actionLabel: l10n.driverQuickDeliveries,
          actionIcon: Icons.list_alt_rounded,
          onAction: () => context.canPop()
              ? context.pop()
              : context.go(RoutePaths.driverDeliveries),
        ),
      ],
    );
  }

  Widget _buildSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DriverDeliveriesState state,
    DriverDelivery delivery,
  ) {
    final deliveries = state.deliveries;
    final deliveryTrips = tripsCarrying(
      delivery,
      ref.watch(driverTripsControllerProvider).trips,
    );
    // The banner belongs to the delivery whose action failed: shown on another
    // one it would offer to verify and retry the wrong parcel.
    final showsFailure =
        state.actionFailure != null && state.failedDeliveryId == delivery.id;

    return RefreshIndicator(
      // A driver refreshes this sheet for the status: the parcel and the trips
      // carrying it are reloaded together so the two can never disagree.
      onRefresh: () => Future.wait([
        ref.read(driverDeliveriesControllerProvider.notifier).refresh(),
        ref.read(driverTripsControllerProvider.notifier).refresh(),
      ]),
      child: ListView(
        // A closed delivery is a short sheet; without this the list would never
        // scroll and the pull-to-refresh would stay dead.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          DriverContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showsFailure) ...[
                  ActionFailureBanner(delivery: delivery),
                  const SizedBox(height: 16),
                ],
                DeliverySummaryHeader(delivery: delivery),
                const SizedBox(height: 20),
                SectionHeader(title: l10n.trackingTitle),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DeliveryProgress(delivery: delivery),
                  ),
                ),
                if (delivery.isClosed) ...[
                  const SizedBox(height: 16),
                  const DeliveredNotice(),
                ],
                const SizedBox(height: 20),
                SectionHeader(title: l10n.driverRouteTitle),
                const SizedBox(height: 12),
                DeliveryRouteCard(delivery: delivery),
                const SizedBox(height: 20),
                SectionHeader(title: l10n.checkoutItemsTitle),
                const SizedBox(height: 4),
                DeliveryItemsCard(delivery: delivery),
                if (deliveryTrips.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  SectionHeader(title: l10n.sectionTrips),
                  const SizedBox(height: 12),
                  for (final trip in deliveryTrips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DeliveryTripCard(
                        trip: trip,
                        deliveries: deliveries,
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                SectionHeader(title: l10n.driverCustomerLabel),
                const SizedBox(height: 12),
                DeliveryCustomerCard(delivery: delivery),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Trips carrying [delivery], in the order they are scheduled.
///
/// The relation is real and one-directional — a trip lists the deliveries it
/// carries — so the join is made here on the identifiers both sides hold. A
/// delivery that belongs to no trip simply gets no card.
List<DeliveryTrip> tripsCarrying(
  DriverDelivery delivery,
  List<DeliveryTrip> trips,
) {
  final matches = [
    for (final trip in trips)
      if (trip.deliveryIds.contains(delivery.id)) trip,
  ];
  matches.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return matches;
}

/// Placeholder shaped like the finished sheet, shown while the deliveries load.
///
/// The driver opens this page from a list that is usually already loaded, so
/// this is the rare path — but it must not be a white screen either way.
class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        const SkeletonBox(height: 148, radius: 16),
        const SizedBox(height: 20),
        const SkeletonBox(width: 160, height: 20, radius: 8),
        const SizedBox(height: 12),
        const SkeletonBox(height: 210, radius: 16),
        const SizedBox(height: 20),
        const SkeletonBox(width: 120, height: 20, radius: 8),
        const SizedBox(height: 12),
        const SkeletonBox(height: 150, radius: 16),
        const SizedBox(height: 20),
        const SkeletonBox(width: 150, height: 20, radius: 8),
        const SizedBox(height: 12),
        const SkeletonBox(height: 96, radius: 16),
      ],
    );
  }
}
