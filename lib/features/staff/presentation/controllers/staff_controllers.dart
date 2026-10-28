// ignore_for_file: cancel_subscriptions

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_repository.dart';

class StaffInboxController extends GetxController {
  StaffInboxController({required this.repository, required this.socket});
  final StaffRepository repository;
  final SocketService socket;
  final Rx<UiState<List<StaffConversation>>> state =
      Rx<UiState<List<StaffConversation>>>(const Idle());
  final Rx<UiState<List<StaffMessage>>> messagesState =
      Rx<UiState<List<StaffMessage>>>(const Idle());
  final Rxn<StaffConversation> selected = Rxn<StaffConversation>();
  final RxString filter = 'all'.obs;
  final RxString statusFilter = ''.obs;
  final RxBool internalNote = false.obs;
  final RxBool showAiQueue = false.obs;
  final TextEditingController messageText = TextEditingController();
  final RxBool hasOlderMessages = false.obs;
  final RxBool loadingOlder = false.obs;
  final RxBool hasMoreConversations = false.obs;
  final RxBool loadingMoreConversations = false.obs;
  int _conversationPage = 1;
  int _olderPage = 0;
  static const messageLimit = 50;
  StreamSubscription<Map<String, dynamic>>? _messages;
  StreamSubscription<Map<String, dynamic>>? _assigned;
  StreamSubscription<Map<String, dynamic>>? _escalated;

  @override
  void onInit() {
    super.onInit();
    _messages = socket.messageNew.listen(_onMessage);
    _assigned = socket.conversationAssigned.listen(_onConversationChange);
    _escalated = socket.conversationEscalated.listen(_onConversationChange);
    unawaited(load());
    final conversationId = int.tryParse(Get.parameters['conversationId'] ?? '');
    if (conversationId != null) unawaited(open(conversationId));
  }

  Future<void> setFilter(String value) async {
    filter.value = value;
    await load();
  }

  Future<void> setStatus(String value) async {
    statusFilter.value = value;
    await load();
  }

