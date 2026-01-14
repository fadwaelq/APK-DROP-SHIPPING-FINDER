import '../../repositories/product_repository.dart';
import '../../entities/product_entity.dart';

class GetProductsUsecase {
  final ProductRepository repository;

  GetProductsUsecase(this.repository);

  Future<List<ProductEntity>> execute({int? page, int? limit}) async {
    return await repository.getProducts(page: page, limit: limit);
  }
}