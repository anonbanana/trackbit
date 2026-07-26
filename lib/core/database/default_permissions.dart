import 'package:drift/drift.dart';
import 'app_database.dart';

class DefaultPermissions {
  DefaultPermissions._();

  static Future<void> initialize(AppDatabase db) async {
    final count = await db.select(db.permissions).get().then((r) => r.length);
    if (count > 0) return;

    final permissions = [
      // Dashboard
      (
        'dashboard.view',
        'View Dashboard',
        'Dashboard',
        'Access the main dashboard',
      ),
      (
        'dashboard.export',
        'Export Dashboard Data',
        'Dashboard',
        'Export dashboard reports',
      ),

      // Inventory
      (
        'inventory.view',
        'View Inventory',
        'Inventory',
        'View product catalog and stock',
      ),
      ('inventory.create', 'Create Products', 'Inventory', 'Add new products'),
      (
        'inventory.edit',
        'Edit Products',
        'Inventory',
        'Edit existing products',
      ),
      ('inventory.delete', 'Delete Products', 'Inventory', 'Remove products'),
      (
        'inventory.stock.adjust',
        'Adjust Stock',
        'Inventory',
        'Perform stock adjustments',
      ),
      (
        'inventory.barcode',
        'Scan Barcodes',
        'Inventory',
        'Use barcode scanner',
      ),
      (
        'inventory.categories.manage',
        'Manage Categories',
        'Inventory',
        'CRUD product categories',
      ),

      // POS
      ('pos.access', 'Access POS', 'Point of Sale', 'Use the POS interface'),
      (
        'pos.sell',
        'Process Sales',
        'Point of Sale',
        'Complete sales transactions',
      ),
      (
        'pos.discount',
        'Apply Discounts',
        'Point of Sale',
        'Add discounts to sales',
      ),
      (
        'pos.refund',
        'Process Refunds',
        'Point of Sale',
        'Issue refunds to customers',
      ),
      ('pos.print', 'Print Receipts', 'Point of Sale', 'Print sales receipts'),

      // Sales
      ('sales.view', 'View Sales', 'Sales', 'View sales history'),
      ('sales.export', 'Export Sales', 'Sales', 'Export sales reports'),

      // Invoicing
      ('invoices.view', 'View Invoices', 'Invoicing', 'View invoice list'),
      (
        'invoices.create',
        'Create Invoices',
        'Invoicing',
        'Generate new invoices',
      ),
      ('invoices.edit', 'Edit Invoices', 'Invoicing', 'Modify invoices'),
      ('invoices.delete', 'Delete Invoices', 'Invoicing', 'Remove invoices'),
      (
        'invoices.print',
        'Print Invoices',
        'Invoicing',
        'Print or export invoices',
      ),

      // Expenses
      ('expenses.view', 'View Expenses', 'Expenses', 'View expense list'),
      ('expenses.create', 'Add Expenses', 'Expenses', 'Record new expenses'),
      ('expenses.edit', 'Edit Expenses', 'Expenses', 'Modify expenses'),
      ('expenses.delete', 'Delete Expenses', 'Expenses', 'Remove expenses'),

      // CRM
      ('crm.view', 'View Customers', 'CRM', 'View customer list'),
      ('crm.create', 'Add Customers', 'CRM', 'Create new customers'),
      ('crm.edit', 'Edit Customers', 'CRM', 'Modify customer details'),
      ('crm.delete', 'Delete Customers', 'CRM', 'Remove customers'),

      // Employees
      ('employees.view', 'View Employees', 'Employees', 'View employee list'),
      ('employees.create', 'Add Employees', 'Employees', 'Hire new employees'),
      (
        'employees.edit',
        'Edit Employees',
        'Employees',
        'Modify employee details',
      ),
      ('employees.delete', 'Delete Employees', 'Employees', 'Remove employees'),

      // Roles & Users
      ('roles.view', 'View Roles', 'Roles', 'View role list'),
      ('roles.create', 'Create Roles', 'Roles', 'Add new roles'),
      ('roles.edit', 'Edit Roles', 'Roles', 'Modify roles and permissions'),
      ('roles.delete', 'Delete Roles', 'Roles', 'Remove roles'),
      ('users.view', 'View Users', 'Users', 'View user list'),
      ('users.create', 'Create Users', 'Users', 'Add new users'),
      ('users.edit', 'Edit Users', 'Users', 'Modify user details'),
      ('users.delete', 'Delete Users', 'Users', 'Remove users'),

      // Reports
      ('reports.view', 'View Reports', 'Reports', 'Access reports section'),
      (
        'reports.export',
        'Export Reports',
        'Reports',
        'Export reports in PDF/Excel/CSV',
      ),

      // Sync
      ('sync.view', 'View Sync Status', 'Sync', 'View sync dashboard'),
      (
        'sync.trigger',
        'Trigger Sync',
        'Sync',
        'Manually trigger synchronization',
      ),
      ('sync.configure', 'Configure Sync', 'Sync', 'Modify sync settings'),

      // Settings
      ('settings.view', 'View Settings', 'Settings', 'Access settings'),
      (
        'settings.edit',
        'Edit Settings',
        'Settings',
        'Modify application settings',
      ),
      (
        'settings.receipt',
        'Configure Receipt',
        'Settings',
        'Modify receipt print settings',
      ),
    ];

    for (final (id, label, group, description) in permissions) {
      await db
          .into(db.permissions)
          .insert(
            PermissionsCompanion(
              id: Value(id),
              label: Value(label),
              groupName: Value(group),
              description: Value(description),
            ),
          );
    }
  }
}
