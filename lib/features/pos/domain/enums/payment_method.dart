enum PaymentMethod {
  cash,
  card,
  transfer;

  String get label {
    switch (this) {
      case PaymentMethod.cash: return 'Cash';
      case PaymentMethod.card: return 'Card';
      case PaymentMethod.transfer: return 'Bank Transfer';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere((e) => e.name == value);
  }
}
