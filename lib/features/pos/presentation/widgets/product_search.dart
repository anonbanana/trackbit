import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pos_providers.dart';

class ProductSearchWidget extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic> product) onProductSelected;

  const ProductSearchWidget({super.key, required this.onProductSelected});

  @override
  ConsumerState<ProductSearchWidget> createState() =>
      _ProductSearchWidgetState();
}

class _ProductSearchWidgetState extends ConsumerState<ProductSearchWidget> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(searchedPosProductsProvider(_query));

    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty && _query.isNotEmpty) {
                return const Center(child: Text('No products found'));
              }
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(product['name'] as String),
                    subtitle: Text('\$${product['price']}'),
                    onTap: () => widget.onProductSelected(product),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
