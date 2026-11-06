import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/json.dart';

void main() {
  test('reads integers, decimals and UTC dates from JSON values', () {
    expect(asInt(12, 'id'), 12);
    expect(asInt(12.0, 'id'), 12);
    expect(asDouble(1500, 'quantity'), 1500.0);
    expect(asDouble(2.5, 'quantity'), 2.5);
    expect(asIntOrNull(null), isNull);
    final date = asDate('2026-11-06T10:00:00+01:00', 'createdAt');
    expect(date.isUtc, isTrue);
    expect(date.hour, 9);
  });

  test('names the field when the type is wrong', () {
    expect(
      () => asInt('12', 'id'),
      throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('"id"'))),
    );
    expect(() => asInt(1.5, 'id'), throwsFormatException);
    expect(() => asDouble('1.5', 'unitPrice'), throwsFormatException);
    expect(() => asDate('hier', 'createdAt'), throwsFormatException);
    expect(() => asMap([], 'user'), throwsFormatException);
  });
}
