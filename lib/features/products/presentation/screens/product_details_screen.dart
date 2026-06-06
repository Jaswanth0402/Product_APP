import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:product_app/core/router/app_router.dart';
import 'package:product_app/features/products/domain/entities/product_entity.dart';
import 'package:product_app/features/products/presentation/providers/product_providers.dart';
import 'package:product_app/features/products/presentation/widgets/rating_bar.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      body: productAsync.when(
        loading: () => const _LoadingDetail(),
        error: (e, _) => _ErrorDetail(error: e.toString()),
        data: (product) => _ProductDetailContent(product: product),
      ),
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  const _ProductDetailContent({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          actions: [
            IconButton(
              tooltip: 'Edit product',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.goNamed(
                AppRoutes.editProductName,
                extra: product,
              ),
            ),
            IconButton(
              tooltip: 'Delete product',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: CarouselSlider(
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                autoPlay: product.images.length > 1,
                autoPlayInterval: const Duration(seconds: 5),
              ),
              items: product.images.map((url) {
                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(
                        child: CircularProgressIndicator.adaptive()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.broken_image_outlined,
                        size: 48, color: colorScheme.outline),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (product.discountPercentage > 0)
                          Text(
                            '${product.discountPercentage.toStringAsFixed(0)}% off',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _Chip(
                        label: product.category, icon: Icons.category_outlined),
                    _Chip(label: product.brand, icon: Icons.business_outlined),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    RatingBar(rating: product.rating),
                    const SizedBox(width: 8),
                    Text(
                      '${product.rating.toStringAsFixed(1)} / 5',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Text('Description',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                ),
                const SizedBox(height: 24),
                _StockIndicator(stock: product.stock),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(deleteProductUseCaseProvider).call(product.id);
      ref.read(productListNotifierProvider.notifier).removeProduct(product.id);
      if (context.mounted) context.pop();
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    );
  }
}

class _StockIndicator extends StatelessWidget {
  const _StockIndicator({required this.stock});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final color = stock > 20
        ? Colors.green
        : stock > 5
            ? Colors.orange
            : Colors.red;
    return Row(
      children: [
        Icon(Icons.inventory_outlined, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          '$stock in stock',
          style: TextStyle(fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }
}

class _LoadingDetail extends StatelessWidget {
  const _LoadingDetail();

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator.adaptive(),
      );
}

class _ErrorDetail extends StatelessWidget {
  const _ErrorDetail({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error),
        ),
      );
}
