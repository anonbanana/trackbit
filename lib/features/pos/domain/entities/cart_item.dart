import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String productId;
  final String productName;
  final String sku;
  final double unitPrice;
  final double quantity;
  final String unit;
  final String? barcode;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.unitPrice,
    this.quantity = 1,
    required this.unit,
    this.barcode,
  });

  double get subtotal => unitPrice * quantity;

  CartItem copyWith({double? quantity}) {
    return CartItem(
      productId: productId,
      productName: productName,
      sku: sku,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      unit: unit,
      barcode: barcode,
    );
  }

  @override
  List<Object?> get props => [productId, quantity, unitPrice];
}
