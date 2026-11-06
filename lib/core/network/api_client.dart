import 'package:dio/dio.dart';

import 'package:agri_connect/core/config/env.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/network/api_failure_mapper.dart';

/// Thin wrapper over the single [Dio] of the application.
///
/// Every backend call of the app goes through it: paths are relative to
/// `/api/v2` (`'auth/login'`, `'catalog/listings'`), and every error comes out
/// as an [ApiFailure], never as a raw [DioException].
///
/// `auth: false` marks a public route (login, register, refresh...): the
/// authentication interceptor added in the next step leaves it untouched.
class ApiClient {
  ApiClient({
    Dio? dio,
    String? baseUrl,
    List<Interceptor> interceptors = const [],
  }) : dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: Env.connectTimeout,
               receiveTimeout: Env.receiveTimeout,
               responseType: ResponseType.json,
             ),
           ) {
    this.dio.options.baseUrl = withTrailingSlash(baseUrl ?? Env.apiBaseUrl);
    this.dio.interceptors.addAll(interceptors);
  }

  final Dio dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
    Map<String, dynamic>? headers,
  }) => _send('GET', path, query: query, auth: auth, headers: headers);

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool auth = true,
    Map<String, dynamic>? headers,
  }) => _send(
    'POST',
    path,
    data: data,
    query: query,
    auth: auth,
    headers: headers,
  );

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool auth = true,
    Map<String, dynamic>? headers,
  }) => _send(
    'PATCH',
    path,
    data: data,
    query: query,
    auth: auth,
    headers: headers,
  );

  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool auth = true,
    Map<String, dynamic>? headers,
  }) => _send(
    'PUT',
    path,
    data: data,
    query: query,
    auth: auth,
    headers: headers,
  );

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool auth = true,
    Map<String, dynamic>? headers,
  }) => _send(
    'DELETE',
    path,
    data: data,
    query: query,
    auth: auth,
    headers: headers,
  );

  /// Multipart upload (photos, documents) with a longer send timeout.
  Future<dynamic> postMultipart(
    String path,
    FormData data, {
    bool auth = true,
    Map<String, dynamic>? headers,
  }) => _send(
    'POST',
    path,
    data: data,
    auth: auth,
    headers: headers,
    sendTimeout: Env.uploadTimeout,
  );

  /// Raw bytes, for private files (verification documents) that must be
  /// fetched with the reviewer's own `Authorization` header.
  Future<List<int>> getBytes(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) async {
    final result = await _send(
      'GET',
      path,
      query: query,
      auth: auth,
      responseType: ResponseType.bytes,
    );
    if (result is List<int>) return result;
    throw ApiFailure(
      kind: ApiFailureKind.client,
      serverMessage: 'Expected a binary response',
    );
  }

  Future<dynamic> _send(
    String method,
    String path, {
    required bool auth,
    Object? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    Duration? sendTimeout,
  }) async {
    try {
      final response = await dio.request<dynamic>(
        relativePath(path),
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          headers: headers,
          extra: {'auth': auth},
          responseType: responseType,
          sendTimeout: sendTimeout,
        ),
      );
      return response.data;
    } on DioException catch (error) {
      throw apiFailureFromDio(error);
    }
  }

  /// Dio resolves a path against the base URL like a browser: a leading `/`
  /// would drop the `/api/v2` segment, so it is stripped.
  static String relativePath(String path) =>
      path.startsWith('/') ? path.replaceFirst(RegExp(r'^/+'), '') : path;

  /// The base URL must end with `/` for relative paths to append to it.
  static String withTrailingSlash(String baseUrl) {
    final normalized = Env.normalizeBaseUrl(baseUrl);
    return normalized.isEmpty ? normalized : '$normalized/';
  }
}
