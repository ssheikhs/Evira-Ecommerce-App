import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/state_message.dart';
import '../../../auth/provider/auth_provider.dart';
import '../../../cart/presentation/widgets/cart_icon_button.dart';
import '../../provider/product_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_card.dart';

/// Home screen: search, category filter and a responsive product grid.
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch(ProductProvider provider) {
    _searchController.clear();
    provider.search('');
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final isSignedIn = context.select<AuthProvider, bool>(
      (auth) => auth.isAuthenticated,
    );

    return Scaffold(
      appBar: AppBar(
        title: const _BrandTitle(),
        actions: [
          IconButton(
            tooltip: isSignedIn ? 'My account' : 'Sign in',
            icon: Icon(
              isSignedIn ? Icons.account_circle : Icons.account_circle_outlined,
            ),
            onPressed: () =>
                context.push(isSignedIn ? AppRouter.profile : AppRouter.signin),
          ),
          const CartIconButton(),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    provider.search(value);
                    setState(() {}); // show / hide the clear button
                  },
                  decoration: InputDecoration(
                    hintText: 'Search phones, laptops, beauty...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () => _clearSearch(provider),
                          ),
                  ),
                ),
              ),
              CategoryChips(
                categories: provider.categories,
                selected: provider.selectedCategory,
                onSelected: (category) {
                  _searchController.clear();
                  provider.selectCategory(category);
                },
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(provider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.products.isEmpty) {
      return StateMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load products',
        message: provider.errorMessage,
        actionLabel: 'Try again',
        onAction: provider.loadProducts,
      );
    }

    if (provider.products.isEmpty) {
      return StateMessage(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message: provider.query.isEmpty
            ? 'This category is empty right now.'
            : 'Nothing matches "${provider.query}". Try another word.',
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadProducts,
      child: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            // Columns grow with screen width: 2 on phones, more on tablets.
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisExtent: 290,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.products.length,
            itemBuilder: (context, index) =>
                ProductCard(product: provider.products[index]),
          ),
          if (provider.isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.shopping_bag, color: colors.onPrimary, size: 18),
        ),
        const SizedBox(width: 10),
        const Text(
          AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ],
    );
  }
}