  Future<void> load() async {
    state.value = const Loading();
    try {
      final page = await repository.conversations(
        page: 1,
        limit: 20,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
        unassigned: filter.value == 'unassigned' ? true : null,
        mine: filter.value == 'mine' ? true : null,
        escalated: filter.value == 'escalated' ? true : null,
      );
      _conversationPage = page.page;
      hasMoreConversations.value = page.hasMore;
      state.value = Success(page.items);
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }

  Future<void> loadMoreConversations() async {
    final current = state.value;
    if (loadingMoreConversations.value ||
        !hasMoreConversations.value ||
        current is! Success<List<StaffConversation>>) {
      return;
    }
    loadingMoreConversations.value = true;
    try {
      final page = await repository.conversations(
        page: _conversationPage + 1,
        limit: 20,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
        unassigned: filter.value == 'unassigned' ? true : null,
        mine: filter.value == 'mine' ? true : null,
        escalated: filter.value == 'escalated' ? true : null,
      );
      _conversationPage = page.page;
      hasMoreConversations.value = page.hasMore;
      state.value = Success([...current.data, ...page.items]);
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    } finally {
      loadingMoreConversations.value = false;
    }
  }

  Future<void> open(int id) async {
    messagesState.value = const Loading();
    try {
      selected.value = await repository.conversation(id);
      final first = await repository.messages(id, 1, messageLimit);
      final lastPage = first.total == 0
          ? 0
          : (first.total / messageLimit).ceil();
      final latest = lastPage > 1
          ? await repository.messages(id, lastPage, messageLimit)
          : first;
      _olderPage = lastPage - 1;
      hasOlderMessages.value = _olderPage >= 1;
      messagesState.value = Success(latest.items);
    } on ApiFailure catch (failure) {
      messagesState.value = Failure(failure);
    }
  }

  Future<void> loadOlder() async {
    if (loadingOlder.value ||
        !hasOlderMessages.value ||
        selected.value == null) {
      return;
    }
    loadingOlder.value = true;
    try {
      final page = await repository.messages(
        selected.value!.id,
        _olderPage,
        messageLimit,
      );
      final current = messagesState.value;
      if (current is Success<List<StaffMessage>>) {
        messagesState.value = Success([...page.items, ...current.data]);
      }
      _olderPage--;
      hasOlderMessages.value = _olderPage >= 1;
    } on ApiFailure catch (failure) {
      messagesState.value = Failure(failure);
    } finally {
      loadingOlder.value = false;
    }
  }

  Future<bool> send(String content) async {
    final conversation = selected.value;
    if (conversation == null || content.trim().isEmpty) return false;
    try {
      final message = await repository.sendMessage(
        conversation.id,
        content,
        internalNote.value,
      );
      final current = messagesState.value;
      if (current is Success<List<StaffMessage>>) {
        messagesState.value = Success([...current.data, message]);
      } else {
        messagesState.value = Success([message]);
      }
      return true;
    } on ApiFailure catch (failure) {
      messagesState.value = Failure(failure);
      return false;
    }
  }

  Future<void> assign({int? agentId}) async {
    final id = selected.value?.id;
    if (id == null) return;
    try {
      await repository.assign(id, agentId: agentId);
      await open(id);
      await load();
    } on ApiFailure catch (failure) {
      messagesState.value = Failure(failure);
    }
  }

  Future<void> escalate(String reason) async {
    final id = selected.value?.id;
    if (id == null || reason.trim().isEmpty) return;
    try {
      await repository.escalate(id, reason);
      await open(id);
      await load();
    } on ApiFailure catch (failure) {
      messagesState.value = Failure(failure);
    }
  }

  Future<void> closeConversation() async {
    final id = selected.value?.id;
    if (id == null) return;
    try {
      await repository.closeConversation(id);
      await open(id);
      await load();
    } on ApiFailure catch (failure) {
      messagesState.value = Failure(failure);
    }
  }

  void _onMessage(Map<String, dynamic> payload) {
    final nested = payload['message'];
    final conversationId =
        payload['conversationId'] ??
        (nested is Map ? nested['conversationId'] : null);
    if (conversationId is int && conversationId == selected.value?.id) {
      unawaited(open(conversationId));
    }
    unawaited(load());
  }

  void _onConversationChange(Map<String, dynamic> payload) {
    final conversation = payload['conversation'];
    final id =
        payload['id'] ?? (conversation is Map ? conversation['id'] : null);
    if (id is int && id == selected.value?.id) unawaited(open(id));
    unawaited(load());
  }

  @override
  void onClose() {
    if (_messages != null) unawaited(_messages!.cancel());
    if (_assigned != null) unawaited(_assigned!.cancel());
    if (_escalated != null) unawaited(_escalated!.cancel());
    messageText.dispose();
    super.onClose();
  }
}

class StaffLotsController extends GetxController {
  StaffLotsController({required this.repository});
  final StaffRepository repository;
  final Rx<UiState<List<StaffLot>>> state = Rx<UiState<List<StaffLot>>>(
    const Idle(),
  );
  final Rxn<StaffLot> selected = Rxn<StaffLot>();
  final RxList<Map<String, Object?>> qualityHistory =
      <Map<String, Object?>>[].obs;
  final Rx<UiState<List<Map<String, Object?>>>> movementState =
      Rx<UiState<List<Map<String, Object?>>>>(const Idle());
  final RxString statusFilter = ''.obs;
  final RxString supplierIdFilter = ''.obs;
  final RxString productIdFilter = ''.obs;
  final RxBool hasMoreLots = false.obs;
  final RxBool loadingMoreLots = false.obs;
  final RxBool hasMoreMovements = false.obs;
  final RxBool loadingMoreMovements = false.obs;
  int _lotPage = 1;
  int _movementPage = 1;

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    state.value = const Loading();
    try {
      final page = await repository.lots(
        page: 1,
        limit: 20,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
        supplierId: int.tryParse(supplierIdFilter.value),
        productId: int.tryParse(productIdFilter.value),
      );
      _lotPage = page.page;
      hasMoreLots.value = page.hasMore;
      state.value = Success(page.items);
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }

  Future<void> setFilters({
    String? status,
    String? supplierId,
    String? productId,
  }) async {
    if (status != null) statusFilter.value = status;
    if (supplierId != null) supplierIdFilter.value = supplierId;
    if (productId != null) productIdFilter.value = productId;
    await load();
  }

  Future<void> loadMoreLots() async {
    final current = state.value;
    if (loadingMoreLots.value ||
        !hasMoreLots.value ||
        current is! Success<List<StaffLot>>) {
      return;
    }
    loadingMoreLots.value = true;
    try {
      final page = await repository.lots(
        page: _lotPage + 1,
        limit: 20,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
        supplierId: int.tryParse(supplierIdFilter.value),
        productId: int.tryParse(productIdFilter.value),
      );
      _lotPage = page.page;
      hasMoreLots.value = page.hasMore;
      state.value = Success([...current.data, ...page.items]);
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    } finally {
      loadingMoreLots.value = false;
    }
  }

  Future<void> open(int id) async {
    try {
      selected.value = await repository.lot(id);
      qualityHistory.clear();
      _movementPage = 1;
      qualityHistory.assignAll(await repository.qualityChecks(id));
      movementState.value = const Loading();
      final movements = await repository.stockMovements(id, page: 1, limit: 20);
      _movementPage = movements.page;
      hasMoreMovements.value = movements.hasMore;
      movementState.value = Success(movements.items);
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
      movementState.value = Failure(failure);
    }
  }

