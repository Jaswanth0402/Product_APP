import 'package:product_app/core/constants/app_constants.dart';
import 'package:product_app/core/network/api_client.dart';
import 'package:product_app/core/network/api_paths.dart';
import 'package:product_app/core/utils/app_error.dart';
import 'package:product_app/features/products/data/models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<ProductListResponse> getProducts(
      {required int skip, required int limit});
  Future<List<ProductModel>> searchProducts(String query);
  Future<ProductModel> getProductById(int id);
  Future<ProductModel> addProduct(Map<String, dynamic> data);
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> data);
  Future<bool> deleteProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  const ProductRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<ProductListResponse> getProducts({
    required int skip,
    required int limit,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiPaths.products,
      queryParameters: {'limit': limit, 'skip': skip},
    );
    print(response.data);
    try {
      return ProductListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw AppError.parse('Failed to parse product list: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiPaths.searchProducts,
      queryParameters: {'q': query, 'limit': AppConstants.pageSize},
    );
    try {
      final data = response.data as Map<String, dynamic>;
      final list = data['products'] as List<dynamic>;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppError.parse('Failed to parse search results: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiPaths.product(id),
    );
    try {
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw AppError.parse('Failed to parse product: $e');
    }
  }

  @override
  Future<ProductModel> addProduct(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiPaths.addProduct,
      data: data,
    );
    try {
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw AppError.parse('Failed to parse added product: $e');
    }
  }

  @override
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiPaths.updateProduct(id),
      data: data,
    );
    try {
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw AppError.parse('Failed to parse updated product: $e');
    }
  }

  @override
  Future<bool> deleteProduct(int id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiPaths.deleteProduct(id),
    );
    return response.statusCode == 200;
  }
}
