import 'package:dio/dio.dart';

import 'package:agri_connect/core/errors/failures.dart';

/// Converts a Dio error into an [ApiFailure] (docs/API_CONTRACT.md § 2).
ApiFailure apiFailureFromDio(DioException exception) {
  final embedded = exception.error;
  if (embedded is ApiFailure) return embedded;

  final response = exception.response;
  final status = response?.statusCode;
  final body = response?.data;
  final map = body is Map ? body : const <Object?, Object?>{};

  final fieldErrors = <String, String>{};
  final details = map['details'];
  if (details is List) {
    for (final detail in details) {
      if (detail is Map &&
          detail['field'] is String &&
          detail['message'] is String) {
        fieldErrors[detail['field'] as String] = detail['message'] as String;
      }
    }
  }

  final kind = switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => ApiFailureKind.timeout,
    _ when response == null => ApiFailureKind.network,
    _ when status != null && status >= 500 => ApiFailureKind.server,
    _ => ApiFailureKind.client,
  };

  final retryAfterMs = map['retryAfterMs'];
  return ApiFailure(
    kind: kind,
    status: status,
    apiCode: map['code'] is String ? map['code'] as String : null,
    serverMessage: map['error'] is String ? map['error'] as String : null,
    fieldErrors: fieldErrors,
    profileVerificationStatus: map['profileVerificationStatus'] is String
        ? map['profileVerificationStatus'] as String
        : null,
    expectedField: map['expectedField'] is String
        ? map['expectedField'] as String
        : null,
    retryAfter: retryAfterMs is num
        ? Duration(milliseconds: retryAfterMs.round())
        : null,
  );
}
