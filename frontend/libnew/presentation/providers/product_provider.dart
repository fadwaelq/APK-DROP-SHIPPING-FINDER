import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../domain/usecases/product/get_products_usecase.dart';
import '../../domain/entities/product_entity.dart';

class ProductProvider with ChangeNotifier {
  List<ProductEntity> _products = [];
  List<ProductEntity> _trendingProducts = [];
  List<ProductEntity> _favorites = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = ProductCategory.all;
  String _searchQuery = '';

  List<ProductEntity> get products => _products;
  List<ProductEntity> get trendingProducts => _trendingProducts;
  List<ProductEntity> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  final GetProductsUsecase _getProductsUsecase;

  ProductProvider(GetProductsUsecase getProductsUsecase)
      : _getProductsUsecase = getProductsUsecase;

  List<ProductEntity> get filteredProducts {
    // Use trending products if main products list is empty
    var filtered = _products.isNotEmpty ? _products : _trendingProducts;

    // Filter by category (using backend key mapping)
    if (_selectedCategory != ProductCategory.all) {
      final backendKey = ProductCategory.toBackendKey(_selectedCategory);
      filtered = filtered
          .where((p) => p.category.toLowerCase() == backendKey.toLowerCase())
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    // Use addPostFrameCallback to avoid calling notifyListeners during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _products = await _getProductsUsecase.execute(page: 1, limit: 20);
      // Also populate trending products with same data for now
      _trendingProducts = _products;
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    }

    _isLoading = false;
    // Use addPostFrameCallback to avoid calling notifyListeners during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> loadTrendingProducts() async {
    _isLoading = true;
    _error = null;
    // Use addPostFrameCallback to avoid calling notifyListeners during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _trendingProducts = await _getProductsUsecase.execute(page: 1, limit: 20);
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    }

    _isLoading = false;
    // Use addPostFrameCallback to avoid calling notifyListeners during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setCategory(String category) {
    _selectedCategory = category;
    // Use addPostFrameCallback to avoid calling notifyListeners during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    // Use addPostFrameCallback to avoid calling notifyListeners during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void clearError() {
    _error = null;
    // Use addPostFrameCallback to avoid calling notifyListeners during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      // Toggle the favorite status locally
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        _products[productIndex] = _products[productIndex].copyWith(
          isFavorite: !_products[productIndex].isFavorite,
        );
      }

      // Also update favorites list
      if (_favorites.any((p) => p.id == productId)) {
        _favorites.removeWhere((p) => p.id == productId);
      } else {
        final product = _products.firstWhere((p) => p.id == productId);
        _favorites.add(product);
      }

      // Use addPostFrameCallback to avoid calling notifyListeners during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to toggle favorite: ${e.toString()}';
      // Use addPostFrameCallback to avoid calling notifyListeners during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}
