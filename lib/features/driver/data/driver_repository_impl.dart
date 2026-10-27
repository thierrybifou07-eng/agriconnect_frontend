import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/driver/data/driver_api.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_repository.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';

class DriverRepositoryImpl implements DriverRepository {
  const DriverRepositoryImpl(this.api);

  final DriverApi api;

  @override
  Future<Paginated<DriverDelivery>> available({
    required int page,
    required int limit,
  }) => api.available(page: page, limit: limit);

  @override
  Future<Paginated<DriverDelivery>> mine({
    DeliveryStatus? status,
    required int page,
    required int limit,
  }) => api.mine(status: status, page: page, limit: limit);

  @override
  Future<DriverDelivery> accept(int id) => api.accept(id);

  @override
  Future<DriverDelivery> updateStatus(
    int id, {
    required DeliveryStatus status,
    String? failureReason,
  }) => api.updateStatus(id, status: status, failureReason: failureReason);
}
