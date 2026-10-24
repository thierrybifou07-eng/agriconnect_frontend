import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/media/photo_picker.dart';
import 'package:agri_connect/core/media/prepared_photo.dart';
import 'package:agri_connect/core/utils/validators.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/supplier/application/supplier_products_controller.dart';
import 'package:agri_connect/features/supplier/application/product_form_controller.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';
import 'package:agri_connect/shared/widgets/app_text_field.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/failure_view.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';
import 'package:agri_connect/shared/widgets/product_photo_field.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';

/// Screen for creating or editing a supplier product.
///
/// The same form serves both: without [productId] it starts empty with a
/// creation call to action, with one it is filled from the existing product and
/// submits an update. The read-only sheet is a separate screen, so the two
/// never overlap.
class SupplierProductFormPage extends ConsumerStatefulWidget {
  const SupplierProductFormPage({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<SupplierProductFormPage> createState() =>
      _SupplierProductFormPageState();
}

class _SupplierProductFormPageState
    extends ConsumerState<SupplierProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceFocus = FocusNode();
  final _stockFocus = FocusNode();
  String _unit = 'kg';
  List<PreparedPhoto> _photos = const [];
  bool _isPickingPhotos = false;
  bool _photoError = false;

  /// Declaration status of the edited product, `null` while creating a new one.
  DeclarationStatus? _declaration;

  /// Id of the product already copied into the fields, `null` until then.
  String? _seededProductId;

  /// Fingerprint of the fields right after seeding, used to detect edits.
  late String _initialSignature = '';

  /// Maximum number of pictures a product can carry.
  static const int _maxPhotos = 5;

  /// Width the form never exceeds, so it stays readable on a desktop browser.
  static const double _maxFormWidth = 640;

  /// Below this width the price and stock fields stack instead of sitting side
  /// by side, where their labels would be squeezed.
  static const double _twoColumnsBreakpoint = 420;

  bool get _isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    final productId = widget.productId;
    if (productId != null) {
      _seedFrom(
        ref.read(supplierProductsControllerProvider).products,
        productId,
      );
    }
    _initialSignature = _signature();
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
    _stockController.addListener(_onFieldChanged);
  }

  /// Repaints the derived status as soon as the stock changes.
  void _onFieldChanged() => setState(() {});

  /// Current state of every editable field, as a comparable string.
  String _signature() => [
    _nameController.text,
    _descriptionController.text,
    _priceController.text,
    _stockController.text,
    _unit,
    for (final photo in _photos) photo.id,
  ].join('|');

  /// Whether the supplier changed something since the form was filled in.
  bool get _isDirty => _signature() != _initialSignature;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(productFormControllerProvider);
    final productsState = ref.watch(supplierProductsControllerProvider);

