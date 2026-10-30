import 'package:flutter/foundation.dart';

import '../../product/models/product.dart';
import '../data/cart_repository.dart';
import '../models/cart_item.dart';

/// Cart state and price calculations.
class CartProvider extends ChangeNotifier {
  /// Orders at or above this subtotal ship for free.
  static const double freeDeliveryThreshold = 50;
  static const double deliveryCharge = 4.99;

  final CartRepository cartRepository;
  List<CartItem> _items;

  CartProvider({required this.cartRepository})
    : _items = cartRepository.loadCart();

  /// Read-only view so widgets cannot change the cart directly.
  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  double get deliveryFee {
    if (_items.isEmpty || subtotal >= freeDeliveryThreshold) return 0;
    return deliveryCharge;
  }

  double get total => subtotal + deliveryFee;

  /// How much more to spend to unlock free delivery (0 when unlocked).
  double get amountToFreeDelivery {
    final remaining = freeDeliveryThreshold - subtotal;
    return remaining > 0 ? remaining : 0;
  }

  int quantityOf(int productId) {
    return _items
            .where((item) => item.product.id == productId)
            .firstOrNull
            ?.quantity ??
        0;
  }

  bool contains(int productId) => quantityOf(productId) > 0;

  Future<void> addProduct(Product product, {int quantity = 1}) async {
    if (quantity <= 0) return;
    final index = _indexOf(product.id);
    if (index >= 0) {
      final current = _items[index];
      _items[index] = current.copyWith(
        product: product,
        quantity: _clampToStock(product, current.quantity + quantity),
      );
    } else {
      _items.add(
        CartItem(product: product, quantity: _clampToStock(product, quantity)),
      );
    }
    await _persist();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final index = _indexOf(productId);
    if (index < 0) return;
    if (quantity <= 0) {
      await removeProduct(productId);
      return;
    }
    final item = _items[index];
    _items[index] = item.copyWith(
      quantity: _clampToStock(item.product, quantity),
    );
    await _persist();
  }

  Future<void> increment(int productId) =>
      updateQuantity(productId, quantityOf(productId) + 1);

  Future<void> decrement(int productId) =>
      updateQuantity(productId, quantityOf(productId) - 1);

  Future<void> removeProduct(int productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    await _persist();
  }

  /// Puts a removed item back at its old position (used by "Undo").
  Future<void> restoreItem(CartItem item, int index) async {
    if (contains(item.product.id)) return;
    _items.insert(index.clamp(0, _items.length), item);
    await _persist();
  }

  Future<void> clear() async {
    _items = [];
    notifyListeners();
    await cartRepository.clearCart();
  }

  int _indexOf(int productId) =>
      _items.indexWhere((item) => item.product.id == productId);

  /// Never allow more than the available stock (when stock is known).
  int _clampToStock(Product product, int quantity) {
    if (product.stock <= 0) return quantity;
    return quantity > product.stock ? product.stock : quantity;
  }

  Future<void> _persist() async {
    notifyListeners();
    await cartRepository.saveCart(_items);
  }
}
