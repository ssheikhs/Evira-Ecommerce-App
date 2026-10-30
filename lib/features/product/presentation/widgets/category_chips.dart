import 'package:flutter/material.dart';

import '../../models/product_category.dart';

/// Horizontally scrolling category filter.
class CategoryChips extends StatelessWidget {
  final List<ProductCategory> categories;
  final ProductCategory selected;
  final ValueChanged<ProductCategory> onSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          return ChoiceChip(
            label: Text(category.name),
            selected: category == selected,
            showCheckmark: false,
            onSelected: (_) => onSelected(category),
          );
        },
      ),
    );
  }
}
