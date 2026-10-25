abstract final class AppEnv {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String socketUrl = String.fromEnvironment('SOCKET_URL');

  static bool get isConfigured => apiBaseUrl.trim().isNotEmpty;

  static String get origin {
    final base = apiBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    return base.endsWith('/api/v2')
        ? base.substring(0, base.length - '/api/v2'.length)
        : base;
  }
}
