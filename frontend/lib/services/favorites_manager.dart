import 'package:flutter/material.dart';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();

  factory FavoritesManager() {
    return _instance;
  }

  FavoritesManager._internal();

  // The central state containing all favorite products
  final ValueNotifier<List<Map<String, dynamic>>> favoritesNotifier = ValueNotifier([]);

  // Get current favorites
  List<Map<String, dynamic>> get favorites => favoritesNotifier.value;

  // Toggle a product in/out of favorites
  void toggleFavorite(Map<String, dynamic> product) {
    final currentFavorites = List<Map<String, dynamic>>.from(favoritesNotifier.value);
    
    // We assume 'title' is a unique identifier for now
    final existingIndex = currentFavorites.indexWhere((p) => p['title'] == product['title']);

    if (existingIndex >= 0) {
      // It exists => remove it
      currentFavorites.removeAt(existingIndex);
    } else {
      // It doesn't exist => add it
      // Make sure the map has all expected keys
      currentFavorites.add(product);
    }
    
    // Update the notifier to trigger rebuilds
    favoritesNotifier.value = currentFavorites;
  }

  // Check if a product is in favorites
  bool isFavorite(Map<String, dynamic> product) {
    return favoritesNotifier.value.any((p) => p['title'] == product['title']);
  }
}
