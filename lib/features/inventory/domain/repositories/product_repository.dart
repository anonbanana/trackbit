import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../entities/product_attribute.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getAllProducts({
    String? categoryId,
    String? searchQuery,
  });
  Future<Result<Product?>> getProductById(String id);
  Future<Result<Product?>> getProductByBarcode(String barcode);
  Future<Result<Product>> createProduct(
    Product product, {
    List<ProductAttribute>? attributes,
  });
  Future<Result<Product>> updateProduct(
    Product product, {
    List<ProductAttribute>? attributes,
  });
  Future<Result<void>> deleteProduct(String id);
  Future<Result<List<Product>>> getLowStockProducts();
  Future<Result<List<ProductAttribute>>> getProductAttributes(String productId);
  Future<Result<String>> generateSku(String categoryId);
}
