import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:product_app/features/products/domain/entities/product_entity.dart';
import 'package:product_app/features/products/presentation/providers/product_providers.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.existingProduct});
  final ProductEntity? existingProduct;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _categoryCtrl;

  bool _isLoading = false;
  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _descriptionCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(2) : '',
    );
    _categoryCtrl = TextEditingController(text: p?.category ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updated = widget.existingProduct!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          price: double.parse(_priceCtrl.text),
          category: _categoryCtrl.text.trim(),
        );
        final result =
            await ref.read(updateProductUseCaseProvider).call(updated);
        ref.read(productListNotifierProvider.notifier).updateProduct(result);
      } else {
        final result = await ref.read(addProductUseCaseProvider).call(
              title: _titleCtrl.text.trim(),
              description: _descriptionCtrl.text.trim(),
              price: double.parse(_priceCtrl.text),
              category: _categoryCtrl.text.trim(),
            );
        ref.read(productListNotifierProvider.notifier).addProduct(result);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _FormField(
              controller: _titleCtrl,
              label: 'Product Name',
              hint: 'e.g. iPhone 15 Pro',
              icon: Icons.title_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Product name is required';
                }
                if (v.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _FormField(
              controller: _descriptionCtrl,
              label: 'Description',
              hint: 'Enter a detailed product description',
              icon: Icons.description_outlined,
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _FormField(
              controller: _priceCtrl,
              label: 'Price (USD)',
              hint: 'e.g. 29.99',
              icon: Icons.attach_money_rounded,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Price is required';
                }
                final parsed = double.tryParse(v);
                if (parsed == null) return 'Enter a valid number';
                if (parsed <= 0) return 'Price must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _FormField(
              controller: _categoryCtrl,
              label: 'Category',
              hint: 'e.g. smartphones',
              icon: Icons.category_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Category is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded),
              label: Text(_isEditing ? 'Save Changes' : 'Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
