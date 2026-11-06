import 'package:dio/dio.dart';

import 'package:agri_connect/core/network/api_failure_mapper.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';

/// Signs requests and renews the access token (docs/API_CONTRACT.md § 3).
///
/// - Adds `Authorization: Bearer <access>` to every request not marked
///   `auth: false`.
/// - On a 401 from a protected route, runs ONE `POST /auth/refresh` shared by
///   every concurrent request (single flight), stores BOTH rotated tokens,
///   then replays the original request once. A replayed request is never
///   retried again, so a server that keeps answering 401 cannot loop.
/// - A refused refresh, or a 403 `ACCOUNT_SUSPENDED`, clears the tokens and
///   reports the end of the session on [SessionEvents].
///
/// The refresh call uses its own Dio without this interceptor: the backend
/// destroys the session when an already-rotated refresh token is reused, so
/// the refresh must never be signed or replayed by accident.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.tokenStorage,
    required this.sessionEvents,
    Dio Function(BaseOptions options)? refreshDioFactory,
  }) : _refreshDioFactory = refreshDioFactory ?? Dio.new;

  /// The client this interceptor is attached to, used for the replay.
  final Dio dio;
  final TokenStorage tokenStorage;
  final SessionEvents sessionEvents;
  final Dio Function(BaseOptions options) _refreshDioFactory;
  Future<String?>? _refreshInFlight;

  @override
  Future<void> onRequest(
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
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final failure = apiFailureFromDio(err);

    if (failure.isSuspended) {
      await _endSession(SessionEndReason.suspended);
      handler.next(err);
      return;
    }

    if (!failure.isUnauthorized ||
        request.extra['auth'] == false ||
        request.extra['retried'] == true) {
      handler.next(err);
      return;
    }

    // Another request may already have refreshed while this one was in
    // flight: reuse the stored token instead of refreshing a second time.
    final current = await tokenStorage.read();
    final sentAuthorization = request.headers['Authorization'];
    final accessToken =
        current != null && sentAuthorization != 'Bearer ${current.access}'
        ? current.access
        : await refreshAccessToken();
    if (accessToken == null) {
      handler.next(err);
      return;
    }

    final data = request.data;
    final replay = request.copyWith(
      headers: {...request.headers, 'Authorization': 'Bearer $accessToken'},
      extra: {...request.extra, 'retried': true},
      // A multipart body is a stream that can only be sent once.
      data: data is FormData ? data.clone() : data,
    );
    try {
      handler.resolve(await dio.fetch<dynamic>(replay));
    } on DioException catch (replayError) {
      handler.next(replayError);
    }
  }

  /// Returns a valid access token, refreshing it at most once at a time.
  ///
  /// Also used by the Socket.io service, whose handshake token must be fresh
  /// at every reconnection. Returns `null` when the session is over.
  Future<String?> refreshAccessToken() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;
    final refresh = _refresh().whenComplete(() => _refreshInFlight = null);
    _refreshInFlight = refresh;
    return refresh;
  }

  Future<String?> _refresh() async {
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
      ),
    );
    try {
      final response = await refreshDio.post<dynamic>(
        'auth/refresh',
        data: {'refreshToken': tokens.refresh},
      );
      final body = response.data;
      if (body is! Map ||
          body['accessToken'] is! String ||
          body['refreshToken'] is! String) {
        await _endSession(SessionEndReason.expired);
        return null;
      }
      final access = body['accessToken'] as String;
      await tokenStorage.save(
        access: access,
        refresh: body['refreshToken'] as String,
      );
      return access;
    } on DioException catch (refreshError) {
      final failure = apiFailureFromDio(refreshError);
      // 400/401/403: the refresh token is dead. A network error or a 5xx is
      // not proof of that: keep the session and let the caller retry later.
      if (failure.status == 400 ||
          failure.status == 401 ||
          failure.status == 403) {
        await _endSession(
          failure.isSuspended
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
