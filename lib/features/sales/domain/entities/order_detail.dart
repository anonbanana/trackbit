import 'package:equatable/equatable.dart';

class OrderDetailItem extends Equatable {
  final String id;
  final String productName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double subtotal;

  const OrderDetailItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [id, productName, quantity];
}

class OrderDetail extends Equatable {
  final String id;
  final String orderNumber;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String userId;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final String status;
  final List<OrderDetailItem> items;
  final DateTime createdAt;

  const OrderDetail({
    required this.id,
    required this.orderNumber,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.userId,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, orderNumber, total, status];
}
