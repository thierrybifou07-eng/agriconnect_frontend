import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/config/env.dart';

void main() {
  group('Env', () {
    test('the default base URL targets the Android emulator and is valid', () {
      expect(Env.apiBaseUrl, 'http://10.0.2.2:4000/api/v2');
      expect(Env.validate(Env.apiBaseUrl), isNull);
      expect(Env.origin, 'http://10.0.2.2:4000');
    });

    test('derives the origin without /api/v2 and tolerates trailing slashes', () {
      expect(
        Env.originOf('http://192.168.1.10:4000/api/v2/'),
        'http://192.168.1.10:4000',
      );
      expect(Env.normalizeBaseUrl('  https://x.test/api/v2// '), 'https://x.test/api/v2');
    });

    test('rejects a relative URL, another scheme or a missing /api/v2', () {
      expect(Env.validate('/api/v2'), isNotNull);
      expect(Env.validate('ftp://x.test/api/v2'), isNotNull);
      expect(Env.validate('http://10.0.2.2:4000'), contains('/api/v2'));
    });
  });
}
