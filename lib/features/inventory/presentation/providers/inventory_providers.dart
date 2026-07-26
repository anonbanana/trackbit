import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/datasources/stock_movement_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/stock_movement_repository_impl.dart';
import '../../domain/entities/category.dart' as domain;
import '../../domain/entities/category_attribute.dart' as domain_attr;
import '../../domain/entities/product.dart' as domain_product;
import '../../domain/entities/product_attribute.dart' as domain_pa;
import '../../domain/entities/stock_movement.dart' as domain_sm;
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/stock_movement_repository.dart';
import '../../../../core/database/app_database.dart' as db;

final categoryDataSourceProvider = Provider<CategoryLocalDataSource>((ref) {
  return CategoryLocalDataSource(ref.watch(db.databaseProvider));
});

final productDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSource(ref.watch(db.databaseProvider));
});

final stockMovementDataSourceProvider = Provider<StockMovementLocalDataSource>((
  ref,
) {
  return StockMovementLocalDataSource(ref.watch(db.databaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryDataSourceProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    ref.watch(productDataSourceProvider),
    ref.watch(categoryDataSourceProvider),
  );
});

final stockMovementRepositoryProvider = Provider<StockMovementRepository>((
  ref,
) {
  return StockMovementRepositoryImpl(
    ref.watch(stockMovementDataSourceProvider),
    ref.watch(productDataSourceProvider),
  );
});

final categoriesProvider = FutureProvider<List<domain.Category>>((ref) async {
  final result = await ref.watch(categoryRepositoryProvider).getAllCategories();
  return result.when(
    success: (data) => data,
    error: (failure) => throw Exception(failure.message),
  );
});

final categoryAttributesProvider =
    FutureProvider.family<List<domain_attr.CategoryAttribute>, String>((
      ref,
      categoryType,
    ) async {
      final result = await ref
          .watch(categoryRepositoryProvider)
          .getAttributesByCategoryType(categoryType);
      return result.when(
        success: (data) => data,
        error: (failure) => throw Exception(failure.message),
      );
    });

final productsProvider = FutureProvider<List<domain_product.Product>>((
  ref,
) async {
  final result = await ref.watch(productRepositoryProvider).getAllProducts();
  return result.when(
    success: (data) => data,
    error: (failure) => throw Exception(failure.message),
  );
});

final productsByCategoryProvider =
    FutureProvider.family<List<domain_product.Product>, String>((
      ref,
      categoryId,
    ) async {
      final result = await ref
          .watch(productRepositoryProvider)
          .getAllProducts(categoryId: categoryId);
      return result.when(
        success: (data) => data,
        error: (failure) => throw Exception(failure.message),
      );
    });

final searchedProductsProvider =
    FutureProvider.family<List<domain_product.Product>, String>((
      ref,
      query,
    ) async {
      if (query.isEmpty) {
        final result = await ref
            .watch(productRepositoryProvider)
            .getAllProducts();
        return result.when(
          success: (data) => data,
          error: (failure) => throw Exception(failure.message),
        );
      }
      final result = await ref
          .watch(productRepositoryProvider)
          .getAllProducts(searchQuery: query);
      return result.when(
        success: (data) => data,
        error: (failure) => throw Exception(failure.message),
      );
    });

final productAttributesProvider =
    FutureProvider.family<List<domain_pa.ProductAttribute>, String>((
      ref,
      productId,
    ) async {
      final result = await ref
          .watch(productRepositoryProvider)
          .getProductAttributes(productId);
      return result.when(
        success: (data) => data,
        error: (failure) => throw Exception(failure.message),
      );
    });

final lowStockProductsProvider = FutureProvider<List<domain_product.Product>>((
  ref,
) async {
  final result = await ref
      .watch(productRepositoryProvider)
      .getLowStockProducts();
  return result.when(
    success: (data) => data,
    error: (failure) => throw Exception(failure.message),
  );
});

final stockMovementsProvider = FutureProvider<List<domain_sm.StockMovement>>((
  ref,
) async {
  final result = await ref
      .watch(stockMovementRepositoryProvider)
      .getAllMovements();
  return result.when(
    success: (data) => data,
    error: (failure) => throw Exception(failure.message),
  );
});

final stockMovementsByProductProvider =
    FutureProvider.family<List<domain_sm.StockMovement>, String>((
      ref,
      productId,
    ) async {
      final result = await ref
          .watch(stockMovementRepositoryProvider)
          .getMovementsByProduct(productId);
      return result.when(
        success: (data) => data,
        error: (failure) => throw Exception(failure.message),
      );
    });
