import 'package:flutter/material.dart';
import '../../domain/entities/category_attribute.dart';

class DynamicAttributeForm extends StatelessWidget {
  final List<CategoryAttribute> attributes;
  final Map<String, TextEditingController> controllers;
  final Map<String, String> selectValues;

  const DynamicAttributeForm({
    super.key,
    required this.attributes,
    required this.controllers,
    required this.selectValues,
  });

  @override
  Widget build(BuildContext context) {
    if (attributes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attributes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...attributes.map(
          (attr) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: attr.attributeType == 'select'
                ? DropdownButtonFormField<String>(
                    initialValue: selectValues[attr.attributeKey],
                    decoration: InputDecoration(labelText: attr.attributeLabel),
                    items: _parseOptions(attr.optionsJson)
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) => selectValues[attr.attributeKey] = v ?? '',
                    validator: attr.isRequired
                        ? (v) => v == null || v.isEmpty ? 'Required' : null
                        : null,
                  )
                : TextFormField(
                    controller: controllers[attr.attributeKey],
                    decoration: InputDecoration(labelText: attr.attributeLabel),
                    keyboardType: attr.attributeType == 'number'
                        ? TextInputType.number
                        : TextInputType.text,
                    validator: attr.isRequired
                        ? (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null
                        : null,
                  ),
          ),
        ),
      ],
    );
  }

  List<String> _parseOptions(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final stripped = json
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '');
      return stripped
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
