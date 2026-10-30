import 'package:flutter/foundation.dart';

import '../../product/models/product.dart';

/// One product line in the cart. Immutable: change it with [copyWith].
@immutable
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  double get lineTotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(
        Map<String, dynamic>.from(map['product'] as Map? ?? const {}),
      ),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'product': product.toMap(),
    'quantity': quantity,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          other.product == product &&
          other.quantity == quantity;

  @override
  int get hashCode => Object.hash(product, quantity);
}
