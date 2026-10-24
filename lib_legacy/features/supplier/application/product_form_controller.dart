import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/supplier/application/supplier_products_controller.dart';
import 'package:agri_connect/features/supplier/application/supplier_providers.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';

/// Submission state of the product form.
class ProductFormState {
  const ProductFormState({this.isSaving = false, this.failure});

  final bool isSaving;

  /// Last submission failure, kept on screen so the supplier can retry without
  /// losing what they typed.
  final Failure? failure;

  ProductFormState copyWith({bool? isSaving, Failure? failure}) {
    return ProductFormState(
      isSaving: isSaving ?? this.isSaving,
      failure: failure ?? this.failure,
    );
  }
}

final productFormControllerProvider =
    NotifierProvider<ProductFormController, ProductFormState>(
      ProductFormController.new,
    );

/// Orchestrates product creation and edition.
class ProductFormController extends Notifier<ProductFormState> {
  @override
  ProductFormState build() => const ProductFormState();

  /// Persists the declaration and refreshes the product list on success.
  ///
  /// [declaration] is the state the supplier explicitly asked for: keeping the
  /// record as a draft, or submitting it for review. No other state is ever
  /// produced here, because the platform owns every later transition.
  ///
  /// Returns the [Failure] to display, or `null` when the declaration was saved.
  Future<Failure?> submit({
    String? productId,
    required ProductDraft draft,
    required DeclarationStatus declaration,
  }) async {
    // A second tap must never reach the repository: the guard is taken before
    // the first await, so two rapid taps cannot both pass this check.
    if (state.isSaving) return state.failure;
    state = const ProductFormState(isSaving: true);
    try {
      final product = await ref
          .read(supplierRepositoryProvider)
          .saveProduct(
            productId: productId,
            draft: draft,
            declaration: declaration,
          );
      ref.read(supplierProductsControllerProvider.notifier).upsert(product);
      state = const ProductFormState();
      return null;
    } on Failure catch (failure) {
      state = ProductFormState(failure: failure);
      return failure;
    } catch (_) {
      state = const ProductFormState(failure: UnexpectedFailure());
      return const UnexpectedFailure();
    }
  }
}
