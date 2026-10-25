import 'dart:async';

import 'package:agri_connect/core/network/api_failure.dart';

class ApiFailureEvents {
  final StreamController<ApiFailure> _controller =
      StreamController<ApiFailure>.broadcast();

  Stream<ApiFailure> get stream => _controller.stream;

  void emit(ApiFailure failure) {
    if (failure.isProfileNotVerified) _controller.add(failure);
  }

  Future<void> close() => _controller.close();
}
