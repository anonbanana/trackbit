# TrackBit — Complete Architecture & Implementation Plan

> **Project:** Offline-first business management app (POS, Inventory, Accounting, CRM, etc.)
> **Date:** June 22, 2026
> **Tech Stack:** Flutter + Drift (SQLite) + Riverpod + GoRouter + Clean Architecture

---

## 1. Recommended Tech Stack

| Layer | Technology | Rationale |
|---|---|---|
| **Framework** | Flutter 3.x + Dart 3.x | Single codebase → Android, iOS, Web. Best offline + POS printing support. AOT-compiled native ARM — lowest resource usage. |
| **Local Database** | Drift (SQLite ORM) | Relational, reactive streams, type-safe migrations, battle-tested for complex business data. Best for relational data (orders↔items↔products↔categories↔users↔roles). |
| **State Management** | Riverpod 3.x (code-gen) | Compile-time safety, no BuildContext needed (critical for background sync), excellent testability, auto-retry. |
| **Architecture** | Clean Architecture + Feature-First | Future-proof for online upgrade, testable, maintainable. |
| **Router** | GoRouter | Declarative, supports route guards for RBAC. |
| **LAN Sync** | `web_socket_channel` + `shelf_web_socket` | Official Dart WebSocket, bidirectional P2P. |
| **Device Discovery** | `multicast_dns` | mDNS for finding peers on LAN. |
| **POS Printing** | `unified_esc_pos_printer` | USB/BT/BLE/TCP/IP, 200+ printer profiles, BSD license. |
| **PDF Export** | `pdf` + `printing` | Flutter-widget-like PDF API, native OS print. |
| **Excel/CSV** | `excel` + `csv` | Pure Dart, MIT license. |
| **RBAC** | Custom domain + permission_policy | Hierarchical roles, subclassification, customizable. |
| **HTTP Client** | `dio` | For future online features. |
| **Backend (Future)** | Supabase (PostgreSQL + RLS + Realtime) | Open-source, self-hostable, zero cost to devs. |
| **Encryption** | `flutter_secure_storage` + `sqlcipher_flutter_libs` | Sensitive data at rest. |

**Total license cost: $0** — all MIT/BSD/Apache 2.0.

### Why Flutter > Alternatives

| Requirement | React Native | Ionic/Capacitor | **Flutter** |
|---|---|---|---|
| POS thermal printing (BT/USB/WiFi) | Fragmented, many platform-specific libs | Limited web-based printing only | `unified_esc_pos_printer` — one API for all connections |
| Offline-first with relational data | WatermelonDB (good but slower) | IndexedDB (limited) | **Drift + SQLite** — fastest, type-safe, reactive |
| Web + Mobile from one codebase | Separate web layer (Expo Web) | Yes (but slow on mobile) | **True single codebase** — same Dart code everywhere |
| LAN sync (WebSocket P2P) | Requires native modules or JS libs | Limited | **Native Dart sockets** — no bridge overhead |
| Lightweight on low-end devices | JS bridge overhead, higher memory | Wrapper around webview | **AOT-compiled native ARM** — lowest resource usage |
| Future cloud upgrade path | Possible | Possible | Clean Architecture makes it natural |

---

## 2. High-Level Architecture

```
lib/
├── core/                          # Shared kernel (no feature dependencies)
│   ├── constants/                 # App-wide constants, enums, colors
│   ├── database/                  # Drift DB, tables, DAOs
│   ├── errors/                    # Failure types, exceptions
│   ├── router/                    # GoRouter config
│   ├── theme/                     # Light/dark Material 3 theme
│   └── utils/                     # Result, validators, extensions
│
├── features/                      # Feature-first organization
│   ├── auth/                      # Login, registration, session
│   │   ├── data/datasources/      # Local DB, secure storage
│   │   ├── data/models/           # Data models
│   │   ├── data/repositories/     # Repository implementations
│   │   ├── domain/entities/       # AppUser entity
│   │   ├── domain/repositories/   # Abstract AuthRepository
│   │   └── presentation/          # Providers, pages, widgets
│   │
│   ├── roles/                     # User roles & permissions (RBAC)
│   │   ├── data/datasources/
│   │   ├── data/repositories/
│   │   ├── domain/entities/       # Role, Permission entities
│   │   ├── domain/repositories/   # Abstract RoleRepository
│   │   └── presentation/          # Role form, role list, providers
│   │
│   ├── dashboard/                 # Main dashboard
│   │   └── presentation/          # Dashboard with nav tiles
│   │
│   ├── inventory/                 # Stock management
│   │   ├── data/
│   │   ├── domain/                # Product, Category, StockMovement
│   │   └── presentation/          # Product CRUD, category mgmt, stock adj
│   │
│   ├── pos/                       # Point of Sale
│   │   ├── data/
│   │   ├── domain/                # Order, Payment, Cart
│   │   └── presentation/          # POS UI, cart, checkout, receipt
│   │
│   ├── sales/                     # Sales history
│   ├── invoicing/                 # Invoice generation
│   ├── expenses/                  # Expense tracking
│   ├── employees/                 # Employee management
│   ├── crm/                       # Customer management
│   ├── reports/                   # Reports & exports (PDF/Excel/CSV)
│   └── sync/                      # LAN sync status & settings
│
└── main.dart
```

