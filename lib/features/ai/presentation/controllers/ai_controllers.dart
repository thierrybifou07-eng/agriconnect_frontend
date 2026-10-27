// ignore_for_file: cancel_subscriptions

import 'dart:async';

import 'package:get/get.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/ai/domain/ai_entities.dart';
import 'package:agri_connect/features/ai/domain/ai_repository.dart';

class AiSuggestionController extends GetxController {
  AiSuggestionController({
    required this.repository,
    required this.socket,
    this.pollInterval = const Duration(seconds: 3),
    this.cloudPollLimit = const Duration(seconds: 90),
    this.ollamaPollLimit = const Duration(minutes: 3),
  });

  final AiRepository repository;
  final SocketService socket;
  final Duration pollInterval;
  final Duration cloudPollLimit;
  final Duration ollamaPollLimit;
  final Rxn<AiSuggestion> current = Rxn<AiSuggestion>();
  final Rx<UiState<Paginated<AiSuggestion>>> queueState =
      Rx<UiState<Paginated<AiSuggestion>>>(const Idle());
  final Rx<UiState<void>> actionState = Rx<UiState<void>>(const Idle());
  final RxInt readyCount = 0.obs;
  final RxSet<int> aiAgentIds = <int>{}.obs;
  final RxInt page = 1.obs;
  final RxString statusFilter = ''.obs;
  final RxString kindFilter = ''.obs;
  final RxString provider = ''.obs;
  final RxString lastErrorCode = ''.obs;
  final Rxn<ApiFailure> badgeFailure = Rxn<ApiFailure>();

  final Map<int, Timer> _polls = {};
  final Map<int, DateTime> _pollStartedAt = {};
  final Set<int> _pollingRequests = {};
  StreamSubscription<Map<String, dynamic>>? _createdSubscription;
  StreamSubscription<Map<String, dynamic>>? _updatedSubscription;

  @override
  void onInit() {
    super.onInit();
    _createdSubscription = socket.aiSuggestion.listen(_onSuggestionEvent);
    _updatedSubscription = socket.aiSuggestionUpdated.listen(
      _onSuggestionEvent,
    );
    unawaited(refreshBadge());
    final conversationId = int.tryParse(Get.parameters['conversationId'] ?? '');
    if (conversationId != null) unawaited(loadConversation(conversationId));
  }

  Future<void> loadConversation(int conversationId) async {
    actionState.value = const Idle<void>();
    lastErrorCode.value = '';
    try {
      final result = await repository.suggestions(
        page: 1,
        limit: 20,
        conversationId: conversationId,
      );
      final open = result.items.where(
        (item) => item.status == AiSuggestionStatus.pending,
      );
      if (open.isNotEmpty) {
        current.value = open.first;
        aiAgentIds.add(open.first.agent.id);
        if (open.first.isGenerating) _startPolling(open.first.id);
      } else {
        current.value = null;
      }
      actionState.value = const Success<void>(null);
      lastErrorCode.value = '';
    } on ApiFailure catch (failure) {
      actionState.value = Failure<void>(failure);
    }
  }

  Future<void> suggestReply(int conversationId) async {
    await _createSuggestion(() => repository.suggestReply(conversationId));
  }

  Future<AiSuggestion?> suggestListingDraft(int lotId) async =>
      _createSuggestion(() => repository.suggestListingDraft(lotId));

  Future<AiSuggestion?> _createSuggestion(
    Future<AiSuggestionRequest> Function() create,
  ) async {
    current.value = null;
    actionState.value = const Loading<void>();
    lastErrorCode.value = '';
    try {
      final response = await create();
      actionState.value = const Success<void>(null);
      await refreshBadge();
      final item = await repository.suggestion(response.suggestionId);
      current.value = item;
      if (item.isGenerating) _startPolling(item.id);
      await loadQueue();
      return item;
    } on ApiFailure catch (failure) {
      actionState.value = Failure<void>(failure);
      lastErrorCode.value = failure.code ?? '';
      return null;
    }
  }

  Future<void> retry() async {
    final item = current.value;
    if (item == null) return;
    current.value = null;
    if (item.conversationId != null) {
      await suggestReply(item.conversationId!);
    } else if (item.lotId != null) {
      await suggestListingDraft(item.lotId!);
    }
  }

  Future<bool> approve({String? editedContent}) async {
    final item = current.value;
    if (item == null) return false;
    return approveSuggestion(item.id, editedContent: editedContent);
  }

  Future<bool> approveSuggestion(int id, {String? editedContent}) async {
    actionState.value = const Loading<void>();
    try {
      final approved = await repository.approve(
        id,
        editedContent: editedContent,
      );
      if (current.value?.id == id) current.value = approved;
      actionState.value = const Success<void>(null);
      await refreshBadge();
      await loadQueue();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure<void>(failure);
      lastErrorCode.value = failure.code ?? '';
      return false;
    }
  }

