import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:product_app/core/router/app_router.dart';
import 'package:product_app/core/services/connectivity_service.dart';
import 'package:product_app/features/products/domain/entities/product_entity.dart';
import 'package:product_app/features/products/presentation/providers/product_providers.dart';
import 'package:product_app/features/products/presentation/widgets/offline_banner.dart';
import 'package:product_app/features/products/presentation/widgets/product_card.dart';
import 'package:product_app/features/products/presentation/widgets/product_shimmer.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(productListNotifierProvider.notifier);
    final pagingController = notifier.pagingController;
    final isOnline = ref.watch(connectivityNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.goNamed(AppRoutes.searchName),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.goNamed(AppRoutes.settingsName),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline) const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: notifier.refresh,
              child: PagedGridView<int, ProductEntity>(
                pagingController: pagingController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                builderDelegate: PagedChildBuilderDelegate<ProductEntity>(
                  itemBuilder: (context, product, index) => ProductCard(
                    product: product,
                    onTap: () => context.goNamed(
                      AppRoutes.productDetailName,
                      pathParameters: {'id': product.id.toString()},
                    ),
                  ),
                  firstPageProgressIndicatorBuilder: (_) =>
                      const ProductShimmerGrid(),
                  newPageProgressIndicatorBuilder: (_) =>
                      const _LoadMoreIndicator(),
                  noItemsFoundIndicatorBuilder: (_) => const _EmptyState(),
                  firstPageErrorIndicatorBuilder: (ctx) => _ErrorState(
                    onRetry: pagingController.refresh,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed(AppRoutes.addProductName),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load products',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
