import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../auth/models/user_model.dart';
import '../../cart/models/cart_item.dart';
import '../../payment/data/payment_repository.dart';
import '../../payment/models/payment_session.dart';
import '../data/order_repository.dart';
import '../models/order_item.dart';
import '../models/order_model.dart';
import '../models/order_status.dart';
import '../models/payment_method.dart';
import '../models/shipping_address.dart';

/// Checkout, online payment and order history state.
class OrderProvider extends ChangeNotifier {
  final OrderRepository orderRepository;
  final PaymentRepository paymentRepository;

  OrderProvider({
    required this.orderRepository,
    required this.paymentRepository,
  });

  final Random _random = Random();

  PaymentMethod _paymentMethod = PaymentMethod.cashOnDelivery;
  bool _isStartingPayment = false;
  bool _isPlacingOrder = false;
  String? _checkoutError;

  List<OrderModel> _orders = [];
  bool _isLoadingOrders = false;
  int? _userId;

  PaymentMethod get paymentMethod => _paymentMethod;
  bool get isStartingPayment => _isStartingPayment;
  bool get isPlacingOrder => _isPlacingOrder;
  bool get isBusy => _isStartingPayment || _isPlacingOrder;
  String? get checkoutError => _checkoutError;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoadingOrders => _isLoadingOrders;

  OrderModel? findOrder(String id) =>
      _orders.where((order) => order.id == id).firstOrNull;

  /// Called whenever the signed-in user changes.
  void onUserChanged(int? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _orders = [];
    _paymentMethod = PaymentMethod.cashOnDelivery;
    _checkoutError = null;
    notifyListeners();
    if (userId != null) loadOrders();
  }

  void selectPaymentMethod(PaymentMethod method) {
    if (method == _paymentMethod) return;
    _paymentMethod = method;
    notifyListeners();
  }

  /// Pre-fills the checkout form from the user's profile.
  ShippingAddress addressFor(UserModel? user) {
    if (user == null) return ShippingAddress.empty;
    return ShippingAddress(
      fullName: user.fullName,
      phone: '',
      address: user.address,
      city: user.city,
      postalCode: user.postalCode,
    );
  }

  /// Creates an aamarPay session. Returns `null` and sets [checkoutError]
  /// when the gateway cannot be reached.
  Future<PaymentSession?> startOnlinePayment({
    required double amount,
    required ShippingAddress address,
    required UserModel user,
    required int itemCount,
  }) async {
    _isStartingPayment = true;
    _checkoutError = null;
    notifyListeners();

    try {
      return await paymentRepository.createPayment(
        transactionId: _newId('EVTX'),
        amount: amount,
        customerName: address.fullName,
        customerEmail: user.email,
        customerPhone: address.phone,
        customerAddress: address.address,
        customerCity: address.city,
        description: 'Evira order: $itemCount item(s)',
      );
    } catch (e) {
      _checkoutError = e.toString();
      return null;
    } finally {
      _isStartingPayment = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> placeOrder({
    required UserModel user,
    required List<CartItem> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required ShippingAddress address,
    String? transactionId,
  }) async {
    _isPlacingOrder = true;
    _checkoutError = null;
    notifyListeners();

    try {
      final order = OrderModel(
        id: _newId('EV'),
        userId: user.id,
        items: items.map(OrderItem.fromCartItem).toList(),
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        shippingAddress: address,
        paymentMethod: _paymentMethod,
        paymentStatus: transactionId != null
            ? PaymentStatus.paid
            : PaymentStatus.unpaid,
        transactionId: transactionId,
        createdAt: DateTime.now(),
      );

      final placed = await orderRepository.placeOrder(order);
      _orders = [placed, ..._orders.where((o) => o.id != placed.id)];
      _paymentMethod = PaymentMethod.cashOnDelivery;
      return placed;
    } catch (e) {
      _checkoutError = e.toString();
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoadingOrders = true;
    notifyListeners();

    try {
      final result = await orderRepository.getOrders(userId: userId);
      if (userId == _userId) _orders = result;
    } catch (_) {
      // Repository already falls back to saved orders; keep what we have.
    }

    _isLoadingOrders = false;
    notifyListeners();
  }

  void clearCheckoutError() {
    if (_checkoutError == null) return;
    _checkoutError = null;
    notifyListeners();
  }

  /// Short, readable, unique id such as `EV-MH2K9Q-482`.
  String _newId(String prefix) {
    final time = DateTime.now().millisecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase();
    final suffix = 100 + _random.nextInt(900);
    return '$prefix-$time-$suffix';
  }
}
