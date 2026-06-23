# TrackBit — Session Summary

**Date:** June 23, 2026
**Sprint:** 3 (Sales, CRM, Invoicing, Expenses)
**Status:** ✅ Complete

---

## What Was Built

### Project Setup
- Flutter 3.x project targeting Android, iOS, and Web
- Tech stack: Flutter + Drift (SQLite) + Riverpod + GoRouter + Clean Architecture
- Zero-cost, open-source stack (all MIT/BSD/Apache 2.0)

### Core Layer (`lib/core/`)
| File | Purpose |
|---|---|
| `database/app_database.dart` | Drift database with 21 tables covering all modules |
| `database/default_permissions.dart` | Seeds 47 granular permissions across 10 feature groups |
| `database/daos/settings_dao.dart` | Key-value settings data access |
| `router/app_router.dart` | GoRouter with routes for all 12 feature modules (+ nested inventory/POS routes) |
| `theme/app_theme.dart` | Material 3 light/dark theme |
| `constants/app_constants.dart` | App-wide constants |
| `constants/app_colors.dart` | Color palette |
| `errors/app_exception.dart` | Exception types |
| `errors/failure.dart` | Failure types for Result pattern |
| `utils/result.dart` | `Result<T>` sealed class (Success/Error) |
| `utils/extensions.dart` | DateTime, number, string extensions |
| `utils/validators.dart` | Form validators |

### Sprint 1 Foundation (carried forward)
- 21 database tables, Auth (login/register/session), Roles & Permissions CRUD with 9 default roles, 47 permissions, Dashboard with nav tiles

### Inventory Feature (`lib/features/inventory/`) ✅
| File | Purpose |
|---|---|
| `domain/enums/category_type.dart` | 7 category types (Food, Clothing, Electronics, Gaming, Optical, Luggage, Custom) |
| `domain/enums/movement_type.dart` | Stock movement types (Stock In, Stock Out, Adjustment) |
| `domain/entities/category.dart` | Category entity with type, icon, hierarchy |
| `domain/entities/category_attribute.dart` | Dynamic attribute template entity |
| `domain/entities/product.dart` | Product entity with SKU, barcode, pricing, stock, low-stock flag |
| `domain/entities/product_attribute.dart` | EAV pattern for dynamic attribute values |
| `domain/entities/stock_movement.dart` | Stock movement entity |
| `domain/repositories/category_repository.dart` | Category CRUD + attribute management |
| `domain/repositories/product_repository.dart` | Product CRUD + search + barcode + SKU generation |
| `domain/repositories/stock_movement_repository.dart` | Movement tracking |
| `data/datasources/category_local_datasource.dart` | Drift DB operations for categories & attributes |
| `data/datasources/product_local_datasource.dart` | Drift DB operations for products & attributes |
| `data/datasources/stock_movement_local_datasource.dart` | Drift DB operations for stock movements |
| `data/repositories/category_repository_impl.dart` | Category repository implementation |
| `data/repositories/product_repository_impl.dart` | Product repository with SKU generation |
| `data/repositories/stock_movement_repository_impl.dart` | Stock movement with auto stock update |
| `presentation/providers/inventory_providers.dart` | All Riverpod providers for inventory |
| `presentation/pages/inventory_page.dart` | Main inventory hub with nav to sub-features |
| `presentation/pages/category_list_page.dart` | Category list with type icons/colors, delete |
| `presentation/pages/category_form_page.dart` | Create/edit categories with dynamic attribute templates |
| `presentation/pages/product_list_page.dart` | Product list with search, low-stock banner, popup menu |
| `presentation/pages/product_form_page.dart` | Create/edit products with dynamic attributes per category type |
| `presentation/pages/stock_movement_page.dart` | Record stock in/out/adjustments + movement history |
| `presentation/pages/low_stock_page.dart` | Low-stock alerts with quick "Add Stock" action |
| `presentation/widgets/dynamic_attribute_form.dart` | Reusable dynamic attribute form widget |

**Key behaviors:**
- Category type selects dynamic attribute template (Food→cooking_method/expiry/ingredients, Clothing→size/gender/material/color, Electronics→brand/model/warranty/voltage, Gaming→platform/genre/region/edition, Optical→lens_type/frame_material/prescription/color, Luggage→material/size/weight/capacity/color/wheel/lock, Custom→user-defined)
- Product form shows dynamic attribute fields based on selected category type
- Stock movement automatically updates product stock quantity
- Low-stock detection via `minStock` threshold

