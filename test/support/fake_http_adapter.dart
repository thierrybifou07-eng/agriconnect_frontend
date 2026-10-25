import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class FakeHttpResponse {
  const FakeHttpResponse({required this.statusCode, required this.data});

  final int statusCode;
  final Object? data;
}

class FakeHttpAdapter implements HttpClientAdapter {
  final Map<String, Queue<FakeHttpResponse>> _responses = {};
  final Map<String, int> callCounts = {};
  final List<RequestOptions> requests = [];

  void enqueue(String path, FakeHttpResponse response) {
    (_responses[path] ??= Queue<FakeHttpResponse>()).add(response);
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
    final response = queue.removeFirst();
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
