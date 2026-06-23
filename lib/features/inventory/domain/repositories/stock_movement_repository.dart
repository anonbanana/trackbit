import '../../../../core/utils/result.dart';
import '../entities/stock_movement.dart';

abstract class StockMovementRepository {
  Future<Result<List<StockMovement>>> getMovementsByProduct(String productId);
  Future<Result<List<StockMovement>>> getAllMovements();
  Future<Result<StockMovement>> createMovement(StockMovement movement);
}
