import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/agent/application/agent_providers.dart';
import 'package:agri_connect/features/agent/domain/agent_repository.dart';

/// Immutable snapshot shared by every agent section list.
///
/// The four sections behave identically — one initial load, a pull-to-refresh,
/// per-item updates guarded against double taps, and one action failure surfaced
/// once — so they share a single state shape instead of four near-identical
/// copies.
class AgentSectionState<T> {
  const AgentSectionState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.items = const [],
    this.updatingIds = const {},
    this.actionFailure,
    this.failedId,
  });

  final bool isLoading;
  final bool isRefreshing;

  /// Initial load failure, retryable through the controller's `refresh`.
  final Failure? failure;

  final List<T> items;

  /// Cases currently being updated; guards against double submissions.
  final Set<String> updatingIds;

  /// Last action failure, surfaced once to the UI.
  final Failure? actionFailure;

  /// Case that failed, so the UI can point at it.
  final String? failedId;

  bool isUpdating(String id) => updatingIds.contains(id);

  AgentSectionState<T> copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    List<T>? items,
    Set<String>? updatingIds,
    Failure? actionFailure,
    String? failedId,
    bool clearFailure = false,
    bool clearActionFailure = false,
  }) {
    return AgentSectionState<T>(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      // A failure is dropped only when the caller says so: a copy that simply
      // omitted it must not make a failed load or action look like it never
      // happened.
      failure: clearFailure ? null : (failure ?? this.failure),
      items: items ?? this.items,
      updatingIds: updatingIds ?? this.updatingIds,
      actionFailure: clearActionFailure
          ? null
          : (actionFailure ?? this.actionFailure),
      failedId: clearActionFailure ? null : (failedId ?? this.failedId),
    );
  }
}

/// Shared behaviour of the four agent section controllers.
///
/// A concrete controller only says how to load its items and what identifies
/// them; the loading, refreshing and update lifecycle lives here once.
abstract class AgentListController<T> extends Notifier<AgentSectionState<T>> {
  @override
  AgentSectionState<T> build() {
    Future<void>.microtask(_load);
    return AgentSectionState<T>(isLoading: true);
  }

  /// Stable identity of an item, used to replace it after an update.
  String idOf(T item);

  /// Loads the whole section from the repository.
  Future<List<T>> loadItems(AgentRepository repository);

  /// Reloads on pull-to-refresh and on retry after a failure.
  ///
  /// Refreshes rather than loads: items already on screen stay there under the
  /// pull indicator instead of being replaced by a skeleton.
  Future<void> refresh() async {
    if (state.isLoading || state.isRefreshing) return;
    state = state.copyWith(
      isLoading: state.items.isEmpty,
      isRefreshing: true,
      clearFailure: true,
    );
    await _load();
  }

  Future<void> _load() async {
    final repository = ref.read(agentRepositoryProvider);
    try {
      final items = await loadItems(repository);
      // A fresh load is the real state of the world: it supersedes both a load
      // failure and an action whose outcome was never confirmed.
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        items: items,
        clearFailure: true,
        clearActionFailure: true,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        failure: failure,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        failure: const UnexpectedFailure(),
      );
    }
  }

  /// Runs an update for [id] and replaces the item with what the repository
  /// returns. Returns whether it succeeded.
  ///
  /// Nothing is retried automatically: on failure the real state is left
  /// untouched and the failure is surfaced once, exactly like the driver flow.
  Future<bool> runAction(
    String id,
    Future<T> Function(AgentRepository repository) action,
  ) async {
    if (state.updatingIds.contains(id)) return false;
    state = state.copyWith(
      updatingIds: {...state.updatingIds, id},
      clearActionFailure: true,
      clearFailure: true,
    );

    try {
      final updated = await action(ref.read(agentRepositoryProvider));
      final items = [
        for (final item in state.items)
          if (idOf(item) == id) updated else item,
      ];
      state = state.copyWith(
        items: items,
        updatingIds: {...state.updatingIds}..remove(id),
        clearActionFailure: true,
      );
      return true;
    } on Failure catch (failure) {
      state = state.copyWith(
        updatingIds: {...state.updatingIds}..remove(id),
        actionFailure: failure,
        failedId: id,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        updatingIds: {...state.updatingIds}..remove(id),
        actionFailure: const UnexpectedFailure(),
        failedId: id,
      );
      return false;
    }
  }
}
