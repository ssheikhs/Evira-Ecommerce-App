import 'package:ecommerce_app/core/network/api_exceptions.dart';
import 'package:ecommerce_app/features/auth/models/user_model.dart';
import 'package:ecommerce_app/features/cart/models/cart_item.dart';
import 'package:ecommerce_app/features/order/data/order_repository.dart';
import 'package:ecommerce_app/features/order/models/order_model.dart';
import 'package:ecommerce_app/features/order/models/order_status.dart';
import 'package:ecommerce_app/features/order/models/payment_method.dart';
import 'package:ecommerce_app/features/order/models/shipping_address.dart';
import 'package:ecommerce_app/features/order/provider/order_provider.dart';
import 'package:ecommerce_app/features/payment/data/payment_repository.dart';
import 'package:ecommerce_app/features/payment/models/payment_session.dart';
import 'package:ecommerce_app/features/product/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeOrderRepository implements OrderRepository {
  final List<OrderModel> stored = [];

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    stored.add(order);
    return order;
  }

  @override
  Future<List<OrderModel>> getOrders({required int userId}) async =>
      stored.where((o) => o.userId == userId).toList();
}

class FakePaymentRepository implements PaymentRepository {
  bool shouldFail = false;

  @override
  Future<PaymentSession> createPayment({
    required String transactionId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    required String customerCity,
    required String description,
  }) async {
    if (shouldFail) throw const ApiException('Gateway down');
    return PaymentSession(
      transactionId: transactionId,
      paymentUrl: 'https://sandbox.example/pay',
    );
  }
}

void main() {
  const user = UserModel(
    id: 1,
    username: 'emilys',
    email: 'emily@example.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    address: '626 Main Street',
    city: 'Phoenix',
    postalCode: '29112',
  );
  const address = ShippingAddress(
    fullName: 'Emily Johnson',
    phone: '01712345678',
    address: '626 Main Street',
    city: 'Phoenix',
    postalCode: '29112',
  );
  const items = [
    CartItem(product: Product(id: 1, title: 'Phone', price: 20), quantity: 2),
  ];

  late FakeOrderRepository orders;
  late FakePaymentRepository payments;
  late OrderProvider provider;

  setUp(() {
    orders = FakeOrderRepository();
    payments = FakePaymentRepository();
    provider = OrderProvider(
      orderRepository: orders,
      paymentRepository: payments,
    );
    provider.onUserChanged(user.id);
  });

  Future<OrderModel?> place({String? transactionId}) => provider.placeOrder(
    user: user,
    items: items,
    subtotal: 40,
    deliveryFee: 4.99,
    total: 44.99,
    address: address,
    transactionId: transactionId,
  );

  test('cash on delivery orders are saved as unpaid', () async {
    final order = await place();

    expect(order, isNotNull);
    expect(order!.paymentMethod, PaymentMethod.cashOnDelivery);
    expect(order.paymentStatus, PaymentStatus.unpaid);
    expect(order.items.single.quantity, 2);
    expect(provider.orders.first.id, order.id);
    expect(orders.stored, hasLength(1));
  });

  test('orders with a transaction id are marked paid', () async {
    provider.selectPaymentMethod(PaymentMethod.aamarPay);
    final order = await place(transactionId: 'EVTX-1');

    expect(order!.paymentMethod, PaymentMethod.aamarPay);
    expect(order.paymentStatus, PaymentStatus.paid);
    // The method resets for the next checkout.
    expect(provider.paymentMethod, PaymentMethod.cashOnDelivery);
  });

  test('startOnlinePayment returns a session', () async {
    final session = await provider.startOnlinePayment(
      amount: 44.99,
      address: address,
      user: user,
      itemCount: 2,
    );
    expect(session, isNotNull);
    expect(session!.transactionId, startsWith('EVTX-'));
    expect(provider.isStartingPayment, isFalse);
  });

  test('startOnlinePayment reports gateway errors', () async {
    payments.shouldFail = true;
    final session = await provider.startOnlinePayment(
      amount: 44.99,
      address: address,
      user: user,
      itemCount: 2,
    );
    expect(session, isNull);
    expect(provider.checkoutError, 'Gateway down');
  });

  test('signing out clears the order history', () async {
    await place();
    provider.onUserChanged(null);
    expect(provider.orders, isEmpty);
  });

  test('addressFor pre-fills from the profile', () {
    final prefilled = provider.addressFor(user);
    expect(prefilled.fullName, 'Emily Johnson');
    expect(prefilled.city, 'Phoenix');
    expect(prefilled.phone, isEmpty); // asked for at checkout
  });
}