### Architecture Principles
- **Domain layer is pure Dart** — Business rules are testable without Flutter/database/network dependencies
- **Repository abstraction** — Swap local DB for remote API later without changing business logic
- **Feature-first** — Each feature is isolated; teams can work independently
- **Dependency rule** — Inner layers (domain) never depend on outer layers (UI, database, network)
- **Offline-first** — Local database is the source of truth; sync engine is a transport layer

---

## 3. Database Schema (21 Tables)

### Users & Auth
```sql
users (id, username, password_hash, full_name, role_id FK→roles, is_active, created_at, updated_at)
```

### Roles & Permissions
```sql
roles (id, name, label, description, parent_role_id FK→roles, is_system, is_customizable, level, created_at, updated_at)
permissions (id, label, group_name, description)
role_permissions (role_id FK→roles, permission_id FK→permissions) PK=(role_id, permission_id)
```

### Categories & Inventory
```sql
categories (id, name, type, icon, is_system, parent_id FK→categories, sort_order, created_at, updated_at)
  -- type enum: FOOD, CLOTHING, ELECTRONICS, GAMING, OPTICAL, LUGGAGE, CUSTOM
category_attributes (id, category_type, attribute_key, attribute_label, attribute_type, is_required, options_json, sort_order)
  -- Dynamic templates per category type
products (id, sku, name, description, category_id FK→categories, barcode, unit, price, cost, stock_qty, min_stock, image_path, is_active, created_at, updated_at)
product_attributes (id, product_id FK→products, attribute_key, attribute_value) -- dynamic values per product
stock_movements (id, product_id FK→products, type, quantity, reference_type, reference_id, note, created_at)
```

### POS & Sales
```sql
customers (id, name, phone, email, address, loyalty_points, created_at, updated_at)
orders (id, order_number, customer_id FK→customers, user_id FK→users, subtotal, tax, discount, total, payment_method, status, created_at, updated_at)
order_items (id, order_id FK→orders, product_id FK→products, quantity, unit_price, subtotal)
payments (id, order_id FK→orders, amount, method, reference, created_at)
```

### Invoicing
```sql
invoices (id, invoice_number, order_id FK→orders, customer_id FK→customers, due_date, status, total, created_at, updated_at)
invoice_items (id, invoice_id FK→invoices, description, quantity, unit_price, total)
```

### Expenses & Employees
```sql
expenses (id, title, category, amount, paid_by FK→users, receipt_image, note, created_at)
employees (id, user_id FK→users, position, salary, hire_date, phone, address, is_active, created_at, updated_at)
```

### Sync Engine
```sql
sync_queue (id AUTO_INCREMENT, entity_table, record_id, operation, payload_json, status, device_id, created_at, synced_at)
sync_peers (id, device_id, device_name, ip_address, last_seen, is_active)
```

### Settings
```sql
app_settings (key PK, value)
receipt_settings (id PK DEFAULT 'default', store_name, store_address, store_phone, tax_rate, paper_width, header_text, footer_text, logo_path, show_tax, show_discount)
```

---

## 4. Default Role Hierarchy

```
Level 0: Super Admin (system-level, non-customizable)
Level 1: Boss-Owner, Boss-Co-Owner
Level 2: Store Manager, Branch Manager
Level 3: Employee-Accountant, Employee-Cashier, Employee-Warehouse, Employee-Sales
```

- All roles except Super Admin are **user-customizable** (rename, change permissions, delete)
- Hierarchy is enforced via `level` column (lower = more authority)
- Parent-child relationships via `parent_role_id` for permission inheritance

---

## 5. Inventory Type System (Dynamic Attributes)

