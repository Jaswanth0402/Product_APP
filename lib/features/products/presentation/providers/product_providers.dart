import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:product_app/core/constants/app_constants.dart';
import 'package:product_app/core/network/api_client.dart';
import 'package:product_app/features/products/data/datasources/product_local.dart';
import 'package:product_app/features/products/data/datasources/product_remote.dart';
import 'package:product_app/features/products/data/repositories/product_repo_impl.dart';
import 'package:product_app/features/products/domain/entities/product_entity.dart';
import 'package:product_app/features/products/domain/repositories/product_repository.dart';
import 'package:product_app/features/products/domain/usecases/product_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_providers.g.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

@riverpod
ProductRemoteDataSource productRemoteDataSource(Ref ref) {
  return ProductRemoteDataSourceImpl(ref.watch(apiClientProvider));
}

@riverpod
ProductLocalDataSource productLocalDataSource(Ref ref) {
  return ProductLocalDataSourceImpl(productsBox, recentlyViewedBox);
}

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepositoryImpl(
    ref.watch(productRemoteDataSourceProvider),
    ref.watch(productLocalDataSourceProvider),
  );
}

// ---------------------------------------------------------------------------
// Use case providers
// ---------------------------------------------------------------------------

@riverpod
GetProductsUseCase getProductsUseCase(Ref ref) =>
    GetProductsUseCase(ref.watch(productRepositoryProvider));

@riverpod
SearchProductsUseCase searchProductsUseCase(Ref ref) =>
    SearchProductsUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetProductByIdUseCase getProductByIdUseCase(Ref ref) =>
    GetProductByIdUseCase(ref.watch(productRepositoryProvider));

@riverpod
AddProductUseCase addProductUseCase(Ref ref) =>
    AddProductUseCase(ref.watch(productRepositoryProvider));

@riverpod
UpdateProductUseCase updateProductUseCase(Ref ref) =>
    UpdateProductUseCase(ref.watch(productRepositoryProvider));

@riverpod
DeleteProductUseCase deleteProductUseCase(Ref ref) =>
    DeleteProductUseCase(ref.watch(productRepositoryProvider));

@riverpod
AddToRecentlyViewedUseCase addToRecentlyViewedUseCase(Ref ref) =>
    AddToRecentlyViewedUseCase(ref.watch(productRepositoryProvider));

// ---------------------------------------------------------------------------
// Product list state (with pagination)
// ---------------------------------------------------------------------------

@riverpod
class ProductListNotifier extends _$ProductListNotifier {
  late PagingController<int, ProductEntity> pagingController;

  @override
  List<ProductEntity> build() {
    pagingController = PagingController(firstPageKey: 1);
    pagingController.addPageRequestListener(_fetchPage);
    ref.onDispose(pagingController.dispose);
    return [];
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final result = await ref.read(getProductsUseCaseProvider).call(
            page: pageKey,
            limit: AppConstants.pageSize,
          );

      final isLastPage =
          (pageKey - 1) * AppConstants.pageSize + result.products.length >=
              result.total;

      if (isLastPage) {
        pagingController.appendLastPage(result.products);
      } else {
        pagingController.appendPage(result.products, pageKey + 1);
      }

      // Mirror into local state for non-paged consumers
      state = [...state, ...result.products];
    } catch (e) {
      pagingController.error = e;
    }
  }

  Future<void> refresh() async {
    state = [];
    pagingController.refresh();
  }

  void addProduct(ProductEntity product) {
    state = [product, ...state];
  }

  void updateProduct(ProductEntity updated) {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p,
    ];
  }

  void removeProduct(int id) {
    state = state.where((p) => p.id != id).toList();
  }
}

// ---------------------------------------------------------------------------
// Single product detail
// ---------------------------------------------------------------------------

@riverpod
Future<ProductEntity> productDetail(Ref ref, int id) async {
  final product = await ref.watch(getProductByIdUseCaseProvider).call(id);
  // Side effect: record as recently viewed
  await ref.read(addToRecentlyViewedUseCaseProvider).call(id);
  return product;
}

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  AsyncValue<List<ProductEntity>> build() => const AsyncData([]);

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(searchProductsUseCaseProvider).call(query),
    );
  }

  void clear() => state = const AsyncData([]);
}