    if (_isEditing && _seededProductId == null) {
      return _buildUnresolved(context, l10n, productsState);
    }

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _leave();
      },
      child: Scaffold(
        appBar: _appBar(l10n, _isEditing ? l10n.editProduct : l10n.addProduct),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxFormWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePadding,
                  8,
                  AppSizes.pagePadding,
                  AppSizes.pagePadding,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _IdentityHeader(isEditing: _isEditing),
                      const SizedBox(height: 16),
                      _FormSection(
                        title: l10n.productFormInfoSection,
                        icon: Icons.info_outline_rounded,
                        children: [
                          AppTextField(
                            controller: _nameController,
                            label: l10n.productNameLabel,
                            icon: Icons.edit_rounded,
                            validator: Validators.productName(l10n),
                            textInputAction: TextInputAction.next,
                          ),
                          AppTextField(
                            controller: _descriptionController,
                            label: l10n.productDescriptionLabel,
                            icon: Icons.notes_rounded,
                            maxLines: 3,
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _FormSection(
                        title: l10n.productFormPricingSection,
                        icon: Icons.sell_outlined,
                        children: [
                          _PriceAndStock(
                            priceController: _priceController,
                            stockController: _stockController,
                            unit: _unit,
                            l10n: l10n,
                            onUnitChanged: (value) {
                              if (value != null) {
                                setState(() => _unit = value);
                              }
                            },
                            onPriceSubmitted: (_) => _stockFocus.requestFocus(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _FormSection(
                        title: l10n.productFormPhotosSection,
                        icon: Icons.photo_camera_outlined,
                        children: [
                          ProductPhotoField(
                            photos: _photos,
                            isLoading: _isPickingPhotos,
                            hasError: _photoError,
                            maxPhotos: _maxPhotos,
                            emptyLabel: l10n.productFormPhotosEmpty,
                            hint: l10n.productFormPhotosHint,
                            pickLabel: l10n.addPhoto,
                            replaceLabel: l10n.productFormReplacePhoto,
                            removeLabel: l10n.productFormRemovePhoto,
                            loadingLabel: l10n.productFormPickingPhotos,
                            errorLabel: l10n.productFormPhotoError,
                            onPick: _addPhotos,
                            onRemove: (photo) =>
                                setState(() => _photos.remove(photo)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _FormSection(
                        title: l10n.productFormStatusSection,
                        icon: Icons.visibility_outlined,
                        children: [_StatusPreview(stock: _parsedStock)],
                      ),
                      const SizedBox(height: 18),
                      _FormSection(
                        title: l10n.declarationStatusSection,
                        icon: Icons.verified_user_outlined,
                        children: [
                          _DeclarationNotice(
                            declaration: _currentDeclaration,
                            isEditing: _isEditing,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (state.failure != null) ...[
                        _SaveFailureBanner(
                          message: state.failure!.message(l10n),
                          isSaving: state.isSaving,
                          onRetry: () =>
                              _submit(DeclarationStatus.pendingReview),
                        ),
                        const SizedBox(height: 16),
                      ],
                      PrimaryButton(
                        label: state.isSaving
                            ? l10n.savingProduct
                            : (_isEditing
                                  ? l10n.productFormUpdateAction
                                  : l10n.productFormPublishAction),
                        loading: state.isSaving,
                        onPressed: () =>
                            _submit(DeclarationStatus.pendingReview),
                        icon: Icons.send_rounded,
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: state.isSaving
                            ? null
                            : () => _submit(DeclarationStatus.draft),
                        icon: const Icon(Icons.save_outlined),
                        label: Text(l10n.declarationSaveDraftAction),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Leaves the form, asking for a confirmation when edits would be lost.
  Future<void> _leave() async {
    if (_isDirty && !await _confirmDiscard()) return;
    if (!mounted) return;
    _goBackToProducts();
  }

  /// Pops the form when it was opened from the products list, and falls back to
  /// that list when the form was opened cold, where there is nothing to pop.
  void _goBackToProducts() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_productsPath);
    }
  }

  /// Asks whether the pending edits may be dropped; `true` means leave.
  Future<bool> _confirmDiscard() async {
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.keepEditingAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.leaveFormAction),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  /// Copies [productId] into the fields as soon as the catalog exposes it.
  ///
  /// Seeding is idempotent, so it can safely be called again while the
  /// products list is still loading.
  void _seedFrom(List<Product> products, String productId) {
    if (_seededProductId == productId) return;
    for (final product in products) {
      if (product.id != productId) continue;
      _seededProductId = productId;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      _stockController.text = product.stockQuantity.toString();
      _unit = product.unit;
      _photos = List<PreparedPhoto>.of(product.photos);
      _declaration = product.declaration;
      _initialSignature = _signature();
      return;
    }
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onFieldChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_onFieldChanged)
      ..dispose();
    _priceController
      ..removeListener(_onFieldChanged)
      ..dispose();
    _stockController
      ..removeListener(_onFieldChanged)
      ..dispose();
    _priceFocus.dispose();
    _stockFocus.dispose();
    super.dispose();
  }

  /// Reads photos, keeping the section in its own loading and error state so a
  /// failure never loses what the supplier already typed.
  Future<void> _addPhotos() async {
    if (_isPickingPhotos) return;
    final room = _maxPhotos - _photos.length;
    if (room <= 0) return;

    setState(() {
      _isPickingPhotos = true;
      _photoError = false;
    });

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await ref
          .read(photoPickerProvider)
          .pickPhotos(limit: room);
      if (!mounted) return;
      setState(() {
        // The picker is free to return more than asked on some platforms.
        _photos = [..._photos, ...picked.take(room)];
        _isPickingPhotos = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPickingPhotos = false;
        _photoError = true;
      });
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.productFormPhotoError)),
      );
    }
  }

  /// Current stock, or `null` while the field is empty or invalid.
  int? get _parsedStock {
    final input = _stockController.text.trim().replaceAll(' ', '');
    return input.isEmpty ? null : int.tryParse(input);
  }

  /// Declaration status currently stored for the edited product, if any.
  DeclarationStatus? get _currentDeclaration => _declaration;

  /// Saves the declaration in [declaration].
  ///
  /// The supplier picks between keeping the record as a draft and submitting it
  /// for review; every later state belongs to the platform.
  Future<void> _submit(DeclarationStatus declaration) async {
    if (ref.read(productFormControllerProvider).isSaving) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productFormValidationSummary)),
      );
      return;
    }
    final priceInput = _priceController.text
        .trim()
        .replaceAll(' ', '')
        .replaceAll(',', '.');
    final parsedPrice = double.parse(priceInput);
    final parsedStock = _parsedStock!;
    final l10n = context.l10n;

    final failure = await ref
        .read(productFormControllerProvider.notifier)
        .submit(
          productId: widget.productId,
          draft: ProductDraft(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: parsedPrice.round(),
            stockQuantity: parsedStock,
            unit: _unit,
            photos: _photos,
          ),
          declaration: declaration,
        );

    if (!mounted) return;
    if (failure == null) {
      _initialSignature = _signature();
      _declaration = declaration;
      final message = declaration == DeclarationStatus.draft
          ? l10n.declarationDraftSavedSnack
          : l10n.declarationSubmittedSnack;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      _goBackToProducts();
    } else {
      // The fields are left untouched on purpose: the supplier only has to press
      // the button again, nothing is retyped.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message(l10n))));
    }
  }

  String get _productsPath {
    final user = ref.read(authControllerProvider).user;
    return '${user?.role.routePrefix ?? '/supplier'}/products';
  }

  AppBar _appBar(AppLocalizations l10n, String title) => AppBar(
    title: Text(title),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: _leave,
    ),
  );

  /// Holds the form back until the edited product is actually resolved.
  ///
  /// Without this, opening the edition screen before the catalog has loaded
  /// would present empty fields and allow saving them over the real product.
  Widget _buildUnresolved(
    BuildContext context,
    AppLocalizations l10n,
    SupplierProductsState productsState,
  ) {
    final productId = widget.productId!;
    final appBar = _appBar(l10n, l10n.editProduct);

    final failure = productsState.failure;
    if (failure != null) {
      return Scaffold(
        appBar: appBar,
        body: FailureView(
          failure: failure,
          onRetry: () =>
              ref.read(supplierProductsControllerProvider.notifier).refresh(),
        ),
      );
    }

    final isMissing =
        !productsState.isLoading &&
        !productsState.products.any((p) => p.id == productId);
    if (isMissing) {
      return Scaffold(
        appBar: appBar,
        body: EmptyState(
          icon: Icons.inventory_2_outlined,
          title: l10n.productNotFound,
          body: l10n.productNotFoundBody,
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _seedFrom(productsState.products, productId));
    });
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          children: const [FormSkeleton(withPreview: true)],
        ),
      ),
    );
  }
}

