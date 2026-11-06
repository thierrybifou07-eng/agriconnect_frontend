import 'package:agri_connect/core/network/json.dart';

/// Page of a paginated list: `{ items, page, limit, total }`.
///
/// `page >= 1`, `1 <= limit <= 100`, `total >= 0` (docs/API_CONTRACT.md § 2).
class Paginated<T> {
  const Paginated({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;

  /// Whether another page exists after this one.
  bool get hasMore => page * limit < total;

  factory Paginated.fromJson(
    Object? json,
    T Function(JsonMap item) parseItem,
  ) {
    final map = asMap(json, 'page');
    final page = asInt(map['page'], 'page');
    final limit = asInt(map['limit'], 'limit');
    final total = asInt(map['total'], 'total');
    if (page < 1 || limit < 1 || limit > 100 || total < 0) {
      throw FormatException('Invalid pagination bounds', map);
    }
    final items = asList(map['items'], 'items');
    return Paginated<T>(
      items: [
        for (var i = 0; i < items.length; i++)
          parseItem(asMap(items[i], 'items[$i]')),
      ],
      page: page,
      limit: limit,
      total: total,
    );
  }
}