Categories auto-apply attribute templates:

| Category Type | Auto Attributes | Default Unit |
|---|---|---|
| **Food** | `cooking_method` (Fried/Soup/Grilled/Steamed/Frozen), `expiry_days`, `ingredients` | Piece, Kg, Gram, Liter |
| **Clothing** | `size` (XS-XXL), `gender`, `material`, `color` | Piece, Pair |
| **Electronics** | `brand`, `model`, `warranty_months`, `voltage` | Piece, Unit |
| **Gaming** | `platform` (PC/PS/Xbox), `genre`, `region`, `edition` | Piece, Copy |
| **Optical** | `lens_type`, `frame_material`, `prescription`, `color` | Piece, Pair |
| **Luggage** | `material` (Polycarbonate/ABS/Nylon/Leather), `size_cm`, `weight_kg`, `capacity_liters`, `color`, `wheel_type`, `lock_type` | Piece, Set |
| **Custom** | User-defined attributes | User-defined |

---

## 6. Default Permissions (47 total)

| Group | Permissions |
|---|---|
| **Dashboard** | view, export |
| **Inventory** | view, create, edit, delete, stock.adjust, barcode, categories.manage |
| **POS** | access, sell, discount, refund, print |
| **Sales** | view, export |
| **Invoicing** | view, create, edit, delete, print |
| **Expenses** | view, create, edit, delete |
| **CRM** | view, create, edit, delete |
| **Employees** | view, create, edit, delete |
| **Roles** | view, create, edit, delete |
| **Users** | view, create, edit, delete |
| **Reports** | view, export |
| **Sync** | view, trigger, configure |
| **Settings** | view, edit, receipt |

---

## 7. LAN Sync Architecture

```
┌──────────────────────┐        mDNS (_trackbit._tcp)       ┌──────────────────────┐
│   Device A (Host)    │◄══════════════════════════════►     │   Device B (Client)  │
│                      │                                     │                      │
│  ┌────────────────┐  │  WebSocket (JSON protocol)          │  ┌────────────────┐  │
│  │  Drift DB      │◄─┼─────────────────────────────────────┼─►│  Drift DB      │  │
│  └────────┬───────┘  │                                     │  └────────┬───────┘  │
│           │          │                                     │           │          │
│  ┌────────▼───────┐  │                                     │  ┌────────▼───────┐  │
│  │  Sync Engine    │  │                                     │  │  Sync Engine    │  │
│  │  (outbox poller)│  │                                     │  │  (outbox poller)│  │
│  └────────┬───────┘  │                                     │  └────────┬───────┘  │
│           │          │                                     │           │          │
│  ┌────────▼───────┐  │                                     │  ┌────────▼───────┐  │
│  │  Sync Transport │  │                                     │  │  Sync Transport │  │
│  │  (WebSocket)    │  │                                     │  │  (WebSocket)    │  │
│  └────────────────┘  │                                     │  └────────────────┘  │
└──────────────────────┘                                     └──────────────────────┘
```

**Sync process:**
1. Every write transaction inserts into `sync_queue` (same SQLite transaction — atomic)
2. Host advertises via mDNS — clients discover and connect via WebSocket
3. Host sends pending operations from `sync_queue` — clients acknowledge
4. Clients can also push local changes — host broadcasts to all peers
5. Conflict resolution: Last-Write-Wins via `updated_at` timestamp
6. Full snapshot sync on first connection; delta sync (since `last_sync_at`) thereafter
7. **Two modes:** Auto-sync (background every 5 sec) + Manual (button in sync settings)

---

## 8. Future Online Upgrade Path

### Phase 1: Pure Offline (Now — MVP)
- All data in local Drift database
- P2P sync via WebSocket/mDNS over LAN
- No internet connection required

### Phase 2: Cloud Sync
- Self-hosted Supabase backend (customer pays for hosting, ~$7-25/mo VPS)
- Multi-device sync via cloud (not just LAN)
- Same repository interface — just add a `RemoteDataSource` alongside `LocalDataSource`
- Sync engine gets new transport (`SupabaseTransport`) alongside existing `WebSocketTransport`

### Phase 3: E-Commerce
- Generate e-commerce website from inventory data
- Web storefront (Next.js/Astro)
- Orders sync back to mobile app
- Customer hosts themselves via their chosen hosting provider

### Phase 4: Marketing
- Email/SMS campaigns, promo codes, customer analytics
- Connects to existing customer data

