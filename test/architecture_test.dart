import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('source stays free of forbidden architecture patterns', () async {
    final root = Directory('lib');
    final arbDir = Directory('lib/core/localization/l10n');

    if (!root.existsSync()) {
      fail('lib directory is missing');
    }

    final violations = <String>[];

    final libFiles =
        root
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .where((file) => !file.path.toLowerCase().contains('generated'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    final forbiddenImportPatterns = [
      RegExp(r'flutter_riverpod'),
      RegExp(r'go_router'),
    ];

    final forbiddenIdentifierPatterns = [
      RegExp(r'\bDemo[A-Za-z0-9_]*\b'),
      RegExp(r'\bMockData[A-Za-z0-9_]*\b'),
      RegExp(r'\bFake[A-Za-z0-9_]*\b'),
    ];

    for (final file in libFiles) {
      final normalizedPath = file.path.replaceAll(r'\', '/');
      final lines = await file.readAsLines();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final normalized = line.trim();
        if (normalized.isEmpty) {
          continue;
        }

        if (forbiddenImportPatterns.any(
          (pattern) => pattern.hasMatch(normalized),
        )) {
          violations.add(
            '${file.path}:${i + 1}: forbidden dependency: ${line.trim()}',
          );
        }

        if (forbiddenIdentifierPatterns.any(
          (pattern) => pattern.hasMatch(normalized),
        )) {
          violations.add(
            '${file.path}:${i + 1}: forbidden identifier: ${line.trim()}',
          );
        }

        final restrictedLayer =
            normalizedPath.contains('/data/') ||
            normalizedPath.contains('/domain/') ||
            normalizedPath.contains('/core/network/') ||
            normalizedPath.contains('/core/storage/');
        if (restrictedLayer && RegExp(r'Get\.find\s*\(').hasMatch(normalized)) {
          violations.add(
            '${file.path}:${i + 1}: forbidden Get.find in restricted layer: ${line.trim()}',
          );
        }

        if (!normalizedPath.contains('/core/config/') &&
            RegExp(r'https?://').hasMatch(normalized)) {
          violations.add(
            '${file.path}:${i + 1}: hardcoded URL: ${line.trim()}',
          );
        }
      }
    }

    final arbFiles =
        arbDir
            .listSync(followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('.arb'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    final referenceKeys = <String>{};
    for (final file in arbFiles) {
      final content = await file.readAsString();
      final keys = RegExp(
        r'"([A-Za-z0-9_]+)"\s*:',
      ).allMatches(content).map((match) => match.group(1)!).toSet();
      if (file.path.endsWith('app_fr.arb')) {
        referenceKeys.addAll(keys);
      }
    }

    for (final file in arbFiles) {
      final content = await file.readAsString();
      final keys = RegExp(
        r'"([A-Za-z0-9_]+)"\s*:',
      ).allMatches(content).map((match) => match.group(1)!).toSet();
      final fileLabel = file.path.split(Platform.pathSeparator).last;
      if (fileLabel == 'app_fr.arb') {
        continue;
      }

      final missing = referenceKeys.difference(keys).toList()..sort();
      final extra = keys.difference(referenceKeys).toList()..sort();
      if (missing.isNotEmpty || extra.isNotEmpty) {
        violations.add(
          'ARB key mismatch in $fileLabel: missing=${missing.join(', ')}, extra=${extra.join(', ')}',
        );
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
