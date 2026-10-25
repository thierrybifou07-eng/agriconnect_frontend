import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/media/media_url.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/account/presentation/controllers/profile_controller.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/reference/presentation/widgets/reference_pickers.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = controller.currentUser;
    if (user == null) return const Scaffold(body: SizedBox.shrink());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Obx(() {
                  final avatar = MediaUrl.resolve(
                    Get.find<AuthController>().currentUser?.avatarUrl,
                  );
                  return CircleAvatar(
                    radius: 44,
                    backgroundImage: avatar == null
                        ? null
                        : NetworkImage(avatar),
                    onBackgroundImageError: avatar == null ? null : (_, _) {},
                    child: avatar == null
                        ? const Icon(Icons.person_outline, size: 42)
                        : null,
                  );
                }),
                const SizedBox(height: 8),
                Obx(
                  () => OutlinedButton.icon(
                    onPressed: controller.uploadingAvatar.value
                        ? null
                        : () async {
                            final uploaded = await controller
                                .chooseAndUploadAvatar();
                            if (uploaded == true) {
                              AppNotifier.success(l10n.profileUpdated);
                            } else if (uploaded == false) {
                              final failure = controller.avatarFailure.value;
                              AppNotifier.error(
                                failure?.code == 'INVALID_FILE'
                                    ? l10n.accountAvatarInvalid
                                    : failure == null
                                    ? l10n.accountAvatarInvalid
                                    : AppNotifier.failureMessage(failure, l10n),
                              );
                            }
                          },
                    icon: controller.uploadingAvatar.value
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_camera_outlined),
                    label: Text(l10n.accountAvatarChange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.accountInfo,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _textField(
                  context,
                  controller.firstname,
                  l10n.accountFirstName,
                  required: true,
                ),
                _textField(
                  context,
                  controller.lastname,
                  l10n.accountLastName,
                  required: true,
                ),
                TextFormField(
                  initialValue: user.email ?? '',
                  readOnly: true,
                  decoration: InputDecoration(labelText: l10n.accountEmail),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: user.phone ?? '',
                  readOnly: true,
                  decoration: InputDecoration(labelText: l10n.phoneLabel),
                ),
                const SizedBox(height: 12),
                _textField(context, controller.location, l10n.accountLocation),
                if (controller.canEditRoleProfile) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.accountProfile,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ..._roleFields(context),
                ],
                const SizedBox(height: 20),
                Obx(
                  () => FilledButton(
                    onPressed: controller.saving.value
                        ? null
                        : () async {
                            final saved = await controller.save();
                            if (saved) {
                              AppNotifier.success(l10n.profileUpdated);
                            } else if (controller.state.value
                                case final Failure<AuthUser> state) {
                              AppNotifier.error(
                                AppNotifier.failureMessage(state.failure, l10n),
                              );
                            }
                          },
                    child: controller.saving.value
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.profileSaveAction),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _accountLink(
            icon: Icons.verified_user_outlined,
            title: l10n.accountDocuments,
            route: AppRoutes.documents,
            visible:
                user.role == RoleCode.supplier || user.role == RoleCode.buyer,
          ),
          _accountLink(
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.accountPayoutAccounts,
            route: AppRoutes.payoutAccounts,
            visible:
                user.role == RoleCode.supplier || user.role == RoleCode.buyer,
          ),
          _accountLink(
            icon: Icons.card_giftcard_outlined,
            title: l10n.accountReferral,
            route: AppRoutes.referral,
          ),
          _accountLink(
            icon: Icons.devices_outlined,
            title: l10n.accountSessions,
            route: AppRoutes.sessions,
          ),
          _accountLink(
            icon: Icons.language_outlined,
            title: l10n.accountLanguage,
            route: AppRoutes.language,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout),
            label: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  List<Widget> _roleFields(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (controller.role) {
      case RoleCode.supplier:
        return [
          _textField(
            context,
            controller.farmName,
            l10n.accountFarmName,
            required: true,
            maxLength: 120,
          ),
          _textField(
            context,
            controller.description,
            l10n.accountDescription,
            maxLength: 2000,
            maxLines: 3,
          ),
          _zonePicker(context),
        ];
      case RoleCode.buyer:
        return [
          DropdownButtonFormField<String>(
            initialValue: controller.buyerType.value,
            decoration: InputDecoration(labelText: l10n.accountBuyerType),
            items: [
              for (final item in const [
                'RETAILER',
                'FARMER',
                'WHOLESALER',
                'OTHER',
              ])
                DropdownMenuItem(
                  value: item,
                  child: Text(_buyerType(item, l10n)),
                ),
            ],
            onChanged: (value) {
              if (value != null) controller.buyerType.value = value;
            },
          ),
          _textField(
            context,
            controller.businessName,
            l10n.accountBusinessName,
            maxLength: 120,
          ),
          _zonePicker(context),
        ];
      case RoleCode.driver:
        return [
          _textField(
            context,
            controller.vehicleType,
            l10n.accountVehicleType,
            maxLength: 50,
          ),
          _textField(
            context,
            controller.plateNumber,
            l10n.accountPlateNumber,
            maxLength: 20,
          ),
        ];
      default:
        return const [];
    }
  }

  Widget _zonePicker(BuildContext context) => Obx(() {
    if (controller.loadingZones.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      );
    }
    if (controller.zoneFailure.value != null) {
      return TextButton.icon(
        onPressed: controller.loadZones,
        icon: const Icon(Icons.refresh),
        label: Text(AppLocalizations.of(context).retry),
      );
    }
    return ZonePicker(
      repository: controller.references,
      value: controller.selectedZone,
      label: AppLocalizations.of(context).accountZone,
    );
  });

  Widget _textField(
    BuildContext context,
    TextEditingController textController,
    String label, {
    bool required = false,
    int? maxLength,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: textController,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? AppLocalizations.of(context).validationNameRequired
                : null
          : null,
    ),
  );

  Widget _accountLink({
    required IconData icon,
    required String title,
    required String route,
    bool visible = true,
  }) {
    if (!visible) return const SizedBox.shrink();
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Get.toNamed(route),
    );
  }

  String _buyerType(String type, AppLocalizations l10n) => switch (type) {
    'RETAILER' => l10n.accountRetailer,
    'FARMER' => l10n.accountFarmer,
    'WHOLESALER' => l10n.accountWholesaler,
    _ => l10n.accountOther,
  };

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirm == true) await Get.find<AuthController>().signOut();
  }
}
