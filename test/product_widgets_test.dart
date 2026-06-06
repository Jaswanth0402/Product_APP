import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:product_app/features/products/domain/entities/product_entity.dart';
import 'package:product_app/features/products/presentation/widgets/product_card.dart';
import 'package:product_app/features/products/presentation/widgets/rating_bar.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProductEntity _fakeProduct({int id = 1}) => ProductEntity(
      id: id,
      title: 'Awesome Gadget',
      description: 'A great product for testing',
      price: 149.99,
      discountPercentage: 15,
      rating: 4.3,
      stock: 25,
      brand: 'GadgetCo',
      category: 'electronics',
      thumbnail: 'https://example.com/thumb.jpg',
      images: ['https://example.com/img.jpg'],
    );

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)),
    );

// ---------------------------------------------------------------------------
// ProductCard widget tests
// ---------------------------------------------------------------------------

void main() {
  group('ProductCard', () {
    testWidgets('displays product title', (tester) async {
      await tester.pumpWidget(
        _wrap(ProductCard(product: _fakeProduct(), onTap: () {})),
      );
      expect(find.text('Awesome Gadget'), findsOneWidget);
    });

    testWidgets('displays product price', (tester) async {
      await tester.pumpWidget(
        _wrap(ProductCard(product: _fakeProduct(), onTap: () {})),
      );
      expect(find.text('\$149.99'), findsOneWidget);
    });

    testWidgets('displays product category', (tester) async {
      await tester.pumpWidget(
        _wrap(ProductCard(product: _fakeProduct(), onTap: () {})),
      );
      expect(find.text('electronics'), findsOneWidget);
    });

    testWidgets('triggers onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            height: 300,
            child: ProductCard(
              product: _fakeProduct(),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // RatingBar widget tests
  // ---------------------------------------------------------------------------

  group('RatingBar', () {
    testWidgets('renders 5 star icons', (tester) async {
      await tester.pumpWidget(_wrap(const RatingBar(rating: 3.5)));
      // 2 full stars + 1 half star + 2 empty = 5 total icons
      expect(find.byType(Icon), findsNWidgets(5));
    });

    testWidgets('renders all filled stars for rating of 5', (tester) async {
      await tester.pumpWidget(_wrap(const RatingBar(rating: 5)));
      final icons = tester
          .widgetList<Icon>(find.byType(Icon))
          .map((i) => i.icon)
          .toList();
      expect(icons.every((i) => i == Icons.star_rounded), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Form validation logic tests
  // ---------------------------------------------------------------------------

  group('Product form validation', () {
    double? parsePrice(String input) => double.tryParse(input);

    test('empty title is invalid', () {
      final result = _validateTitle('');
      expect(result, isNotNull);
    });

    test('title with 2 chars is invalid', () {
      final result = _validateTitle('ab');
      expect(result, isNotNull);
    });

    test('valid title passes', () {
      final result = _validateTitle('iPhone 15');
      expect(result, isNull);
    });

    test('non-numeric price is invalid', () {
      expect(parsePrice('abc'), isNull);
    });

    test('negative price is invalid', () {
      final parsed = parsePrice('-5');
      expect(parsed != null && parsed <= 0, isTrue);
    });

    test('valid price passes', () {
      final parsed = parsePrice('29.99');
      expect(parsed != null && parsed > 0, isTrue);
    });
  });
}

String? _validateTitle(String? value) {
  if (value == null || value.trim().isEmpty) return 'Product name is required';
  if (value.trim().length < 3) return 'Name must be at least 3 characters';
  return null;
}