  Future<void> loadMoreMovements() async {
    final lotId = selected.value?.lot.id;
    final current = movementState.value;
    if (lotId == null ||
        loadingMoreMovements.value ||
        !hasMoreMovements.value ||
        current is! Success<List<Map<String, Object?>>>) {
      return;
    }
    loadingMoreMovements.value = true;
    try {
      final page = await repository.stockMovements(
        lotId,
        page: _movementPage + 1,
        limit: 20,
      );
      _movementPage = page.page;
      hasMoreMovements.value = page.hasMore;
      movementState.value = Success([...current.data, ...page.items]);
    } on ApiFailure catch (failure) {
      movementState.value = Failure(failure);
    } finally {
      loadingMoreMovements.value = false;
    }
  }

  Future<ApiFailure?> _action(Future<void> Function() action) async {
    try {
      await action();
      if (selected.value != null) await open(selected.value!.lot.id);
      await load();
      return null;
    } on ApiFailure catch (failure) {
      return failure;
    }
  }

  Future<ApiFailure?> validate() {
    final lot = selected.value?.lot;
    return lot == null
        ? Future.value(null)
        : _action(() => repository.validateLot(lot.id));
  }

  Future<ApiFailure?> reject(String reason) {
    final lot = selected.value?.lot;
    return lot == null
        ? Future.value(null)
        : _action(() => repository.rejectLot(lot.id, reason));
  }

  Future<ApiFailure?> returnLot(String reason) {
    final lot = selected.value?.lot;
    return lot == null
        ? Future.value(null)
        : _action(() => repository.returnLot(lot.id, reason));
  }

  Future<ApiFailure?> qualityCheck(String grade, String? notes) {
    final lot = selected.value?.lot;
    return lot == null
        ? Future.value(null)
        : _action(() => repository.qualityCheck(lot.id, grade, notes));
  }
}

class StaffListingsController extends GetxController {
  StaffListingsController({required this.repository});
  final StaffRepository repository;
  final Rx<UiState<List<StaffListing>>> state = Rx<UiState<List<StaffListing>>>(
    const Idle(),
  );
  final Rxn<StaffListing> selected = Rxn<StaffListing>();
  final RxString statusFilter = ''.obs;
  final RxString supplierIdFilter = ''.obs;
  final RxString productIdFilter = ''.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadingMore = false.obs;
  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    state.value = const Loading();
    try {
      final result = await repository.listings(
        page: 1,
        limit: 20,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
        supplierId: int.tryParse(supplierIdFilter.value),
        productId: int.tryParse(productIdFilter.value),
      );
      _page = result.page;
      hasMore.value = result.hasMore;
      state.value = Success(result.items);
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }

  Future<void> setFilters({
    String? status,
    String? supplierId,
    String? productId,
  }) async {
    if (status != null) statusFilter.value = status;
    if (supplierId != null) supplierIdFilter.value = supplierId;
    if (productId != null) productIdFilter.value = productId;
    await load();
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (loadingMore.value ||
        !hasMore.value ||
        current is! Success<List<StaffListing>>) {
      return;
    }
    loadingMore.value = true;
    try {
      final result = await repository.listings(
        page: _page + 1,
        limit: 20,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
        supplierId: int.tryParse(supplierIdFilter.value),
        productId: int.tryParse(productIdFilter.value),
      );
      _page = result.page;
      hasMore.value = result.hasMore;
      state.value = Success([...current.data, ...result.items]);
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    } finally {
      loadingMore.value = false;
    }
  }

  Future<ApiFailure?> changePublication(StaffListing listing) async {
    try {
      if (listing.status == 'ACTIVE') {
        await repository.unpublishListing(listing.id);
      } else {
        await repository.publishListing(listing.id);
      }
      await load();
      if (selected.value?.id == listing.id) {
        selected.value = await repository.listing(listing.id);
      }
      return null;
    } on ApiFailure catch (failure) {
      return failure;
    }
  }

  Future<void> open(int id) async {
    try {
      selected.value = await repository.listing(id);
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }

  Future<ApiFailure?> createListing(
    int lotId,
    String title,
    String? description,
    List<String> imagePaths,
  ) async {
    try {
      await repository.createListing(lotId, title, description, imagePaths);
      await load();
      return null;
    } on ApiFailure catch (failure) {
      return failure;
    }
  }

  Future<ApiFailure?> updateListing(int id, Map<String, Object?> fields) async {
    try {
      await repository.updateListing(id, fields);
      await load();
      if (selected.value?.id == id) {
        selected.value = await repository.listing(id);
      }
      return null;
    } on ApiFailure catch (failure) {
      return failure;
    }
  }
}
