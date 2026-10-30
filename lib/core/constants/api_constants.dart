import 'package:flutter/foundation.dart';

/// Base URLs, endpoints and timeouts used by the network layer.
class ApiConstants {
  ApiConstants._();

  /// Public catalog and auth API.
  static const String baseUrl = 'https://dummyjson.com';

  /// Local json-server that stores placed orders (see `mock_server/`).
  ///
  /// Override it for a real device on the same Wi-Fi:
  /// `flutter run --dart-define=ORDER_API_URL=http://192.168.0.105:3001`
  static String get orderBaseUrl {
    const fromEnv = String.fromEnvironment('ORDER_API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    // The Android emulator reaches the host machine through 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Products
  static const String products = '/products';
  static const String productSearch = '/products/search';
  static const String productCategoryList = '/products/category-list';
  static String productsByCategory(String slug) => '/products/category/$slug';
  static String productById(int id) => '/products/$id';

  // Auth
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';

  // Orders (mock server)
  static const String orders = '/orders';
}
