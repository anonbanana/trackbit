import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_attribute.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _dataSource;

  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Category>>> getAllCategories() async {
    try {
      final categories = await _dataSource.getAllCategories();
      return Success(categories);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load categories: $e'));
    }
  }

  @override
  Future<Result<Category?>> getCategoryById(String id) async {
    try {
      final category = await _dataSource.getCategoryById(id);
      return Success(category);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load category: $e'));
    }
  }

  @override
  Future<Result<Category>> createCategory(Category category) async {
    try {
      await _dataSource.insertCategory(category);
      return Success(category);
    } catch (e) {
      return Error(DatabaseFailure('Failed to create category: $e'));
    }
  }

  @override
  Future<Result<Category>> updateCategory(Category category) async {
    try {
      await _dataSource.updateCategory(category);
      return Success(category);
    } catch (e) {
      return Error(DatabaseFailure('Failed to update category: $e'));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      await _dataSource.deleteCategory(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete category: $e'));
    }
  }

  @override
  Future<Result<List<CategoryAttribute>>> getAttributesByCategoryType(String categoryType) async {
    try {
      final attributes = await _dataSource.getAttributesByCategoryType(categoryType);
      return Success(attributes);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load attributes: $e'));
    }
  }

  @override
  Future<Result<void>> saveCategoryAttributes(List<CategoryAttribute> attributes) async {
    try {
      if (attributes.isEmpty) return const Success(null);
      final categoryType = attributes.first.categoryType.name;
      await _dataSource.clearAttributesByCategoryType(categoryType);
      for (final attr in attributes) {
        await _dataSource.insertCategoryAttribute(attr);
      }
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to save attributes: $e'));
    }
  }
}
