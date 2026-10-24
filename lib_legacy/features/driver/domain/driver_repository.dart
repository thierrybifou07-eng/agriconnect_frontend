import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';

/// Data access of the driver workspace.
///
/// Swapping the demo implementation for a real remote one must be the only
/// change required to go live.
abstract interface class DriverRepository {
  /// Deliveries assigned to the signed-in driver.
  Future<List<DriverDelivery>> fetchDeliveries();

  /// Trips (grouped routes) of the signed-in driver.
  Future<List<DeliveryTrip>> fetchTrips();

  /// Moves a delivery to [status] and returns the updated delivery.
  Future<DriverDelivery> updateDeliveryStatus(
    String deliveryId,
    DriverDeliveryStatus status,
  );
}
