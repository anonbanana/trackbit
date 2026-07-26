import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/stock_movement.dart' as domain;
import '../../domain/enums/movement_type.dart';

class StockMovementLocalDataSource {
  final db.AppDatabase _database;

  StockMovementLocalDataSource(this._database);

  Future<List<domain.StockMovement>> getAllMovements() async {
    final results =
        await (_database.select(_database.stockMovements)..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();
    return results.map(_mapMovement).toList();
  }

  Future<List<domain.StockMovement>> getMovementsByProduct(
    String productId,
  ) async {
    final results =
        await (_database.select(_database.stockMovements)
              ..where((t) => t.productId.equals(productId))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    return results.map(_mapMovement).toList();
  }

  Future<void> insertMovement(domain.StockMovement movement) async {
    await _database
        .into(_database.stockMovements)
        .insert(
          db.StockMovementsCompanion(
            id: Value(movement.id),
            productId: Value(movement.productId),
            type: Value(movement.type.name),
            quantity: Value(movement.quantity),
            referenceType: Value(movement.referenceType),
            referenceId: Value(movement.referenceId),
            note: Value(movement.note),
            createdAt: Value(movement.createdAt),
          ),
        );
  }

  domain.StockMovement _mapMovement(db.StockMovement row) {
    return domain.StockMovement(
      id: row.id,
      productId: row.productId,
      type: MovementType.fromString(row.type),
      quantity: row.quantity,
      referenceType: row.referenceType,
      referenceId: row.referenceId,
      note: row.note,
      createdAt: row.createdAt,
    );
  }
}
