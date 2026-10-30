import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../provider/cart_provider.dart';

/// Cart icon with a live item-count badge. Opens the cart.
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<CartProvider, int>((cart) => cart.itemCount);

    return IconButton(
      tooltip: 'Cart',
      onPressed: () => context.push(AppRouter.cart),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}
