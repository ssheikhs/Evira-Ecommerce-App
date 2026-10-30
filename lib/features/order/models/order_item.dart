import 'package:flutter/foundation.dart';

import '../../cart/models/cart_item.dart';

/// A snapshot of a cart line at the moment the order was placed.
/// Later price changes in the catalog do not change past orders.
@immutable
class OrderItem {
  final int productId;
  final String title;
  final String thumbnail;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.quantity,
  });

  double get lineTotal => price * quantity;

  factory OrderItem.fromCartItem(CartItem item) {
    return OrderItem(
      productId: item.product.id,
      title: item.product.title,
      thumbnail: item.product.thumbnail,
      price: item.product.price,
      quantity: item.quantity,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: (map['productId'] as num?)?.toInt() ?? 0,
      title: map['title']?.toString() ?? '',
      thumbnail: map['thumbnail']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'title': title,
    'thumbnail': thumbnail,
    'price': price,
    'quantity': quantity,
  };
}
