import 'package:product_app/features/products/data/datasources/product_local.dart';
import 'package:product_app/features/products/data/datasources/product_remote.dart';
import 'package:product_app/features/products/data/models/product_model.dart';
import 'package:product_app/features/products/domain/entities/product_entity.dart';
import 'package:product_app/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote, this._local);
  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;

  @override
  Future<({List<ProductEntity> products, int total})> getProducts({
    required int page,
    required int limit,
  }) async {
    try {
      final skip = (page - 1) * limit;
      final response = await _remote.getProducts(skip: skip, limit: limit);

      // Cache only first page
      if (page == 1) {
        await _local.cacheProducts(response.products);
      }

      return (
        products: response.products.map((m) => m.toEntity()).toList(),
        total: response.total,
      );
    } catch (_) {
      // Fallback to cache when offline or server error
      final cached = await _local.getCachedProducts();
      if (cached != null && cached.isNotEmpty) {
        return (
          products: cached.map((m) => m.toEntity()).toList(),
          total: cached.length,
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final models = await _remote.searchProducts(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ProductEntity> getProductById(int id) async {
    final model = await _remote.getProductById(id);
    return model.toEntity();
  }

  @override
  Future<ProductEntity> addProduct({
    required String title,
    required String description,
    required double price,
    required String category,
  }) async {
    final model = await _remote.addProduct({
      'title': title,
      'description': description,
      'price': price,
      'category': category,
    });
    return model.toEntity();
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    final data = ProductModel.fromEntity(product).toJson()
      ..remove('id'); // API doesn't want id in body
    final model = await _remote.updateProduct(product.id, data);

    // dummyjson returns a merged response; map it back
    return model.toEntity().copyWith(
          title: product.title,
          description: product.description,
          price: product.price,
          category: product.category,
        );
  }

  @override
  Future<bool> deleteProduct(int id) => _remote.deleteProduct(id);

  @override
  Future<List<int>> getRecentlyViewedIds() => _local.getRecentlyViewedIds();

  @override
  Future<void> addToRecentlyViewed(int productId) =>
      _local.addToRecentlyViewed(productId);
}
