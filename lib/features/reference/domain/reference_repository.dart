import 'package:agri_connect/features/reference/domain/reference_entities.dart';

abstract interface class ReferenceRepository {
  Future<List<RefCategory>> categories({bool forceRefresh = false});
  Future<List<RefUnit>> units({bool forceRefresh = false});
  Future<List<RefProduct>> products({
    String? q,
    int? categoryId,
    bool forceRefresh = false,
  });
  Future<List<RefZone>> zones({bool forceRefresh = false});
  Future<List<RefHub>> hubs({int? zoneId, bool forceRefresh = false});
  void invalidate();
}
