import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/core/utils/validators.dart';
import 'package:agri_connect/features/buyer/application/buyer_cart_controller.dart';
import 'package:agri_connect/features/buyer/application/checkout_controller.dart';
import 'package:agri_connect/shared/widgets/app_text_field.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';

/// Checkout screen: delivery details, order summary and submission.
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    // `validate` returns true when the form has no error: proceed only then,
    // exactly like the login, register and product forms do.
    if (!_formKey.currentState!.validate()) return;

    final order = await ref
        .read(checkoutControllerProvider.notifier)
        .place(
          deliveryAddress: _addressController.text,
          buyerPhone: _phoneController.text,
          deliveryNote: _noteController.text.trim(),
        );

    if (!mounted) return;
    if (order != null) {
      // The cart is now empty: the funnel ends on the confirmation, which owns
      // its own way out, instead of on a checkout the buyer would have to fix.
      context.go(RoutePaths.buyerOrderConfirmation(order.id));
    }
    // On failure there is nothing to do here: the notice stays on screen next
    // to the button, which is the only place a buyer looks after a failed
    // order, and a snackbar on top of it would only say it twice.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final checkout = ref.watch(checkoutControllerProvider);
    final cart = ref.watch(cartControllerProvider);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.checkoutTitle)),
        body: EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: l10n.cartEmptyTitle,
          body: l10n.cartEmptyBody,
          actionLabel: l10n.viewCatalog,
          actionIcon: Icons.storefront_outlined,
          onAction: () => context.go(RoutePaths.buyerCatalog),
        ),
      );
    }

    final failure = checkout.failure;

    void editCart() {
      if (checkout.isPlacing) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RoutePaths.buyerCart);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.checkoutTitle),
        // An icon keeps the bar readable at 320 px, where a text action and the
        // title no longer fit side by side at a large text scale.
        actions: [
          IconButton(
            onPressed: checkout.isPlacing ? null : editCart,
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.checkoutEditCart,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.checkoutSummary(
                      cart.itemCount,
                      Money.format(
                        cart.totalAmount,
                        locale: context.localeCode,
                      ),
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: checkout.isPlacing ? null : editCart,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(l10n.checkoutEditCart),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.checkoutDeliveryTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _addressController,
                    label: l10n.checkoutAddressLabel,
                    icon: Icons.place_outlined,
                    validator: Validators.address(l10n),
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _phoneController,
                    label: l10n.checkoutPhoneLabel,
                    icon: Icons.phone_outlined,
                    validator: Validators.phone(l10n),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _noteController,
                    label: l10n.checkoutNoteLabel,
                    icon: Icons.notes_rounded,
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.checkoutItemsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          for (var i = 0; i < cart.lines.length; i++) ...[
                            _ItemRow(line: cart.lines[i]),
                            if (i < cart.lines.length - 1)
                              const Divider(height: 20),
                          ],
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.totalLabel,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                Money.format(
                                  cart.totalAmount,
                                  locale: context.localeCode,
                                ),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (failure != null) ...[
                    const SizedBox(height: 20),
                    _FailureNotice(message: failure.message(l10n)),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: checkout.isPlacing
                        ? l10n.placingOrder
                        : l10n.placeOrder,
                    loading: checkout.isPlacing,
                    onPressed: checkout.isPlacing ? null : _submit,
                    icon: Icons.shopping_cart_checkout_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FailureNotice extends StatelessWidget {
  const _FailureNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.checkoutErrorTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One line of the recap: what it is, how many, and what it weighs in.
///
/// The line total is shown here as well as on the cart and on the order
/// detail: the recap is where the buyer checks that the total at the bottom
/// adds up, and a recap that hides the line totals cannot be checked at all.
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            line.product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '${line.quantity} × '
            '${Money.format(line.product.price, locale: context.localeCode)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          Money.format(line.total, locale: context.localeCode),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
