import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/media_url.dart';

void main() {
  test('prefixes relative upload paths with the backend origin', () {
    expect(
      MediaUrl.resolve('/uploads/lots/a.jpg', origin: 'http://10.0.2.2:4000'),
      'http://10.0.2.2:4000/uploads/lots/a.jpg',
    );
    expect(
      MediaUrl.resolve('uploads/lots/a.jpg', origin: 'http://10.0.2.2:4000/'),
      'http://10.0.2.2:4000/uploads/lots/a.jpg',
    );
  });

  test('keeps absolute URLs and maps empty values to null', () {
    expect(
      MediaUrl.resolve('https://cdn.example.test/a.jpg'),
      'https://cdn.example.test/a.jpg',
    );
    expect(MediaUrl.resolve(null), isNull);
    expect(MediaUrl.resolve('  '), isNull);
  });
}
