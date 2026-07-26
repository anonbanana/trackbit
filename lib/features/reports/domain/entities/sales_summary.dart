import 'package:equatable/equatable.dart';

class SalesSummary extends Equatable {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final int refundedOrders;
  final double refundedAmount;

  const SalesSummary({
    this.totalRevenue = 0,
    this.totalOrders = 0,
    this.averageOrderValue = 0,
    this.refundedOrders = 0,
    this.refundedAmount = 0,
  });

  @override
  List<Object?> get props => [totalRevenue, totalOrders, averageOrderValue];
}

class DailySalesSummary extends Equatable {
  final DateTime date;
  final double revenue;
  final int orders;

  const DailySalesSummary({
    required this.date,
    required this.revenue,
    required this.orders,
  });

  @override
  List<Object?> get props => [date, revenue, orders];
}
