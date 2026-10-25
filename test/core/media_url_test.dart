import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/config/app_env.dart';
import 'package:agri_connect/core/media/media_url.dart';

void main() {
  test('keeps absolute HTTP URLs and resolves nullable paths', () {
    expect(
      MediaUrl.resolve('https://cdn.example.test/photo.jpg'),
      'https://cdn.example.test/photo.jpg',
    );
    expect(MediaUrl.resolve(null), isNull);
    expect(
      MediaUrl.resolve('/uploads/photo.jpg'),
      AppEnv.origin.isEmpty ? isNull : '${AppEnv.origin}/uploads/photo.jpg',
    );
  });
}
