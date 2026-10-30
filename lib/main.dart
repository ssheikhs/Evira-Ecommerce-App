import 'package:flutter/material.dart';

import 'app.dart';
import 'core/constants/api_constants.dart';
import 'core/constants/payment_constants.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/preference_service.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/data/auth_remote_datasource.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/cart/data/cart_repository.dart';
import 'features/cart/provider/cart_provider.dart';
import 'features/order/data/order_repository.dart';
import 'features/order/provider/order_provider.dart';
import 'features/payment/data/payment_repository.dart';
import 'features/product/data/product_repository.dart';
import 'features/product/provider/product_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await PreferenceService.init();

  // Network clients: one per backend.
  final catalogClient = DioClient(preferenceService: prefs);
  final orderClient = DioClient(
    preferenceService: prefs,
    baseUrl: ApiConstants.orderBaseUrl,
    connectTimeout: const Duration(seconds: 4),
    attachAuthToken: false,
  );
  final paymentClient = DioClient(
    preferenceService: prefs,
    baseUrl: PaymentConstants.sandboxBaseUrl,
    attachAuthToken: false, // never send our token to a third party
  );

  // State.
  final authProvider = AuthProvider(
    authRepository: AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(dioClient: catalogClient),
      preferenceService: prefs,
    ),
  );
  final orderProvider = OrderProvider(
    orderRepository: OrderRepositoryImpl(
      dioClient: orderClient,
      preferenceService: prefs,
    ),
    paymentRepository: AamarPayRepository(dioClient: paymentClient),
  );

  // Keep order history in step with the signed-in user.
  orderProvider.onUserChanged(authProvider.user?.id);
  authProvider.addListener(
    () => orderProvider.onUserChanged(authProvider.user?.id),
  );

  runApp(
    EviraApp(
      themeProvider: ThemeProvider(preferenceService: prefs),
      authProvider: authProvider,
      productProvider: ProductProvider(
        productRepository: ProductRepositoryImpl(dioClient: catalogClient),
      ),
      cartProvider: CartProvider(
        cartRepository: CartRepositoryImpl(preferenceService: prefs),
      ),
      orderProvider: orderProvider,
      router: AppRouter.create(authProvider),
    ),
  );
}
