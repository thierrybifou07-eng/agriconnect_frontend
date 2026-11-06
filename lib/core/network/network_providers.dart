import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/network/api_client.dart';

/// The single API client of the application.
///
/// Remote repositories read it with `ref.watch(apiClientProvider)`; tests
/// override it with a client built on a fake HTTP adapter.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(() => client.dio.close(force: true));
  return client;
});
