import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/product.dart' as domain;
import '../../domain/entities/product_attribute.dart' as domain;

class ProductLocalDataSource {
  final db.AppDatabase _database;

  ProductLocalDataSource(this._database);

  Future<List<domain.Product>> getAllProducts({
    String? categoryId,
    String? searchQuery,
  }) async {
    var query = _database.select(_database.products)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);

    if (categoryId != null) {
      query = query..where((t) => t.categoryId.equals(categoryId));
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final pattern = '%$searchQuery%';
      query = query
        ..where(
          (t) =>
              t.name.like(pattern) |
              t.sku.like(pattern) |
              t.barcode.like(pattern),
        );
    }

    final results = await query.get();
    return results.map(_mapProduct).toList();
  }

  Future<domain.Product?> getProductById(String id) async {
    final result = await (_database.select(
      _database.products,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return result != null ? _mapProduct(result) : null;
  }

  Future<domain.Product?> getProductByBarcode(String barcode) async {
    final result = await (_database.select(
      _database.products,
    )..where((t) => t.barcode.equals(barcode))).getSingleOrNull();
    return result != null ? _mapProduct(result) : null;
  }

  Future<void> insertProduct(domain.Product product) async {
    await _database
        .into(_database.products)
        .insert(
          db.ProductsCompanion(
            id: Value(product.id),
            sku: Value(product.sku),
            name: Value(product.name),
            description: Value(product.description),
            categoryId: Value(product.categoryId),
            barcode: Value(product.barcode),
            unit: Value(product.unit),
            price: Value(product.price),
            cost: Value(product.cost),
            stockQty: Value(product.stockQty),
            minStock: Value(product.minStock),
            imagePath: Value(product.imagePath),
            isActive: Value(product.isActive),
            createdAt: Value(product.createdAt),
            updatedAt: Value(product.updatedAt),
          ),
        );
  }

  Future<void> updateProduct(domain.Product product) async {
    await (_database.update(
      _database.products,
    )..where((t) => t.id.equals(product.id))).write(
      db.ProductsCompanion(
        sku: Value(product.sku),
        name: Value(product.name),
        description: Value(product.description),
        categoryId: Value(product.categoryId),
        barcode: Value(product.barcode),
        unit: Value(product.unit),
        price: Value(product.price),
        cost: Value(product.cost),
        stockQty: Value(product.stockQty),
        minStock: Value(product.minStock),
        imagePath: Value(product.imagePath),
        isActive: Value(product.isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateProductStock(String productId, double newQty) async {
    await (_database.update(
      _database.products,
    )..where((t) => t.id.equals(productId))).write(
      db.ProductsCompanion(
        stockQty: Value(newQty),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteProduct(String id) async {
    await (_database.delete(
      _database.products,
    )..where((t) => t.id.equals(id))).go();
  }

  Future<domain.Product?> getProductBySku(String sku) async {
    final result = await (_database.select(
      _database.products,
    )..where((t) => t.sku.equals(sku))).getSingleOrNull();
    return result != null ? _mapProduct(result) : null;
  }

  Future<List<domain.Product>> getLowStockProducts() async {
    final results =
        await (_database.select(_database.products)..where(
              (t) =>
                  t.stockQty.isNotNull() &
                  t.minStock.isNotNull() &
                  t.stockQty.isSmallerOrEqual(t.minStock),
            ))
            .get();
    return results.map(_mapProduct).toList();
  }

  Future<void> insertProductAttribute(domain.ProductAttribute attribute) async {
    await _database
        .into(_database.productAttributes)
        .insert(
          db.ProductAttributesCompanion(
            id: Value(attribute.id),
            productId: Value(attribute.productId),
            attributeKey: Value(attribute.attributeKey),
            attributeValue: Value(attribute.attributeValue),
          ),
        );
  }

  Future<List<domain.ProductAttribute>> getProductAttributes(
    String productId,
  ) async {
    final results = await (_database.select(
      _database.productAttributes,
    )..where((t) => t.productId.equals(productId))).get();
    return results
        .map(
          (a) => domain.ProductAttribute(
            id: a.id,
            productId: a.productId,
            attributeKey: a.attributeKey,
            attributeValue: a.attributeValue,
          ),
        )
        .toList();
  }

  Future<void> deleteProductAttributes(String productId) async {
    await (_database.delete(
      _database.productAttributes,
    )..where((t) => t.productId.equals(productId))).go();
  }

  domain.Product _mapProduct(db.Product row) {
    return domain.Product(
      id: row.id,
      sku: row.sku,
      name: row.name,
      description: row.description,
      categoryId: row.categoryId,
      barcode: row.barcode,
      unit: row.unit,
      price: row.price,
      cost: row.cost,
      stockQty: row.stockQty,
      minStock: row.minStock,
      imagePath: row.imagePath,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
