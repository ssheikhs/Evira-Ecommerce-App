import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';

/// A product category, e.g. slug `home-decoration`, name `Home Decoration`.
@immutable
class ProductCategory {
  final String slug;
  final String name;

  const ProductCategory({required this.slug, required this.name});

  /// Pseudo category that shows every product.
  static const ProductCategory all = ProductCategory(slug: '', name: 'All');

  bool get isAll => slug.isEmpty;

  factory ProductCategory.fromSlug(String slug) =>
      ProductCategory(slug: slug, name: Formatters.titleCase(slug));

  @override
  bool operator ==(Object other) =>
      other is ProductCategory && other.slug == slug;

  @override
  int get hashCode => slug.hashCode;
}