  Future<bool> reject({String? reason}) async {
    final item = current.value;
    if (item == null) return false;
    actionState.value = const Loading<void>();
    try {
      current.value = await repository.reject(item.id, reason: reason);
      actionState.value = const Success<void>(null);
      await refreshBadge();
      await loadQueue();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure<void>(failure);
      lastErrorCode.value = failure.code ?? '';
      return false;
    }
  }

  Future<void> loadQueue({bool append = false}) async {
    final requestedPage = append ? page.value + 1 : 1;
    if (!append) queueState.value = const Loading();
    try {
      final result = await repository.suggestions(
        page: requestedPage,
        limit: 20,
        status: statusFilter.value,
        kind: kindFilter.value,
      );
      page.value = result.page;
      final old = queueState.value;
      final combined = append && old is Success<Paginated<AiSuggestion>>
          ? Paginated<AiSuggestion>(
              items: [...old.data.items, ...result.items],
              page: result.page,
              limit: result.limit,
              total: result.total,
            )
          : result;
      aiAgentIds.addAll(result.items.map((item) => item.agent.id));
      queueState.value = Success(combined);
      await refreshBadge();
    } on ApiFailure catch (failure) {
      queueState.value = Failure(failure);
    }
  }

  Future<void> setQueueFilters({String? status, String? kind}) async {
    if (status != null) statusFilter.value = status;
    if (kind != null) kindFilter.value = kind;
    await loadQueue();
  }

  Future<void> refreshBadge() async {
    try {
      final all = await repository.suggestions(page: 1, limit: 100);
      aiAgentIds.addAll(all.items.map((item) => item.agent.id));
      final result = await repository.suggestions(
        page: 1,
        limit: 100,
        status: 'PENDING',
      );
      readyCount.value = result.items.where((item) => item.isReady).length;
      badgeFailure.value = null;
    } on ApiFailure catch (failure) {
      badgeFailure.value = failure;
    }
  }

  void setProvider(String value) => provider.value = value;

  Future<void> _onSuggestionEvent(Map<String, dynamic> payload) async {
    final id = payload['id'];
    if (id is int) {
      try {
        final item = await repository.suggestion(id);
        aiAgentIds.add(item.agent.id);
        actionState.value = const Success<void>(null);
        lastErrorCode.value = '';
        if (item.conversationId == current.value?.conversationId ||
            item.id == current.value?.id) {
          current.value = item;
        }
        if (item.isGenerating) {
          _startPolling(item.id);
        } else {
          _stopPolling(item.id);
        }
      } on ApiFailure catch (failure) {
        actionState.value = Failure<void>(failure);
        lastErrorCode.value = failure.code ?? '';
      }
    }
    await loadQueue();
  }

  void _startPolling(int id) {
    if (_polls.containsKey(id)) return;
    _pollStartedAt[id] = DateTime.now();
    _polls[id] = Timer.periodic(pollInterval, (timer) {
      if (!_pollingRequests.add(id)) return;
      unawaited(() async {
        try {
          final item = await repository.suggestion(id);
          actionState.value = const Success<void>(null);
          lastErrorCode.value = '';
          if (current.value?.id == id) current.value = item;
          if (!item.isGenerating) {
            _stopPolling(id);
            await loadQueue();
          } else {
            final startedAt = _pollStartedAt[id];
            if (startedAt == null) return;
            final maximum = provider.value == 'ollama'
                ? ollamaPollLimit
                : cloudPollLimit;
            if (DateTime.now().difference(startedAt) >= maximum) {
              _stopPolling(id);
            }
          }
        } on ApiFailure catch (failure) {
          actionState.value = Failure<void>(failure);
          lastErrorCode.value = failure.code ?? '';
        } finally {
          _pollingRequests.remove(id);
        }
      }());
    });
  }

  void _stopPolling(int id) {
    _polls.remove(id)?.cancel();
    _pollStartedAt.remove(id);
  }

  @override
  void onClose() {
    for (final timer in _polls.values) {
      timer.cancel();
    }
    _polls.clear();
    if (_createdSubscription != null) {
      unawaited(_createdSubscription!.cancel());
    }
    if (_updatedSubscription != null) {
      unawaited(_updatedSubscription!.cancel());
    }
    super.onClose();
  }
}

class AiEngineController extends GetxController {
  AiEngineController({required this.repository});

  final AiRepository repository;
  final Rx<UiState<AiEngineStatus>> status = Rx<UiState<AiEngineStatus>>(
    const Idle(),
  );
  final Rx<UiState<AiTestResult>> testState = Rx<UiState<AiTestResult>>(
    const Idle(),
  );

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    status.value = const Loading();
    try {
      final engine = await repository.engineStatus();
      status.value = Success(engine);
      if (Get.isRegistered<AiSuggestionController>()) {
        Get.find<AiSuggestionController>().setProvider(engine.provider);
      }
    } on ApiFailure catch (failure) {
      status.value = Failure(failure);
    }
  }

  Future<void> testEngine({String? prompt}) async {
    testState.value = const Loading();
    try {
      testState.value = Success(await repository.testEngine(prompt: prompt));
    } on ApiFailure catch (failure) {
      testState.value = Failure(failure);
    }
  }
}
