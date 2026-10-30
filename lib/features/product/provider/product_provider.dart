import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/product_repository.dart';
import '../models/product_category.dart';
import '../models/product.dart';

/// Holds the catalog: products, categories, search and the opened product.
class ProductProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  ProductProvider({required this.productRepository, bool autoLoad = true}) {
    if (autoLoad) {
      loadProducts();
      loadCategories();
    }
  }

  List<Product> _products = [];
  List<ProductCategory> _categories = [ProductCategory.all];
  ProductCategory _selectedCategory = ProductCategory.all;
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  Product? _selectedProduct;
  bool _isLoadingDetails = false;
  String? _detailsError;

  Timer? _searchDebounce;
  int _requestId = 0;

  List<Product> get products => _products;
  List<ProductCategory> get categories => _categories;
  ProductCategory get selectedCategory => _selectedCategory;
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Product? get selectedProduct => _selectedProduct;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get detailsError => _detailsError;

  Future<void> loadProducts() async {
    // Ignore responses from older requests (e.g. fast typing in search).
    final requestId = ++_requestId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await productRepository.getProducts(
        categorySlug: _selectedCategory.slug,
        query: _query,
      );
      if (requestId != _requestId) return;
      _products = result;
    } catch (e) {
      if (requestId != _requestId) return;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      final fetched = await productRepository.getCategories();
      _categories = [ProductCategory.all, ...fetched];
      notifyListeners();
    } catch (_) {
      // Categories are optional; the "All" chip keeps the screen usable.
    }
  }

  void selectCategory(ProductCategory category) {
    if (category == _selectedCategory) return;
    _selectedCategory = category;
    // DummyJSON cannot combine search and category, so a category resets search.
    _query = '';
    loadProducts();
  }

  /// Debounced search, so we do not call the API on every key press.
  void search(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      final next = value.trim();
      if (next == _query) return;
      _query = next;
      _selectedCategory = ProductCategory.all;
      loadProducts();
    });
  }

  Future<void> loadProductDetails(int id) async {
    // Show what we already have from the list straight away.
    _selectedProduct = _products.where((p) => p.id == id).firstOrNull;
    _isLoadingDetails = _selectedProduct == null;
    _detailsError = null;
    notifyListeners();

    try {
      _selectedProduct = await productRepository.getProductById(id);
    } catch (e) {
      _detailsError = e.toString();
    }

    _isLoadingDetails = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
