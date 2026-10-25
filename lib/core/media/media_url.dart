import 'package:agri_connect/core/config/app_env.dart';

abstract final class MediaUrl {
  static String? resolve(String? path) {
    if (path == null || path.isEmpty) return null;
    final uri = Uri.tryParse(path);
    if (uri?.scheme == 'http' || uri?.scheme == 'https') return path;
    if (AppEnv.origin.isEmpty) return null;
    return '${AppEnv.origin}${path.startsWith('/') ? path : '/$path'}';
  }
}
