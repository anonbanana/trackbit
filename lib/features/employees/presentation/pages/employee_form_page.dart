import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/employee.dart';
import '../providers/employee_providers.dart';

class EmployeeFormPage extends ConsumerStatefulWidget {
  final String? employeeId;
  const EmployeeFormPage({super.key, this.employeeId});

  @override
  ConsumerState<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends ConsumerState<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _positionCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.employeeId != null) {
      _loadEmployee();
    }
  }

  Future<void> _loadEmployee() async {
    final result = await ref.read(employeeRepositoryProvider).getEmployeeById(widget.employeeId!);
    result.when(success: (emp) {
      if (emp != null && mounted) {
        _positionCtrl.text = emp.position;
        _salaryCtrl.text = emp.salary.toString();
        _phoneCtrl.text = emp.phone ?? '';
        _addressCtrl.text = emp.address ?? '';
        _isActive = emp.isActive;
      }
    }, error: (_) {});
  }

  @override
  void dispose() {
    _positionCtrl.dispose();
    _salaryCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final salary = double.tryParse(_salaryCtrl.text) ?? 0;

    if (widget.employeeId != null) {
      final emp = Employee(
        id: widget.employeeId!,
        position: _positionCtrl.text.trim(),
        salary: salary,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        isActive: _isActive,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(employeeRepositoryProvider).updateEmployee(emp);
    } else {
      final emp = Employee(
        id: const Uuid().v4(),
        position: _positionCtrl.text.trim(),
        salary: salary,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        isActive: _isActive,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(employeeRepositoryProvider).createEmployee(emp);
    }

    if (mounted) {
      ref.invalidate(employeesProvider);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employeeId != null ? 'Edit Employee' : 'Add Employee'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _positionCtrl,
              decoration: const InputDecoration(labelText: 'Position *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _salaryCtrl,
              decoration: const InputDecoration(labelText: 'Salary', border: OutlineInputBorder(), prefixText: '\$ '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
