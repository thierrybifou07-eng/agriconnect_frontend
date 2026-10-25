import 'package:agri_connect/features/reference/data/reference_api.dart';

import 'package:agri_connect/features/reference/domain/reference_entities.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';

class ReferenceRepositoryImpl implements ReferenceRepository {
  ReferenceRepositoryImpl(this._api);

  final ReferenceApi _api;
  final Map<String, List<Object>> _cache = {};

  @override
  Future<List<RefCategory>> categories({bool forceRefresh = false}) =>
      _get('categories', _api.categories, forceRefresh);

  @override
  Future<List<RefUnit>> units({bool forceRefresh = false}) =>
      _get('units', _api.units, forceRefresh);

  @override
  Future<List<RefProduct>> products({
    String? q,
    int? categoryId,
    bool forceRefresh = false,
  }) {
    final normalizedQuery = q?.trim() ?? '';
    final key = 'products:$normalizedQuery:$categoryId';
    return _get(
      key,
      () => _api.products(q: normalizedQuery, categoryId: categoryId),
      forceRefresh,
    );
  }

  @override
  Future<List<RefZone>> zones({bool forceRefresh = false}) =>
      _get('zones', _api.zones, forceRefresh);

  @override
  Future<List<RefHub>> hubs({int? zoneId, bool forceRefresh = false}) =>
      _get('hubs:$zoneId', () => _api.hubs(zoneId: zoneId), forceRefresh);

  Future<List<T>> _get<T extends Object>(
    String key,
    Future<List<T>> Function() load,
    bool forceRefresh,
  ) async {
    if (forceRefresh) _cache.remove(key);
    final cached = _cache[key];
    if (cached != null) return List<T>.unmodifiable(cached.cast<T>());
    final loaded = await load();
    _cache[key] = List<Object>.unmodifiable(loaded);
    return List<T>.unmodifiable(loaded);
  }

  @override
  void invalidate() => _cache.clear();
}
