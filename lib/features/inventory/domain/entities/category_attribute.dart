import 'package:equatable/equatable.dart';
import '../enums/category_type.dart';

class CategoryAttribute extends Equatable {
  final String id;
  final CategoryType categoryType;
  final String attributeKey;
  final String attributeLabel;
  final String attributeType;
  final bool isRequired;
  final String? optionsJson;
  final int sortOrder;

  const CategoryAttribute({
    required this.id,
    required this.categoryType,
    required this.attributeKey,
    required this.attributeLabel,
    required this.attributeType,
    this.isRequired = false,
    this.optionsJson,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, attributeKey, categoryType];
}
