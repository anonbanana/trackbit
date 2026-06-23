import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String categoryId;
  final String? barcode;
  final String unit;
  final double price;
  final double cost;
  final double stockQty;
  final double minStock;
  final String? imagePath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    required this.categoryId,
    this.barcode,
    required this.unit,
    required this.price,
    required this.cost,
    this.stockQty = 0,
    this.minStock = 0,
    this.imagePath,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => stockQty <= minStock;

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    String? categoryId,
    String? barcode,
    String? unit,
    double? price,
    double? cost,
    double? stockQty,
    double? minStock,
    String? imagePath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      barcode: barcode ?? this.barcode,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stockQty: stockQty ?? this.stockQty,
      minStock: minStock ?? this.minStock,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, sku, name];
}
