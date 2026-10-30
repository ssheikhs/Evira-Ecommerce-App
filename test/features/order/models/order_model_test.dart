import 'package:ecommerce_app/features/cart/models/cart_item.dart';
import 'package:ecommerce_app/features/order/models/order_item.dart';
import 'package:ecommerce_app/features/order/models/order_model.dart';
import 'package:ecommerce_app/features/order/models/order_status.dart';
import 'package:ecommerce_app/features/order/models/payment_method.dart';
import 'package:ecommerce_app/features/order/models/shipping_address.dart';
import 'package:ecommerce_app/features/product/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const address = ShippingAddress(
    fullName: 'Sheikh Sazzaduzzaman',
    phone: '01712345678',
    address: 'House 12, Road 5',
    city: 'Narayanganj',
    postalCode: '1400',
  );

  final order = OrderModel(
    id: 'EV-TEST-123',
    userId: 1,
    items: [
      OrderItem.fromCartItem(
        const CartItem(
          product: Product(
            id: 9,
            title: 'Watch',
            price: 25,
            thumbnail: 't.png',
          ),
          quantity: 2,
        ),
      ),
    ],
    subtotal: 50,
    deliveryFee: 0,
    total: 50,
    shippingAddress: address,
    paymentMethod: PaymentMethod.aamarPay,
    paymentStatus: PaymentStatus.paid,
    transactionId: 'EVTX-1',
    createdAt: DateTime.utc(2026, 10, 25, 12),
  );

  test('OrderItem snapshots the cart line', () {
    final item = order.items.single;
    expect(item.productId, 9);
    expect(item.title, 'Watch');
    expect(item.lineTotal, 50);
    expect(order.itemCount, 2);
  });

  test('toMap and fromMap round-trip', () {
    final copy = OrderModel.fromMap(order.toMap());

    expect(copy.id, order.id);
    expect(copy.userId, 1);
    expect(copy.items.single.quantity, 2);
    expect(copy.shippingAddress, address);
    expect(copy.paymentMethod, PaymentMethod.aamarPay);
    expect(copy.paymentStatus, PaymentStatus.paid);
    expect(copy.transactionId, 'EVTX-1');
    expect(copy.status, OrderStatus.confirmed);
    expect(copy.createdAt, order.createdAt);
  });

  test('unknown enum values fall back to safe defaults', () {
    expect(PaymentMethod.fromValue('bitcoin'), PaymentMethod.cashOnDelivery);
    expect(PaymentStatus.fromValue(null), PaymentStatus.unpaid);
    expect(OrderStatus.fromValue('lost'), OrderStatus.confirmed);
  });
}
