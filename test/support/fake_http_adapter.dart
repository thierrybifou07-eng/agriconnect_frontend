import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Canned HTTP answer for [FakeHttpAdapter].
class FakeHttpResponse {
  const FakeHttpResponse({required this.statusCode, this.data});

  final int statusCode;
  final Object? data;
}

/// Dio adapter that answers from queued responses, keyed by relative path,
/// and records every request it receives. No network is ever touched.
///
/// Throwing a [DioException] from [enqueueError] simulates a transport error
/// (timeout, connection refused).
class FakeHttpAdapter implements HttpClientAdapter {
  final Map<String, Queue<Object>> _responses = {};
  final Map<String, int> callCounts = {};
  final List<RequestOptions> requests = [];

  void enqueue(String path, FakeHttpResponse response) {
    (_responses[path] ??= Queue<Object>()).add(response);
  }

  void enqueueError(String path, DioExceptionType type) {
    (_responses[path] ??= Queue<Object>()).add(type);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path.replaceFirst(RegExp(r'^/+'), '');
    callCounts.update(path, (count) => count + 1, ifAbsent: () => 1);
    requests.add(options);
    final queue = _responses[path];
    if (queue == null || queue.isEmpty) {
      throw StateError('No fake HTTP response queued for $path');
    }
    final next = queue.removeFirst();
    if (next is DioExceptionType) {
      throw DioException(requestOptions: options, type: next);
    }
    final response = next as FakeHttpResponse;
    return ResponseBody.fromString(
      jsonEncode(response.data),
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
