import 'package:agri_connect/core/config/env.dart';

/// Resolves the media paths returned by the API.
///
/// Public files come back as `/uploads/<folder>/<file>`, relative to the
/// backend **origin** (not to `/api/v2`). Absolute URLs are kept as they are.
abstract final class MediaUrl {
  static String? resolve(String? path, {String? origin}) {
    if (path == null) return null;
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) return trimmed;
    final base = Env.normalizeBaseUrl(origin ?? Env.origin);
    final relative = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$relative';
  }
}
