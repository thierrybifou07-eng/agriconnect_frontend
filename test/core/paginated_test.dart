import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/paginated.dart';

void main() {
  test('parses paginated data and determines whether more items exist', () {
    final page = Paginated<int>.fromJson({
      'items': [1, 2],
      'page': 2,
      'limit': 2,
      'total': 5,
    }, (item) => item as int);

    expect(page.items, [1, 2]);
    expect(page.page, 2);
    expect(page.limit, 2);
    expect(page.total, 5);
    expect(page.hasMore, isTrue);
  });

  test('rejects malformed pagination values', () {
    expect(
      () => Paginated<int>.fromJson({
        'items': 'invalid',
        'page': 1,
        'limit': 20,
        'total': 1,
      }, (item) => item as int),
      throwsFormatException,
    );
  });
}
