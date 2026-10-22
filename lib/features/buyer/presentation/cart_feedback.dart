import 'package:flutter/material.dart';

import 'package:agri_connect/core/localization/locale_x.dart';

/// Confirms that a product just landed in the cart.
///
/// The dashboard and the catalog add a product from a grid, where the cart
/// badge that grew is often off screen, so the confirmation follows the tap
/// instead of leaving the buyer to look for it.
///
/// The product detail deliberately does not use it: its sticky bar already
/// reports the quantity now in the cart, and a snackbar would float over that
/// bar and swallow the taps meant for the next action.
void showAddedToCart(BuildContext context, String productName) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(context.l10n.addedToCart(productName))),
  );
}
