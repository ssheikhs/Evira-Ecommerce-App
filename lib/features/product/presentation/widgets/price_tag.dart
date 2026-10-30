import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../models/product.dart';

/// Current price with the original price struck through when discounted.
class PriceTag extends StatelessWidget {
  final Product product;
  final double fontSize;

  const PriceTag({super.key, required this.product, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 6,
      children: [
        Text(
          Formatters.price(product.price),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
        if (product.hasDiscount)
          Text(
            Formatters.price(product.originalPrice),
            style: TextStyle(
              fontSize: fontSize * 0.75,
              color: theme.colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

/// Small "-12%" badge.
class DiscountBadge extends StatelessWidget {
  final double percentage;

  const DiscountBadge({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.discount,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '-${percentage.round()}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Star icon with the numeric rating.
class RatingLabel extends StatelessWidget {
  final double rating;
  final int? reviewCount;

  const RatingLabel({super.key, required this.rating, this.reviewCount});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.rating),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        if (reviewCount != null)
          Text(' ($reviewCount)', style: TextStyle(fontSize: 12, color: muted)),
      ],
    );
  }
}
