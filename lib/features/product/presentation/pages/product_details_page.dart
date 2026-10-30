import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/state_message.dart';
import '../../../cart/presentation/widgets/cart_icon_button.dart';
import '../../../cart/presentation/widgets/quantity_selector.dart';
import '../../../cart/provider/cart_provider.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../provider/product_provider.dart';
import '../widgets/price_tag.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductDetails(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final product = provider.selectedProduct?.id == widget.productId
        ? provider.selectedProduct
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: const [CartIconButton(), SizedBox(width: 4)],
      ),
      body: _buildBody(provider, product),
      bottomNavigationBar: product == null ? null : _buildBottomBar(product),
    );
  }

  Widget _buildBody(ProductProvider provider, Product? product) {
    if (product == null) {
      if (provider.detailsError != null) {
        return StateMessage(
          icon: Icons.error_outline,
          title: 'Could not load this product',
          message: provider.detailsError,
          actionLabel: 'Try again',
          onAction: () => provider.loadProductDetails(widget.productId),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        final gallery = _Gallery(product: product);
        final info = _ProductInfo(product: product);

        if (isWide) {
          // Tablet / landscape: gallery and details side by side.
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: gallery,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                      child: info,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          children: [
            gallery,
            Padding(padding: const EdgeInsets.all(16), child: info),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(Product product) {
    final cart = context.watch<CartProvider>();
    final inCart = cart.quantityOf(product.id);
    final maxQuantity = product.stock > 0 ? product.stock : 99;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: !product.inStock
            ? const FilledButton(onPressed: null, child: Text('Out of stock'))
            : Row(
                children: [
                  QuantitySelector(
                    quantity: _quantity,
                    onDecrement: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    onIncrement: _quantity < maxQuantity
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(
                        inCart > 0
                            ? 'Add more ($inCart in cart)'
                            : 'Add to cart',
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () => _addToCart(product),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    final messenger = ScaffoldMessenger.of(context);
    await context.read<CartProvider>().addProduct(product, quantity: _quantity);
    if (!mounted) return;
    setState(() => _quantity = 1);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Added to cart'),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () => context.push(AppRouter.cart),
          ),
        ),
      );
  }
}

class _Gallery extends StatefulWidget {
  final Product product;

  const _Gallery({required this.product});

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.gallery;
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.isEmpty ? 1 : images.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) {
                final image = AppNetworkImage(
                  url: images.isEmpty ? '' : images[index],
                  fit: BoxFit.contain,
                );
                return Padding(
                  padding: const EdgeInsets.all(24),
                  // Same Hero tag as the card, so the image flies in.
                  child: index == 0
                      ? Hero(tag: 'product-${widget.product.id}', child: image)
                      : image,
                );
              },
            ),
            if (images.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    final active = index == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active ? colors.primary : colors.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final Product product;

  const _ProductInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          [
            if (product.brand.isNotEmpty) product.brand,
            Formatters.titleCase(product.category),
          ].join('  •  '),
          style: TextStyle(color: muted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          product.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            RatingLabel(
              rating: product.rating,
              reviewCount: product.reviews.length,
            ),
            const SizedBox(width: 12),
            _StockChip(product: product),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            PriceTag(product: product, fontSize: 26),
            const SizedBox(width: 10),
            if (product.hasDiscount)
              DiscountBadge(percentage: product.discountPercentage),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(product.description, style: TextStyle(color: muted, height: 1.5)),
        const SizedBox(height: 20),
        _InfoTile(
          icon: Icons.local_shipping_outlined,
          text: product.shippingInformation,
        ),
        _InfoTile(
          icon: Icons.verified_user_outlined,
          text: product.warrantyInformation,
        ),
        _InfoTile(
          icon: Icons.assignment_return_outlined,
          text: product.returnPolicy,
        ),
        if (product.reviews.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Reviews',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...product.reviews.map((review) => _ReviewTile(review: review)),
        ],
      ],
    );
  }
}

class _StockChip extends StatelessWidget {
  final Product product;

  const _StockChip({required this.product});

  @override
  Widget build(BuildContext context) {
    final lowStock = product.inStock && product.stock <= 10;
    final color = !product.inStock
        ? AppColors.error
        : lowStock
        ? AppColors.warning
        : AppColors.success;
    final label = !product.inStock
        ? 'Out of stock'
        : lowStock
        ? 'Only ${product.stock} left'
        : 'In stock';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            child: Text(
              review.reviewerName.isEmpty ? '?' : review.reviewerName[0],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < review.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: AppColors.rating,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(review.comment, style: TextStyle(color: muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
