import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/section_card.dart';
import '../../models/order_model.dart';
import '../../provider/order_provider.dart';

class OrderSuccessPage extends StatelessWidget {
  final String orderId;

  const OrderSuccessPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.select<OrderProvider, OrderModel?>(
      (orders) => orders.findOrder(orderId),
    );
    final theme = Theme.of(context);

    // Back from here returns to the shop, not to the finished checkout.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRouter.home);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SuccessIcon(),
                    const SizedBox(height: 24),
                    Text(
                      'Order placed!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thank you for shopping with us. We will deliver your '
                      'order within 3 to 5 working days.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (order != null) _OrderFacts(order: order),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go(AppRouter.home),
                      child: const Text('Continue shopping'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      // Nested routes give the stack Home > Orders > Details.
                      onPressed: () =>
                          context.go(AppRouter.orderDetails(orderId)),
                      child: const Text('View order details'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Center(
        child: CircleAvatar(
          radius: 52,
          backgroundColor: AppColors.success.withValues(alpha: 0.12),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 72,
            color: AppColors.success,
          ),
        ),
      ),
    );
  }
}

class _OrderFacts extends StatelessWidget {
  final OrderModel order;

  const _OrderFacts({required this.order});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          _Fact(label: 'Order number', value: '#${order.id}'),
          _Fact(label: 'Amount', value: Formatters.price(order.total)),
          _Fact(label: 'Payment', value: order.paymentMethod.title),
          _Fact(label: 'Status', value: order.paymentStatus.label),
          if (order.transactionId != null)
            _Fact(label: 'Transaction ID', value: order.transactionId!),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;

  const _Fact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
