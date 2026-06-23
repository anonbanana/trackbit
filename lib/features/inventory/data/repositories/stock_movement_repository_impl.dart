import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/stock_movement_repository.dart';
import '../datasources/stock_movement_local_datasource.dart';
import '../datasources/product_local_datasource.dart';
import '../../domain/enums/movement_type.dart';

class StockMovementRepositoryImpl implements StockMovementRepository {
  final StockMovementLocalDataSource _dataSource;
  final ProductLocalDataSource _productDataSource;

  StockMovementRepositoryImpl(this._dataSource, this._productDataSource);

  @override
  Future<Result<List<StockMovement>>> getAllMovements() async {
    try {
      final movements = await _dataSource.getAllMovements();
      return Success(movements);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load movements: $e'));
    }
  }

  @override
  Future<Result<List<StockMovement>>> getMovementsByProduct(String productId) async {
    try {
      final movements = await _dataSource.getMovementsByProduct(productId);
      return Success(movements);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load movements: $e'));
    }
  }

  @override
  Future<Result<StockMovement>> createMovement(StockMovement movement) async {
    try {
      final product = await _productDataSource.getProductById(movement.productId);
      if (product == null) {
        return Error(DatabaseFailure('Product not found'));
      }

      double newQty = product.stockQty;
      switch (movement.type) {
        case MovementType.stockIn:
          newQty += movement.quantity;
        case MovementType.stockOut:
          newQty -= movement.quantity;
          if (newQty < 0) newQty = 0;
        case MovementType.adjustment:
          newQty = movement.quantity;
      }

      await _productDataSource.updateProductStock(movement.productId, newQty);
      await _dataSource.insertMovement(movement);
      return Success(movement);
    } catch (e) {
      return Error(DatabaseFailure('Failed to create movement: $e'));
    }
  }
}
