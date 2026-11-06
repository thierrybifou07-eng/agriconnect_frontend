import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/json.dart';
import 'package:agri_connect/core/network/paginated.dart';

void main() {
  test('parses a page and knows whether another one follows', () {
    final page = Paginated<int>.fromJson(
      {
        'items': [
          {'id': 1},
          {'id': 2},
        ],
        'page': 1,
        'limit': 2,
        'total': 3,
      },
      (item) => asInt(item['id'], 'id'),
    );
    expect(page.items, [1, 2]);
    expect(page.hasMore, isTrue);

    final last = Paginated<int>.fromJson(
      {'items': <Object>[], 'page': 2, 'limit': 2, 'total': 3},
      (item) => asInt(item['id'], 'id'),
    );
    expect(last.hasMore, isFalse);
  });

  test('rejects missing items and out-of-contract bounds', () {
    int parse(JsonMap item) => 0;
    expect(
      () => Paginated<int>.fromJson({'page': 1, 'limit': 20, 'total': 0}, parse),
      throwsFormatException,
    );
    expect(
      () => Paginated<int>.fromJson(
        {'items': <Object>[], 'page': 0, 'limit': 20, 'total': 0},
        parse,
      ),
      throwsFormatException,
    );
    expect(
      () => Paginated<int>.fromJson(
        {'items': <Object>[], 'page': 1, 'limit': 101, 'total': 0},
        parse,
      ),
      throwsFormatException,
    );
  });
}
