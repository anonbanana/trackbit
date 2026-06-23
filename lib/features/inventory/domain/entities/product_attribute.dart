import 'package:equatable/equatable.dart';

class ProductAttribute extends Equatable {
  final String id;
  final String productId;
  final String attributeKey;
  final String attributeValue;

  const ProductAttribute({
    required this.id,
    required this.productId,
    required this.attributeKey,
    required this.attributeValue,
  });

  @override
  List<Object?> get props => [id, productId, attributeKey];
}
