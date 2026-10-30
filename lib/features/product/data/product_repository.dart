import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../models/product_category.dart';
import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({String? categorySlug, String? query});
  Future<Product> getProductById(int id);
  Future<List<ProductCategory>> getCategories();
}

class ProductRepositoryImpl implements ProductRepository {
  final DioClient dioClient;

  ProductRepositoryImpl({required this.dioClient});

  @override
  Future<List<Product>> getProducts({
    String? categorySlug,
    String? query,
  }) async {
    final search = query?.trim() ?? '';
    final String path;
    final params = <String, dynamic>{'limit': 0};

    if (search.isNotEmpty) {
      path = ApiConstants.productSearch;
      params['q'] = search;
    } else if (categorySlug != null && categorySlug.isNotEmpty) {
      path = ApiConstants.productsByCategory(categorySlug);
    } else {
      path = ApiConstants.products;
    }

    final response = await dioClient.get(path, queryParameters: params);
    final data = response.data;
    if (data is Map && data['products'] is List) {
      return (data['products'] as List)
          .whereType<Map>()
          .map((e) => Product.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw const ServerException('Unexpected response while loading products.');
  }

  @override
  Future<Product> getProductById(int id) async {
    final response = await dioClient.get(ApiConstants.productById(id));
    final data = response.data;
    if (data is Map) {
      return Product.fromMap(Map<String, dynamic>.from(data));
    }
    throw const NotFoundException('Product not found.');
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    final response = await dioClient.get(ApiConstants.productCategoryList);
    final data = response.data;
    if (data is List) {
      return data
          .map((slug) => ProductCategory.fromSlug(slug.toString()))
          .toList();
    }
    return const [];
  }
}
