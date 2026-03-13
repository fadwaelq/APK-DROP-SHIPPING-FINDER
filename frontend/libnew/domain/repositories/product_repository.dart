import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({int? page, int? limit});
  Future<List<ProductEntity>> getTrendingProducts();
  Future<List<ProductEntity>> searchProducts(String query);
  Future<ProductEntity?> getProductById(String id);
  Future<List<ProductEntity>> getFavorites();
  Future<bool> toggleFavorite(String productId);
  Future<bool> updateSubscription(String plan);
}