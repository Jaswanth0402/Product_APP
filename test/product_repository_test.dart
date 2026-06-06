import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:product_app/features/products/data/datasources/product_local.dart';
import 'package:product_app/features/products/data/datasources/product_remote.dart';
import 'package:product_app/features/products/data/models/product_model.dart';
import 'package:product_app/features/products/data/repositories/product_repo_impl.dart';
import 'package:product_app/features/products/domain/entities/product_entity.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

class MockProductLocalDataSource extends Mock
    implements ProductLocalDataSource {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProductModel _fakeModel({int id = 1}) => ProductModel(
      id: id,
      title: 'Test Product $id',
      description: 'A test product',
      price: 99.99,
      discountPercentage: 10,
      rating: 4.5,
      stock: 50,
      brand: 'TestBrand',
      category: 'electronics',
      thumbnail: 'https://example.com/img.jpg',
      images: ['https://example.com/img.jpg'],
    );

ProductListResponse _fakeListResponse({int count = 3}) => ProductListResponse(
      products: List.generate(count, (i) => _fakeModel(id: i + 1)),
      total: 100,
      skip: 0,
      limit: count,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockProductRemoteDataSource remote;
  late MockProductLocalDataSource local;
  late ProductRepositoryImpl repository;

  setUp(() {
    remote = MockProductRemoteDataSource();
    local = MockProductLocalDataSource();
    repository = ProductRepositoryImpl(remote, local);
  });

  group('getProducts', () {
    test('returns products from remote on success and caches them', () async {
      when(() => remote.getProducts(skip: 0, limit: 20))
          .thenAnswer((_) async => _fakeListResponse());
      when(() => local.cacheProducts(any())).thenAnswer((_) async {});

      final result = await repository.getProducts(page: 1, limit: 20);

      expect(result.products.length, 3);
      expect(result.total, 100);
      verify(() => local.cacheProducts(any())).called(1);
    });

    test('falls back to cache when remote throws', () async {
      when(() => remote.getProducts(skip: 0, limit: 20))
          .thenThrow(Exception('network error'));
      when(() => local.getCachedProducts())
          .thenAnswer((_) async => [_fakeModel()]);

      final result = await repository.getProducts(page: 1, limit: 20);

      expect(result.products.length, 1);
    });

    test('rethrows when both remote and cache fail', () async {
      when(() => remote.getProducts(skip: 0, limit: 20))
          .thenThrow(Exception('network error'));
      when(() => local.getCachedProducts()).thenAnswer((_) async => null);

      expect(
        () => repository.getProducts(page: 1, limit: 20),
        throwsException,
      );
    });
  });

  group('getProductById', () {
    test('returns mapped entity on success', () async {
      when(() => remote.getProductById(1))
          .thenAnswer((_) async => _fakeModel());

      final result = await repository.getProductById(1);

      expect(result, isA<ProductEntity>());
      expect(result.id, 1);
      expect(result.title, 'Test Product 1');
    });
  });

  group('addProduct', () {
    test('calls remote with correct data and returns entity', () async {
      when(() => remote.addProduct(any()))
          .thenAnswer((_) async => _fakeModel(id: 201));

      final result = await repository.addProduct(
        title: 'New Product',
        description: 'Desc',
        price: 49.99,
        category: 'gadgets',
      );

      expect(result.id, 201);
      verify(() => remote.addProduct(any())).called(1);
    });
  });

  group('deleteProduct', () {
    test('returns true on success', () async {
      when(() => remote.deleteProduct(1)).thenAnswer((_) async => true);

      final result = await repository.deleteProduct(1);

      expect(result, isTrue);
    });
  });

  group('recently viewed', () {
    test('delegates getRecentlyViewedIds to local datasource', () async {
      when(() => local.getRecentlyViewedIds()).thenAnswer((_) async => [1, 2]);

      final ids = await repository.getRecentlyViewedIds();
      expect(ids, [1, 2]);
    });

    test('delegates addToRecentlyViewed to local datasource', () async {
      when(() => local.addToRecentlyViewed(5)).thenAnswer((_) async {});

      await repository.addToRecentlyViewed(5);
      verify(() => local.addToRecentlyViewed(5)).called(1);
    });
  });
}
