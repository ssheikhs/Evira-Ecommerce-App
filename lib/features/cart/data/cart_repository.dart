import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/preference_service.dart';
import '../models/cart_item.dart';

/// Saves the cart on the device so it survives app restarts.
abstract class CartRepository {
  List<CartItem> loadCart();
  Future<void> saveCart(List<CartItem> items);
  Future<void> clearCart();
}

class CartRepositoryImpl implements CartRepository {
  final PreferenceService preferenceService;

  CartRepositoryImpl({required this.preferenceService});

  @override
  List<CartItem> loadCart() {
    return preferenceService
        .readJsonList(StorageKeys.cartItems)
        .map(CartItem.fromMap)
        .where((item) => item.product.id != 0 && item.quantity > 0)
        .toList();
  }

  @override
  Future<void> saveCart(List<CartItem> items) {
    return preferenceService.writeJsonList(
      StorageKeys.cartItems,
      items.map((item) => item.toMap()).toList(),
    );
  }

  @override
  Future<void> clearCart() => saveCart(const []);
}
