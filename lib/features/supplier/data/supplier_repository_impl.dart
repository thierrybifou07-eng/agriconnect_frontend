import 'package:dio/dio.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/supplier/data/supplier_api.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  const SupplierRepositoryImpl(this._api);

  final SupplierApi _api;

  @override
  Future<Paginated<SupplierLot>> lots({
    String? status,
    int page = 1,
    int limit = 20,
  }) => _parse(() => _api.lots(status: status, page: page, limit: limit));

  @override
  Future<SupplierLot> lot(int id) => _parse(() => _api.lot(id));

  @override
  Future<SupplierLot> createLot(
    Map<String, Object?> fields,
    List<String> paths,
  ) => _parse(
    () => _api.createLot(SupplierLotMultipartBuilder.build(fields, paths)),
  );

  @override
  Future<SupplierLot> updateLot(int id, Map<String, Object?> fields) =>
      _parse(() => _api.updateLot(id, fields));

  @override
  Future<void> deleteLot(int id) => _parse(() => _api.deleteLot(id));

  @override
  Future<SupplierLot> withdrawLot(int id, String reason) =>
      _parse(() => _api.withdrawLot(id, reason));

  @override
  Future<Paginated<SupplierPayout>> payouts({int page = 1, int limit = 20}) =>
      _parse(() => _api.payouts(page: page, limit: limit));

  @override
  Future<Paginated<SupplierCompensation>> compensations({
    int page = 1,
    int limit = 20,
  }) => _parse(() => _api.compensations(page: page, limit: limit));

  Future<T> _parse<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FormatException catch (error) {
      throw ApiFailure(
        status: null,
        code: null,
        message: error.message,
        fieldErrors: const {},
        kind: ApiFailureKind.server,
      );
    }
  }
}

abstract final class SupplierLotMultipartBuilder {
  static FormData build(Map<String, Object?> fields, List<String> paths) {
    final form = FormData();
    for (final entry in fields.entries) {
      form.fields.add(MapEntry(entry.key, '${entry.value}'));
    }
    for (final path in paths) {
      form.files.add(MapEntry('images', MultipartFile.fromFileSync(path)));
    }
    return form;
  }
}
