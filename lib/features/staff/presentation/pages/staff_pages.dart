import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/state_views.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_controllers.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_workflow_controllers.dart';
import 'package:agri_connect/features/staff/presentation/pages/staff_workflow_pages.dart';
import 'package:agri_connect/features/supplier/domain/supplier_entities.dart';
import 'package:agri_connect/shared/widgets/role_shell.dart';

enum StaffSection { support, stock, listings, orders, verifications, account }

List<StaffSection> visibleStaffSections(AuthUser? user) {
  if (user == null) return const [StaffSection.account];
  final sections = <StaffSection>[];
  if (user.canAny({
    AgentCapability.buyerSupport,
    AgentCapability.supplierSupport,
  })) {
    sections.add(StaffSection.support);
  }
  if (user.can(AgentCapability.stockValidation)) {
    sections.add(StaffSection.stock);
  }
  if (user.can(AgentCapability.listingManagement)) {
    sections.add(StaffSection.listings);
  }
  if (user.canAny({
    AgentCapability.orderProcessing,
    AgentCapability.paymentFollowup,
    AgentCapability.dispatchCoordination,
    AgentCapability.disputeHandling,
  })) {
    sections.add(StaffSection.orders);
  }
  if (user.can(AgentCapability.userVerification)) {
    sections.add(StaffSection.verifications);
  }
  sections.add(StaffSection.account);
  return List.unmodifiable(sections);
}

class StaffShellPage extends StatelessWidget {
  const StaffShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().currentUser;
    final labels = AppLocalizations.of(context);
    final tabs = <ShellTab>[];
    for (final section in visibleStaffSections(user)) {
      tabs.add(switch (section) {
        StaffSection.support => ShellTab(
          icon: Icons.support_agent,
          label: labels.staffSupport,
          page: (_) => const StaffInboxPanel(),
          route: AppRoutes.staffConversations,
        ),
        StaffSection.stock => ShellTab(
          icon: Icons.inventory_2_outlined,
          label: labels.staffStock,
          page: (_) => const StaffLotsPanel(),
          route: AppRoutes.staffLots,
        ),
        StaffSection.listings => ShellTab(
          icon: Icons.campaign_outlined,
          label: labels.staffListings,
          page: (_) => const StaffListingsPanel(),
          route: AppRoutes.staffListings,
        ),
        StaffSection.orders => ShellTab(
          icon: Icons.shopping_bag_outlined,
          label: labels.staffOrders,
          page: (_) => const StaffOrdersPanel(),
        ),
        StaffSection.verifications => ShellTab(
          icon: Icons.verified_user_outlined,
          label: labels.staffVerifications,
          page: (_) => const StaffVerificationsPanel(),
        ),
        StaffSection.account => ShellTab(
          icon: Icons.person_outline,
          label: labels.staffAccount,
          page: (_) => const _StaffAccountPanel(),
        ),
      });
    }
    return RoleShell(title: 'AgriConnect', tabs: tabs);
  }
}

class _StaffAccountPanel extends StatelessWidget {
  const _StaffAccountPanel();
  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final user = Get.find<AuthController>().currentUser;
    final hasCapability =
        user?.role == RoleCode.admin ||
        user?.role == RoleCode.root ||
        user?.agent?.capabilities.isNotEmpty == true;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hasCapability) ...[
            const Icon(Icons.lock_outline, size: 40),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                labels.staffNoCapabilities,
                textAlign: TextAlign.center,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.profile),
              child: Text(labels.staffHelpAdmin),
            ),
          ] else
            Text('${user?.firstname ?? ''} ${user?.lastname ?? ''}'.trim()),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            child: Text(labels.staffAccount),
          ),
        ],
      ),
    );
  }
}

class StaffInboxPage extends StatelessWidget {
  const StaffInboxPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: _StaffAppBar(titleKey: _StaffTitle.support),
    body: StaffInboxPanel(),
  );
}

class StaffLotsPage extends StatelessWidget {
  const StaffLotsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: _StaffAppBar(titleKey: _StaffTitle.stock),
    body: StaffLotsPanel(),
  );
}

class StaffListingsPage extends StatelessWidget {
  const StaffListingsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: _StaffAppBar(titleKey: _StaffTitle.listings),
    body: StaffListingsPanel(),
  );
}

enum _StaffTitle { support, stock, listings }

