import 'package:dio/dio.dart';

import 'package:agri_connect/core/config/app_env.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/api_failure_events.dart';
import 'package:agri_connect/core/network/api_interceptors.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required SessionEvents sessionEvents,
    this.failureEvents,
    String? baseUrl,
    Dio? dio,
    Dio Function(BaseOptions options)? refreshDioFactory,
  }) : dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: _normalizeBaseUrl(baseUrl ?? AppEnv.apiBaseUrl),
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
             ),
           ) {
    _interceptor = AuthInterceptor(
      dio: this.dio,
      tokenStorage: tokenStorage,
      sessionEvents: sessionEvents,
      refreshDioFactory: refreshDioFactory,
      onTokenRefreshed: (token) => onTokenRefreshed?.call(token),
    );
    this.dio.options.baseUrl = _normalizeBaseUrl(this.dio.options.baseUrl);
    this.dio.interceptors.add(_interceptor);
  }

  final Dio dio;
  final ApiFailureEvents? failureEvents;
  late final AuthInterceptor _interceptor;
  void Function(String token)? onTokenRefreshed;
  Future<String?> ensureFreshToken() => _interceptor.ensureFreshToken();

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
    Map<String, dynamic>? headers,
  }) => _send('GET', path, query: query, auth: auth, headers: headers);

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? query,
    Object? data,
    bool auth = true,
    Map<String, dynamic>? headers,
    Duration? receiveTimeout,
  }) => _send(
    'POST',
    path,
    query: query,
    data: data,
    auth: auth,
    headers: headers,
    receiveTimeout: receiveTimeout,
  );

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? query,
    Object? data,
    bool auth = true,
    Map<String, dynamic>? headers,
  }) => _send(
    'PATCH',
    path,
    query: query,
    data: data,
    auth: auth,
    headers: headers,
  );

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? query,
    Object? data,
    bool auth = true,
    Map<String, dynamic>? headers,
  }) => _send(
    'PUT',
    path,
    query: query,
    data: data,
    auth: auth,
    headers: headers,
  );

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? query,
    Object? data,
    bool auth = true,
    Map<String, dynamic>? headers,
  }) => _send(
    'DELETE',
    path,
    query: query,
    data: data,
    auth: auth,
    headers: headers,
  );

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
    sendTimeout: const Duration(seconds: 120),
  );

  Future<List<int>> getBytes(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
    Map<String, dynamic>? headers,
  }) async {
    final result = await _send(
      'GET',
      path,
      query: query,
      auth: auth,
      headers: headers,
      responseType: ResponseType.bytes,
    );
    if (result is List<int>) return result;
    throw const FormatException('Expected a binary response');
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? data,
    required bool auth,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) async {
    try {
      final response = await dio.request<dynamic>(
        _normalizePath(path),
        queryParameters: query,
        data: data,
        options: Options(
          method: method,
          headers: headers,
          extra: {'auth': auth},
          responseType: responseType,
          sendTimeout: sendTimeout,
          receiveTimeout: receiveTimeout,
        ),
      );
      return response.data;
    } on DioException catch (error) {
      final failure = error.error;
      final apiFailure = failure is ApiFailure
          ? failure
          : ApiFailure.fromDio(error);
      failureEvents?.emit(apiFailure);
      throw apiFailure;
    }
  }

  static String _normalizePath(String path) =>
      path.startsWith('/') ? path.substring(1) : path;

  static String _normalizeBaseUrl(String baseUrl) {
    final normalized = baseUrl.trim();
    if (normalized.isEmpty || normalized.endsWith('/')) return normalized;
    return '$normalized/';
  }
}
