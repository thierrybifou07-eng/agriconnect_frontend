import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';

abstract interface class DriverRepository {
  Future<Paginated<DriverDelivery>> available({
    required int page,
    required int limit,
  });

  Future<Paginated<DriverDelivery>> mine({
    DeliveryStatus? status,
    required int page,
    required int limit,
  });

  Future<DriverDelivery> accept(int id);

  Future<DriverDelivery> updateStatus(
    int id, {
    required DeliveryStatus status,
    String? failureReason,
  });
}
