import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/features/admin/presentation/pages/admin_create_staff_dialog.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_controllers.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class AdminUsersPanel extends GetView<AdminUsersController> {
  const AdminUsersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final isRoot = canEditPlatformSettings(
      Get.find<AuthController>().currentUser?.role ?? RoleCode.unknown,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      labels.adminTabUsers,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => CreateStaffDialog(
                        controller: controller,
                        isRoot: isRoot,
                      ),
                    ),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: Text(labels.adminCreateStaff),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: labels.adminUsersSearch,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: controller.setSearch,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _filterDropdown(
                    label: labels.adminRoleFilter,
                    value: controller.role.value ?? 'ALL',
                    values: const [
                      'ALL',
                      'ROOT',
                      'ADMIN',
                      'AGENT',
                      'DRIVER',
                      'SUPPLIER',
                      'BUYER',
                    ],
                    labels: {
                      'ALL': labels.adminAll,
                      'ROOT': 'ROOT',
                      'ADMIN': 'ADMIN',
                      'AGENT': 'AGENT',
                      'DRIVER': 'DRIVER',
                      'SUPPLIER': 'SUPPLIER',
                      'BUYER': 'BUYER',
                    },
                    onChanged: (value) =>
                        controller.setRole(value == 'ALL' ? null : value),
                  ),
                  _filterDropdown(
                    label: labels.adminStatusFilter,
                    value: controller.status.value ?? 'ALL',
                    values: const ['ALL', 'ACTIVE', 'SUSPENDED'],
                    labels: {
                      'ALL': labels.adminAll,
                      'ACTIVE': labels.adminActive,
                      'SUSPENDED': labels.adminSuspended,
                    },
                    onChanged: (value) =>
                        controller.setStatus(value == 'ALL' ? null : value),
                  ),
                  _filterDropdown(
                    label: labels.adminVerificationFilter,
                    value: controller.profileVerificationStatus.value ?? 'ALL',
                    values: const [
                      'ALL',
                      'UNVERIFIED',
                      'PENDING',
                      'VERIFIED',
                      'REJECTED',
                    ],
                    labels: {
                      'ALL': labels.adminAll,
                      'UNVERIFIED': labels.adminUnverified,
                      'PENDING': labels.adminPending,
                      'VERIFIED': labels.adminVerified,
                      'REJECTED': labels.adminRejected,
                    },
                    onChanged: (value) =>
                        controller.setProfileVerificationStatus(
                          value == 'ALL' ? null : value,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final state = controller.state.value;
            if (state is Loading<List<AdminUser>> ||
                state is Idle<List<AdminUser>>) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is Failure<List<AdminUser>>) {
              return AdminRetryMessage(
                message: adminApiFailureMessage(labels, state.failure),
                onRetry: controller.load,
              );
            }
            final users = (state as Success<List<AdminUser>>).data;
            if (users.isEmpty) return Center(child: Text(labels.adminNoUsers));
            return RefreshIndicator(
              onRefresh: controller.load,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final suspended = user.status?.toUpperCase() == 'SUSPENDED';
                  return ListTile(
                    title: Text(
                      user.fullName.isEmpty ? user.email ?? '—' : user.fullName,
                    ),
                    subtitle: Text(
                      '${user.role ?? '—'} · ${user.status ?? '—'} · '
                      '${user.profileVerificationStatus ?? '—'}',
                    ),
                    onTap: () => _showUserDetails(context, user),
                    trailing: IconButton(
                      tooltip: suspended
                          ? labels.adminReactivate
                          : labels.adminSuspend,
                      onPressed: () => _confirmUserAction(
                        context,
                        user,
                        suspend: !suspended,
                      ),
                      icon: Icon(
                        suspended ? Icons.lock_open : Icons.person_off_outlined,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _filterDropdown({
    required String label,
    required String value,
    required List<String> values,
    required Map<String, String> labels,
    required ValueChanged<String> onChanged,
  }) => SizedBox(
    width: 190,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, isDense: true),
      items: [
        for (final option in values)
          DropdownMenuItem(value: option, child: Text(labels[option]!)),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    ),
  );

  Future<void> _confirmUserAction(
    BuildContext context,
    AdminUser user, {
    required bool suspend,
  }) async {
    final labels = AppLocalizations.of(context);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          suspend
              ? labels.adminConfirmSuspendTitle
              : labels.adminConfirmReactivateTitle,
        ),
        content: Text(
          suspend
              ? labels.adminConfirmSuspendBody
              : labels.adminConfirmReactivateBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(labels.adminCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(labels.adminConfirm),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    if (await controller.setSuspended(user, suspend: suspend)) {
      AppNotifier.success(labels.adminAccountUpdated);
    } else {
      final state = controller.actionState.value;
      if (state is Failure<void>) {
        AppNotifier.error(adminApiFailureMessage(labels, state.failure));
      }
    }
  }

  void _showUserDetails(BuildContext context, AdminUser user) {
    final labels = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(labels.adminUserDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail(labels.adminStaffRole, user.role),
            _detail(labels.adminStatusFilter, user.status),
            _detail(
              labels.adminProfileVerification,
              user.profileVerificationStatus,
            ),
            _detail(
              labels.adminEmailVerified,
              user.emailVerified == null
                  ? '—'
                  : user.emailVerified!
                  ? labels.adminVerified
                  : labels.adminUnverified,
            ),
            _detail(
              labels.adminCreatedAt,
              user.createdAt == null
                  ? null
                  : DateFormat.yMd(labels.localeName).format(user.createdAt!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed(
                AppRoutes.staffVerifications,
                parameters: {'userId': '${user.id}'},
              );
            },
            child: Text(labels.adminViewDocuments),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(labels.adminCancel),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text('$label: ${value ?? '—'}'),
  );
}
