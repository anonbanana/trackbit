import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../providers/inventory_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_attribute.dart';
import '../../domain/enums/category_type.dart';
import '../../../../core/constants/app_colors.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  final String? categoryId;

  const CategoryFormPage({super.key, this.categoryId});

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uuid = const Uuid();

  CategoryType _selectedType = CategoryType.custom;
  bool _isLoading = false;

  final _attributeControllers = <String, TextEditingController>{};

  bool get _isEditing => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadCategory();
    }
    _loadAttributeTemplates();
  }

  Future<void> _loadCategory() async {
    setState(() => _isLoading = true);
    final repo = ref.read(categoryRepositoryProvider);
    final result = await repo.getCategoryById(widget.categoryId!);
    result.when(
      success: (category) {
        if (category != null) {
          _nameController.text = category.name;
          _selectedType = category.type;
          ref.invalidate(categoryAttributesProvider);
        }
      },
      error: (_) {},
    );
    setState(() => _isLoading = false);
  }

  Future<void> _loadAttributeTemplates() async {
    _getDefaultAttributes(_selectedType);
    setState(() {});
  }

  List<CategoryAttribute> _getDefaultAttributes(CategoryType type) {
    final defaults = _defaultAttributesForType(type);
    for (final attr in defaults) {
      if (!_attributeControllers.containsKey(attr.attributeKey)) {
        _attributeControllers[attr.attributeKey] = TextEditingController();
      }
    }
    return defaults;
  }

  List<CategoryAttribute> _defaultAttributesForType(CategoryType type) {
    switch (type) {
      case CategoryType.food:
        return [
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'cooking_method',
            attributeLabel: 'Cooking Method',
            attributeType: 'select',
            isRequired: false,
            optionsJson: '["Fried","Soup","Grilled","Steamed","Frozen"]',
            sortOrder: 0,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'expiry_days',
            attributeLabel: 'Expiry (Days)',
            attributeType: 'number',
            isRequired: false,
            sortOrder: 1,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'ingredients',
            attributeLabel: 'Ingredients',
            attributeType: 'text',
            isRequired: false,
            sortOrder: 2,
          ),
        ];
      case CategoryType.clothing:
        return [
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'size',
            attributeLabel: 'Size',
            attributeType: 'select',
            isRequired: true,
            optionsJson: '["XS","S","M","L","XL","XXL"]',
            sortOrder: 0,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'gender',
            attributeLabel: 'Gender',
            attributeType: 'select',
            isRequired: true,
            optionsJson: '["Male","Female","Unisex"]',
            sortOrder: 1,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'material',
            attributeLabel: 'Material',
            attributeType: 'text',
            isRequired: false,
            sortOrder: 2,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'color',
            attributeLabel: 'Color',
            attributeType: 'text',
            isRequired: false,
            sortOrder: 3,
          ),
        ];
      case CategoryType.electronics:
        return [
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'brand',
            attributeLabel: 'Brand',
            attributeType: 'text',
            isRequired: true,
            sortOrder: 0,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'model',
            attributeLabel: 'Model',
            attributeType: 'text',
            isRequired: true,
            sortOrder: 1,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'warranty_months',
            attributeLabel: 'Warranty (Months)',
            attributeType: 'number',
            isRequired: false,
            sortOrder: 2,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'voltage',
            attributeLabel: 'Voltage',
            attributeType: 'text',
            isRequired: false,
            sortOrder: 3,
          ),
        ];
      case CategoryType.gaming:
        return [
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'platform',
            attributeLabel: 'Platform',
            attributeType: 'select',
            isRequired: true,
            optionsJson: '["PC","PS","Xbox","Nintendo"]',
            sortOrder: 0,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'genre',
            attributeLabel: 'Genre',
            attributeType: 'text',
            isRequired: false,
            sortOrder: 1,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'region',
            attributeLabel: 'Region',
            attributeType: 'text',
            isRequired: false,
            sortOrder: 2,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'edition',
            attributeLabel: 'Edition',
            attributeType: 'text',
            isRequired: false,
            sortOrder: 3,
          ),
        ];
      case CategoryType.optical:
        return [
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'lens_type',
            attributeLabel: 'Lens Type',
            attributeType: 'select',
            isRequired: true,
            optionsJson:
                '["Single Vision","Bifocal","Progressive","Blue Block","Photochromic"]',
            sortOrder: 0,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'frame_material',
            attributeLabel: 'Frame Material',
            attributeType: 'select',
            isRequired: true,
            optionsJson:
                '["Metal","Plastic","Titanium","Acetate","Combination"]',
            sortOrder: 1,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'prescription',
            attributeLabel: 'Prescription',
            attributeType: 'text',
            isRequired: false,
            sortOrder: 2,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'color',
            attributeLabel: 'Color',
            attributeType: 'text',
            isRequired: false,
            sortOrder: 3,
          ),
        ];
      case CategoryType.luggage:
        return [
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'material',
            attributeLabel: 'Material',
            attributeType: 'select',
            isRequired: true,
            optionsJson: '["Polycarbonate","ABS","Nylon","Leather"]',
            sortOrder: 0,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'size_cm',
            attributeLabel: 'Size (cm)',
            attributeType: 'text',
            isRequired: true,
            sortOrder: 1,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'weight_kg',
            attributeLabel: 'Weight (kg)',
            attributeType: 'number',
            isRequired: false,
            sortOrder: 2,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'capacity_liters',
            attributeLabel: 'Capacity (L)',
            attributeType: 'number',
            isRequired: false,
            sortOrder: 3,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'color',
            attributeLabel: 'Color',
            attributeType: 'text',
            isRequired: false,
            sortOrder: 4,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'wheel_type',
            attributeLabel: 'Wheel Type',
            attributeType: 'select',
            isRequired: false,
            optionsJson: '["Single","Double","Spinner","None"]',
            sortOrder: 5,
          ),
          CategoryAttribute(
            id: _uuid.v4(),
            categoryType: type,
            attributeKey: 'lock_type',
            attributeLabel: 'Lock Type',
            attributeType: 'select',
            isRequired: false,
            optionsJson: '["Combination","Key","TSA","None"]',
            sortOrder: 6,
          ),
        ];
      case CategoryType.custom:
        return [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _attributeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attributes = _getDefaultAttributes(_selectedType);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
      ),
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
                        labelText: 'Category Name',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CategoryType>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Category Type',
                      ),
                      items: CategoryType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Row(
                                children: [
                                  Icon(
                                    _getIcon(t),
                                    size: 18,
                                    color: _getColor(t),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(t.label),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _selectedType = v;
                            _attributeControllers.clear();
                          });
                        }
                      },
                    ),
                    if (attributes.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Default Attributes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...attributes.map(
                        (attr) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attr.attributeLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (attr.attributeType == 'select' &&
                                  attr.optionsJson != null)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: _parseOptions(attr.optionsJson)
                                      .map(
                                        (o) => Chip(
                                          label: Text(
                                            o,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                      .toList(),
                                )
                              else
                                Text(
                                  attr.attributeType == 'select'
                                      ? 'Select option'
                                      : 'Text field',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Attributes are predefined for this category type',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveCategory,
                      child: Text(
                        _isEditing ? 'Update Category' : 'Create Category',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  IconData _getIcon(CategoryType type) {
    switch (type) {
      case CategoryType.food:
        return Icons.restaurant;
      case CategoryType.clothing:
        return Icons.checkroom;
      case CategoryType.electronics:
        return Icons.devices;
      case CategoryType.gaming:
        return Icons.sports_esports;
      case CategoryType.optical:
        return Icons.visibility;
      case CategoryType.luggage:
        return Icons.luggage;
      case CategoryType.custom:
        return Icons.category;
    }
  }

  List<String> _parseOptions(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr);
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

  Color _getColor(CategoryType type) {
    switch (type) {
      case CategoryType.food:
        return AppColors.success;
      case CategoryType.clothing:
        return AppColors.secondary;
      case CategoryType.electronics:
        return AppColors.primary;
      case CategoryType.gaming:
        return AppColors.accent;
      case CategoryType.optical:
        return AppColors.info;
      case CategoryType.luggage:
        return AppColors.warning;
      case CategoryType.custom:
        return const Color(0xFF64748B);
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final category = Category(
      id: _isEditing ? widget.categoryId! : _uuid.v4(),
      name: _nameController.text.trim(),
      type: _selectedType,
      isSystem: _isEditing,
      sortOrder: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(categoryRepositoryProvider);
    final result = _isEditing
        ? await repo.updateCategory(category)
        : await repo.createCategory(category);

    result.when(
      success: (_) async {
        final attributes = _defaultAttributesForType(_selectedType);
        if (attributes.isNotEmpty) {
          await repo.saveCategoryAttributes(attributes);
        }
        if (mounted) {
          ref.invalidate(categoriesProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing ? 'Category updated' : 'Category created',
              ),
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
