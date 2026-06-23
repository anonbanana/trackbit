import '../../../../core/utils/result.dart';
import '../../domain/entities/cart.dart';

abstract class PosRepository {
  Future<Result<void>> processOrder({
    required Cart cart,
    required String userId,
    required String paymentMethod,
    String? customerId,
    String? customerName,
    String? customerPhone,
  });
  Future<Result<List<Map<String, dynamic>>>> searchProducts(String query);
  Future<Result<Map<String, dynamic>?>> getProductByBarcode(String barcode);
  Future<Result<Map<String, dynamic>?>> getReceiptSettings();
}
