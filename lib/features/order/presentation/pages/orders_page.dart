import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/state_message.dart';
import '../../provider/order_provider.dart';
import '../widgets/order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    // Refresh in case orders were placed on another device.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final orders = provider.orders;

    Widget body;
    if (provider.isLoadingOrders && orders.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (orders.isEmpty) {
      body = StateMessage(
        icon: Icons.receipt_long_outlined,
        title: 'No orders yet',
        message: 'Orders you place will show up here.',
        actionLabel: 'Start shopping',
        onAction: () => context.go(AppRouter.home),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: provider.loadOrders,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(
              order: order,
              onTap: () => context.push(AppRouter.orderDetails(order.id)),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: body,
        ),
      ),
    );
  }
}
