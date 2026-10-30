import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/provider/cart_provider.dart';
import '../../models/product.dart';
import 'price_tag.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inCart = context.select<CartProvider, bool>(
      (cart) => cart.contains(product.id),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRouter.product(product.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      padding: const EdgeInsets.all(12),
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: AppNetworkImage(
                          url: product.thumbnail,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: DiscountBadge(
                        percentage: product.discountPercentage,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RatingLabel(rating: product.rating),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: PriceTag(product: product, fontSize: 15)),
                      _AddButton(product: product, inCart: inCart),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final Product product;
  final bool inCart;

  const _AddButton({required this.product, required this.inCart});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton.filled(
        padding: EdgeInsets.zero,
        iconSize: 18,
        tooltip: inCart ? 'In cart' : 'Add to cart',
        style: IconButton.styleFrom(
          backgroundColor: inCart ? colors.primaryContainer : colors.primary,
          foregroundColor: inCart ? colors.primary : colors.onPrimary,
        ),
        onPressed: product.inStock
            ? () {
                context.read<CartProvider>().addProduct(product);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('${product.title} added to cart'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'VIEW CART',
                        onPressed: () => context.push(AppRouter.cart),
                      ),
                    ),
                  );
              }
            : null,
        icon: Icon(inCart ? Icons.check : Icons.add),
      ),
    );
  }
}