class _StaffAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _StaffAppBar({required this.titleKey});
  final _StaffTitle titleKey;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return AppBar(
      title: Text(switch (titleKey) {
        _StaffTitle.support => labels.staffSupport,
        _StaffTitle.stock => labels.staffStock,
        _StaffTitle.listings => labels.staffListings,
      }),
    );
  }
}

class StaffInboxPanel extends GetView<StaffInboxController> {
  const StaffInboxPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final filters = {
      'all': labels.staffInboxAll,
      'unassigned': labels.staffInboxUnassigned,
      'mine': labels.staffInboxMine,
      'escalated': labels.staffInboxEscalated,
    };
    return Obx(() {
      final current = controller.state.value;
      if (current is Loading<List<StaffConversation>>) {
        return const LoadingView();
      }
      if (current is Failure<List<StaffConversation>>) {
        return current.failure.status == 403
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    labels.staffSupportTypeDenied,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ErrorView(failure: current.failure, onRetry: controller.load);
      }
      final items = current is Success<List<StaffConversation>>
          ? current.data
          : const <StaffConversation>[];
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: filters.entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(entry.value),
                        selected: controller.filter.value == entry.key,
                        onSelected: (_) => controller.setFilter(entry.key),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: controller.statusFilter.value,
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(labels.staffInboxAll),
                  ),
                  DropdownMenuItem(
                    value: 'OPEN',
                    child: Text(labels.staffStatusOpen),
                  ),
                  DropdownMenuItem(
                    value: 'WAITING_CUSTOMER',
                    child: Text(labels.staffStatusWaiting),
                  ),
                  DropdownMenuItem(
                    value: 'CLOSED',
                    child: Text(labels.staffStatusClosed),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) controller.setStatus(value);
                },
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyView(message: labels.staffNoData)
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.extentAfter < 240) {
                        unawaited(controller.loadMoreConversations());
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final conversation = items[index];
                        final customer = conversation.customer;
                        final name =
                            '${customer['firstname'] ?? ''} ${customer['lastname'] ?? ''}'
                                .trim();
                        return ListTile(
                          leading: Icon(
                            conversation.isEscalated
                                ? Icons.priority_high
                                : Icons.chat_bubble_outline,
                          ),
                          title: Text(
                            conversation.subject ??
                                labels.staffConversationSubject,
                          ),
                          subtitle: Text(
                            '$name · ${_conversationType(labels, conversation.type)} · ${_conversationStatus(labels, conversation.status)}',
                          ),
                          onTap: () => Get.toNamed(
                            AppRoutes.staffConversation(conversation.id),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          if (controller.hasMoreConversations.value ||
              controller.loadingMoreConversations.value)
            TextButton(
              onPressed: controller.loadingMoreConversations.value
                  ? null
                  : controller.loadMoreConversations,
              child: Text(labels.staffLoadMore),
            ),
          Obx(
            () => controller.selected.value == null
                ? const SizedBox.shrink()
                : Flexible(child: _ConversationThread(controller: controller)),
          ),
        ],
      );
    });
  }
}

