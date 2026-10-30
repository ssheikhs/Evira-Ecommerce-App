import 'package:flutter/foundation.dart';

import 'review.dart';

/// A product from the DummyJSON catalog.
///
/// The class is immutable: every field is `final`, so a [Product] can be
/// shared safely between the list, details page and cart. To change a value,
/// create a new instance with [copyWith].
@immutable
class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String availabilityStatus;
  final String warrantyInformation;
  final String shippingInformation;
  final String returnPolicy;
  final String thumbnail;
  final List<String> images;
  final List<Review> reviews;

  const Product({
    required this.id,
    required this.title,
    this.description = '',
    this.category = '',
    this.brand = '',
    this.price = 0,
    this.discountPercentage = 0,
    this.rating = 0,
    this.stock = 0,
    this.availabilityStatus = '',
    this.warrantyInformation = '',
    this.shippingInformation = '',
    this.returnPolicy = '',
    this.thumbnail = '',
    this.images = const [],
    this.reviews = const [],
  });

  bool get inStock => stock > 0;

  bool get hasDiscount => discountPercentage >= 1;

  /// Price before the discount, shown with a strike-through.
  double get originalPrice {
    if (!hasDiscount || discountPercentage >= 100) return price;
    return price / (1 - discountPercentage / 100);
  }

  /// All images to show in the gallery, falling back to the thumbnail.
  List<String> get gallery =>
      images.isNotEmpty ? images : [if (thumbnail.isNotEmpty) thumbnail];

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (map['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      availabilityStatus: map['availabilityStatus']?.toString() ?? '',
      warrantyInformation: map['warrantyInformation']?.toString() ?? '',
      shippingInformation: map['shippingInformation']?.toString() ?? '',
      returnPolicy: map['returnPolicy']?.toString() ?? '',
      thumbnail: map['thumbnail']?.toString() ?? '',
      images: _stringList(map['images']),
      reviews: map['reviews'] is List
          ? (map['reviews'] as List)
                .whereType<Map>()
                .map((e) => Review.fromMap(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'brand': brand,
    'price': price,
    'discountPercentage': discountPercentage,
    'rating': rating,
    'stock': stock,
    'availabilityStatus': availabilityStatus,
    'warrantyInformation': warrantyInformation,
    'shippingInformation': shippingInformation,
    'returnPolicy': returnPolicy,
    'thumbnail': thumbnail,
    'images': images,
    'reviews': reviews.map((r) => r.toMap()).toList(),
  };

  Product copyWith({String? title, double? price, int? stock, double? rating}) {
    return Product(
      id: id,
      title: title ?? this.title,
      description: description,
      category: category,
      brand: brand,
      price: price ?? this.price,
      discountPercentage: discountPercentage,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      availabilityStatus: availabilityStatus,
      warrantyInformation: warrantyInformation,
      shippingInformation: shippingInformation,
      returnPolicy: returnPolicy,
      thumbnail: thumbnail,
      images: images,
      reviews: reviews,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, title: $title, price: $price)';
}
