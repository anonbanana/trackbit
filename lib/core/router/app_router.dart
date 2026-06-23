import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/roles/presentation/pages/role_list_page.dart';
import '../../features/roles/presentation/pages/role_form_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/inventory/presentation/pages/category_list_page.dart';
import '../../features/inventory/presentation/pages/category_form_page.dart';
import '../../features/inventory/presentation/pages/product_list_page.dart';
import '../../features/inventory/presentation/pages/product_form_page.dart';
import '../../features/inventory/presentation/pages/stock_movement_page.dart';
import '../../features/inventory/presentation/pages/low_stock_page.dart';
import '../../features/pos/presentation/pages/pos_main_page.dart';
import '../../features/pos/presentation/pages/checkout_page.dart';
import '../../features/sales/presentation/pages/sales_page.dart';
import '../../features/invoicing/presentation/pages/invoicing_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/employees/presentation/pages/employee_form_page.dart';
import '../../features/crm/presentation/pages/crm_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/sync/presentation/pages/sync_page.dart';

GoRouter appRouter(WidgetRef ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isInitial = authState.status == AuthStatus.initial;

      if (isInitial) return null;

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/dashboard', name: 'dashboard', builder: (context, state) => const DashboardPage()),
      GoRoute(
        path: '/roles',
        name: 'roles',
        builder: (context, state) => const RoleListPage(),
        routes: [
          GoRoute(path: 'add', name: 'role-add', builder: (context, state) => const RoleFormPage()),
          GoRoute(path: ':id/edit', name: 'role-edit', builder: (context, state) => RoleFormPage(roleId: state.pathParameters['id'])),
        ],
      ),
      GoRoute(
        path: '/inventory',
        name: 'inventory',
        builder: (context, state) => const InventoryPage(),
        routes: [
          GoRoute(
            path: 'categories',
            name: 'category-list',
            builder: (context, state) => const CategoryListPage(),
            routes: [
              GoRoute(path: 'add', name: 'category-add', builder: (context, state) => const CategoryFormPage()),
              GoRoute(path: ':id/edit', name: 'category-edit', builder: (context, state) => CategoryFormPage(categoryId: state.pathParameters['id'])),
            ],
          ),
          GoRoute(
            path: 'products',
            name: 'product-list',
            builder: (context, state) => const ProductListPage(),
            routes: [
              GoRoute(path: 'add', name: 'product-add', builder: (context, state) => const ProductFormPage()),
              GoRoute(path: ':id/edit', name: 'product-edit', builder: (context, state) => ProductFormPage(productId: state.pathParameters['id'])),
            ],
          ),
          GoRoute(
            path: 'stock',
            name: 'stock-movements',
            builder: (context, state) => const StockMovementPage(),
            routes: [
              GoRoute(path: 'add', name: 'stock-movement-add', builder: (context, state) => StockMovementPage(productId: state.extra as String?)),
            ],
          ),
          GoRoute(path: 'alerts', name: 'low-stock', builder: (context, state) => const LowStockPage()),
        ],
      ),
      GoRoute(
        path: '/pos',
        name: 'pos',
        builder: (context, state) => const PosMainPage(),
        routes: [
          GoRoute(path: 'checkout', name: 'pos-checkout', builder: (context, state) => const CheckoutPage()),
        ],
      ),
      GoRoute(path: '/sales', name: 'sales', builder: (context, state) => const SalesPage()),
      GoRoute(path: '/invoicing', name: 'invoicing', builder: (context, state) => const InvoicingPage()),
      GoRoute(path: '/expenses', name: 'expenses', builder: (context, state) => const ExpensesPage()),
      GoRoute(
        path: '/employees',
        name: 'employees',
        builder: (context, state) => const EmployeesPage(),
        routes: [
          GoRoute(path: 'add', name: 'employee-add', builder: (context, state) => const EmployeeFormPage()),
          GoRoute(path: ':id/edit', name: 'employee-edit', builder: (context, state) => EmployeeFormPage(employeeId: state.pathParameters['id'])),
        ],
      ),
      GoRoute(path: '/crm', name: 'crm', builder: (context, state) => const CrmPage()),
      GoRoute(path: '/reports', name: 'reports', builder: (context, state) => const ReportsPage()),
      GoRoute(path: '/sync', name: 'sync', builder: (context, state) => const SyncPage()),
    ],
  );
}