/// Opening line of the form, explaining what the next action will do.
class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Text(
      isEditing ? l10n.productFormEditHint : l10n.productFormCreateHint,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }
}

/// Price, stock and unit, side by side only when there is room for them.
class _PriceAndStock extends StatelessWidget {
  const _PriceAndStock({
    required this.priceController,
    required this.stockController,
    required this.unit,
    required this.l10n,
    required this.onUnitChanged,
    required this.onPriceSubmitted,
  });

  final TextEditingController priceController;
  final TextEditingController stockController;
  final String unit;
  final AppLocalizations l10n;
  final ValueChanged<String?> onUnitChanged;
  final ValueChanged<String> onPriceSubmitted;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < _SupplierProductFormPageState._twoColumnsBreakpoint;

    final price = AppTextField(
      controller: priceController,
      label: l10n.productPriceLabel,
      icon: Icons.monetization_on_outlined,
      validator: Validators.price(l10n),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: onPriceSubmitted,
    );
    final stock = AppTextField(
      controller: stockController,
      label: l10n.productStockLabel,
      icon: Icons.inventory_2_outlined,
      validator: Validators.stock(l10n),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
    );
    final unitField = DropdownButtonFormField<String>(
      initialValue: unit,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.productUnitLabel,
        prefixIcon: const Icon(Icons.straighten_rounded),
      ),
      items: [
        for (final value in ProductUnits.all)
          DropdownMenuItem(value: value, child: Text(value)),
      ],
      onChanged: onUnitChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stacked) ...[
          price,
          const SizedBox(height: 14),
          stock,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: price),
              const SizedBox(width: 14),
              Expanded(child: stock),
            ],
          ),
        const SizedBox(height: 14),
        unitField,
      ],
    );
  }
}

/// Publishing status derived from the stock, shown as a preview.
class _StatusPreview extends StatelessWidget {
  const _StatusPreview({required this.stock});

  final int? stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final status = (stock ?? 0) > 0
        ? ProductStatus.onSale
        : ProductStatus.outOfStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.productFormStatusHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: StatusBadge(
                label: status.label(l10n),
                color: status.color(context),
              ),
            ),
          ],
        ),
        if (status == ProductStatus.outOfStock) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.productFormOutOfStockHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Explains the declaration workflow and shows the stored status when editing.
class _DeclarationNotice extends StatelessWidget {
  const _DeclarationNotice({
    required this.declaration,
    required this.isEditing,
  });

  final DeclarationStatus? declaration;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEditing && declaration != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.declarationStatusSection,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: StatusBadge(
                  label: declaration!.label(l10n),
                  color: declaration!.color(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.declarationDemoNotice,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Submission error kept on screen, with a manual retry.
class _SaveFailureBanner extends StatelessWidget {
  const _SaveFailureBanner({
    required this.message,
    required this.isSaving,
    required this.onRetry,
  });

  final String message;
  final bool isSaving;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Material(
      color: colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.productFormSaveErrorTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: isSaving ? null : onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.retry),
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

/// Titled card grouping related fields of the product form.
class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