### POS Feature (`lib/features/pos/`) ✅
| File | Purpose |
|---|---|
| `domain/entities/cart_item.dart` | Cart item entity with subtotal calculation |
| `domain/entities/cart.dart` | Cart aggregate with discount/tax/total computation |
| `domain/enums/payment_method.dart` | Cash, Card, Bank Transfer |
| `domain/repositories/pos_repository.dart` | Order processing + product search |
| `data/datasources/pos_local_datasource.dart` | Drift DB operations for orders, payments, customers |
| `data/repositories/pos_repository_impl.dart` | Full order processing (order→items→payment→stock→movement) |
| `presentation/providers/pos_providers.dart` | CartNotifier (StateNotifier) + search providers |
| `presentation/pages/pos_main_page.dart` | Split-panel POS: product grid + cart sidebar, barcode dialog |
| `presentation/pages/checkout_page.dart` | Customer info, discount/tax, payment method, summary |
| `presentation/widgets/product_search.dart` | Search widget component |
| `presentation/widgets/cart_widget.dart` | Cart display widget |
| `presentation/widgets/payment_selector.dart` | Payment method selector |

**Key behaviors:**
- Product grid with search and barcode scanning dialog
- Cart with quantity increment/decrement, remove
- Discount (% off) and tax rate fields in checkout
- Three payment methods: Cash, Card, Bank Transfer
- Optional customer capture (name + phone)
- Order processing creates: order record, order items, payment record, stock movement (OUT), customer record

### Sales History Feature (`lib/features/sales/`) ✅
| File | Purpose |
|---|---|
| `domain/entities/sale.dart` | Sale entity with status, totals, payment method |
| `domain/entities/sale_item.dart` | Sale line item entity |
| `domain/enums/sale_status.dart` | Completed, Refunded, Partially Refunded |
| `domain/repositories/sales_repository.dart` | Sales query, refund, summary |
| `data/datasources/sales_local_datasource.dart` | Drift DB operations for sales/items |
| `data/repositories/sales_repository_impl.dart` | Sales repository with refund processing & auto stock reversion |
| `presentation/providers/sales_providers.dart` | Riverpod providers for sales |
| `presentation/pages/sales_page.dart` | Sales list with date/status/payment filters, summaries, refund action |
| `presentation/pages/sale_detail_page.dart` | Order detail: items, payments, timeline |

**Key behaviors:**
- Filterable sales history (date range, status, payment method)
- Daily/monthly summary cards
- Refund processing with stock reversion and DB audit trail
- Full order detail view with item breakdown and payment info

### CRM Feature (`lib/features/crm/`) ✅
| File | Purpose |
|---|---|
| `domain/entities/customer.dart` | Customer entity with contact info, loyalty points |
| `domain/repositories/crm_repository.dart` | Customer CRUD + loyalty + purchase history |
| `data/datasources/crm_local_datasource.dart` | Drift DB operations for customers |
| `data/repositories/crm_repository_impl.dart` | Customer repository with purchase history queries |
| `presentation/providers/crm_providers.dart` | Riverpod providers for CRM |
| `presentation/pages/crm_page.dart` | Customer list with search, purchase history toggle per customer |
| `presentation/pages/customer_form_page.dart` | Create/edit customer form |

**Key behaviors:**
- Customer search by name/phone/email
- View purchase history inline per customer (expandable)
- Loyalty points tracking
- Full CRUD for customer records

### Invoicing Feature (`lib/features/invoicing/`) ✅
| File | Purpose |
|---|---|
| `domain/entities/invoice.dart` | Invoice entity with status, totals, due date |
| `domain/entities/invoice_item.dart` | Invoice line item entity |
| `domain/enums/invoice_status.dart` | Draft, Sent, Paid, Overdue, Cancelled |
| `domain/repositories/invoicing_repository.dart` | Invoice CRUD + item management |
| `data/datasources/invoicing_local_datasource.dart` | Drift DB operations for invoices/items |
| `data/repositories/invoicing_repository_impl.dart` | Invoice repository with status transitions |
| `presentation/providers/invoicing_providers.dart` | Riverpod providers for invoicing |
| `presentation/pages/invoicing_page.dart` | Invoice list with status/date filters, overdue highlighting |
| `presentation/pages/invoice_form_page.dart` | Create/edit invoice with dynamic line items |

**Key behaviors:**
- Invoice list with status filters and overdue highlighting (red badge)
- Invoice form with dynamic line items (add/remove items, auto-calculated totals)
- Four statuses: Draft → Sent → Paid | Overdue | Cancelled
- Subtotal, tax, total auto-computation per invoice

