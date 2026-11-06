/// Typed readers for JSON maps coming from the backend.
///
/// Every reader names the field in its [FormatException], so a contract drift
/// (a field renamed, an integer sent as a string) fails loudly and points at
/// the culprit instead of crashing later with an anonymous cast error.
/// Never cast JSON values directly (`json['id'] as int`) in data/ code.
library;

typedef JsonMap = Map<String, dynamic>;

/// [value] as a JSON object.
JsonMap asMap(Object? value, [String field = 'value']) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('Expected an object for "$field"', value);
}

/// [value] as a JSON array.
List<dynamic> asList(Object? value, [String field = 'value']) {
  if (value is List) return value;
  throw FormatException('Expected an array for "$field"', value);
}

/// Identifiers and counters: the backend sends integers.
int asInt(Object? value, [String field = 'value']) {
  if (value is int) return value;
  if (value is num && value == value.truncate()) return value.toInt();
  throw FormatException('Expected an integer for "$field"', value);
}

int? asIntOrNull(Object? value, [String field = 'value']) =>
    value == null ? null : asInt(value, field);

/// Amounts (2 decimals) and quantities (3 decimals): JSON numbers.
double asDouble(Object? value, [String field = 'value']) {
  if (value is num) return value.toDouble();
  throw FormatException('Expected a number for "$field"', value);
}

double? asDoubleOrNull(Object? value, [String field = 'value']) =>
    value == null ? null : asDouble(value, field);

String asString(Object? value, [String field = 'value']) {
  if (value is String) return value;
  throw FormatException('Expected a string for "$field"', value);
}

String? asStringOrNull(Object? value, [String field = 'value']) =>
    value == null ? null : asString(value, field);

bool asBool(Object? value, [String field = 'value']) {
  if (value is bool) return value;
  throw FormatException('Expected a boolean for "$field"', value);
}

/// ISO 8601 dates, always converted to UTC.
DateTime asDate(Object? value, [String field = 'value']) {
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed.toUtc();
  }
  throw FormatException('Expected an ISO 8601 date for "$field"', value);
}

DateTime? asDateOrNull(Object? value, [String field = 'value']) =>
    value == null ? null : asDate(value, field);