class _ConversationThread extends StatelessWidget {
  const _ConversationThread({required this.controller});
  final StaffInboxController controller;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final conversation = controller.selected.value!;
    final customer = conversation.customer;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              '${customer['firstname'] ?? ''} ${customer['lastname'] ?? ''}'
                  .trim(),
            ),
            subtitle: Text(
              '${_conversationType(labels, conversation.type)} · ${_conversationStatus(labels, conversation.status)} · ${conversation.subject ?? labels.staffConversationSubject}'
              '${conversation.assignedAgentName == null ? '' : ' · ${conversation.assignedAgentName}'}'
              '${conversation.escalationReason == null ? '' : ' · ${conversation.escalationReason}'}'
              '${conversation.listingId == null ? '' : ' · ${labels.staffListings} #${conversation.listingId}'}'
              '${conversation.lotId == null ? '' : ' · ${labels.staffStock} #${conversation.lotId}'}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (conversation.status != StaffConversationStatus.closed &&
                    Get.find<AuthController>().currentUser?.can(
                          AgentCapability.orderProcessing,
                        ) ==
                        true)
                  IconButton(
                    tooltip: labels.staffCreateQuote,
                    onPressed: () {
                      final buyerId = conversation.customer['id'];
                      if (buyerId is! int) return;
                      unawaited(
                        Get.toNamed(
                          AppRoutes.staffOrderCreate,
                          parameters: {
                            'buyerId': '$buyerId',
                            'conversationId': '${conversation.id}',
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.request_quote_outlined),
                  ),
                if (conversation.status != StaffConversationStatus.closed)
                  PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'assign') {
                        await controller.assign();
                      }
                      if (action == 'escalate') {
                        final reason = await _askText(
                          labels,
                          labels.staffReason,
                        );
                        if (reason != null) {
                          await controller.escalate(reason);
                        }
                      }
                      if (action == 'close') {
                        await controller.closeConversation();
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'assign',
                        child: Text(labels.staffAssign),
                      ),
                    ],
                  ),
                PopupMenuItem(
                  value: 'escalate',
                  child: Text(labels.staffEscalate),
                ),
                PopupMenuItem(value: 'close', child: Text(labels.staffClose)),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final state = controller.messagesState.value;
              if (state is Loading<List<StaffMessage>>) {
                return const LoadingView();
              }
              if (state is Failure<List<StaffMessage>>) {
                if (state.failure.status == 403) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          labels.staffSupportTypeDenied,
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () => controller.open(conversation.id),
                          child: Text(labels.retry),
                        ),
                      ],
                    ),
                  );
                }
                return ErrorView(
                  failure: state.failure,
                  onRetry: () => controller.open(conversation.id),
                );
              }
              final messages = state is Success<List<StaffMessage>>
                  ? state.data
                  : const <StaffMessage>[];
              return ListView(
                reverse: false,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  if (controller.hasOlderMessages.value)
                    TextButton(
                      onPressed: controller.loadOlder,
                      child: Text(labels.staffLoadMore),
                    ),
                  for (final message in messages)
                    Align(
                      alignment: message.isInternal
                          ? Alignment.center
                          : Alignment.centerLeft,
                      child: Card(
                        color: message.isInternal
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(message.content),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          const Divider(height: 1),
          if (conversation.status != StaffConversationStatus.closed)
            _MessageComposer(controller: controller),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(labels.staffSuggestionReserved),
          ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({required this.controller});
  final StaffInboxController controller;
  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  final text = TextEditingController();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(labels.staffInternalNote),
              value: widget.controller.internalNote.value,
              onChanged: (value) =>
                  widget.controller.internalNote.value = value,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: text,
                  decoration: InputDecoration(
                    hintText: labels.staffMessageHint,
                  ),
                ),
              ),
              IconButton(
                tooltip: labels.staffSend,
                onPressed: () async {
                  if (await widget.controller.send(text.text)) text.clear();
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StaffLotsPanel extends GetView<StaffLotsController> {
  const StaffLotsPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Obx(() {
      final state = controller.state.value;
      if (state is Loading<List<StaffLot>>) return const LoadingView();
      if (state is Failure<List<StaffLot>>) {
        return ErrorView(failure: state.failure, onRetry: controller.load);
      }
      final lots = state is Success<List<StaffLot>>
          ? state.data
          : const <StaffLot>[];
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: controller.statusFilter.value,
                  hint: Text(labels.staffStatusFilter),
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(labels.staffInboxAll),
                    ),
                    for (final status in LotStatus.values)
                      DropdownMenuItem(
                        value: status.apiValue,
                        child: Text(_lotStatus(labels, status)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setFilters(status: value);
                  },
                ),
                SizedBox(
                  width: 130,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: labels.staffSupplierId,
                    ),
                    onSubmitted: (value) =>
                        controller.setFilters(supplierId: value),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: labels.staffProductId,
                    ),
                    onSubmitted: (value) =>
                        controller.setFilters(productId: value),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: lots.isEmpty
                ? EmptyView(message: labels.staffNoData)
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.extentAfter < 240) {
                        unawaited(controller.loadMoreLots());
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: lots.length,
                      itemBuilder: (_, index) {
                        final staffLot = lots[index];
                        final lot = staffLot.lot;
                        return ListTile(
                          title: Text('${lot.product.name} · ${lot.lotCode}'),
                          subtitle: Text(
                            '${_lotStatus(labels, lot.status)} · ${staffLot.supplier['farmName'] ?? ''}',
                          ),
                          onTap: () => controller.open(lot.id),
                        );
                      },
                    ),
                  ),
          ),
          if (controller.hasMoreLots.value || controller.loadingMoreLots.value)
            TextButton(
              onPressed: controller.loadingMoreLots.value
                  ? null
                  : controller.loadMoreLots,
              child: Text(labels.staffLoadMore),
            ),
          if (controller.selected.value != null)
            _LotActions(controller: controller),
        ],
      );
    });
  }
}

