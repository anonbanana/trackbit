import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Cart extends Equatable {
  final List<CartItem> items;
  final double discount;
  final double taxRate;

  const Cart({this.items = const [], this.discount = 0, this.taxRate = 0});

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get discountAmount => subtotal * (discount / 100);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * (taxRate / 100);
  double get total => taxableAmount + taxAmount;

  int get itemCount => items.length;

  Cart copyWith({List<CartItem>? items, double? discount, double? taxRate}) {
    return Cart(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  @override
  List<Object?> get props => [items, discount, taxRate];
}
