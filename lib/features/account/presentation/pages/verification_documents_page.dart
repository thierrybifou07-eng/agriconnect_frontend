import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/state_views.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/utils/dates.dart';
import 'package:agri_connect/features/account/domain/account_entities.dart';
import 'package:agri_connect/features/account/presentation/controllers/verification_documents_controller.dart';

class VerificationDocumentsPage
    extends GetView<VerificationDocumentsController> {
  const VerificationDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountDocuments)),
      body: Obx(() {
        final state = controller.state.value;
        if (state is Loading<List<VerificationDocument>> ||
            state is Idle<List<VerificationDocument>>) {
          return const LoadingView();
        }
        if (state is Failure<List<VerificationDocument>>) {
          return ErrorView(failure: state.failure, onRetry: controller.load);
        }
        final documents = (state as Success<List<VerificationDocument>>).data;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.accountDocumentsIntro),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: controller.selectedType.value,
              decoration: InputDecoration(labelText: l10n.accountDocumentType),
              items: [
                for (final type in const [
                  'ID_CARD',
                  'BUSINESS_REGISTRATION',
                  'FARM_PROOF',
                  'OTHER',
                ])
                  DropdownMenuItem(
                    value: type,
                    child: Text(_documentType(type, l10n)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) controller.selectedType.value = value;
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.uploading.value
                  ? null
                  : controller.selectFile,
              icon: const Icon(Icons.attach_file),
              label: Text(
                controller.selectedFile.value?.name ??
                    l10n.accountSelectDocument,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: controller.uploading.value
                  ? null
                  : () => _upload(context),
              icon: controller.uploading.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(l10n.accountUploadDocument),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.accountVerificationTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (documents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(l10n.accountDocumentsEmpty),
              )
            else
              for (final document in documents)
                _DocumentTile(document: document),
          ],
        );
      }),
    );
  }

  Future<void> _upload(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final uploaded = await controller.uploadSelectedFile();
    if (uploaded) {
      AppNotifier.success(l10n.accountDocumentUploaded);
      return;
    }
    final failure = controller.uploadFailure.value;
    if (failure == null) return;
    final message = switch (failure.code) {
      'TOO_MANY_PENDING_DOCUMENTS' => l10n.accountDocumentPendingLimit,
      'FILE_TOO_LARGE' => l10n.accountDocumentTooLarge,
      'INVALID_FILE' => l10n.accountDocumentInvalid,
      'FILE_REQUIRED' => l10n.accountSelectDocument,
      _ => AppNotifier.failureMessage(failure, l10n),
    };
    AppNotifier.error(message);
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document});

  final VerificationDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(_documentType(document.type, l10n)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (document.createdAt != null)
              Text(Dates.short(document.createdAt!)),
            if (document.note != null && document.note!.isNotEmpty)
              Text(document.note!),
          ],
        ),
        trailing: Chip(label: Text(_documentStatus(document.status, l10n))),
      ),
    );
  }
}

String _documentType(String code, AppLocalizations l10n) => switch (code) {
  'ID_CARD' => l10n.accountDocumentId,
  'BUSINESS_REGISTRATION' => l10n.accountDocumentBusiness,
  'FARM_PROOF' => l10n.accountDocumentFarm,
  _ => l10n.accountDocumentOther,
};

String _documentStatus(String status, AppLocalizations l10n) =>
    switch (status) {
      'PENDING' => l10n.accountPending,
      'VERIFIED' => l10n.accountVerificationVerified,
      'REJECTED' => l10n.accountRejected,
      _ => status,
    };