class _LotActions extends StatelessWidget {
  const _LotActions({required this.controller});
  final StaffLotsController controller;
  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final selected = controller.selected.value!;
    final lot = selected.lot;
    final canValidate = lot.status == LotStatus.pendingValidation;
    final canReturn =
        (lot.status == LotStatus.available ||
            lot.status == LotStatus.fullyReserved) &&
        lot.quantityReserved == 0;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${labels.staffContext}: ${selected.supplier['farmName'] ?? ''}',
            ),
            Text('${lot.product.name} · ${lot.quantityAvailable}'),
            Text('${labels.staffGrade}: ${selected.qualityGrade ?? '-'}'),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.qualityHistory.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text(labels.staffGrade)),
                          DataColumn(label: Text(labels.staffNotes)),
                        ],
                        rows: [
                          for (final check in controller.qualityHistory)
                            DataRow(
                              cells: [
                                DataCell(Text('${check['grade'] ?? ''}')),
                                DataCell(Text('${check['notes'] ?? ''}')),
                              ],
                            ),
                        ],
                      ),
                    ),
                  if (controller.movementState.value
                      is Success<List<Map<String, Object?>>>)
                    for (final movement
                        in (controller.movementState.value
                                as Success<List<Map<String, Object?>>>)
                            .data)
                      Text(
                        movement.entries
                            .map((entry) => '${entry.key}: ${entry.value}')
                            .join(' · '),
                      ),
                  if (controller.hasMoreMovements.value)
                    TextButton(
                      onPressed: controller.loadMoreMovements,
                      child: Text(labels.staffLoadMore),
                    ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                if (canValidate)
                  FilledButton(
                    onPressed: () async {
                      final failure = await controller.validate();
                      if (failure?.code == 'NOT_VERIFIED') {
                        AppNotifier.error(labels.staffSupplierNotVerified);
                      } else if (failure != null) {
                        AppNotifier.error(failure.message);
                      }
                    },
                    child: Text(labels.staffValidate),
                  ),
                if (canValidate)
                  OutlinedButton(
                    onPressed: () async {
                      final reason = await _askText(labels, labels.staffReason);
                      if (reason != null) {
                        final failure = await controller.reject(reason);
                        if (failure != null) AppNotifier.error(failure.message);
                      }
                    },
                    child: Text(labels.staffReject),
                  ),
                if (canReturn)
                  OutlinedButton(
                    onPressed: () async {
                      final reason = await _askText(labels, labels.staffReason);
                      if (reason != null) {
                        final failure = await controller.returnLot(reason);
                        if (failure != null) {
                          AppNotifier.error(failure.message);
                        }
                      }
                    },
                    child: Text(labels.staffReturn),
                  ),
                OutlinedButton(
                  onPressed: () => _qualityDialog(context, controller),
                  child: Text(labels.staffQualityCheck),
                ),
                if (Get.find<AuthController>().currentUser?.can(
                      AgentCapability.disputeHandling,
                    ) ==
                    true)
                  OutlinedButton(
                    onPressed: () => _compensationDialog(
                      context,
                      Get.find<StaffOrdersController>(),
                      lot.id,
                      lot.quantityInitial,
                    ),
                    child: Text(labels.staffCompensate),
                  ),
              ],
            ),
            if (canValidate &&
                selected.supplier['profileVerificationStatus'] != 'VERIFIED' &&
                (Get.find<AuthController>().currentUser?.can(
                      AgentCapability.userVerification,
                    ) ??
                    false))
              TextButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.staffVerifications,
                  parameters: {'userId': '${selected.supplier['id']}'},
                ),
                child: Text(labels.staffSupplierReview),
              ),
          ],
        ),
      ),
    );
  }
}

