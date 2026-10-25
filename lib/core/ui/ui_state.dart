import 'package:agri_connect/core/network/api_failure.dart';

sealed class UiState<T> {
  const UiState();
}

final class Idle<T> extends UiState<T> {
  const Idle();
}

final class Loading<T> extends UiState<T> {
  const Loading();
}

final class Success<T> extends UiState<T> {
  const Success(this.data);

  final T data;
}

final class Failure<T> extends UiState<T> {
  const Failure(this.failure);

  final ApiFailure failure;
}
