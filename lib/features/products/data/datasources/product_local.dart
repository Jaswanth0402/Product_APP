import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:product_app/core/constants/app_constants.dart';
import 'package:product_app/core/constants/hive_constants.dart';
import 'package:product_app/features/products/data/models/product_model.dart';

abstract interface class ProductLocalDataSource {
  Future<List<ProductModel>?> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<int>> getRecentlyViewedIds();
  Future<void> addToRecentlyViewed(int productId);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  const ProductLocalDataSourceImpl(this._productsBox, this._recentlyViewedBox);
  final Box<String> _productsBox;
  final Box<int> _recentlyViewedBox;

  static const _cacheKey = 'cached_products';

  @override
  Future<List<ProductModel>?> getCachedProducts() async {
    final cached = _productsBox.get(_cacheKey);
    if (cached == null) return null;
    try {
      final list = jsonDecode(cached) as List<dynamic>;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final encoded = jsonEncode(products.map((p) => p.toJson()).toList());
    await _productsBox.put(_cacheKey, encoded);
  }

  @override
  Future<List<int>> getRecentlyViewedIds() async {
    return _recentlyViewedBox.values.toList();
  }

  @override
  Future<void> addToRecentlyViewed(int productId) async {
    // Remove existing entry if present (to move to front)
    final existingKey = _recentlyViewedBox.keys.cast<dynamic>().firstWhere(
          (k) => _recentlyViewedBox.get(k) == productId,
          orElse: () => null,
        );
    if (existingKey != null) {
      await _recentlyViewedBox.delete(existingKey);
    }

    // Enforce FIFO limit
    while (_recentlyViewedBox.length >= AppConstants.recentlyViewedLimit) {
      await _recentlyViewedBox.deleteAt(0);
    }

    await _recentlyViewedBox.add(productId);
  }
}

// Convenience provider helpers — referenced from repository provider
Box<String> get productsBox => Hive.box<String>(HiveConstants.productsBox);
Box<int> get recentlyViewedBox =>
    Hive.box<int>(HiveConstants.recentlyViewedBox);