class StaffListingsPanel extends GetView<StaffListingsController> {
  const StaffListingsPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Obx(() {
      final state = controller.state.value;
      if (state is Loading<List<StaffListing>>) {
        return const LoadingView();
      }
      if (state is Failure<List<StaffListing>>) {
        return ErrorView(failure: state.failure, onRetry: controller.load);
      }
      final listings = state is Success<List<StaffListing>>
          ? state.data
          : const <StaffListing>[];
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: controller.statusFilter.value,
                  hint: Text(labels.staffStatusFilter),
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(labels.staffInboxAll),
                    ),
                    DropdownMenuItem(
                      value: 'DRAFT',
                      child: Text(labels.staffListingDraft),
                    ),
                    DropdownMenuItem(
                      value: 'ACTIVE',
                      child: Text(labels.staffListingActive),
                    ),
                    DropdownMenuItem(
                      value: 'SOLD',
                      child: Text(labels.staffListingSold),
                    ),
                    DropdownMenuItem(
                      value: 'INACTIVE',
                      child: Text(labels.staffListingInactive),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setFilters(status: value);
                  },
                ),
                SizedBox(
                  width: 130,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: labels.staffSupplierId,
                    ),
                    onSubmitted: (value) =>
                        controller.setFilters(supplierId: value),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: labels.staffProductId,
                    ),
                    onSubmitted: (value) =>
                        controller.setFilters(productId: value),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FilledButton.icon(
                onPressed: () => _createListingDialog(context, controller),
                icon: const Icon(Icons.add),
                label: Text(labels.staffListingCreate),
              ),
            ),
          ),
          Expanded(
            child: listings.isEmpty
                ? EmptyView(message: labels.staffNoData)
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.extentAfter < 240) {
                        unawaited(controller.loadMore());
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: listings.length,
                      itemBuilder: (_, index) {
                        final item = listings[index];
                        return ListTile(
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.reference} · ${item.product['name'] ?? ''} · ${item.zone['name'] ?? ''} · ${_listingStatus(labels, item.status)} · ${item.unitPrice} XAF',
                          ),
                          onTap: () => controller.open(item.id),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) async {
                              if (action == 'publish') {
                                final failure = await controller
                                    .changePublication(item);
                                if (failure != null) {
                                  AppNotifier.error(
                                    _listingFailure(labels, failure),
                                  );
                                }
                              } else if (action == 'edit') {
                                await _editListingDialog(
                                  context,
                                  controller,
                                  item,
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(labels.staffEdit),
                              ),
                              if (item.status == 'ACTIVE')
                                PopupMenuItem(
                                  value: 'publish',
                                  child: Text(labels.staffUnpublish),
                                )
                              else if (item.status == 'DRAFT' ||
                                  item.status == 'INACTIVE')
                                PopupMenuItem(
                                  value: 'publish',
                                  child: Text(labels.staffPublish),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
          if (controller.hasMore.value || controller.loadingMore.value)
            TextButton(
              onPressed: controller.loadingMore.value
                  ? null
                  : controller.loadMore,
              child: Text(labels.staffLoadMore),
            ),
          if (controller.selected.value != null)
            _ListingDetailPanel(controller: controller),
        ],
      );
    });
  }
}

class _ListingDetailPanel extends StatelessWidget {
  const _ListingDetailPanel({required this.controller});
  final StaffListingsController controller;
  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final listing = controller.selected.value!;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(listing.description ?? ''),
            Text('${labels.staffPrice}: ${listing.unitPrice} XAF'),
            Text('${labels.staffContext}: ${listing.zone['name'] ?? ''}'),
            Wrap(
              spacing: 8,
              children: [
                if (listing.status != 'SOLD')
                  OutlinedButton(
                    onPressed: () =>
                        _editListingDialog(context, controller, listing),
                    child: Text(labels.staffEdit),
                  ),
                if (listing.status == 'ACTIVE' ||
                    listing.status == 'DRAFT' ||
                    listing.status == 'INACTIVE')
                  FilledButton(
                    onPressed: () async {
                      final failure = await controller.changePublication(
                        listing,
                      );
                      if (failure != null) {
                        AppNotifier.error(_listingFailure(labels, failure));
                      }
                    },
                    child: Text(
                      listing.status == 'ACTIVE'
                          ? labels.staffUnpublish
                          : labels.staffPublish,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _askText(AppLocalizations labels, String label) async {
  final text = TextEditingController();
  final result = await Get.dialog<String>(
    AlertDialog(
      title: Text(label),
      content: TextField(controller: text, maxLength: 500, autofocus: true),
      actions: [
        TextButton(onPressed: Get.back, child: Text(labels.cancel)),
        FilledButton(
          onPressed: () => Get.back(result: text.text.trim()),
          child: Text(labels.staffCreate),
        ),
      ],
    ),
  );
  text.dispose();
  return result?.isNotEmpty == true ? result : null;
}

Future<void> _qualityDialog(
  BuildContext context,
  StaffLotsController controller,
) async {
  final notes = TextEditingController();
  var grade = 'A';
  final result = await Get.dialog<(String, String?)>(
    StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(AppLocalizations.of(context).staffQualityCheck),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: grade,
              items: const ['A', 'B', 'C']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => grade = value!),
            ),
            TextField(
              controller: notes,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).staffNotes,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Get.back(result: (grade, notes.text)),
            child: Text(AppLocalizations.of(context).staffCreate),
          ),
        ],
      ),
    ),
  );
  notes.dispose();
  if (result != null) {
    final failure = await controller.qualityCheck(result.$1, result.$2);
    if (failure != null) AppNotifier.error(failure.message);
  }
}

