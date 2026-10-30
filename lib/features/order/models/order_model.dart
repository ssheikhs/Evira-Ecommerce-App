import 'package:flutter/foundation.dart';

import 'order_item.dart';
import 'order_status.dart';
import 'payment_method.dart';
import 'shipping_address.dart';

@immutable
class OrderModel {
  final String id;
  final int userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final ShippingAddress shippingAddress;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? transactionId;
  final OrderStatus status;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    this.status = OrderStatus.confirmed,
    required this.createdAt,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toString() ?? '',
      userId: (map['userId'] as num?)?.toInt() ?? 0,
      items: map['items'] is List
          ? (map['items'] as List)
                .whereType<Map>()
                .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      shippingAddress: map['shippingAddress'] is Map
          ? ShippingAddress.fromMap(
              Map<String, dynamic>.from(map['shippingAddress'] as Map),
            )
          : ShippingAddress.empty,
      paymentMethod: PaymentMethod.fromValue(map['paymentMethod']?.toString()),
      paymentStatus: PaymentStatus.fromValue(map['paymentStatus']?.toString()),
      transactionId: map['transactionId']?.toString(),
      status: OrderStatus.fromValue(map['status']?.toString()),
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'items': items.map((item) => item.toMap()).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'shippingAddress': shippingAddress.toMap(),
    'paymentMethod': paymentMethod.value,
    'paymentStatus': paymentStatus.value,
    'transactionId': transactionId,
    'status': status.value,
    'createdAt': createdAt.toIso8601String(),
  };
}
