import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/signin_page.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/order/presentation/pages/checkout_page.dart';
import '../../features/order/presentation/pages/order_details_page.dart';
import '../../features/order/presentation/pages/order_success_page.dart';
import '../../features/order/presentation/pages/orders_page.dart';
import '../../features/payment/models/payment_session.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../features/product/presentation/pages/product_details_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../widgets/state_message.dart';

/// All app routes. Every page is nested under home, so `context.go()` to
/// any path still leaves a sensible back stack (e.g. Home > Orders > Order).
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String cart = '/cart';
  static const String signin = '/signin';
  static const String profile = '/profile';
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String orders = '/orders';

  static String product(int id) => '/product/$id';
  static String orderDetails(String id) => '/orders/$id';
  static String orderSuccess(String id) => '/order-success/$id';

  /// Pages that need a signed-in user.
  static const List<String> _protected = [
    profile,
    checkout,
    payment,
    orders,
    '/order-success',
  ];

  static GoRouter create(AuthProvider auth) {
    return GoRouter(
      initialLocation: home,
      refreshListenable: auth,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final needsAuth = _protected.any(
          (path) => location == path || location.startsWith('$path/'),
        );
        if (needsAuth && !auth.isAuthenticated) {
          return Uri(
            path: signin,
            queryParameters: {'redirect': state.uri.toString()},
          ).toString();
        }
        return null;
      },
      routes: [
        GoRoute(
          path: home,
          builder: (context, state) => const ProductListPage(),
          routes: [
            GoRoute(
              path: 'product/:id',
              builder: (context, state) => ProductDetailsPage(
                productId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
            ),
            GoRoute(
              path: 'cart',
              builder: (context, state) => const CartPage(),
            ),
            GoRoute(
              path: 'signin',
              builder: (context, state) =>
                  SignInPage(redirect: state.uri.queryParameters['redirect']),
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: 'checkout',
              builder: (context, state) => const CheckoutPage(),
            ),
            GoRoute(
              path: 'payment',
              // A payment page only makes sense with a session from checkout.
              redirect: (context, state) =>
                  state.extra is PaymentSession ? null : cart,
              builder: (context, state) =>
                  PaymentPage(session: state.extra! as PaymentSession),
            ),
            GoRoute(
              path: 'orders',
              builder: (context, state) => const OrdersPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      OrderDetailsPage(orderId: state.pathParameters['id']!),
                ),
              ],
            ),
            GoRoute(
              path: 'order-success/:id',
              builder: (context, state) =>
                  OrderSuccessPage(orderId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(),
        body: StateMessage(
          icon: Icons.explore_off_outlined,
          title: 'Page not found',
          message: 'We could not find "${state.uri.path}".',
          actionLabel: 'Back to shop',
          onAction: () => context.go(home),
        ),
      ),
    );
  }
}
