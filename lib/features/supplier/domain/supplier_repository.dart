import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';

abstract interface class SupplierRepository {
  Future<Paginated<SupplierLot>> lots({
    String? status,
    int page = 1,
    int limit = 20,
  });
  Future<SupplierLot> lot(int id);
  Future<SupplierLot> createLot(
    Map<String, Object?> fields,
    List<String> paths,
  );
  Future<SupplierLot> updateLot(int id, Map<String, Object?> fields);
  Future<void> deleteLot(int id);
  Future<SupplierLot> withdrawLot(int id, String reason);
  Future<Paginated<SupplierPayout>> payouts({int page = 1, int limit = 20});
  Future<Paginated<SupplierCompensation>> compensations({
    int page = 1,
    int limit = 20,
  });
}
