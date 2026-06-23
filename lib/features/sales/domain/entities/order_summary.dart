import 'package:equatable/equatable.dart';

class OrderSummary extends Equatable {
  final String id;
  final String orderNumber;
  final String? customerName;
  final double total;
  final String paymentMethod;
  final String status;
  final int itemCount;
  final DateTime createdAt;

  const OrderSummary({
    required this.id,
    required this.orderNumber,
    this.customerName,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.itemCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, orderNumber, total, status];
}