### Key Principle
> **Local database is always the source of truth.** The app never blocks on network. The repository pattern means Phase 1 code needs zero rewrites — only new data sources are added.

---

## 9. Receipt Printing

**Library:** `unified_esc_pos_printer` — supports:
- Bluetooth (SPP)
- Bluetooth Low Energy (BLE)
- USB-OTG
- TCP/IP (WiFi)
- Cash drawer control, barcodes, QR codes
- 200+ built-in printer capability profiles

**Configurable via UI:**
- Paper width (58mm / 80mm)
- Store name, address, phone
- Header/footer text
- Tax rate
- Logo image
- Show/hide tax and discount

---

## 10. Implementation Phases (Sprints)

### Sprint 1: ✅ Foundation (Done)
- Flutter project setup with all dependencies
- Drift database (21 tables)
- Core layer (theme, constants, errors, utils, router)
- Auth feature (login, register, session management)
- Roles & Permissions (CRUD, hierarchy, 9 default roles, 47 permissions)
- Dashboard with navigation tiles
- Placeholder pages for all other features

### Sprint 2: Inventory + POS (Next)
- **Inventory:** Category CRUD with dynamic attributes, Product CRUD, barcode scanning, stock movements, low-stock alerts
- **POS:** Product search, cart, discount/tax, payment methods, receipt printing (BT/WiFi/USB), sales transaction processing

### Sprint 3: Supporting Modules
- Sales history
- Invoicing (generate from orders, PDF export, print)
- Expenses (CRUD, categorize, receipt images)
- CRM (customer database, purchase history, loyalty points)

### Sprint 4: Admin & Reports
- Employees management
- Reports with multi-format export (PDF, Excel, CSV)
- Settings (receipt config, store info, backup/restore)

### Sprint 5: LAN Sync
- Sync engine (transactional outbox pattern)
- mDNS service discovery
- WebSocket protocol
- Sync status UI (auto + manual modes)
- Conflict resolution

---

## 11. File Reference

### Core Infrastructure
| File | Description |
|---|---|
| `pubspec.yaml` | Dependencies (drift, riverpod, go_router, flutter_secure_storage, crypto, uuid, equatable, intl, web_socket_channel, multicast_dns) |
| `lib/main.dart` | App entry point — initializes DB, seeds data, runs app |
| `lib/app.dart` | `MaterialApp.router` with theme config |
| `lib/core/database/app_database.dart` | Drift DB + 21 table definitions + `databaseProvider` |
| `lib/core/database/app_database.g.dart` | Generated Drift code (auto-generated) |
| `lib/core/database/default_permissions.dart` | Seeds 47 permissions |
| `lib/core/router/app_router.dart` | GoRouter with all feature routes |
| `lib/core/theme/app_theme.dart` | Material 3 light/dark theme |
| `lib/core/utils/result.dart` | `Result<T>` sealed class |

### Auth (`lib/features/auth/`)
| File | Description |
|---|---|
| `domain/entities/app_user.dart` | AppUser entity |
| `domain/repositories/auth_repository.dart` | Abstract AuthRepository |
| `data/datasources/auth_local_datasource.dart` | Local DB + secure storage |
| `data/repositories/auth_repository_impl.dart` | SHA256 password hashing, CRUD |
| `presentation/providers/auth_provider.dart` | AuthNotifier + AuthState |
| `presentation/pages/login_page.dart` | Login form with validation |
| `presentation/pages/register_page.dart` | Registration form with role selector |

### Roles (`lib/features/roles/`)
| File | Description |
|---|---|
| `domain/entities/role.dart` | Role entity |
| `domain/entities/permission.dart` | Permission entity |
| `domain/repositories/role_repository.dart` | Abstract RoleRepository |
| `data/datasources/role_local_datasource.dart` | Role CRUD + permission assignment |
| `data/repositories/role_repository_impl.dart` | Seeds 9 default roles |
| `presentation/providers/role_provider.dart` | Riverpod providers |
| `presentation/pages/role_list_page.dart` | Grouped by hierarchy level |
| `presentation/pages/role_form_page.dart` | Create/edit with permission checkboxes |

---

## 12. Build & Run Commands

```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run on web
flutter run -d chrome

# Run tests
flutter test

# Static analysis
flutter analyze

# Generate Dart code (Drift, Riverpod, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Build APK
flutter build apk --debug

# Build for web
flutter build web
```

---

## 13. Project Repository

- **GitHub:** https://github.com/anonbanana/trackbit
- **License:** GNU v3.0
- **Branch:** `main`
