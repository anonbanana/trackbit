import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pos_local_datasource.dart';
import '../../data/repositories/pos_repository_impl.dart';
import '../../domain/repositories/pos_repository.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../../../core/database/app_database.dart';

final posDataSourceProvider = Provider<PosLocalDataSource>((ref) {
  return PosLocalDataSource(ref.watch(databaseProvider));
});

final posRepositoryProvider = Provider<PosRepository>((ref) {
  return PosRepositoryImpl(ref.watch(posDataSourceProvider));
});

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(const Cart());

  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final newItems = [...state.items];
      newItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
      state = state.copyWith(items: newItems);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void updateQuantity(String productId, double quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = state.copyWith(
      items: state.items.map((i) {
        if (i.productId == productId) {
          return i.copyWith(quantity: quantity);
        }
        return i;
      }).toList(),
    );
  }

  void setDiscount(double discount) {
    state = state.copyWith(discount: discount.clamp(0, 100));
  }

  void setTaxRate(double taxRate) {
    state = state.copyWith(taxRate: taxRate.clamp(0, 100));
  }

  void clear() {
    state = const Cart();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

final searchedPosProductsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final result = await ref.watch(posRepositoryProvider).searchProducts(query);
  return result.when(
    success: (data) => data,
    error: (failure) => throw Exception(failure.message),
  );
});
