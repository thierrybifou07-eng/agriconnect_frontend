/// Network configuration of the application, read from `--dart-define`.
///
/// `API_BASE_URL` is the REST root, always ending with `/api/v2`
/// (e.g. `http://10.0.2.2:4000/api/v2` on the Android emulator, or
/// `http://<LAN IP of the PC>:4000/api/v2` on a real phone). The Socket.io
/// server and the public media files live at the **origin**, without the
/// `/api/v2` suffix: [origin] derives it once so nothing else re-guesses it.
///
/// Usage: `flutter run --dart-define-from-file=env/dev.emulator.json`.
abstract final class Env {
  static const String _defaultApiBaseUrl = 'http://10.0.2.2:4000/api/v2';
  static const String _apiSuffix = '/api/v2';

  /// REST root, without a trailing slash.
  static String get apiBaseUrl => normalizeBaseUrl(
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: _defaultApiBaseUrl,
    ),
  );

  /// Scheme, host and port of the backend: Socket.io and `/uploads/...`.
  static String get origin => originOf(apiBaseUrl);

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Uploads (multipart) may carry up to five 5 MB photos on a slow link.
  static const Duration uploadTimeout = Duration(seconds: 120);

  /// Trims the value and drops trailing slashes.
  static String normalizeBaseUrl(String raw) =>
      raw.trim().replaceFirst(RegExp(r'/+$'), '');

  /// The origin of [baseUrl]: the same URL without its `/api/v2` suffix.
  static String originOf(String baseUrl) {
    final normalized = normalizeBaseUrl(baseUrl);
    return normalized.endsWith(_apiSuffix)
        ? normalized.substring(0, normalized.length - _apiSuffix.length)
        : normalized;
  }

  /// Why [baseUrl] cannot be used, or `null` when it is valid.
  ///
  /// The URL must be absolute (http or https, with a host) and end with
  /// `/api/v2`: a missing suffix would send every call to a 404.
  static String? validate(String baseUrl) {
    final normalized = normalizeBaseUrl(baseUrl);
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      return 'API_BASE_URL must be an absolute http(s) URL: "$baseUrl"';
    }
    if (!normalized.endsWith(_apiSuffix)) {
      return 'API_BASE_URL must end with $_apiSuffix: "$baseUrl"';
    }
    return null;
  }
}
