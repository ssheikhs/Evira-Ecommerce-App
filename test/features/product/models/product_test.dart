import 'package:ecommerce_app/features/product/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product.fromMap', () {
    test('parses a DummyJSON product', () {
      final product = Product.fromMap({
        'id': 1,
        'title': 'Essence Mascara',
        'category': 'beauty',
        'price': 9.99,
        'discountPercentage': 10,
        'rating': 4.94,
        'stock': 5,
        'thumbnail': 'https://example.com/thumb.png',
        'images': ['https://example.com/1.png'],
        'reviews': [
          {'rating': 5, 'comment': 'Great!', 'reviewerName': 'Ana'},
        ],
      });

      expect(product.id, 1);
      expect(product.title, 'Essence Mascara');
      expect(product.price, 9.99);
      expect(product.inStock, isTrue);
      expect(product.reviews.single.reviewerName, 'Ana');
    });

    test('uses safe defaults when fields are missing or null', () {
      final product = Product.fromMap({'id': 7, 'title': null});

      expect(product.title, '');
      expect(product.price, 0);
      expect(product.images, isEmpty);
      expect(product.reviews, isEmpty);
      expect(product.inStock, isFalse);
    });
  });

  test('originalPrice reverses the discount', () {
    const product = Product(
      id: 1,
      title: 'Bag',
      price: 80,
      discountPercentage: 20,
    );
    expect(product.hasDiscount, isTrue);
    expect(product.originalPrice, closeTo(100, 0.001));
  });

  test('gallery falls back to the thumbnail', () {
    const product = Product(id: 1, title: 'Lamp', thumbnail: 'thumb.png');
    expect(product.gallery, ['thumb.png']);
  });

  test('toMap and fromMap round-trip', () {
    const original = Product(
      id: 3,
      title: 'Phone',
      price: 499,
      stock: 12,
      images: ['a.png', 'b.png'],
    );
    final copy = Product.fromMap(original.toMap());

    expect(copy, original);
    expect(copy.images, original.images);
    expect(copy.stock, 12);
  });
}
