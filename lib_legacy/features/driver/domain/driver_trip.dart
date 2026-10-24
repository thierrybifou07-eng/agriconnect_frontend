import 'package:agri_connect/features/driver/domain/driver_delivery.dart';

/// Aggregated state of a trip, derived from its deliveries.
enum TripStatus { upcoming, active, completed }

/// Where a trip stands, read from the deliveries it carries.
///
/// A trip is never stored with a status: the deliveries it refers to are what
/// say whether the outing is still ahead, on the road, or over. Reading it in
/// one place keeps the trips list and a delivery detail from disagreeing.
extension TripStatusProgressX on DeliveryTrip {
  /// Progress of this trip given the [deliveries] currently known.
  ///
  /// A trip whose deliveries are not loaded yet is [TripStatus.upcoming]: it is
  /// the state it starts in, and it never claims progress it cannot prove.
  TripStatus statusFrom(List<DriverDelivery> deliveries) {
    if (deliveryIds.isEmpty) return TripStatus.upcoming;

    var delivered = 0;
    var onTheRoad = false;
    for (final delivery in deliveries) {
      if (!deliveryIds.contains(delivery.id)) continue;
      if (delivery.isDelivered) delivered++;
      if (delivery.isInTransit) onTheRoad = true;
    }

    // The referenced deliveries may not be loaded: without all of them there is
    // no proof the outing is over, so it stays ahead.
    if (delivered < deliveryIds.length) {
      return onTheRoad ? TripStatus.active : TripStatus.upcoming;
    }
    return TripStatus.completed;
  }
}

/// Grouping of deliveries performed along one route.
///
/// A trip is a work plan: the same vehicle visits several customers during a
/// single outing. Its progress is derived from the deliveries it refers to.
class DeliveryTrip {
  const DeliveryTrip({
    required this.id,
    required this.routeLabel,
    required this.vehicleLabel,
    required this.deliveryIds,
    required this.scheduledAt,
    required this.createdAt,
  });

  final String id;

  /// Human-readable route summary, e.g. "Adjamé → Yopougon".
  final String routeLabel;

  final String vehicleLabel;

  /// Identifiers of the [DriverDelivery]s assigned to this trip.
  final List<String> deliveryIds;

  final DateTime scheduledAt;
  final DateTime createdAt;
}
