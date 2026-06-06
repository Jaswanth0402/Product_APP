import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_app/features/products/domain/entities/product_entity.dart';
import 'package:product_app/features/products/presentation/screens/product_details_screen.dart';
import 'package:product_app/features/products/presentation/screens/product_form_screen.dart';
import 'package:product_app/features/products/presentation/screens/product_list_screen.dart';
import 'package:product_app/features/products/presentation/screens/search_screen.dart';
import 'package:product_app/features/products/presentation/screens/settings_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.products,
    routes: [
      GoRoute(
        path: AppRoutes.products,
        name: AppRoutes.productsName,
        builder: (context, state) => const ProductListScreen(),
        routes: [
          GoRoute(
            path: 'search',
            name: AppRoutes.searchName,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: ':id',
            name: AppRoutes.productDetailName,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ProductDetailScreen(productId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: AppRoutes.settingsName,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.addProduct,
            name: AppRoutes.addProductName,
            builder: (context, state) => const ProductFormScreen(),
          ),
          GoRoute(
            path: AppRoutes.editProduct,
            name: AppRoutes.editProductName,
            builder: (context, state) {
              final product = state.extra! as ProductEntity;
              return ProductFormScreen(existingProduct: product);
            },
          ),
        ],
      ),
    ],
  );
}

abstract final class AppRoutes {
  static const products = '/products';
  static const productsName = 'products';

  static const search = '/products/search';
  static const searchName = 'search';

  static const productDetail = '/products/:id';
  static const productDetailName = 'product-detail';

  static const addProduct = '/products/add-product';
  static const addProductName = 'add-product';

  static const editProduct = '/products/edit-product';
  static const editProductName = 'edit-product';

  static const settings = '/products/settings';
  static const settingsName = 'settings';
}
