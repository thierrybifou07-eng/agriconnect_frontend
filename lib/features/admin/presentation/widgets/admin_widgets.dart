import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/features/admin/domain/admin_entities.dart';

Widget adminCapabilityCheckbox(
  AppLocalizations labels,
  String code,
  Set<String> selected,
  ValueChanged<bool> onChanged,
) => CheckboxListTile(
  contentPadding: EdgeInsets.zero,
  dense: true,
  value: selected.contains(code),
  title: Text(adminCapabilityLabel(labels, code)),
  onChanged: (value) => onChanged(value == true),
);

String adminCapabilityLabel(AppLocalizations labels, String code) =>
    switch (code) {
      'BUYER_SUPPORT' => labels.adminCapabilityBuyerSupport,
      'SUPPLIER_SUPPORT' => labels.adminCapabilitySupplierSupport,
      'LISTING_MANAGEMENT' => labels.adminCapabilityListingManagement,
      'ORDER_PROCESSING' => labels.adminCapabilityOrderProcessing,
      'STOCK_VALIDATION' => labels.adminCapabilityStockValidation,
      'PAYMENT_FOLLOWUP' => labels.adminCapabilityPaymentFollowup,
      'DISPATCH_COORDINATION' => labels.adminCapabilityDispatchCoordination,
      'USER_VERIFICATION' => labels.adminCapabilityUserVerification,
      'DISPUTE_HANDLING' => labels.adminCapabilityDisputeHandling,
      _ => code,
    };

class AdminRetryMessage extends StatelessWidget {
  const AdminRetryMessage({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.isEmpty ? labels.adminErrorLoading : message),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: Text(labels.adminRetry)),
          ],
        ),
      ),
    );
  }
}

String adminApiFailureMessage(AppLocalizations labels, ApiFailure failure) =>
    failure.code == 'INVALID_RESPONSE'
    ? labels.adminInvalidApiResponse
    : failure.message;

String adminAuditActor(AppLocalizations labels, AdminAuditLog entry) {
  if (entry.actorAgent != null) return entry.actorAgent!;
  if (entry.actorUser != null) return entry.actorUser!;
  if (entry.actorAgentId != null) {
    return '${labels.adminAuditActorAgentId}: ${entry.actorAgentId}';
  }
  if (entry.actorUserId != null) {
    return '${labels.adminAuditActorUserId}: ${entry.actorUserId}';
  }
  return labels.adminNoData;
}

String adminShortDate(BuildContext context, DateTime date) =>
    DateFormat.yMd(AppLocalizations.of(context).localeName).format(date);
