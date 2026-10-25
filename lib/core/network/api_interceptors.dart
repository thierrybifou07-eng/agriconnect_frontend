import 'package:dio/dio.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.tokenStorage,
    required this.sessionEvents,
    Dio Function(BaseOptions options)? refreshDioFactory,
  }) : _refreshDioFactory = refreshDioFactory ?? _createRefreshDio;

  final Dio dio;
  final TokenStorage tokenStorage;
  final SessionEvents sessionEvents;
  final Dio Function(BaseOptions options) _refreshDioFactory;
  Future<String?>? _refreshInFlight;

  static Dio _createRefreshDio(BaseOptions options) => Dio(options);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['auth'] != false) {
      final tokens = await tokenStorage.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.access}';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final failure = ApiFailure.fromDio(err);
    if (failure.isSuspended) {
      await tokenStorage.clear();
      sessionEvents.emit(SessionEndReason.suspended);
    }

    if (!failure.isUnauthorized ||
        request.extra['auth'] == false ||
        request.extra['retried'] == true) {
      handler.next(err);
      return;
    }

    final currentTokens = await tokenStorage.read();
    final failedAuthorization = request.headers['Authorization'];
    final accessToken =
        currentTokens != null &&
            failedAuthorization != 'Bearer ${currentTokens.access}'
        ? currentTokens.access
        : await _refreshSingleFlight();
    if (accessToken == null) {
      handler.next(err);
      return;
    }

    final headers = Map<String, dynamic>.from(request.headers)
      ..['Authorization'] = 'Bearer $accessToken';
    final extra = Map<String, dynamic>.from(request.extra)..['retried'] = true;
    final requestData = request.data;
    final data = requestData is FormData ? requestData.clone() : requestData;
    try {
      final replayed = request.copyWith(
        headers: headers,
        extra: extra,
        data: data,
      );
      handler.resolve(await dio.fetch<dynamic>(replayed));
    } on DioException catch (replayError) {
      handler.reject(replayError);
    }
  }

  Future<String?> _refreshSingleFlight() async {
    final existing = _refreshInFlight;
    if (existing != null) return existing;

    final refresh = _refreshAccessToken();
    _refreshInFlight = refresh;
    try {
      return await refresh;
    } finally {
      if (identical(_refreshInFlight, refresh)) _refreshInFlight = null;
    }
  }

  Future<String?> _refreshAccessToken() async {
    final tokens = await tokenStorage.read();
    if (tokens == null || tokens.refresh.isEmpty) {
      await _endSession(SessionEndReason.expired);
      return null;
    }

    final refreshDio = _refreshDioFactory(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: dio.options.connectTimeout,
        receiveTimeout: dio.options.receiveTimeout,
        sendTimeout: dio.options.sendTimeout,
        headers: dio.options.headers,
      ),
    );
    try {
      final response = await refreshDio.post<dynamic>(
        'auth/refresh',
        data: {'refreshToken': tokens.refresh},
      );
      final payload = response.data;
      if (payload is! Map ||
          payload['accessToken'] is! String ||
          payload['refreshToken'] is! String) {
        await _endSession(SessionEndReason.expired);
        return null;
      }
      final access = payload['accessToken'] as String;
      final refresh = payload['refreshToken'] as String;
      await tokenStorage.save(access: access, refresh: refresh);
      return access;
    } on DioException catch (refreshError) {
      final refreshFailure = ApiFailure.fromDio(refreshError);
      if (refreshFailure.status == 400 ||
          refreshFailure.status == 401 ||
          refreshFailure.status == 403) {
        await _endSession(
          refreshFailure.isSuspended
              ? SessionEndReason.suspended
              : SessionEndReason.expired,
        );
      }
      return null;
    } finally {
      refreshDio.close(force: true);
    }
  }

  Future<void> _endSession(SessionEndReason reason) async {
    await tokenStorage.clear();
    sessionEvents.emit(reason);
  }
}
