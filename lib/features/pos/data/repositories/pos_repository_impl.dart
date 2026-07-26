import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/pos_repository.dart';
import '../../domain/entities/cart.dart';
import '../datasources/pos_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class PosRepositoryImpl implements PosRepository {
  final PosLocalDataSource _dataSource;
  final db.AppDatabase _database;
  final _uuid = const Uuid();

  PosRepositoryImpl(this._dataSource, this._database);

  @override
  Future<Result<List<Map<String, dynamic>>>> searchProducts(
    String query,
  ) async {
    try {
      final products = await _dataSource.searchProducts(query);
      return Success(products);
    } catch (e) {
      return const Error(DatabaseFailure('Failed to search products'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getProductByBarcode(
    String barcode,
  ) async {
    try {
      final product = await _dataSource.getProductByBarcode(barcode);
      return Success(product);
    } catch (e) {
      return const Error(DatabaseFailure('Failed to find product'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getReceiptSettings() async {
    try {
      final settings = await _dataSource.getReceiptSettings();
      return Success(settings);
    } catch (e) {
      return const Error(DatabaseFailure('Failed to load receipt settings'));
    }
  }

  @override
  Future<Result<void>> processOrder({
    required Cart cart,
    required String userId,
    required String paymentMethod,
    String? customerId,
    String? customerName,
    String? customerPhone,
  }) async {
    try {
      if (cart.items.isEmpty) {
        return const Error(ValidationFailure('Cart is empty'));
      }

      await _database.transaction(() async {
        if (customerName != null && customerName.isNotEmpty) {
          customerId = await _dataSource.insertCustomer(
            customerName,
            customerPhone,
          );
        }

        final orderNumber = await _dataSource.getNextOrderNumber();
        final orderId = _uuid.v4();
        final now = DateTime.now();

        await _dataSource.insertOrder(
          db.OrdersCompanion(
            id: Value(orderId),
            orderNumber: Value(orderNumber),
            customerId: Value(customerId),
            userId: Value(userId),
            subtotal: Value(cart.subtotal),
            tax: Value(cart.taxAmount),
            discount: Value(cart.discountAmount),
            total: Value(cart.total),
            paymentMethod: Value(paymentMethod),
            status: const Value('completed'),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

        for (final item in cart.items) {
          await _dataSource.insertOrderItem(
            db.OrderItemsCompanion(
              id: Value(_uuid.v4()),
              orderId: Value(orderId),
              productId: Value(item.productId),
              quantity: Value(item.quantity),
              unitPrice: Value(item.unitPrice),
              subtotal: Value(item.subtotal),
            ),
          );

          await _dataSource.updateProductStock(item.productId, item.quantity);

          await _dataSource.insertStockMovement(
            db.StockMovementsCompanion(
              id: Value(_uuid.v4()),
              productId: Value(item.productId),
              type: const Value('out'),
              quantity: Value(item.quantity),
              referenceType: const Value('order'),
              referenceId: Value(orderId),
              note: Value('Sale: $orderNumber'),
              createdAt: Value(now),
            ),
          );
        }

        await _dataSource.insertPayment(
          db.PaymentsCompanion(
            id: Value(_uuid.v4()),
            orderId: Value(orderId),
            amount: Value(cart.total),
            method: Value(paymentMethod),
            createdAt: Value(now),
          ),
        );
      });

      return const Success(null);
    } catch (e) {
      return const Error(DatabaseFailure('Failed to process order'));
    }
  }
}
