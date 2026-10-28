// ignore_for_file: cancel_subscriptions

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_repository.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_repository.dart';
import 'package:agri_connect/shared/domain/order_status.dart';

class StaffOrdersController extends GetxController {
  StaffOrdersController({
    required this.repository,
    required this.staffRepository,
    required this.referenceRepository,
    required this.user,
    this.socket,
  });

  final StaffWorkflowRepository repository;
  final StaffRepository staffRepository;
  final ReferenceRepository referenceRepository;
  final AuthUser user;
  final SocketService? socket;

  final Rx<UiState<List<StaffOrder>>> state = Rx<UiState<List<StaffOrder>>>(
    const Idle(),
  );
  final Rx<UiState<StaffOrder>> detailState = Rx<UiState<StaffOrder>>(
    const Idle(),
  );
  final Rx<UiState<List<StaffPayment>>> paymentsState =
      Rx<UiState<List<StaffPayment>>>(const Idle());
  final Rx<UiState<List<StaffDelivery>>> deliveriesState =
      Rx<UiState<List<StaffDelivery>>>(const Idle());
  final Rx<UiState<List<StaffListing>>> activeListingsState =
      Rx<UiState<List<StaffListing>>>(const Idle());
  final Rxn<StaffOrder> selected = Rxn<StaffOrder>();
  final Rxn<ApiFailure> actionFailure = Rxn<ApiFailure>();
  final Rxn<ApiFailure> quoteMessageFailure = Rxn<ApiFailure>();
  final RxBool submitting = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasMoreDeliveries = false.obs;
  final RxBool loadingMoreDeliveries = false.obs;
  final RxString deliveryStatusFilter = ''.obs;
  final RxString deliveryStatus = ''.obs;
  final RxBool deliveryAvailable = false.obs;
  final Rx<DateTime> clock = DateTime.now().obs;
  int _page = 1;
  int _deliveryPage = 1;
  Timer? _countdownTimer;
  String? _paymentIdempotencyKey;
  StreamSubscription<Map<String, dynamic>>? _deliveryStatuses;
  StreamSubscription<Map<String, dynamic>>? _deliveryAvailability;

  bool get canRefund =>
      user.role == RoleCode.admin || user.role == RoleCode.root;
  bool get canProcessOrders => user.can(AgentCapability.orderProcessing);
  bool get canFollowPayments =>
      user.can(AgentCapability.paymentFollowup) &&
      !(user.agent?.kind?.toUpperCase() == 'AI' ||
          user.agent?.autonomy?.toUpperCase() == 'AUTONOMOUS');
  bool get canDispatch => user.can(AgentCapability.dispatchCoordination);
  bool get canCompensate => user.can(AgentCapability.disputeHandling);

  static const Map<OrderStatus, Set<OrderStatus>> manualTransitions = {
    OrderStatus.quoted: {OrderStatus.confirmed, OrderStatus.cancelled},
    OrderStatus.confirmed: {OrderStatus.preparing, OrderStatus.cancelled},
    OrderStatus.preparing: {OrderStatus.readyForPickup, OrderStatus.cancelled},
    OrderStatus.readyForPickup: {OrderStatus.completed},
    OrderStatus.outForDelivery: {OrderStatus.completed},
    OrderStatus.completed: {},
    OrderStatus.cancelled: {},
  };

  static bool canTransition(OrderStatus from, OrderStatus to) =>
      manualTransitions[from]?.contains(to) == true &&
      to != OrderStatus.outForDelivery;