### Expenses Feature (`lib/features/expenses/`) ✅
| File | Purpose |
|---|---|
| `domain/entities/expense.dart` | Expense entity with category, amount, receipt path |
| `domain/enums/expense_category.dart` | 10 categories (Supplies, Utilities, Rent, etc.) |
| `domain/repositories/expenses_repository.dart` | Expense CRUD + category summaries |
| `data/datasources/expenses_local_datasource.dart` | Drift DB operations for expenses |
| `data/repositories/expenses_repository_impl.dart` | Expense repository with category summaries |
| `presentation/providers/expenses_providers.dart` | Riverpod providers for expenses |
| `presentation/pages/expenses_page.dart` | Expense list with category/date filters, summary per category |

**Key behaviors:**
- Filterable expense list (category, date range)
- Per-category summary tiles with amounts and counts
- Full CRUD for expense records
- 10 predefined expense categories

### Router Updates
- `/inventory` → main inventory hub with nested routes:
  - `/inventory/categories`, `/inventory/categories/add`, `/inventory/categories/:id/edit`
  - `/inventory/products`, `/inventory/products/add`, `/inventory/products/:id/edit`
  - `/inventory/stock`, `/inventory/stock/add`
  - `/inventory/alerts`
- `/pos` → POS main page, `/pos/checkout` → checkout
- `/sales` → Sales history list, `/sales/:id` → Sale detail
- `/crm` → Customer list, `/crm/add`, `/crm/:id/edit` → Customer form
- `/invoicing` → Invoice list, `/invoicing/add`, `/invoicing/:id/edit` → Invoice form
- `/expenses` → Expense list

---

## Build Verification
- `dart analyze lib/` — **0 errors, 0 warnings**, 31 info-level lint suggestions
- `flutter test` — environment-specific tool path issue (WSL); code compiles and analyzes cleanly

---

## Known Issues / Notes

1. **No router auth guard** — Routes are accessible by direct URL without login. Add `GoRouter` redirect in future sprint.
2. **No default admin user seeded** — On first launch, user must register first.
3. **Receipt printing not implemented** — POS has receipt settings in DB but no print functionality yet. Requires `unified_esc_pos_printer` package.
4. **Barcode scanning** — Manual entry dialog only; camera-based scanning needs `mobile_scanner` or similar package.
5. **No image upload** — Products have `imagePath` field but no image picker integrated.
6. **RadioListTile deprecated API** — Checkout and payment selector use deprecated `groupValue`/`onChanged`; should migrate to `RadioGroup` in future Flutter update.

---

## How to Run

```bash
cd /mnt/d/my-app/trackbit
flutter pub get
flutter run           # Runs on connected device/emulator
flutter run -d chrome  # Runs on web
flutter test          # Runs tests
```

---

## Project Structure

```
trackbit/
├── android/
├── ios/
├── web/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── app_database.g.dart
│   │   │   ├── daos/settings_dao.dart
│   │   │   └── default_permissions.dart
│   │   ├── errors/
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── extensions.dart
│   │       ├── result.dart
│   │       └── validators.dart
│   └── features/
│       ├── auth/              # Login, Register, User management ✅
│       ├── roles/             # Roles & Permissions CRUD ✅
│       ├── dashboard/         # Main dashboard with nav tiles ✅
│       ├── inventory/         # Full Inventory (categories, products, stock) ✅
│       ├── pos/               # Full POS (cart, checkout, payment) ✅
│       ├── sales/             # Sales history, refunds, summaries ✅
│       ├── invoicing/         # Invoice CRUD with line items ✅
│       ├── expenses/          # Expense CRUD with categories ✅
│       ├── crm/               # Customer management with loyalty ✅
│       ├── employees/         # Placeholder
│       ├── reports/           # Placeholder
│       └── sync/              # Placeholder
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── SESSION_SUMMARY.md
```

---

## Next Up: Sprint 4 — Employees, Reports, Sync & Polish

### Employees (`lib/features/employees/`)
- Employee management (CRUD)
- Role assignment per employee
- Login as employee
- Time tracking / clock in-out

### Reports (`lib/features/reports/`)
- Dashboard with charts (sales, expenses, profit)
- PDF report generation
- Export to CSV/Excel
- Date-range based reporting

### Sync (`lib/features/sync/`)
- Cloud backup/restore (SQLite → remote)
- Multi-device sync
- Conflict resolution

### Polish & Production Readiness
- Auth guard on router (redirect to login if not authenticated)
- Default admin seeder on first launch
- Image upload for products & expenses (receipts)
- Camera-based barcode scanning
- Receipt printing via ESC/POS
- Migrate deprecated RadioListTile to RadioGroup

---

## Repo
- GitHub: https://github.com/anonbanana/trackbit (GNU v3.0)
- Branch: `main`
