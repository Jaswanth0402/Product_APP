import 'package:json_annotation/json_annotation.dart';

import 'package:product_app/features/products/domain/entities/product_entity.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String category;
  final String thumbnail;
  final List<String> images;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductEntity toEntity() => ProductEntity(
        id: id,
        title: title,
        description: description,
        price: price,
        discountPercentage: discountPercentage,
        rating: rating,
        stock: stock,
        brand: brand ?? 'Unknown',
        category: category,
        thumbnail: thumbnail,
        images: images.isEmpty ? [thumbnail] : images,
      );

  factory ProductModel.fromEntity(ProductEntity entity) => ProductModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        price: entity.price,
        discountPercentage: entity.discountPercentage,
        rating: entity.rating,
        stock: entity.stock,
        brand: entity.brand,
        category: entity.category,
        thumbnail: entity.thumbnail,
        images: entity.images,
      );
}

@JsonSerializable()
class ProductListResponse {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  const ProductListResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductListResponseFromJson(json);
}
