import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get fullName => text()();
  TextColumn get roleId => text().references(Roles, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Roles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get label => text()();
  TextColumn get description => text().nullable()();
  TextColumn get parentRoleId => text().nullable().references(Roles, #id)();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isCustomizable => boolean().withDefault(const Constant(true))();
  IntColumn get level => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Permissions extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  TextColumn get groupName => text()();
  TextColumn get description => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class RolePermissions extends Table {
  TextColumn get roleId => text().references(Roles, #id)();
  TextColumn get permissionId => text().references(Permissions, #id)();
  @override
  Set<Column> get primaryKey => {roleId, permissionId};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get icon => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  TextColumn get parentId => text().nullable().references(Categories, #id)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class CategoryAttributes extends Table {
  TextColumn get id => text()();
  TextColumn get categoryType => text()();
  TextColumn get attributeKey => text()();
  TextColumn get attributeLabel => text()();
  TextColumn get attributeType => text()();
  BoolColumn get isRequired => boolean().withDefault(const Constant(false))();
  TextColumn get optionsJson => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get sku => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get barcode => text().nullable()();
  TextColumn get unit => text()();
  RealColumn get price => real()();
  RealColumn get cost => real()();
  RealColumn get stockQty => real().withDefault(const Constant(0))();
  RealColumn get minStock => real().withDefault(const Constant(0))();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class ProductAttributes extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get attributeKey => text()();
  TextColumn get attributeValue => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get type => text()();
  RealColumn get quantity => real()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get loyaltyPoints => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get orderNumber => text()();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  TextColumn get userId => text().references(Users, #id)();
  RealColumn get subtotal => real()();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  TextColumn get paymentMethod => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class OrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get productId => text().references(Products, #id)();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get subtotal => real()();
  @override
  Set<Column> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().references(Orders, #id)();
  RealColumn get amount => real()();
  TextColumn get method => text()();
  TextColumn get reference => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get orderId => text().nullable().references(Orders, #id)();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get status => text()();
  RealColumn get total => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get description => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get total => real()();
  @override
  Set<Column> get primaryKey => {id};
}

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  TextColumn get paidBy => text().references(Users, #id)();
  TextColumn get receiptImage => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Employees extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id).nullable()();
  TextColumn get position => text()();
  RealColumn get salary => real().withDefault(const Constant(0))();
  DateTimeColumn get hireDate => dateTime().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityTable => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();}

class SyncPeers extends Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  TextColumn get deviceName => text()();
  TextColumn get ipAddress => text()();
  DateTimeColumn get lastSeen => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class ReceiptSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('default'))();
  TextColumn get storeName => text().nullable()();
  TextColumn get storeAddress => text().nullable()();
  TextColumn get storePhone => text().nullable()();
  RealColumn get taxRate => real().withDefault(const Constant(0))();
  IntColumn get paperWidth => integer().withDefault(const Constant(58))();
  TextColumn get headerText => text().nullable()();
  TextColumn get footerText => text().nullable()();
  TextColumn get logoPath => text().nullable()();
  BoolColumn get showTax => boolean().withDefault(const Constant(true))();
  BoolColumn get showDiscount => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Users,
    Roles,
    Permissions,
    RolePermissions,
    Categories,
    CategoryAttributes,
    Products,
    ProductAttributes,
    StockMovements,
    Customers,
    Orders,
    OrderItems,
    Payments,
    Invoices,
    InvoiceItems,
    Expenses,
    Employees,
    SyncQueue,
    SyncPeers,
    AppSettings,
    ReceiptSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, AppConstants.dbName));
    return NativeDatabase(file);
  }));

  @override
  int get schemaVersion => AppConstants.dbVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
  );
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
