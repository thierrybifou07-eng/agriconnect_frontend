import 'package:dio/dio.dart';

enum ApiFailureKind { network, timeout, server, client }

class ApiFailure implements Exception {
  const ApiFailure({
    required this.status,
    required this.code,
    required this.message,
    required this.fieldErrors,
    required this.kind,
  });

  final int? status;
  final String? code;
  final String message;
  final Map<String, String> fieldErrors;
  final ApiFailureKind kind;

  bool get isUnauthorized => status == 401;
  bool get isSuspended =>
      code == 'ACCOUNT_SUSPENDED' ||
      (code == null &&
          status == 403 &&
          message.toLowerCase().contains('suspendu'));
  bool get isProfileNotVerified => code == 'PROFILE_NOT_VERIFIED';
  bool get isStateConflict => code == 'INVALID_STATE_TRANSITION';
  bool get isCapabilityRequired =>
      code == 'CAPABILITY_REQUIRED' ||
      message.toLowerCase().contains('capacité requise');

  factory ApiFailure.fromDio(DioException exception) {
    final response = exception.response;
    final status = response?.statusCode;
    final body = response?.data;
    final map = body is Map ? body : const <Object?, Object?>{};
    final rawDetails = map['details'];
    final errors = <String, String>{};
    if (rawDetails is List) {
      for (final detail in rawDetails) {
        if (detail is Map &&
            detail['field'] is String &&
            detail['message'] is String) {
          errors[detail['field'] as String] = detail['message'] as String;
        }
      }
    }

    final kind = switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => ApiFailureKind.timeout,
      DioExceptionType.connectionError ||
      DioExceptionType.unknown when response == null => ApiFailureKind.network,
      _ when status != null && status >= 500 => ApiFailureKind.server,
      _ => ApiFailureKind.client,
    };

    return ApiFailure(
      status: status,
      code: map['code'] is String ? map['code'] as String : null,
      message: map['error'] is String
          ? map['error'] as String
          : exception.message ?? 'Request failed',
      fieldErrors: Map.unmodifiable(errors),
      kind: kind,
    );
  }

  @override
  String toString() => 'ApiFailure($status, $code, $message)';
}
