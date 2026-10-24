import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/buyer/application/buyer_cart_controller.dart';
import 'package:agri_connect/features/buyer/application/buyer_orders_controller.dart';
import 'package:agri_connect/features/buyer/application/buyer_providers.dart';
import 'package:agri_connect/features/buyer/domain/buyer_order.dart';
import 'package:agri_connect/features/buyer/domain/buyer_repository.dart';

/// Submission state of the checkout screen.
class CheckoutState {
  const CheckoutState({this.isPlacing = false, this.failure});

  final bool isPlacing;
  final Failure? failure;

  CheckoutState copyWith({bool? isPlacing, Failure? failure}) {
    return CheckoutState(
      isPlacing: isPlacing ?? this.isPlacing,
      failure: failure ?? this.failure,
    );
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutState>(CheckoutController.new);

/// Places the current cart as an order and clears it on success.
class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  /// Returns the created order, or `null` when the placement failed.
  Future<BuyerOrder?> place({
    required String deliveryAddress,
    required String buyerPhone,
    String? deliveryNote,
  }) async {
    final cart = ref.read(cartControllerProvider);
    if (cart.isEmpty) return null;

    final request = PlaceOrderRequest(
      deliveryAddress: deliveryAddress.trim(),
      deliveryNote: deliveryNote?.trim(),
      buyerPhone: buyerPhone.trim(),
      items: [
        for (final line in cart.lines)
          BuyerOrderItem(
            productId: line.product.id,
            productName: line.product.name,
            unitPrice: line.product.price,
            quantity: line.quantity,
          ),
      ],
    );

    state = const CheckoutState(isPlacing: true);
    try {
      final order = await ref.read(buyerRepositoryProvider).placeOrder(request);
      ref.read(buyerOrdersControllerProvider.notifier).upsert(order);
      ref.read(cartControllerProvider.notifier).clear();
      state = const CheckoutState();
      return order;
    } on Failure catch (failure) {
      state = CheckoutState(failure: failure);
      return null;
    } catch (_) {
      state = const CheckoutState(failure: UnexpectedFailure());
      return null;
    }
  }
}
