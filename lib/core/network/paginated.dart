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

  bool get hasMore => page * limit < total;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic item) parse,
  ) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('Paginated response is missing items');
    }
    final page = _integer(json['page'], 'page');
    final limit = _integer(json['limit'], 'limit');
    final total = _integer(json['total'], 'total');
    if (page < 1 || limit < 1 || limit > 100 || total < 0) {
      throw const FormatException('Paginated response has invalid bounds');
    }
    return Paginated<T>(
      items: rawItems.map(parse).toList(growable: false),
      page: page,
      limit: limit,
      total: total,
    );
  }

  static int _integer(Object? value, String field) {
    if (value is int) return value;
    if (value is num && value == value.toInt()) return value.toInt();
    throw FormatException('Paginated response has invalid $field');
  }
}
