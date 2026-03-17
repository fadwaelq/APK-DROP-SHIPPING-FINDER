import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();

  factory FavoritesManager() {
    return _instance;
  }

  FavoritesManager._internal();

  // The central state containing all favorite products
  final ValueNotifier<List<Map<String, dynamic>>> favoritesNotifier = ValueNotifier([]);

  // Load favorites from backend
  Future<void> loadFavorites() async {
    try {
      final result = await ApiService().getProductsFavorites();
      
      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        favoritesNotifier.value = data.map((item) {
          final Map<String, dynamic> product = Map<String, dynamic>.from(item['product_details'] ?? {});
          product['watchlist_id'] = item['id']; 
          return product;
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<Map<String, dynamic>> toggleFavorite(Map<String, dynamic> product) async {
    final productId = product['id']?.toString();
    if (productId == null) return {'success': false, 'message': 'Product ID missing'};

    final currentFavorites = List<Map<String, dynamic>>.from(favoritesNotifier.value);
    final existingIndex = currentFavorites.indexWhere((p) => p['id'].toString() == productId);

    try {
      if (existingIndex >= 0) {
        final watchlistId = currentFavorites[existingIndex]['watchlist_id']?.toString();
        if (watchlistId != null) {
          final result = await ApiService().deleteFromWatchlist(watchlistId);
          // Si le serveur dit 200 (OK) OU 404 (Pas trouvé/Déjà supprimé), on retire de la liste
          if (result['success'] == true || result['message']?.contains('404') == true) {
             currentFavorites.removeAt(existingIndex);
             favoritesNotifier.value = currentFavorites;
             return {'success': true};
          }
          return result;
        }
      } 
      
      final result = await ApiService().toggleProductFavorite(productId);
      if (result['success'] == true) {
        await loadFavorites(); 
        return {'success': true};
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Check if a product is in favorites
  bool isFavorite(Map<String, dynamic> product) {
    final productId = product['id']?.toString();
    return favoritesNotifier.value.any((p) => p['id'].toString() == productId);
  }
}
