import 'package:product_app/features/products/domain/entities/product_entity.dart';
import 'package:product_app/features/products/domain/repositories/product_repository.dart';

// ---------------------------------------------------------------------------
// Get paginated products
// ---------------------------------------------------------------------------
class GetProductsUseCase {
  const GetProductsUseCase(this._repository);
  final ProductRepository _repository;

  Future<({List<ProductEntity> products, int total})> call({
    required int page,
    required int limit,
  }) =>
      _repository.getProducts(page: page, limit: limit);
}

// ---------------------------------------------------------------------------
// Search products with a query string
// ---------------------------------------------------------------------------
class SearchProductsUseCase {
  const SearchProductsUseCase(this._repository);
  final ProductRepository _repository;

  Future<List<ProductEntity>> call(String query) =>
      _repository.searchProducts(query);
}

// ---------------------------------------------------------------------------
// Get a single product by ID
// ---------------------------------------------------------------------------
class GetProductByIdUseCase {
  const GetProductByIdUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductEntity> call(int id) => _repository.getProductById(id);
}

// ---------------------------------------------------------------------------
// Add a new product
// ---------------------------------------------------------------------------
class AddProductUseCase {
  const AddProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductEntity> call({
    required String title,
    required String description,
    required double price,
    required String category,
  }) =>
      _repository.addProduct(
        title: title,
        description: description,
        price: price,
        category: category,
      );
}

// ---------------------------------------------------------------------------
// Update an existing product
// ---------------------------------------------------------------------------
class UpdateProductUseCase {
  const UpdateProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductEntity> call(ProductEntity product) =>
      _repository.updateProduct(product);
}

// ---------------------------------------------------------------------------
// Delete a product
// ---------------------------------------------------------------------------
class DeleteProductUseCase {
  const DeleteProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<bool> call(int id) => _repository.deleteProduct(id);
}

// ---------------------------------------------------------------------------
// Recently viewed
// ---------------------------------------------------------------------------
class GetRecentlyViewedUseCase {
  const GetRecentlyViewedUseCase(this._repository);
  final ProductRepository _repository;

  Future<List<int>> call() => _repository.getRecentlyViewedIds();
}

class AddToRecentlyViewedUseCase {
  const AddToRecentlyViewedUseCase(this._repository);
  final ProductRepository _repository;

  Future<void> call(int productId) =>
      _repository.addToRecentlyViewed(productId);
}