Future<void> _compensationDialog(
  BuildContext context,
  StaffOrdersController controller,
  int lotId,
  double lotQuantity,
) async {
  final labels = AppLocalizations.of(context);
  final quantity = TextEditingController();
  final deliveryId = TextEditingController();
  final note = TextEditingController();
  var reason = 'EXPIRED_UNSOLD';
  final result = await Get.dialog<(String, double, int?, String?)>(
    StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(labels.staffCompensate),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: reason,
                items: [
                  DropdownMenuItem(
                    value: 'EXPIRED_UNSOLD',
                    child: Text(labels.staffReasonExpiredUnsold),
                  ),
                  DropdownMenuItem(
                    value: 'LOST_OR_DAMAGED',
                    child: Text(labels.staffReasonLostDamaged),
                  ),
                  DropdownMenuItem(
                    value: 'OTHER',
                    child: Text(labels.staffReasonOther),
                  ),
                ],
                onChanged: (value) => setState(() => reason = value!),
              ),
              TextField(
                controller: quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: labels.staffCompensationQuantity,
                  helperText: '${labels.staffLotQuantity}: $lotQuantity',
                ),
              ),
              TextField(
                controller: deliveryId,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: labels.staffDeliveryIdOptional,
                ),
              ),
              TextField(
                controller: note,
                maxLength: 2000,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: labels.staffNotesOptional,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(labels.cancel)),
          FilledButton(
            onPressed: () {
              final parsedQuantity = double.tryParse(quantity.text);
              if (parsedQuantity == null ||
                  parsedQuantity <= 0 ||
                  parsedQuantity > lotQuantity) {
                return;
              }
              Get.back(
                result: (
                  reason,
                  parsedQuantity,
                  int.tryParse(deliveryId.text),
                  note.text.trim().isEmpty ? null : note.text.trim(),
                ),
              );
            },
            child: Text(labels.confirm),
          ),
        ],
      ),
    ),
  );
  quantity.dispose();
  deliveryId.dispose();
  note.dispose();
  if (result == null) return;
  final failure = await controller.compensate(
    lotId: lotId,
    reason: result.$1,
    quantity: result.$2,
    deliveryId: result.$3,
    note: result.$4,
  );
  if (failure?.code == 'COMPENSATION_RATE_ZERO') {
    AppNotifier.error(labels.staffCompensationRateZero);
  } else if (failure != null) {
    AppNotifier.error(failure.message);
  } else {
    AppNotifier.success(labels.staffCompensationSubmitted);
  }
}

Future<void> _createListingDialog(
  BuildContext context,
  StaffListingsController controller,
) async {
  final lot = TextEditingController();
  final title = TextEditingController();
  final description = TextEditingController();
  final picker = ImagePicker();
  final photos = <XFile>[];
  final labels = AppLocalizations.of(context);
  final result = await Get.dialog<(int, String, String?, List<String>)>(
    StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(labels.staffListingCreate),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: lot,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: labels.staffLotId),
              ),
              TextField(
                controller: title,
                maxLength: 140,
                decoration: InputDecoration(labelText: labels.staffTitle),
              ),
              TextField(
                controller: description,
                maxLength: 2000,
                decoration: InputDecoration(labelText: labels.staffDescription),
              ),
              OutlinedButton(
                onPressed: () async {
                  final selected = await picker.pickMultiImage();
                  if (selected.isEmpty || selected.length > 5) {
                    AppNotifier.error(labels.staffPhotosRequired);
                    return;
                  }
                  for (final image in selected) {
                    final extension = image.path.split('.').last.toLowerCase();
                    if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension) ||
                        await image.length() > 5 * 1024 * 1024) {
                      AppNotifier.error(labels.staffPhotoInvalid);
                      return;
                    }
                  }
                  setState(() {
                    photos
                      ..clear()
                      ..addAll(selected);
                  });
                },
                child: Text('${labels.staffPhotosRequired} (${photos.length})'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(labels.cancel)),
          FilledButton(
            onPressed: () {
              final id = int.tryParse(lot.text.trim());
              if (id == null ||
                  title.text.trim().length < 3 ||
                  photos.isEmpty) {
                AppNotifier.error(labels.staffPhotosRequired);
                return;
              }
              Get.back(
                result: (
                  id,
                  title.text,
                  description.text,
                  photos.map((file) => file.path).toList(),
                ),
              );
            },
            child: Text(labels.staffCreate),
          ),
        ],
      ),
    ),
  );
  lot.dispose();
  title.dispose();
  description.dispose();
  if (result != null) {
    final failure = await controller.createListing(
      result.$1,
      result.$2,
      result.$3,
      result.$4,
    );
    if (failure != null) AppNotifier.error(_listingFailure(labels, failure));
  }
}

