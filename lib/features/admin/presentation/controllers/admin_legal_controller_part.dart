part of 'admin_operations_controller.dart';

extension AdminLegalOperations on AdminOperationsController {
  Future<void> loadLegal() async {
    legalState.value = const Loading<List<AdminLegalDocument>>();
    try {
      final docs = await repository.publishedLegal();
      final drafts = publishedDocuments
          .where((document) => document.status == 'DRAFT')
          .toList();
      final merged = [
        ...docs,
        for (final draft in drafts)
          if (!docs.any((document) => document.id == draft.id)) draft,
      ];
      publishedDocuments.assignAll(merged);
      legalState.value = Success(List.unmodifiable(merged));
    } on ApiFailure catch (failure) {
      legalState.value = Failure(failure);
    }
  }

  Future<bool> createLegalVersion(
    String code,
    String version,
    String frenchTitle,
    String frenchContent,
    String englishTitle,
    String englishContent,
  ) async {
    if (!const {
          'CGU',
          'BUYER_TERMS',
          'SUPPLIER_CONSIGNMENT_TERMS',
        }.contains(code) ||
        version.trim().isEmpty ||
        version.trim().length > 20 ||
        frenchTitle.trim().isEmpty ||
        frenchTitle.trim().length > 200 ||
        frenchContent.trim().isEmpty) {
      return false;
    }
    final translations = <Map<String, String>>[
      {
        'locale': 'fr',
        'title': frenchTitle.trim(),
        'content': frenchContent.trim(),
      },
    ];
    if (englishTitle.trim().isNotEmpty != englishContent.trim().isNotEmpty ||
        englishTitle.trim().length > 200) {
      return false;
    }
    if (englishTitle.trim().isNotEmpty) {
      translations.add({
        'locale': 'en',
        'title': englishTitle.trim(),
        'content': englishContent.trim(),
      });
    }
    actionState.value = const Loading<void>();
    try {
      final created = await repository.createLegalVersion(code, {
        'version': version.trim(),
        'translations': translations,
      });
      publishedDocuments.insert(0, created);
      legalState.value = Success(List.unmodifiable(publishedDocuments));
      actionState.value = const Success<void>(null);
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      return false;
    }
  }

  Future<bool> publishLegal(int id) async {
    actionState.value = const Loading<void>();
    try {
      await repository.publishLegalVersion(id);
      publishedDocuments.removeWhere((document) => document.id == id);
      actionState.value = const Success<void>(null);
      await loadLegal();
      return true;
    } on ApiFailure catch (failure) {
      actionState.value = Failure(failure);
      if (failure.status == 409) await loadLegal();
      return false;
    }
  }
}
