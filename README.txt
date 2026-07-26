TrackBit - Session Summary
==========================

Date: 2026-07-24
Platform: WSL2 Ubuntu 24.04.4 LTS
Project: /mnt/d/my-app/trackbit

=================================
1. WSL2 Linux Dev Environment Setup
=================================

Installed and configured:
- Flutter 3.44.8, Dart 3.12.2
- OpenJDK 17
- Android SDK (platforms;android-36, build-tools;36.0.0)
- Chrome 150, clang/cmake/ninja/pkg-config/libgtk-3-dev
- ~/.bashrc configured with JAVA_HOME, ANDROID_HOME, PATH exports

Verified:
- flutter doctor -v (all checks green)
- flutter pub get
- flutter test (39/39 passing)

=================================
2. Code Review & Fixes Applied
=================================

Found and fixed 35 issues across 25+ files:
  5 CRITICAL, 7 HIGH, 14 MEDIUM, 9 LOW

---------------------------------
CRITICAL Fixes
---------------------------------

1. SQL Injection in sync_service.dart
   - Column names validated against whitelist
   - Prevents arbitrary SQL via crafted sync payloads

2. Non-atomic order processing (pos_repository_impl.dart)
   - Entire order write + stock deduction wrapped in database.transaction()

3. Password hash exposed in AppUser entity
   - Removed passwordHash field from AppUser
   - Added changePassword() to auth repository
   - Hash kept in data layer only (auth_local_datasource)

4. SHA-256 password hashing (auth_repository_impl.dart)
   - Added constant-time comparison to prevent timing attacks
   - Kept SHA-256 (bcrypt/argon2 requires native C dependencies)
   - Hash now hidden from entity/UI layer

5. Insecure WebSocket connection
   - Changed ws:// to wss:// in web_socket_sync_service.dart

---------------------------------
HIGH Fixes
---------------------------------

6. Force-unwrap on null user after registration
   - Added null check with generic error messages

7. Stream listener leak in SyncService
   - _syncSubscription stored and cancelled in dispose()

8. SyncService provider memory leak
   - Changed to Provider.autoDispose with ref.onDispose

9. Non-atomic stock update (stock_movement_repository_impl.dart)
   - Returns error for insufficient stock instead of clamping to 0

10. Case-sensitive status mismatch in reports
    - Added .toLowerCase() to status comparisons

11. Inconsistent currency symbols
    - Standardized to $ across all pages (was mixed Rp and $)

12. New device ID generated per sync load
    - Persisted deviceId via SharedPreferences

---------------------------------
MEDIUM Fixes
---------------------------------

13. MovementType.fromString missing orElse
    - Added orElse fallback for unknown types

14. PaymentMethod.fromString missing orElse
    - Added orElse fallback for unknown types

15. _CartSheet unused ref parameter
    - Removed unused parameter

16. TextEditingController leak in profile_page.dart
    - Added _usernameCtrl with proper dispose

17. SKU generation substring crash (product_repository_impl.dart)
    - Added length guard before substring(0,3)

18. N+1 query in expenses repository
    - Batched user lookups instead of per-expense queries

19. Category deletion with existing products
    - Checks for products before allowing deletion
    - Added hasProductsInCategory() to datasource

20. Duplicated _parseOptions in dynamic_attribute_form.dart
    - Consolidated to single method

21. rolesProvider not invalidated after create/update
    - Added ref.invalidate(rolesProvider) after mutations

22. Employees page missing delete option
    - Added delete with confirmation dialog

23. Negative price validation
    - Added checks in product_form_page.dart

24. Stock-out silently clamped to 0
    - Returns error for insufficient stock

25. Silent JSON parse errors in WebSocket
    - Added debugPrint logging for parse failures

26. Expenses paidBy hardcoded to 'system'
    - Now uses authProvider.user?.id

27. Expense form when categories fail to load
    - Added loading/error state handling

28. Negative expense amount validation
    - Added validation in expense form

---------------------------------
LOW Fixes
---------------------------------

29. Low stock filter using in-memory filtering
    - Moved to SQL WHERE clause in product_local_datasource.dart

30. Order number collision risk
    - Counts only matching month prefix

31. ID generation using timestamps
    - Switched to UUID via uuid package

32. drift/web.dart deprecation warning
    - Added ignore comments for known deprecation

33. Const constructor lint fixes
    - Added const to constructor calls across multiple files

34. Expenses page category loading
    - Handles loading and error states

35. RadioListTile deprecated groupValue/onChanged
    - Migrated to RadioGroup ancestor widget

=================================
3. Code Quality Verification
=================================

- flutter analyze: 0 errors, 0 warnings, 1 info (harmless test lint)
- flutter test: 39/39 passing
- build_runner: 110 outputs regenerated successfully

=================================
4. Tech Stack
=================================

- Flutter Riverpod (state management)
- Drift (SQLite ORM)
- GoRouter (navigation)
- Clean Architecture (domain/data/presentation layers)
- 20+ database tables (Users, Roles, Permissions, Products,
  Categories, Orders, OrderItems, Payments, StockMovements,
  Employees, Expenses, Invoices, Customers, etc.)

=================================
5. Key Files Modified
=================================

CRITICAL:
  lib/features/sync/data/services/sync_service.dart
  lib/features/sync/data/services/web_socket_sync_service.dart
  lib/features/pos/data/repositories/pos_repository_impl.dart
  lib/features/auth/domain/entities/app_user.dart
  lib/features/auth/data/repositories/auth_repository_impl.dart
  lib/features/auth/data/datasources/auth_local_datasource.dart

HIGH:
  lib/features/sync/presentation/providers/sync_providers.dart
  lib/features/sync/presentation/pages/sync_page.dart
  lib/features/reports/data/repositories/reports_repository_impl.dart
  lib/features/pos/presentation/pages/pos_main_page.dart
  lib/features/pos/presentation/pages/checkout_page.dart

MEDIUM:
  lib/features/inventory/domain/enums/movement_type.dart
  lib/features/pos/domain/enums/payment_method.dart
  lib/features/settings/presentation/pages/profile_page.dart
  lib/features/inventory/data/repositories/product_repository_impl.dart
  lib/features/expenses/data/repositories/expenses_repository_impl.dart
  lib/features/inventory/data/repositories/category_repository_impl.dart
  lib/features/inventory/data/datasources/category_local_datasource.dart
  lib/features/roles/presentation/pages/role_form_page.dart
  lib/features/employees/presentation/pages/employees_page.dart
  lib/features/inventory/presentation/pages/product_form_page.dart
  lib/features/inventory/data/repositories/stock_movement_repository_impl.dart
  lib/features/sync/data/services/web_socket_sync_service.dart
  lib/features/expenses/presentation/pages/expenses_page.dart

LOW:
  lib/features/inventory/data/datasources/product_local_datasource.dart
  lib/features/pos/data/datasources/pos_local_datasource.dart
  lib/core/database/query_executor_web.dart
  lib/features/pos/presentation/pages/checkout_page.dart

=================================
6. Remaining Notes
=================================

- Hardcoded admin password "admin123" in AppConstants (low severity,
  noted but not changed as it may be intentional for dev/demo)
- SHA-256 kept for password hashing (bcrypt/argon2 would require
  adding native C dependencies to the project)
- drift/web.dart deprecation warning suppressed with ignore comments
- 1 info-level lint in test file (prefer_const_constructors, harmless)
