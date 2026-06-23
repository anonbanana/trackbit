import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../entities/category_attribute.dart';

abstract class CategoryRepository {
  Future<Result<List<Category>>> getAllCategories();
  Future<Result<Category?>> getCategoryById(String id);
  Future<Result<Category>> createCategory(Category category);
  Future<Result<Category>> updateCategory(Category category);
  Future<Result<void>> deleteCategory(String id);
  Future<Result<List<CategoryAttribute>>> getAttributesByCategoryType(String categoryType);
  Future<Result<void>> saveCategoryAttributes(List<CategoryAttribute> attributes);
}