Future<void> _editListingDialog(
  BuildContext context,
  StaffListingsController controller,
  StaffListing listing,
) async {
  final title = TextEditingController(text: listing.title);
  final description = TextEditingController(text: listing.description ?? '');
  final price = TextEditingController(text: listing.unitPrice.toString());
  final labels = AppLocalizations.of(context);
  final result = await Get.dialog<Map<String, Object?>>(
    AlertDialog(
      title: Text(labels.staffEdit),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: title,
            maxLength: 140,
            decoration: InputDecoration(labelText: labels.staffTitle),
          ),
          TextField(
            controller: description,
            maxLength: 2000,
            decoration: InputDecoration(labelText: labels.staffDescription),
          ),
          TextField(
            controller: price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: labels.staffPrice),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text(labels.cancel)),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(price.text.trim());
            if (title.text.trim().length < 3 || value == null || value <= 0) {
              return;
            }
            Get.back(
              result: {
                'title': title.text.trim(),
                'description': description.text.trim(),
                'unitPrice': value,
              },
            );
          },
          child: Text(labels.staffEdit),
        ),
      ],
    ),
  );
  title.dispose();
  description.dispose();
  price.dispose();
  if (result != null) {
    final failure = await controller.updateListing(listing.id, result);
    if (failure != null) AppNotifier.error(_listingFailure(labels, failure));
  }
}

String _listingFailure(AppLocalizations labels, ApiFailure failure) =>
    switch (failure.code) {
      'PRICE_BELOW_SUPPLIER' => labels.staffPriceBelowSupplier,
      'LOT_ALREADY_LINKED' => labels.staffLotAlreadyLinked,
      'LOT_NOT_AVAILABLE' => labels.staffLotNotAvailable,
      'FILE_REQUIRED' => labels.staffFileRequired,
      _ => failure.message,
    };

String _conversationType(AppLocalizations labels, String type) =>
    switch (type) {
      'BUYER_SUPPORT' => labels.staffBuyerSupport,
      'SUPPLIER_SUPPORT' => labels.staffSupplierSupport,
      _ => type,
    };

String _conversationStatus(
  AppLocalizations labels,
  StaffConversationStatus status,
) => switch (status) {
  StaffConversationStatus.open => labels.staffStatusOpen,
  StaffConversationStatus.waitingCustomer => labels.staffStatusWaiting,
  StaffConversationStatus.closed => labels.staffStatusClosed,
};

String _lotStatus(AppLocalizations labels, LotStatus status) =>
    switch (status) {
      LotStatus.pendingValidation => labels.staffLotPending,
      LotStatus.available => labels.staffLotAvailable,
      LotStatus.fullyReserved => labels.staffLotReserved,
      LotStatus.soldOut => labels.staffLotSoldOut,
      LotStatus.expired => labels.staffLotExpired,
      LotStatus.returned => labels.staffLotReturned,
      LotStatus.rejected => labels.staffLotRejected,
      LotStatus.withdrawn => labels.staffLotWithdrawn,
    };

String _listingStatus(AppLocalizations labels, String status) =>
    switch (status) {
      'DRAFT' => labels.staffListingDraft,
      'ACTIVE' => labels.staffListingActive,
      'SOLD' => labels.staffListingSold,
      'INACTIVE' => labels.staffListingInactive,
      _ => status,
    };
