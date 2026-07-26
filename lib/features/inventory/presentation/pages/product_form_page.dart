import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../providers/inventory_providers.dart';
import '../../domain/entities/product.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product_attribute.dart';
import '../../domain/entities/category_attribute.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final String? productId;

  const ProductFormPage({super.key, this.productId});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _minStockController = TextEditingController();
  final _uuid = const Uuid();

  String? _selectedCategoryId;
  String _unit = 'Piece';
  bool _isActive = true;
  bool _isLoading = false;
  String? _imagePath;

  final _attributeControllers = <String, TextEditingController>{};
  final _attributeSelectValues = <String, String>{};

  bool get _isEditing => widget.productId != null;

  List<CategoryAttribute>? _cachedAttributes;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadProduct();
    } else {
      _generateSku();
    }
  }

  Future<void> _generateSku() async {
    if (_selectedCategoryId == null) return;
    final repo = ref.read(productRepositoryProvider);
    final result = await repo.generateSku(_selectedCategoryId!);
    result.when(success: (sku) => _skuController.text = sku, error: (_) {});
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    final repo = ref.read(productRepositoryProvider);
    final result = await repo.getProductById(widget.productId!);
    result.when(
      success: (product) {
        if (product != null) {
          _nameController.text = product.name;
          _skuController.text = product.sku;
          _descriptionController.text = product.description ?? '';
          _barcodeController.text = product.barcode ?? '';
          _priceController.text = product.price.toString();
          _costController.text = product.cost.toString();
          _minStockController.text = product.minStock.toString();
          _selectedCategoryId = product.categoryId;
          _unit = product.unit;
          _isActive = product.isActive;
          _imagePath = product.imagePath;
          _loadAttributes();
        }
      },
      error: (_) {},
    );
    setState(() => _isLoading = false);
  }

  Future<void> _loadAttributes() async {
    if (_selectedCategoryId == null) return;
    final catRepo = ref.read(categoryRepositoryProvider);
    final categoriesResult = await catRepo.getAllCategories();
    categoriesResult.when(
      success: (categories) {
        final cat = categories
            .where((c) => c.id == _selectedCategoryId)
            .firstOrNull;
        if (cat != null) {
          final catType = cat.type.name;
          catRepo.getAttributesByCategoryType(catType).then((result) {
            result.when(
              success: (attrs) {
                _cachedAttributes = attrs;
                for (final attr in attrs) {
                  _attributeControllers[attr.attributeKey] =
                      TextEditingController();
                }
                _loadProductAttributeValues();
                setState(() {});
              },
              error: (_) {},
            );
          });
        }
      },
      error: (_) {},
    );
  }

  Future<void> _loadProductAttributeValues() async {
    if (widget.productId == null) return;
    final repo = ref.read(productRepositoryProvider);
    final result = await repo.getProductAttributes(widget.productId!);
    result.when(
      success: (attrs) {
        for (final attr in attrs) {
          _attributeControllers[attr.attributeKey]?.text = attr.attributeValue;
          _attributeSelectValues[attr.attributeKey] = attr.attributeValue;
        }
        setState(() {});
      },
      error: (_) {},
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _minStockController.dispose();
    for (final c in _attributeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Product' : 'Add Product')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skuController,
                            decoration: const InputDecoration(labelText: 'SKU'),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _barcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Barcode',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    categoriesAsync.when(
                      data: (categories) => DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedCategoryId = v);
                          if (!_isEditing) _generateSku();
                          _loadAttributes();
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Selling Price',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || double.tryParse(v) == null)
                                return 'Invalid price';
                              if (double.parse(v) < 0)
                                return 'Price cannot be negative';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _costController,
                            decoration: const InputDecoration(
                              labelText: 'Cost',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || double.tryParse(v) == null)
                                return 'Invalid cost';
                              if (double.parse(v) < 0)
                                return 'Cost cannot be negative';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minStockController,
                            decoration: const InputDecoration(
                              labelText: 'Min Stock Alert',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _unit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Piece',
                                child: Text('Piece'),
                              ),
                              DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                              DropdownMenuItem(
                                value: 'Gram',
                                child: Text('Gram'),
                              ),
                              DropdownMenuItem(
                                value: 'Liter',
                                child: Text('Liter'),
                              ),
                              DropdownMenuItem(
                                value: 'Pair',
                                child: Text('Pair'),
                              ),
                              DropdownMenuItem(
                                value: 'Set',
                                child: Text('Set'),
                              ),
                              DropdownMenuItem(
                                value: 'Copy',
                                child: Text('Copy'),
                              ),
                              DropdownMenuItem(
                                value: 'Unit',
                                child: Text('Unit'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _unit = v ?? 'Piece'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    if (_cachedAttributes != null &&
                        _cachedAttributes!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Dynamic Attributes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._cachedAttributes!.map(
                        (attr) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: attr.attributeType == 'select'
                              ? DropdownButtonFormField<String>(
                                  initialValue:
                                      _attributeSelectValues[attr.attributeKey],
                                  decoration: InputDecoration(
                                    labelText: attr.attributeLabel,
                                  ),
                                  items: _parseOptions(attr.optionsJson)
                                      .map(
                                        (o) => DropdownMenuItem(
                                          value: o,
                                          child: Text(o),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      _attributeSelectValues[attr
                                              .attributeKey] =
                                          v ?? '',
                                  validator: attr.isRequired
                                      ? (v) => v == null || v.isEmpty
                                            ? 'Required'
                                            : null
                                      : null,
                                )
                              : TextFormField(
                                  controller:
                                      _attributeControllers[attr.attributeKey],
                                  decoration: InputDecoration(
                                    labelText: attr.attributeLabel,
                                  ),
                                  keyboardType: attr.attributeType == 'number'
                                      ? TextInputType.number
                                      : TextInputType.text,
                                  validator: attr.isRequired
                                      ? (v) => v == null || v.trim().isEmpty
                                            ? 'Required'
                                            : null
                                      : null,
                                ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.image),
                            label: Text(
                              _imagePath != null ? 'Change Image' : 'Add Image',
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                        if (_imagePath != null) ...[
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_imagePath!),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.error,
                            ),
                            onPressed: () => setState(() => _imagePath = null),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text(
                        _isEditing ? 'Update Product' : 'Create Product',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
    );
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  List<String> _parseOptions(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: _isEditing ? widget.productId! : _uuid.v4(),
      sku: _skuController.text.trim(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      unit: _unit,
      price: double.parse(_priceController.text.trim()),
      cost: double.parse(_costController.text.trim()),
      minStock: double.tryParse(_minStockController.text.trim()) ?? 0,
      imagePath: _imagePath,
      isActive: _isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final attributes = _cachedAttributes
        ?.map(
          (attr) => ProductAttribute(
            id: _uuid.v4(),
            productId: product.id,
            attributeKey: attr.attributeKey,
            attributeValue:
                _attributeSelectValues[attr.attributeKey] ??
                _attributeControllers[attr.attributeKey]?.text ??
                '',
          ),
        )
        .where((a) => a.attributeValue.isNotEmpty)
        .toList();

    final repo = ref.read(productRepositoryProvider);
    final result = _isEditing
        ? await repo.updateProduct(product, attributes: attributes)
        : await repo.createProduct(product, attributes: attributes);

    result.when(
      success: (_) {
        if (mounted) {
          ref.invalidate(productsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Product updated' : 'Product created'),
            ),
          );
          context.pop();
        }
      },
      error: (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
      },
    );
  }
}
