import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_repository.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';

class FakeDriverRepository implements DriverRepository {
  FakeDriverRepository({required this.delivery});

  final DriverDelivery delivery;
  ApiFailure? acceptFailure;
  ApiFailure? updateFailure;
  DriverDelivery? acceptedResult;
  DriverDelivery? updateResult;
  final List<(int page, int limit)> availableRequests = [];
  final List<(DeliveryStatus? status, int page, int limit)> mineRequests = [];
  final List<(int id, DeliveryStatus status, String? failureReason)> updates =
      [];
  int accepts = 0;

  @override
  Future<Paginated<DriverDelivery>> available({
    required int page,
    required int limit,
  }) async {
    availableRequests.add((page, limit));
    final items = page == 1 && delivery.status == DeliveryStatus.pending
        ? [delivery]
        : <DriverDelivery>[];
    return Paginated(
      items: items,
      page: page,
      limit: limit,
      total: items.length,
    );
  }

  @override
  Future<DriverDelivery> accept(int id) async {
    accepts++;
    if (acceptFailure case final failure?) throw failure;
    return acceptedResult ?? delivery.copyWith(status: DeliveryStatus.accepted);
  }

  @override
  Future<Paginated<DriverDelivery>> mine({
    DeliveryStatus? status,
    required int page,
    required int limit,
  }) async {
    mineRequests.add((status, page, limit));
    final item =
        updateResult ??
        (delivery.status == DeliveryStatus.pending
            ? delivery.copyWith(status: DeliveryStatus.accepted)
            : delivery);
    final items = page == 1 && (status == null || status == item.status)
        ? [item]
        : <DriverDelivery>[];
    return Paginated(
      items: items,
      page: page,
      limit: limit,
      total: items.length,
    );
  }

  @override
  Future<DriverDelivery> updateStatus(
    int id, {
    required DeliveryStatus status,
    String? failureReason,
  }) async {
    updates.add((id, status, failureReason));
    if (updateFailure case final failure?) throw failure;
    return updateResult ?? delivery.copyWith(status: status);
  }
}
