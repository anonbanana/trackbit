import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final String id;
  final String invoiceNumber;
  final String? orderId;
  final String? customerId;
  final String? customerName;
  final DateTime? dueDate;
  final String status;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    this.orderId,
    this.customerId,
    this.customerName,
    this.dueDate,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  });

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? orderId,
    String? customerId,
    String? customerName,
    DateTime? dueDate,
    String? status,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, invoiceNumber, status, total];
}

class InvoiceItem extends Equatable {
  final String id;
  final String invoiceId;
  final String description;
  final double quantity;
  final double unitPrice;
  final double total;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  @override
  List<Object?> get props => [id, invoiceId, description];
}
