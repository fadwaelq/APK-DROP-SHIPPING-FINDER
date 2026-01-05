import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _trendingProducts = [];
  List<Product> _favorites = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = ProductCategory.all;
  String _searchQuery = '';
  String? _currentUserId; // Track current user for favorites

  List<Product> get products => _products;
  List<Product> get trendingProducts => _trendingProducts;
  List<Product> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  final ApiService _apiService = ApiService();

  ProductProvider() {
    // Don't load favorites in constructor - wait for user login
  }

  // Load favorites from local storage for specific user
  Future<void> _loadFavoritesFromStorage() async {
    try {
      if (_currentUserId == null) {
        debugPrint('⚠️  No user logged in, skipping favorites load');
        _favorites = [];
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final storageKey = 'favorites_$_currentUserId';
      final favoritesJson = prefs.getString(storageKey);
      
      debugPrint('📦 Loading favorites for user $_currentUserId...');
      
      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final List<dynamic> favoritesList = jsonDecode(favoritesJson);
        _favorites = favoritesList.map((json) => Product.fromJson(json)).toList();
        debugPrint('✅ Loaded ${_favorites.length} favorites from storage');
        notifyListeners();
      } else {
        debugPrint('📭 No favorites found in storage for this user');
        _favorites = [];
      }
    } catch (e) {
      debugPrint('❌ Error loading favorites from storage: $e');
      _favorites = [];
    }
  }

  // Save favorites to local storage for specific user
  Future<void> _saveFavoritesToStorage() async {
    try {
      if (_currentUserId == null) {
        debugPrint('⚠️  No user logged in, skipping favorites save');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final storageKey = 'favorites_$_currentUserId';
      final favoritesJson = jsonEncode(_favorites.map((p) => p.toJson()).toList());
      await prefs.setString(storageKey, favoritesJson);
      debugPrint('💾 Saved ${_favorites.length} favorites for user $_currentUserId');
    } catch (e) {
      debugPrint('❌ Error saving favorites to storage: $e');
    }
  }

  // Update isFavorite status for products based on saved favorites
  void _updateFavoriteStatus() {
    final favoriteIds = _favorites.map((f) => f.id).toSet();
    
    // Update products list
    for (int i = 0; i < _products.length; i++) {
      if (favoriteIds.contains(_products[i].id)) {
        _products[i] = _products[i].copyWith(isFavorite: true);
      }
    }
    
    // Update trending products list
    for (int i = 0; i < _trendingProducts.length; i++) {
      if (favoriteIds.contains(_trendingProducts[i].id)) {
        _trendingProducts[i] = _trendingProducts[i].copyWith(isFavorite: true);
      }
    }
  }

  List<Product> get filteredProducts {
    // Use trending products if main products list is empty
    var filtered = _products.isNotEmpty ? _products : _trendingProducts;

    // Filter by category (using backend key mapping)
    if (_selectedCategory != ProductCategory.all) {
      final backendKey = ProductCategory.toBackendKey(_selectedCategory);
      filtered = filtered.where((p) => 
        p.category.toLowerCase() == backendKey.toLowerCase()
      ).toList();
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
    notifyListeners();

    try {
      final response = await _apiService.getProducts();
      
      if (response['success']) {
        _products = (response['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        
        // Update isFavorite status based on saved favorites
        _updateFavoriteStatus();
      } else {
        _error = response['message'] ?? 'Failed to load products';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTrendingProducts() async {
    try {
      debugPrint('🔍 Loading trending products...');
      final response = await _apiService.getTrendingProducts();
      
      debugPrint('📦 Response type: ${response.runtimeType}');
      debugPrint('📦 Response: ${response.toString().substring(0, response.toString().length > 200 ? 200 : response.toString().length)}');
      
      if (response == null) {
        debugPrint('⚠️  Response is null');
        _trendingProducts = [];
        notifyListeners();
        return;
      }
      
      // Try multiple possible response formats
      dynamic productsData;
      
      if (response is List) {
        debugPrint('✅ Response is a direct List');
        productsData = response;
      } else if (response is Map) {
        debugPrint('📋 Response is a Map with keys: ${response.keys.toList()}');
        
        if (response.containsKey('success') && response['success'] == true) {
          // Success wrapper with data
          productsData = response['data'] ?? response['products'] ?? response['results'];
          debugPrint('✅ Found data in success wrapper');
        } else if (response.containsKey('data')) {
          productsData = response['data'];
          debugPrint('✅ Found data key');
        } else if (response.containsKey('products')) {
          productsData = response['products'];
          debugPrint('✅ Found products key');
        } else if (response.containsKey('results')) {
          productsData = response['results'];
          debugPrint('✅ Found results key');
        } else {
          debugPrint('❌ No known data key found. Keys: ${response.keys.toList()}');
          _trendingProducts = [];
          notifyListeners();
          return;
        }
      } else {
        debugPrint('❌ Unknown response type: ${response.runtimeType}');
        _trendingProducts = [];
        notifyListeners();
        return;
      }
      
      if (productsData == null) {
        debugPrint('⚠️  Products data is null after extraction');
        _trendingProducts = [];
        notifyListeners();
        return;
      }
      
      debugPrint('📦 Products data type: ${productsData.runtimeType}');
      
      if (productsData is! List) {
        debugPrint('❌ Products data is not a list: ${productsData.runtimeType}');
        debugPrint('❌ Data: ${productsData.toString().substring(0, productsData.toString().length > 100 ? 100 : productsData.toString().length)}');
        _trendingProducts = [];
        notifyListeners();
        return;
      }
      
      debugPrint('✅ Products data is a List with ${(productsData as List).length} items');
      
      _trendingProducts = (productsData)
          .where((item) => item != null)
          .map((json) {
            try {
              return Product.fromJson(json);
            } catch (e) {
              debugPrint('⚠️  Error parsing product: $e');
              return null;
            }
          })
          .where((product) => product != null)
          .cast<Product>()
          .toList();
      
      // Update isFavorite status based on saved favorites
      _updateFavoriteStatus();
      
      notifyListeners();
      debugPrint('✅ Loaded ${_trendingProducts.length} trending products');
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading trending products: ${e.toString()}');
      debugPrint('❌ Stack trace: ${stackTrace.toString()}');
      _error = 'Failed to load products';
      _trendingProducts = [];
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load from local storage first
      await _loadFavoritesFromStorage();
      
      // Try to sync with API if user is logged in
      try {
        final response = await _apiService.getFavorites();
        
        if (response['success'] && response['favorites'] != null) {
          final favoritesData = response['favorites'];
          
          // Check if favorites is a List
          if (favoritesData is List) {
            final apiFavorites = favoritesData
                .map((json) => Product.fromJson(json))
                .toList();
            
            // Merge with local favorites (local takes priority)
            final localIds = _favorites.map((f) => f.id).toSet();
            for (var apiFav in apiFavorites) {
              if (!localIds.contains(apiFav.id)) {
                _favorites.add(apiFav);
              }
            }
            
            // Save merged favorites
            await _saveFavoritesToStorage();
          }
        }
      } catch (e) {
        debugPrint('⚠️  API favorites sync skipped: ${e.toString()}');
        // Continue with local favorites - this is normal if user is not logged in
      }
    } catch (e) {
      _error = 'Failed to load favorites: ${e.toString()}';
      debugPrint('Error loading favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      // Find product in both lists
      Product? product;
      int productIndex = -1;
      
      // Try to find in main products list
      try {
        product = _products.firstWhere((p) => p.id == productId);
        productIndex = _products.indexWhere((p) => p.id == productId);
      } catch (e) {
        // If not found, try trending products
        try {
          product = _trendingProducts.firstWhere((p) => p.id == productId);
          productIndex = _trendingProducts.indexWhere((p) => p.id == productId);
        } catch (e) {
          debugPrint('Product not found: $productId');
          return;
        }
      }
      
      if (product == null) return;
      
      final isFavorite = !product.isFavorite;

      // Optimistic update
      final updatedProduct = product.copyWith(isFavorite: isFavorite);
      
      if (productIndex >= 0 && productIndex < _products.length) {
        _products[productIndex] = updatedProduct;
      }
      
      // Also update in trending list if present
      final trendingIndex = _trendingProducts.indexWhere((p) => p.id == productId);
      if (trendingIndex >= 0) {
        _trendingProducts[trendingIndex] = updatedProduct;
      }
      
      if (isFavorite) {
        if (!_favorites.any((p) => p.id == productId)) {
          _favorites.add(updatedProduct);
        }
      } else {
        _favorites.removeWhere((p) => p.id == productId);
      }
      
      // Save favorites to local storage
      await _saveFavoritesToStorage();
      
      notifyListeners();

      // Try API call (will fail if not authenticated, but that's ok)
      try {
        final response = await _apiService.toggleFavorite(productId);
        
        if (!response['success']) {
          debugPrint('API toggle failed (user may not be logged in): ${response['message']}');
          // Don't revert - keep local favorite state
        }
      } catch (e) {
        debugPrint('API call failed (user may not be logged in): ${e.toString()}');
        // Don't revert - keep local favorite state
      }
    } catch (e) {
      debugPrint('Error toggling favorite: ${e.toString()}');
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.searchProducts(query);
      
      if (response['success']) {
        _products = (response['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set current user and load their favorites
  Future<void> setUser(String? userId) async {
    debugPrint('🔄 setUser called with userId: $userId (current: $_currentUserId)');
    
    if (_currentUserId == userId) {
      debugPrint('⚠️  User ID unchanged, skipping reload');
      return; // No change
    }
    
    _currentUserId = userId;
    debugPrint('👤 User changed to: $userId');
    
    if (userId == null) {
      // User logged out - clear favorites
      _favorites = [];
      debugPrint('🧹 Cleared favorites (user logged out)');
    } else {
      // User logged in - load their favorites from storage AND API
      debugPrint('📂 Loading favorites for user $userId...');
      await loadFavorites(); // This will load from storage AND sync with API
      debugPrint('✅ Favorites loaded: ${_favorites.length} items');
    }
    
    notifyListeners();
  }

  // Clear all favorites (for logout)
  Future<void> clearFavorites() async {
    _favorites = [];
    _currentUserId = null;
    notifyListeners();
    debugPrint('🧹 All favorites cleared');
  }
}
