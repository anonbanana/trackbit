import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/receipt_settings.dart';
import '../providers/settings_providers.dart';

class ReceiptSettingsPage extends ConsumerStatefulWidget {
  const ReceiptSettingsPage({super.key});

  @override
  ConsumerState<ReceiptSettingsPage> createState() =>
      _ReceiptSettingsPageState();
}

class _ReceiptSettingsPageState extends ConsumerState<ReceiptSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameCtrl = TextEditingController();
  final _storeAddressCtrl = TextEditingController();
  final _storePhoneCtrl = TextEditingController();
  final _headerTextCtrl = TextEditingController();
  final _footerTextCtrl = TextEditingController();
  double _taxRate = 0;
  int _paperWidth = 58;
  bool _showTax = true;
  bool _showDiscount = true;
  bool _isLoading = true;

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _storeAddressCtrl.dispose();
    _storePhoneCtrl.dispose();
    _headerTextCtrl.dispose();
    _footerTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(receiptSettingsProvider, (prev, next) {
      next.whenOrNull(
        data: (settings) {
          if (_isLoading) {
            _storeNameCtrl.text = settings.storeName ?? '';
            _storeAddressCtrl.text = settings.storeAddress ?? '';
            _storePhoneCtrl.text = settings.storePhone ?? '';
            _headerTextCtrl.text = settings.headerText ?? '';
            _footerTextCtrl.text = settings.footerText ?? '';
            _taxRate = settings.taxRate;
            _paperWidth = settings.paperWidth;
            _showTax = settings.showTax;
            _showDiscount = settings.showDiscount;
            _isLoading = false;
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _storeNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Store Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _storeAddressCtrl,
              decoration: const InputDecoration(
                labelText: 'Store Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _storePhoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Store Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tax Rate (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              initialValue: _taxRate.toString(),
              onChanged: (v) => _taxRate = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _paperWidth,
              decoration: const InputDecoration(
                labelText: 'Paper Width',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 58, child: Text('58mm')),
                DropdownMenuItem(value: 80, child: Text('80mm')),
              ],
              onChanged: (v) => setState(() => _paperWidth = v ?? 58),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _headerTextCtrl,
              decoration: const InputDecoration(
                labelText: 'Header Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _footerTextCtrl,
              decoration: const InputDecoration(
                labelText: 'Footer Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Show Tax on Receipt'),
              value: _showTax,
              onChanged: (v) => setState(() => _showTax = v),
            ),
            SwitchListTile(
              title: const Text('Show Discount on Receipt'),
              value: _showDiscount,
              onChanged: (v) => setState(() => _showDiscount = v),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveReceiptSettings(
      ReceiptSettings(
        storeName: _storeNameCtrl.text.trim().isEmpty
            ? null
            : _storeNameCtrl.text.trim(),
        storeAddress: _storeAddressCtrl.text.trim().isEmpty
            ? null
            : _storeAddressCtrl.text.trim(),
        storePhone: _storePhoneCtrl.text.trim().isEmpty
            ? null
            : _storePhoneCtrl.text.trim(),
        taxRate: _taxRate,
        paperWidth: _paperWidth,
        headerText: _headerTextCtrl.text.trim().isEmpty
            ? null
            : _headerTextCtrl.text.trim(),
        footerText: _footerTextCtrl.text.trim().isEmpty
            ? null
            : _footerTextCtrl.text.trim(),
        showTax: _showTax,
        showDiscount: _showDiscount,
      ),
    );
    ref.invalidate(receiptSettingsProvider);
    if (mounted) context.pop();
  }
}
