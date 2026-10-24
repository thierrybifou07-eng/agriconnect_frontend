import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/buyer/domain/catalog_product.dart';

/// A purchasable line holding a product and its chosen quantity.
class CartLine {
  const CartLine({required this.product, required this.quantity});

  final BuyerProduct product;
  final int quantity;

  int get total => product.price * quantity;

  CartLine copyWith({int? quantity}) =>
      CartLine(product: product, quantity: quantity ?? this.quantity);
}

/// Immutable snapshot of the buyer cart.
class CartState {
  const CartState({this.lines = const []});

  final List<CartLine> lines;

  bool get isEmpty => lines.isEmpty;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  int get totalAmount => lines.fold(0, (sum, line) => sum + line.total);

  int quantityOf(String productId) {
    for (final line in lines) {
      if (line.product.id == productId) return line.quantity;
    }
    return 0;
  }

  CartState copyWith({List<CartLine>? lines}) =>
      CartState(lines: lines ?? this.lines);
}

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

/// In-memory cart shared across the buyer screens for the whole session.
class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void add(BuyerProduct product, {int quantity = 1}) {
    if (!product.inStock || quantity <= 0) return;
    final lines = List<CartLine>.of(state.lines);
    final index = lines.indexWhere((line) => line.product.id == product.id);
    if (index >= 0) {
      final existing = lines[index];
      final next = (existing.quantity + quantity).clamp(
        1,
        product.stockQuantity,
      );
      lines[index] = existing.copyWith(quantity: next);
    } else {
      lines.add(CartLine(product: product, quantity: quantity));
    }
    state = state.copyWith(lines: List<CartLine>.of(lines));
  }

  void increment(String productId) {
    final index = state.lines.indexWhere(
      (line) => line.product.id == productId,
    );
    if (index < 0) return;
    final line = state.lines[index];
    if (line.quantity >= line.product.stockQuantity) return;
    updateQuantity(productId, line.quantity + 1);
  }

  void decrement(String productId) {
    final index = state.lines.indexWhere(
      (line) => line.product.id == productId,
    );
    if (index < 0) return;
    final line = state.lines[index];
    updateQuantity(productId, line.quantity - 1);
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) return remove(productId);
    final lines = List<CartLine>.of(state.lines);
    final index = lines.indexWhere((line) => line.product.id == productId);
    if (index < 0) return;
    final line = lines[index];
    lines[index] = line.copyWith(
      quantity: quantity.clamp(1, line.product.stockQuantity),
    );
    state = state.copyWith(lines: lines);
  }

  void remove(String productId) {
    state = state.copyWith(
      lines: [
        for (final line in state.lines)
          if (line.product.id != productId) line,
      ],
    );
  }

  void clear() => state = const CartState();
}
