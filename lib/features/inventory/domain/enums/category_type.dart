enum CategoryType {
  food,
  clothing,
  electronics,
  gaming,
  optical,
  luggage,
  custom;

  String get label {
    switch (this) {
      case CategoryType.food: return 'Food';
      case CategoryType.clothing: return 'Clothing';
      case CategoryType.electronics: return 'Electronics';
      case CategoryType.gaming: return 'Gaming';
      case CategoryType.optical: return 'Optical';
      case CategoryType.luggage: return 'Luggage';
      case CategoryType.custom: return 'Custom';
    }
  }

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CategoryType.custom,
    );
  }
}
