import 'package:product_app/features/products/domain/entities/product_entity.dart';

abstract interface class ProductRepository {
  Future<({List<ProductEntity> products, int total})> getProducts({
    required int page,
    required int limit,
  });

  Future<List<ProductEntity>> searchProducts(String query);

  Future<ProductEntity> getProductById(int id);

  Future<ProductEntity> addProduct({
    required String title,
    required String description,
    required double price,
    required String category,
  });

  Future<ProductEntity> updateProduct(ProductEntity product);

  Future<bool> deleteProduct(int id);

  Future<List<int>> getRecentlyViewedIds();

  Future<void> addToRecentlyViewed(int productId);
}
