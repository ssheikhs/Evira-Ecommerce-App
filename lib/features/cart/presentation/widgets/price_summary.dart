import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';

/// Subtotal / delivery / total breakdown, used by cart, checkout and orders.
class PriceSummary extends StatelessWidget {
  final int itemCount;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const PriceSummary({
    super.key,
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _Row(
          label: 'Subtotal ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
          value: Formatters.price(subtotal),
        ),
        const SizedBox(height: 8),
        _Row(
          label: 'Delivery',
          value: deliveryFee == 0 ? 'FREE' : Formatters.price(deliveryFee),
          valueColor: deliveryFee == 0 ? AppColors.success : null,
        ),
        const Divider(height: 24),
        Row(
          children: [
            Text(
              'Total',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              Formatters.price(total),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Text(label, style: TextStyle(color: muted)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }
}
