import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../providers/role_provider.dart';
import '../../domain/entities/role.dart' as domain;
import '../../domain/entities/permission.dart' as domain;

class RoleFormPage extends ConsumerStatefulWidget {
  final String? roleId;

  const RoleFormPage({super.key, this.roleId});

  @override
  ConsumerState<RoleFormPage> createState() => _RoleFormPageState();
}

class _RoleFormPageState extends ConsumerState<RoleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _labelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();

  String? _parentRoleId;
  int _level = 3;
  List<String> _selectedPermissionIds = [];
  bool _isLoading = false;

  bool get _isEditing => widget.roleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadRole();
    }
  }

  Future<void> _loadRole() async {
    setState(() => _isLoading = true);
    final repository = ref.read(roleRepositoryProvider);
    final result = await repository.getRoleById(widget.roleId!);
    result.when(
      success: (role) {
        if (role != null) {
          _nameController.text = role.name;
          _labelController.text = role.label;
          _descriptionController.text = role.description ?? '';
          _parentRoleId = role.parentRoleId;
          _level = role.level;
        }
      },
      error: (_) {},
    );
    final permResult = await repository.getRolePermissionIds(widget.roleId!);
    permResult.when(
      success: (ids) => _selectedPermissionIds = ids,
      error: (_) {},
    );
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);
    final permissionsAsync = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Role' : 'Add Role')),
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
                      controller: _labelController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'System Name',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
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
                    rolesAsync.when(
                      data: (roles) => DropdownButtonFormField<String>(
                        initialValue: _parentRoleId,
                        decoration: const InputDecoration(
                          labelText: 'Parent Role',
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('None (Top Level)'),
                          ),
                          ...roles
                              .where((r) => r.id != widget.roleId)
                              .map(
                                (r) => DropdownMenuItem<String>(
                                  value: r.id,
                                  child: Text(r.label),
                                ),
                              ),
                        ],
                        onChanged: (v) => setState(() => _parentRoleId = v),
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _level,
                      decoration: const InputDecoration(
                        labelText: 'Hierarchy Level',
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('0 - System')),
                        DropdownMenuItem(value: 1, child: Text('1 - Boss')),
                        DropdownMenuItem(value: 2, child: Text('2 - Manager')),
                        DropdownMenuItem(value: 3, child: Text('3 - Employee')),
                      ],
                      onChanged: (v) => setState(() => _level = v ?? 3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Permissions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    permissionsAsync.when(
                      data: (permissions) {
                        final grouped = <String, List<domain.Permission>>{};
                        for (final p in permissions) {
                          grouped.putIfAbsent(p.groupName, () => []).add(p);
                        }
                        return Column(
                          children: grouped.entries.map((entry) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        top: 4,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    ...entry.value.map(
                                      (perm) => CheckboxListTile(
                                        dense: true,
                                        title: Text(
                                          perm.label,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: perm.description != null
                                            ? Text(
                                                perm.description!,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              )
                                            : null,
                                        value: _selectedPermissionIds.contains(
                                          perm.id,
                                        ),
                                        onChanged: (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              _selectedPermissionIds.add(
                                                perm.id,
                                              );
                                            } else {
                                              _selectedPermissionIds.remove(
                                                perm.id,
                                              );
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveRole,
                      child: Text(_isEditing ? 'Update Role' : 'Create Role'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveRole() async {
    if (!_formKey.currentState!.validate()) return;

    final role = domain.Role(
      id: _isEditing ? widget.roleId! : _uuid.v4(),
      name: _nameController.text.trim(),
      label: _labelController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      parentRoleId: _parentRoleId,
      isSystem: false,
      isCustomizable: true,
      level: _level,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repository = ref.read(roleRepositoryProvider);
    final result = _isEditing
        ? await repository.updateRole(role)
        : await repository.createRole(role);

    result.when(
      success: (_) async {
        await repository.assignPermissionsToRole(
          role.id,
          _selectedPermissionIds,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Role updated' : 'Role created'),
            ),
          );
          context.pop();
          ref.invalidate(rolesProvider);
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
