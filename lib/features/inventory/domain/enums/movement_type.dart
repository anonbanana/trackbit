enum MovementType {
  stockIn,
  stockOut,
  adjustment;

  String get label {
    switch (this) {
      case MovementType.stockIn:
        return 'Stock In';
      case MovementType.stockOut:
        return 'Stock Out';
      case MovementType.adjustment:
        return 'Adjustment';
    }
  }

  static MovementType fromString(String value) {
    return MovementType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MovementType.adjustment,
    );
  }
}
