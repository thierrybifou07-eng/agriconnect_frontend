import 'dart:async';

import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/ui_state.dart';

abstract class PaginatedController<T> extends GetxController {
  PaginatedController({this.limit = 20}) {
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100');
    }
  }

  final int limit;
  final Rx<UiState<List<T>>> state = Rx<UiState<List<T>>>(const Idle());

  int _page = 0;
  int _loadGeneration = 0;
  bool _isLoadingFirst = false;
  bool _isLoadingMore = false;
  bool hasMore = true;

  Future<Paginated<T>> fetch(int page, int limit);

  Future<void> loadFirst() async {
    if (_isLoadingFirst) return;
    final generation = ++_loadGeneration;
    _isLoadingFirst = true;
    state.value = const Loading();
    _page = 0;
    hasMore = true;
    try {
      final result = await fetch(1, limit);
      if (generation != _loadGeneration) return;
      _page = result.page;
      hasMore = result.hasMore;
      state.value = Success(List<T>.unmodifiable(result.items));
    } on ApiFailure catch (failure) {
      if (generation == _loadGeneration) state.value = Failure(failure);
    } finally {
      _isLoadingFirst = false;
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (_isLoadingFirst ||
        _isLoadingMore ||
        !hasMore ||
        current is! Success<List<T>>) {
      return;
    }
    _isLoadingMore = true;
    final generation = _loadGeneration;
    try {
      final result = await fetch(_page + 1, limit);
      if (generation != _loadGeneration) return;
      _page = result.page;
      hasMore = result.hasMore;
      state.value = Success(
        List<T>.unmodifiable([...current.data, ...result.items]),
      );
    } on ApiFailure catch (failure) {
      if (generation == _loadGeneration) state.value = Failure(failure);
    } finally {
      _isLoadingMore = false;
    }
  }

  @override
  void refresh() {
    unawaited(loadFirst());
  }
}
