import 'package:equatable/equatable.dart';
import '../enums/movement_type.dart';

class StockMovement extends Equatable {
  final String id;
  final String productId;
  final MovementType type;
  final double quantity;
  final String? referenceType;
  final String? referenceId;
  final String? note;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    this.referenceType,
    this.referenceId,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, productId, type, quantity];
}
