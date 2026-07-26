import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/category.dart' as domain;
import '../../domain/entities/category_attribute.dart' as domain;
import '../../domain/enums/category_type.dart';

class CategoryLocalDataSource {
  final db.AppDatabase _database;

  CategoryLocalDataSource(this._database);

  Future<List<domain.Category>> getAllCategories() async {
    final results = await (_database.select(
      _database.categories,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
    return results.map(_mapCategory).toList();
  }

  Future<domain.Category?> getCategoryById(String id) async {
    final result = await (_database.select(
      _database.categories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return result != null ? _mapCategory(result) : null;
  }

  Future<void> insertCategory(domain.Category category) async {
    await _database
        .into(_database.categories)
        .insert(
          db.CategoriesCompanion(
            id: Value(category.id),
            name: Value(category.name),
            type: Value(category.type.name),
            icon: Value(category.icon),
            isSystem: Value(category.isSystem),
            parentId: Value(category.parentId),
            sortOrder: Value(category.sortOrder),
            createdAt: Value(category.createdAt),
            updatedAt: Value(category.updatedAt),
          ),
        );
  }

  Future<void> updateCategory(domain.Category category) async {
    await (_database.update(
      _database.categories,
    )..where((t) => t.id.equals(category.id))).write(
      db.CategoriesCompanion(
        name: Value(category.name),
        type: Value(category.type.name),
        icon: Value(category.icon),
        parentId: Value(category.parentId),
        sortOrder: Value(category.sortOrder),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<bool> hasProductsInCategory(String categoryId) async {
    final products =
        await (_database.select(_database.products)
              ..where((t) => t.categoryId.equals(categoryId))
              ..limit(1))
            .get();
    return products.isNotEmpty;
  }

  Future<void> deleteCategory(String id) async {
    await (_database.delete(
      _database.categories,
    )..where((t) => t.id.equals(id))).go();
  }

  Future<List<domain.CategoryAttribute>> getAttributesByCategoryType(
    String categoryType,
  ) async {
    final results =
        await (_database.select(_database.categoryAttributes)
              ..where((t) => t.categoryType.equals(categoryType))
              ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
            .get();
    return results
        .map(
          (a) => domain.CategoryAttribute(
            id: a.id,
            categoryType: CategoryType.fromString(a.categoryType),
            attributeKey: a.attributeKey,
            attributeLabel: a.attributeLabel,
            attributeType: a.attributeType,
            isRequired: a.isRequired,
            optionsJson: a.optionsJson,
            sortOrder: a.sortOrder,
          ),
        )
        .toList();
  }

  Future<void> insertCategoryAttribute(
    domain.CategoryAttribute attribute,
  ) async {
    await _database
        .into(_database.categoryAttributes)
        .insert(
          db.CategoryAttributesCompanion(
            id: Value(attribute.id),
            categoryType: Value(attribute.categoryType.name),
            attributeKey: Value(attribute.attributeKey),
            attributeLabel: Value(attribute.attributeLabel),
            attributeType: Value(attribute.attributeType),
            isRequired: Value(attribute.isRequired),
            optionsJson: Value(attribute.optionsJson),
            sortOrder: Value(attribute.sortOrder),
          ),
        );
  }

  Future<void> clearAttributesByCategoryType(String categoryType) async {
    await (_database.delete(
      _database.categoryAttributes,
    )..where((t) => t.categoryType.equals(categoryType))).go();
  }

  domain.Category _mapCategory(db.Category row) {
    return domain.Category(
      id: row.id,
      name: row.name,
      type: CategoryType.fromString(row.type),
      icon: row.icon,
      isSystem: row.isSystem,
      parentId: row.parentId,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
