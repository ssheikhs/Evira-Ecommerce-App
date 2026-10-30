import 'package:ecommerce_app/features/cart/data/cart_repository.dart';
import 'package:ecommerce_app/features/cart/models/cart_item.dart';
import 'package:ecommerce_app/features/cart/provider/cart_provider.dart';
import 'package:ecommerce_app/features/product/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory cart storage for tests.
class FakeCartRepository implements CartRepository {
  List<CartItem> saved;

  FakeCartRepository([List<CartItem>? initial]) : saved = initial ?? [];

  @override
  List<CartItem> loadCart() => List.of(saved);

  @override
  Future<void> saveCart(List<CartItem> items) async => saved = List.of(items);

  @override
  Future<void> clearCart() async => saved = [];
}

void main() {
  const phone = Product(id: 1, title: 'Phone', price: 20, stock: 3);
  const phoneCase = Product(id: 2, title: 'Case', price: 5, stock: 50);

  late FakeCartRepository repository;
  late CartProvider cart;

  setUp(() {
    repository = FakeCartRepository();
    cart = CartProvider(cartRepository: repository);
  });

  test('starts with the saved cart', () {
    final provider = CartProvider(
      cartRepository: FakeCartRepository([
        const CartItem(product: phone, quantity: 2),
      ]),
    );
    expect(provider.itemCount, 2);
  });

  test('adding the same product increases its quantity', () async {
    await cart.addProduct(phone);
    await cart.addProduct(phone);

    expect(cart.items, hasLength(1));
    expect(cart.quantityOf(phone.id), 2);
    expect(repository.saved.single.quantity, 2);
  });

  test('quantity never goes above stock', () async {
    await cart.addProduct(phone, quantity: 10);
    expect(cart.quantityOf(phone.id), 3);
  });

  test('decrementing to zero removes the item', () async {
    await cart.addProduct(phoneCase);
    await cart.decrement(phoneCase.id);

    expect(cart.isEmpty, isTrue);
    expect(repository.saved, isEmpty);
  });

  test('restoreItem puts a removed item back', () async {
    await cart.addProduct(phone);
    await cart.addProduct(phoneCase);
    final removed = cart.items.first;

    await cart.removeProduct(phone.id);
    await cart.restoreItem(removed, 0);

    expect(cart.items.first.product, phone);
  });

  group('totals', () {
    test('charges delivery below the free-delivery threshold', () async {
      await cart.addProduct(phone); // 20
      await cart.addProduct(phoneCase, quantity: 2); // 10

      expect(cart.subtotal, 30);
      expect(cart.deliveryFee, CartProvider.deliveryCharge);
      expect(cart.total, 30 + CartProvider.deliveryCharge);
      expect(cart.amountToFreeDelivery, 20);
    });

    test('delivery is free at or above the threshold', () async {
      await cart.addProduct(phoneCase, quantity: 10); // 50

      expect(cart.deliveryFee, 0);
      expect(cart.total, 50);
    });

    test('an empty cart has no delivery fee', () {
      expect(cart.deliveryFee, 0);
      expect(cart.total, 0);
    });
  });

  test('clear empties the cart and storage', () async {
    await cart.addProduct(phone);
    await cart.clear();

    expect(cart.isEmpty, isTrue);
    expect(repository.saved, isEmpty);
  });
}
