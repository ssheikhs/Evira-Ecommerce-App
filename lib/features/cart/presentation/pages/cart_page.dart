import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_message.dart';
import '../../models/cart_item.dart';
import '../../provider/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/price_summary.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(cart.isEmpty ? 'My cart' : 'My cart (${cart.itemCount})'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.isEmpty
          ? StateMessage(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              message: 'Browse the catalog and add something you like.',
              actionLabel: 'Start shopping',
              onAction: () => context.go(AppRouter.home),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final list = _CartList(items: cart.items);
                final summary = _CheckoutPanel(cart: cart);

                // Wide screens: list on the left, summary pinned on the right.
                if (constraints.maxWidth >= 840) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: list),
                          SizedBox(
                            width: 360,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                              child: summary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(child: list),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: summary,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<CartProvider>().clear();
    }
  }
}

class _CartList extends StatelessWidget {
  final List<CartItem> items;

  const _CartList({required this.items});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final id = item.product.id;

        void remove() {
          cart.removeProduct(id);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('${item.product.title} removed'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () => cart.restoreItem(item, index),
                ),
              ),
            );
        }

        return Dismissible(
          key: ValueKey('cart-$id'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => remove(),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: CartItemTile(
            item: item,
            onIncrement: () => cart.increment(id),
            onDecrement: () => cart.decrement(id),
            onRemove: remove,
          ),
        );
      },
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  final CartProvider cart;

  const _CheckoutPanel({required this.cart});

  @override
  Widget build(BuildContext context) {
    final freeDeliveryGap = cart.amountToFreeDelivery;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (freeDeliveryGap > 0) ...[
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add ${Formatters.price(freeDeliveryGap)} more for free delivery',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: cart.subtotal / CartProvider.freeDeliveryThreshold,
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
            ],
            PriceSummary(
              itemCount: cart.itemCount,
              subtotal: cart.subtotal,
              deliveryFee: cart.deliveryFee,
              total: cart.total,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              // The router sends signed-out users to sign in first.
              onPressed: () => context.push(AppRouter.checkout),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Proceed to checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
