import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/roles/presentation/pages/role_list_page.dart';
import '../../features/roles/presentation/pages/role_form_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import '../../features/sales/presentation/pages/sales_page.dart';
import '../../features/invoicing/presentation/pages/invoicing_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/crm/presentation/pages/crm_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/sync/presentation/pages/sync_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/roles',
      name: 'roles',
      builder: (context, state) => const RoleListPage(),
      routes: [
        GoRoute(
          path: 'add',
          name: 'role-add',
          builder: (context, state) => const RoleFormPage(),
        ),
        GoRoute(
          path: ':id/edit',
          name: 'role-edit',
          builder: (context, state) => RoleFormPage(
            roleId: state.pathParameters['id'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/inventory',
      name: 'inventory',
      builder: (context, state) => const InventoryPage(),
    ),
    GoRoute(
      path: '/pos',
      name: 'pos',
      builder: (context, state) => const PosPage(),
    ),
    GoRoute(
      path: '/sales',
      name: 'sales',
      builder: (context, state) => const SalesPage(),
    ),
    GoRoute(
      path: '/invoicing',
      name: 'invoicing',
      builder: (context, state) => const InvoicingPage(),
    ),
    GoRoute(
      path: '/expenses',
      name: 'expenses',
      builder: (context, state) => const ExpensesPage(),
    ),
    GoRoute(
      path: '/employees',
      name: 'employees',
      builder: (context, state) => const EmployeesPage(),
    ),
    GoRoute(
      path: '/crm',
      name: 'crm',
      builder: (context, state) => const CrmPage(),
    ),
    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) => const ReportsPage(),
    ),
    GoRoute(
      path: '/sync',
      name: 'sync',
      builder: (context, state) => const SyncPage(),
    ),
  ],
);
