import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_attribute.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/category_local_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource _dataSource;
  final CategoryLocalDataSource _categoryDataSource;

  ProductRepositoryImpl(this._dataSource, this._categoryDataSource);

  @override
  Future<Result<List<Product>>> getAllProducts({
    String? categoryId,
    String? searchQuery,
  }) async {
    try {
      final products = await _dataSource.getAllProducts(
        categoryId: categoryId,
        searchQuery: searchQuery,
      );
      return Success(products);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load products: $e'));
    }
  }

  @override
  Future<Result<Product?>> getProductById(String id) async {
    try {
      final product = await _dataSource.getProductById(id);
      return Success(product);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load product: $e'));
    }
  }

  @override
  Future<Result<Product?>> getProductByBarcode(String barcode) async {
    try {
      final product = await _dataSource.getProductByBarcode(barcode);
      return Success(product);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load product by barcode: $e'));
    }
  }

  @override
  Future<Result<Product>> createProduct(
    Product product, {
    List<ProductAttribute>? attributes,
  }) async {
    try {
      await _dataSource.insertProduct(product);
      if (attributes != null) {
        for (final attr in attributes) {
          await _dataSource.insertProductAttribute(attr);
        }
      }
      return Success(product);
    } catch (e) {
      return Error(DatabaseFailure('Failed to create product: $e'));
    }
  }

  @override
  Future<Result<Product>> updateProduct(
    Product product, {
    List<ProductAttribute>? attributes,
  }) async {
    try {
      await _dataSource.updateProduct(product);
      if (attributes != null) {
        await _dataSource.deleteProductAttributes(product.id);
        for (final attr in attributes) {
          await _dataSource.insertProductAttribute(attr);
        }
      }
      return Success(product);
    } catch (e) {
      return Error(DatabaseFailure('Failed to update product: $e'));
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await _dataSource.deleteProductAttributes(id);
      await _dataSource.deleteProduct(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete product: $e'));
    }
  }

  @override
  Future<Result<List<Product>>> getLowStockProducts() async {
    try {
      final products = await _dataSource.getLowStockProducts();
      return Success(products);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load low stock products: $e'));
    }
  }

  @override
  Future<Result<List<ProductAttribute>>> getProductAttributes(
    String productId,
  ) async {
    try {
      final attributes = await _dataSource.getProductAttributes(productId);
      return Success(attributes);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load product attributes: $e'));
    }
  }

  @override
  Future<Result<String>> generateSku(String categoryId) async {
    try {
      final category = await _categoryDataSource.getCategoryById(categoryId);
      final prefix = category != null && category.name.length >= 3
          ? category.name.substring(0, 3).toUpperCase()
          : (category != null ? category.name.toUpperCase() : 'PRD');
      final sku =
          '$prefix-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      return Success(sku);
    } catch (e) {
      return Error(DatabaseFailure('Failed to generate SKU: $e'));
    }
  }
}
