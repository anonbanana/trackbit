import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pos_providers.dart';
import '../../domain/enums/payment_method.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _discountController = TextEditingController();
  final _taxController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final cart = ref.read(cartProvider);
    _discountController.text = cart.discount.toStringAsFixed(0);
    _taxController.text = cart.taxRate.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name (optional)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customerPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone (optional)',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discount & Tax',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _discountController,
                            decoration: const InputDecoration(
                              labelText: 'Discount (%)',
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final val = double.tryParse(v) ?? 0;
                              ref.read(cartProvider.notifier).setDiscount(val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _taxController,
                            decoration: const InputDecoration(
                              labelText: 'Tax Rate (%)',
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final val = double.tryParse(v) ?? 0;
                              ref.read(cartProvider.notifier).setTaxRate(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    RadioGroup<PaymentMethod>(
                      groupValue: _paymentMethod,
                      onChanged: (v) => setState(
                        () => _paymentMethod = v ?? PaymentMethod.cash,
                      ),
                      child: Column(
                        children: PaymentMethod.values
                            .map(
                              (method) => RadioListTile<PaymentMethod>(
                                title: Text(method.label),
                                value: method,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Row(label: 'Subtotal', value: cart.subtotal),
                    if (cart.discount > 0)
                      _Row(
                        label:
                            'Discount (${cart.discount.toStringAsFixed(0)}%)',
                        value: -cart.discountAmount,
                        color: AppColors.error,
                      ),
                    if (cart.taxRate > 0)
                      _Row(
                        label: 'Tax (${cart.taxRate.toStringAsFixed(0)}%)',
                        value: cart.taxAmount,
                      ),
                    const Divider(),
                    _Row(
                      label: 'Total',
                      value: cart.total,
                      bold: true,
                      fontSize: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () => _processOrder(authState.user?.id ?? ''),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Complete Sale - ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(cart.total)}',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processOrder(String userId) async {
    setState(() => _isProcessing = true);
    final cart = ref.read(cartProvider);
    final repo = ref.read(posRepositoryProvider);

    final result = await repo.processOrder(
      cart: cart,
      userId: userId,
      paymentMethod: _paymentMethod.name,
      customerName: _customerNameController.text.trim().isEmpty
          ? null
          : _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim().isEmpty
          ? null
          : _customerPhoneController.text.trim(),
    );

    result.when(
      success: (_) {
        if (mounted) {
          ref.read(cartProvider.notifier).clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sale completed successfully!')),
          );
          context.go('/pos');
        }
      },
      error: (failure) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
        }
      },
    );

    setState(() => _isProcessing = false);
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  final double fontSize;
  final Color? color;

  const _Row({
    required this.label,
    required this.value,
    this.bold = false,
    this.fontSize = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
