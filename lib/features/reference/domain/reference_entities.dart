class RefCategory {
  const RefCategory({
    required this.id,
    required this.code,
    required this.label,
  });

  final int id;
  final String code;
  final String label;

  factory RefCategory.fromJson(Object? json) {
    final map = _object(json, 'category');
    return RefCategory(
      id: _integer(map['id'], 'id'),
      code: _string(map['code'], 'code'),
      label: _string(map['label'], 'label'),
    );
  }
}

class RefUnit {
  const RefUnit({required this.id, required this.code, required this.label});

  final int id;
  final String code;
  final String label;

  factory RefUnit.fromJson(Object? json) {
    final map = _object(json, 'unit');
    return RefUnit(
      id: _integer(map['id'], 'id'),
      code: _string(map['code'], 'code'),
      label: _string(map['label'], 'label'),
    );
  }
}

class RefProduct {
  const RefProduct({
    required this.id,
    required this.name,
    this.description,
    required this.isPerishable,
    this.imageUrl,
    required this.category,
    required this.unit,
  });

  final int id;
  final String name;
  final String? description;
  final bool isPerishable;
  final String? imageUrl;
  final RefCategory category;
  final RefUnit unit;

  factory RefProduct.fromJson(Object? json) {
    final map = _object(json, 'product');
    return RefProduct(
      id: _integer(map['id'], 'id'),
      name: _string(map['name'], 'name'),
      description: _optionalString(map['description']),
      isPerishable: map['isPerishable'] == true,
      imageUrl: _optionalString(map['imageUrl']),
      category: RefCategory.fromJson(map['category']),
      unit: RefUnit.fromJson(map['unit']),
    );
  }
}

class RefZone {
  const RefZone({required this.id, required this.name, this.city, this.region});

  final int id;
  final String name;
  final String? city;
  final String? region;

  String get displayName => [name, city, region]
      .whereType<String>()
      .where((part) => part.isNotEmpty && part != name)
      .fold(name, (previous, part) => '$previous, $part');

  factory RefZone.fromJson(Object? json) {
    final map = _object(json, 'zone');
    return RefZone(
      id: _integer(map['id'], 'id'),
      name: _string(map['name'], 'name'),
      city: _optionalString(map['city']),
      region: _optionalString(map['region']),
    );
  }
}

class RefHub {
  const RefHub({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    required this.zoneId,
    required this.acceptsDropoff,
    required this.acceptsPickup,
  });

  final int id;
  final String name;
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final int zoneId;
  final bool acceptsDropoff;
  final bool acceptsPickup;

  factory RefHub.fromJson(Object? json) {
    final map = _object(json, 'hub');
    return RefHub(
      id: _integer(map['id'], 'id'),
      name: _string(map['name'], 'name'),
      address: _optionalString(map['address']),
      city: _optionalString(map['city']),
      latitude: _optionalDouble(map['latitude']),
      longitude: _optionalDouble(map['longitude']),
      zoneId: _integer(map['zoneId'], 'zoneId'),
      acceptsDropoff: map['acceptsDropoff'] == true,
      acceptsPickup: map['acceptsPickup'] == true,
    );
  }
}

Map<Object?, Object?> _object(Object? value, String label) {
  if (value is Map) return value;
  throw FormatException('Expected $label object');
}

String _string(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('Expected $field string');
}

String? _optionalString(Object? value) => value is String ? value : null;

int _integer(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('Expected $field integer');
}

double? _optionalDouble(Object? value) =>
    value is num ? value.toDouble() : null;
