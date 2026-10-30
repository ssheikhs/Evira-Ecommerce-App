import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/cart/provider/cart_provider.dart';
import 'features/order/provider/order_provider.dart';
import 'features/product/provider/product_provider.dart';

class EviraApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final AuthProvider authProvider;
  final ProductProvider productProvider;
  final CartProvider cartProvider;
  final OrderProvider orderProvider;
  final GoRouter router;

  const EviraApp({
    super.key,
    required this.themeProvider,
    required this.authProvider,
    required this.productProvider,
    required this.cartProvider,
    required this.orderProvider,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: productProvider),
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: orderProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          routerConfig: router,
        ),
      ),
    );
  }
}
