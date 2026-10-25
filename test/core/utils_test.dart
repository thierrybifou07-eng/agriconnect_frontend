import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/utils/dates.dart';
import 'package:agri_connect/core/utils/money.dart';

void main() {
  test('formats XAF amounts with grouped thousands and optional decimals', () {
    expect(Money.format(12500), '12 500 FCFA');
    expect(Money.format(12500.5), '12 500,50 FCFA');
  });

  test('formats dates and relative countdowns', () async {
    await Dates.initialize();
    final now = DateTime(2026, 10, 24, 12);

    expect(Dates.short(now), isNotEmpty);
    expect(Dates.long(now), isNotEmpty);
    expect(
      Dates.relative(now.add(const Duration(hours: 2)), now: now),
      'dans 2 h',
    );
    expect(
      Dates.countdown(now.add(const Duration(hours: 2)), now: now),
      '02:00:00',
    );
    expect(
      Dates.countdown(now.subtract(const Duration(seconds: 1)), now: now),
      '00:00',
    );
  });
}
