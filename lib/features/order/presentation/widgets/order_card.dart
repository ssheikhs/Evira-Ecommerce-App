import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../models/order_model.dart';
import 'order_badges.dart';

/// Compact order row for the order history list.
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final previews = order.items.take(4).toList();
    final hiddenCount = order.items.length - previews.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.dateTime(order.createdAt),
                style: TextStyle(fontSize: 12, color: muted),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final item in previews)
                    Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AppNetworkImage(
                        url: item.thumbnail,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (hiddenCount > 0)
                    Text('+$hiddenCount', style: TextStyle(color: muted)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}'
                      '  •  ${order.paymentMethod.title}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Formatters.price(order.total),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
