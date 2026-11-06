import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/config/env.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/auth_interceptor.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';

/// The single Dio of the application, shared by the API client and its
/// authentication interceptor (which replays requests through it).
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      responseType: ResponseType.json,
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

/// Signs requests and renews tokens; also gives the socket a fresh token.
final authInterceptorProvider = Provider<AuthInterceptor>(
  (ref) => AuthInterceptor(
    dio: ref.watch(dioProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    sessionEvents: ref.watch(sessionEventsProvider),
  ),
);

/// The single API client of the application.
///
/// Remote repositories read it with `ref.watch(apiClientProvider)`; tests
/// override [dioProvider] (fake HTTP adapter) or this provider directly.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    dio: ref.watch(dioProvider),
    interceptors: [ref.watch(authInterceptorProvider)],
  ),
);
