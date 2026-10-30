import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/state_message.dart';
import '../../../cart/presentation/widgets/price_summary.dart';
import '../../models/order_item.dart';
import '../../models/order_model.dart';
import '../../provider/order_provider.dart';
import '../widgets/order_badges.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final order = provider.findOrder(orderId);

    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: order == null
          ? (provider.isLoadingOrders
                ? const Center(child: CircularProgressIndicator())
                : const StateMessage(
                    icon: Icons.search_off_rounded,
                    title: 'Order not found',
                    message: 'This order is not linked to your account.',
                  ))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _OrderDetails(order: order),
              ),
            ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  final OrderModel order;

  const _OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final address = order.shippingAddress;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${order.id}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Placed on ${Formatters.dateTime(order.createdAt)}',
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OrderStatusBadge(status: order.status),
                  PaymentStatusBadge(status: order.paymentStatus),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Items',
          icon: Icons.inventory_2_outlined,
          child: Column(
            children: [
              for (final item in order.items) _ItemRow(item: item),
              const Divider(height: 24),
              PriceSummary(
                itemCount: order.itemCount,
                subtotal: order.subtotal,
                deliveryFee: order.deliveryFee,
                total: order.total,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Delivery address',
          icon: Icons.location_on_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address.fullName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(address.phone, style: TextStyle(color: muted)),
              const SizedBox(height: 4),
              Text(address.singleLine, style: TextStyle(color: muted)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Payment',
          icon: Icons.payment_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(order.paymentMethod.icon, size: 20),
                  const SizedBox(width: 8),
                  Text(order.paymentMethod.title),
                ],
              ),
              if (order.transactionId != null) ...[
                const SizedBox(height: 8),
                SelectableText(
                  'Transaction ID: ${order.transactionId}',
                  style: TextStyle(color: muted),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 52,
              height: 52,
              child: AppNetworkImage(url: item.thumbnail, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${item.quantity} × ${Formatters.price(item.price)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.price(item.lineTotal),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