  @override
  void onInit() {
    super.onInit();
    final realtime = socket;
    if (realtime != null) {
      _deliveryStatuses = realtime.deliveryStatus.listen(_onDeliveryStatus);
      _deliveryAvailability = realtime.deliveryAvailable.listen(
        _onDeliveryAvailable,
      );
    }
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => clock.value = DateTime.now(),
    );
    unawaited(load());
  }

  Future<void> load() async {
    state.value = const Loading();
    try {
      final result = await repository.orders(page: 1, limit: 20);
      _page = result.page;
      hasMore.value = result.hasMore;
      state.value = Success(result.items);
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (loadingMore.value ||
        !hasMore.value ||
        current is! Success<List<StaffOrder>>) {
      return;
    }
    loadingMore.value = true;
    try {
      final result = await repository.orders(page: _page + 1, limit: 20);
      _page = result.page;
      hasMore.value = result.hasMore;
      state.value = Success([...current.data, ...result.items]);
    } on ApiFailure catch (failure) {
      state.value = Failure(failure);
    } finally {
      loadingMore.value = false;
    }
  }

  Future<void> open(int id) async {
    detailState.value = const Loading();
    try {
      final order = await repository.order(id);
      selected.value = order;
      deliveryStatus.value = order.deliveryStatus ?? '';
      deliveryAvailable.value =
          order.deliveryAvailable ?? order.deliveryStatus == 'PENDING';
      detailState.value = Success(order);
      await Future.wait([loadPayments(id), loadDeliveries(id)]);
    } on ApiFailure catch (failure) {
      detailState.value = Failure(failure);
    }
  }

  Future<void> loadPayments(int orderId) async {
    paymentsState.value = const Loading();
    try {
      paymentsState.value = Success(await repository.payments(orderId));
    } on ApiFailure catch (failure) {
      paymentsState.value = Failure(failure);
    }
  }

  Future<void> loadDeliveries(int orderId) async {
    deliveriesState.value = const Loading();
    try {
      final page = await repository.deliveries(
        orderId: orderId,
        page: 1,
        limit: 20,
        status: deliveryStatusFilter.value.isEmpty
            ? null
            : deliveryStatusFilter.value,
      );
      _deliveryPage = page.page;
      hasMoreDeliveries.value = page.hasMore;
      deliveriesState.value = Success(page.items);
      if (page.items.isNotEmpty) {
        deliveryStatus.value = page.items.first.status;
        deliveryAvailable.value = page.items.any(
          (delivery) => delivery.status == 'PENDING',
        );
      }
    } on ApiFailure catch (failure) {
      deliveriesState.value = Failure(failure);
    }
  }

  Future<void> setDeliveryStatus(String status) async {
    deliveryStatusFilter.value = status;
    final orderId = selected.value?.id;
    if (orderId != null) await loadDeliveries(orderId);
  }

  Future<void> loadMoreDeliveries() async {
    final orderId = selected.value?.id;
    final current = deliveriesState.value;
    if (orderId == null ||
        loadingMoreDeliveries.value ||
        !hasMoreDeliveries.value ||
        current is! Success<List<StaffDelivery>>) {
      return;
    }
    loadingMoreDeliveries.value = true;
    try {
      final page = await repository.deliveries(
        orderId: orderId,
        page: _deliveryPage + 1,
        limit: 20,
        status: deliveryStatusFilter.value.isEmpty
            ? null
            : deliveryStatusFilter.value,
      );
      _deliveryPage = page.page;
      hasMoreDeliveries.value = page.hasMore;
      deliveriesState.value = Success([...current.data, ...page.items]);
    } on ApiFailure catch (failure) {
      deliveriesState.value = Failure(failure);
    } finally {
      loadingMoreDeliveries.value = false;
    }
  }

  Future<void> loadActiveListings() async {
    activeListingsState.value = const Loading();
    try {
      final listings = <StaffListing>[];
      var page = await staffRepository.listings(
        page: 1,
        limit: 100,
        status: 'ACTIVE',
      );
      listings.addAll(
        page.items.where((listing) => listing.status == 'ACTIVE'),
      );
      while (page.hasMore) {
        page = await staffRepository.listings(
          page: page.page + 1,
          limit: 100,
          status: 'ACTIVE',
        );
        listings.addAll(
          page.items.where((listing) => listing.status == 'ACTIVE'),
        );
      }
      activeListingsState.value = Success(List.unmodifiable(listings));
    } on ApiFailure catch (failure) {
      activeListingsState.value = Failure(failure);
    }
  }

  Future<StaffOrder?> createQuote(
    Map<String, Object?> body, {
    required String Function(StaffOrder) quoteMessage,
  }) async {
    submitting.value = true;
    actionFailure.value = null;
    quoteMessageFailure.value = null;
    try {
      final order = await repository.createOrder(body);
      final message = quoteMessage(order);
      final conversationId =
          order.conversationId ?? body['conversationId'] as int?;
      if (conversationId != null && message.trim().isNotEmpty) {
        try {
          await staffRepository.sendMessage(
            conversationId,
            message.trim(),
            false,
          );
        } on ApiFailure catch (failure) {
          quoteMessageFailure.value = failure;
        }
      }
      await load();
      return order;
    } on ApiFailure catch (failure) {
      actionFailure.value = failure;
      return null;
    } finally {
      submitting.value = false;
    }
  }

  Future<ApiFailure?> confirm() async {
    final order = selected.value;
    if (order == null || !canTransition(order.status, OrderStatus.confirmed)) {
      return null;
    }
    try {
      await repository.confirmOrder(order.id);
      await open(order.id);
      await load();
      return null;
    } on ApiFailure catch (failure) {
      if (failure.status == 409) await open(order.id);
      return failure;
    }
  }

  Future<ApiFailure?> changeStatus(OrderStatus next) async {
    final order = selected.value;
    if (order == null || !canTransition(order.status, next)) return null;
    try {
      if (next == OrderStatus.cancelled) {
        await repository.cancelOrder(order.id);
      } else {
        await repository.changeOrderStatus(order.id, next.apiValue);
      }
      await open(order.id);
      await load();
      return null;
    } on ApiFailure catch (failure) {
      if (failure.status == 409) await open(order.id);
      return failure;
    }
  }

  String get paymentIdempotencyKey =>
      _paymentIdempotencyKey ??= const Uuid().v4();

  Future<ApiFailure?> recordPayment(
    int orderId, {
    required double amount,
    required String method,
    String? reference,
  }) async {
    final key = paymentIdempotencyKey;
    final body = <String, Object?>{
      'amount': amount,
      'method': method,
      if (reference?.trim().isNotEmpty == true) 'reference': reference!.trim(),
    };
    try {
      await repository.recordPayment(orderId, body, key);
      _paymentIdempotencyKey = null;
      await loadPayments(orderId);
      await open(orderId);
      return null;
    } on ApiFailure catch (failure) {
      if (failure.status == 409 && failure.code != 'INVALID_AMOUNT') {
        _paymentIdempotencyKey = null;
        await loadPayments(orderId);
        await open(orderId);
        return null;
      }
      if (failure.status != null) _paymentIdempotencyKey = null;
      return failure;
    }
  }

  Future<ApiFailure?> refund(int paymentId) async {
    if (!canRefund) return null;
    try {
      await repository.refundPayment(paymentId);
      final orderId = selected.value?.id;
      if (orderId != null) await loadPayments(orderId);
      return null;
    } on ApiFailure catch (failure) {
      return failure;
    }
  }

  Future<ApiFailure?> createDeliveries() async {
    final order = selected.value;
    if (order == null) return null;
    try {
      await repository.createDeliveries(order.id);
      await open(order.id);
      return null;
    } on ApiFailure catch (failure) {
      return failure;
    }
  }

  Future<ApiFailure?> deliveryAction(
    StaffDelivery delivery,
    String action, {
    String? reason,
  }) async {
    try {
      switch (action) {
        case 'release':
          await repository.releaseDelivery(delivery.id, reason: reason);
        case 'redispatch':
          await repository.redispatchDelivery(delivery.id);
        case 'cancel':
          if (reason?.trim().isEmpty != false) return null;
          await repository.cancelDelivery(delivery.id, reason!.trim());
      }
      await loadDeliveries(delivery.orderId);
      return null;
    } on ApiFailure catch (failure) {
      return failure;
    }
  }

  Future<ApiFailure?> compensate({
    required int lotId,
    required String reason,
    required double quantity,
    int? deliveryId,
    String? note,
  }) async {
    try {
      await repository.createCompensation({
        'lotId': lotId,
        'reason': reason,
        'quantity': quantity,
        'deliveryId': ?deliveryId,
        'note': ?(note?.trim().isNotEmpty == true ? note!.trim() : null),
      });
      return null;
    } on ApiFailure catch (failure) {
      return failure;
    }
  }

  void _onDeliveryStatus(Map<String, dynamic> payload) {
    final delivery = payload['delivery'];
    final nested = delivery is Map ? delivery : payload;
    final orderId = nested['orderId'];
    final deliveryId = nested['id'];
    final current = deliveriesState.value;
    final knownDelivery =
        current is Success<List<StaffDelivery>> &&
        current.data.any((item) => item.id == deliveryId);
    if ((orderId is num && orderId.toInt() == selected.value?.id) ||
        knownDelivery) {
      final status = nested['status'];
      if (status is String) deliveryStatus.value = status;
      deliveryAvailable.value = status == 'PENDING';
      final selectedOrderId = orderId is num
          ? orderId.toInt()
          : selected.value?.id;
      if (selectedOrderId != null) unawaited(open(selectedOrderId));
    }
  }

  void _onDeliveryAvailable(Map<String, dynamic> payload) {
    final delivery = payload['delivery'];
    final nested = delivery is Map ? delivery : payload;
    final orderId = nested['orderId'];
    final deliveryId = nested['id'];
    final current = deliveriesState.value;
    final knownDelivery =
        current is Success<List<StaffDelivery>> &&
        current.data.any((item) => item.id == deliveryId);
    if ((orderId is num && orderId.toInt() == selected.value?.id) ||
        knownDelivery) {
      deliveryAvailable.value = true;
      final status = nested['status'];
      if (status is String) deliveryStatus.value = status;
      final selectedOrderId = orderId is num
          ? orderId.toInt()
          : selected.value?.id;
      if (selectedOrderId != null) unawaited(loadDeliveries(selectedOrderId));
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    if (_deliveryStatuses != null) unawaited(_deliveryStatuses!.cancel());
    if (_deliveryAvailability != null) {
      unawaited(_deliveryAvailability!.cancel());
    }
    super.onClose();
  }
}

class StaffVerificationsController extends GetxController {
  StaffVerificationsController({required this.repository});
  final StaffWorkflowRepository repository;

  final Rx<UiState<List<StaffVerification>>> state =
      Rx<UiState<List<StaffVerification>>>(const Idle());
  final Rx<UiState<StaffVerificationDetail>> detailState =
      Rx<UiState<StaffVerificationDetail>>(const Idle());
  final RxList<int> documentBytes = <int>[].obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool submittingDecision = false.obs;
  final Rxn<ApiFailure> actionFailure = Rxn<ApiFailure>();
  final RxString statusFilter = 'PENDING'.obs;
  final RxString typeFilter = ''.obs;
  final RxString roleFilter = ''.obs;
  final RxString userIdFilter = ''.obs;
  final Set<String> _temporaryFiles = {};
  int _page = 1;
  int? selectedId;

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    state.value = const Loading();
    try {
      final result = await repository.verifications(
        page: 1,
        limit: 20,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
        type: typeFilter.value.isEmpty ? null : typeFilter.value,
        role: roleFilter.value.isEmpty ? null : roleFilter.value,
        userId: int.tryParse(userIdFilter.value),
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
    String? type,
    String? role,
    String? userId,
  }) async {
    if (status != null) statusFilter.value = status;
    if (type != null) typeFilter.value = type;
    if (role != null) roleFilter.value = role;
    if (userId != null) userIdFilter.value = userId;
    await load();
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (loadingMore.value ||
        !hasMore.value ||
        current is! Success<List<StaffVerification>>) {
      return;
    }
    loadingMore.value = true;
    try {
      final result = await repository.verifications(
        page: _page + 1,
        limit: 20,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
        type: typeFilter.value.isEmpty ? null : typeFilter.value,
        role: roleFilter.value.isEmpty ? null : roleFilter.value,
        userId: int.tryParse(userIdFilter.value),
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

  Future<void> open(int id) async {
    selectedId = id;
    detailState.value = const Loading();
    documentBytes.clear();
    try {
      final response = await repository.verification(id);
      final current = state.value;
      final queueItem = current is Success<List<StaffVerification>>
          ? current.data.where((item) => item.id == id).firstOrNull
          : null;
      final detail = StaffVerificationDetail(
        id: response.id,
        type: response.type,
        status: response.status,
        user: response.user.isEmpty && queueItem != null
            ? queueItem.user
            : response.user,
        media: response.media.isEmpty && queueItem != null
            ? queueItem.media
            : response.media,
        note: response.note,
        createdAt: response.createdAt,
        signedUrl: response.signedUrl,
      );
      detailState.value = Success(detail);
      if (detail.signedUrl != null && detail.mimeType.startsWith('image/')) {
        documentBytes.assignAll(
          await repository.verificationBytes(detail.signedUrl!),
        );
      }
    } on ApiFailure catch (failure) {
      detailState.value = Failure(failure);
    }
  }

  Future<ApiFailure?> openPdf() async {
    final id = selectedId;
    if (id == null) return null;
    try {
      final detail = await repository.verification(id);
      if (detail.signedUrl == null) {
        return const ApiFailure(
          status: 404,
          code: 'FILE_MISSING',
          message: 'FILE_MISSING',
          fieldErrors: {},
          kind: ApiFailureKind.client,
        );
      }
      final bytes = await repository.verificationBytes(detail.signedUrl!);
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}${Platform.pathSeparator}agriconnect-review-${const Uuid().v4()}.pdf',
      );
      _temporaryFiles.add(file.path);
      await file.writeAsBytes(bytes, flush: true);
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        await _deleteTemporary(file.path);
        _temporaryFiles.remove(file.path);
        return const ApiFailure(
          status: null,
          code: 'PRIVATE_FILE_OPEN_FAILED',
          message: 'PRIVATE_FILE_OPEN_FAILED',
          fieldErrors: {},
          kind: ApiFailureKind.client,
        );
      }
      return null;
    } on ApiFailure catch (failure) {
      return failure;
    } on FileSystemException {
      return const ApiFailure(
        status: null,
        code: 'PRIVATE_FILE_OPEN_FAILED',
        message: 'PRIVATE_FILE_OPEN_FAILED',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
    }
  }

  Future<ApiFailure?> decide({required String decision, String? note}) async {
    final id = selectedId;
    final trimmedNote = note?.trim();
    if (id == null ||
        (decision == 'REJECT' &&
            (trimmedNote == null || trimmedNote.isEmpty)) ||
        (trimmedNote?.length ?? 0) > 2000) {
      return const ApiFailure(
        status: 400,
        code: 'INVALID_DECISION_NOTE',
        message: 'INVALID_DECISION_NOTE',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
    }
    submittingDecision.value = true;
    actionFailure.value = null;
    try {
      await repository.decideVerification(
        id,
        decision: decision,
        note: trimmedNote,
      );
      selectedId = null;
      detailState.value = const Idle();
      await load();
      return null;
    } on ApiFailure catch (failure) {
      actionFailure.value = failure;
      if (failure.status == 409) {
        selectedId = null;
        detailState.value = const Idle();
        await load();
      }
      return failure;
    } finally {
      submittingDecision.value = false;
    }
  }

  @override
  void onClose() {
    for (final path in _temporaryFiles) {
      unawaited(_deleteTemporary(path));
    }
    super.onClose();
  }

  Future<void> _deleteTemporary(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'secure document cleanup',
        ),
      );
    }
  }
}
