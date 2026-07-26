import 'package:flutter/material.dart';
import '../../domain/enums/payment_method.dart';

class PaymentSelector extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        RadioGroup<PaymentMethod>(
          groupValue: selectedMethod,
          onChanged: (v) => onChanged(v ?? PaymentMethod.cash),
          child: Column(
            children: [
              ...PaymentMethod.values.map(
                (method) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<PaymentMethod>(
                    title: Row(
                      children: [
                        Icon(_getIcon(method), size: 20),
                        const SizedBox(width: 8),
                        Text(method.label),
                      ],
                    ),
                    value: method,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.transfer:
        return Icons.account_balance;
    }
  }
}
