import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String id;
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String unit;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? image,
    double? price,
    int? quantity,
    String? unit,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  double get totalPrice => price * quantity;
}

// Cart State
class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Getters
  int get totalItems => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

// Cart Notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  // Add item to cart
  void addItem({
    required String productId,
    required String name,
    required String image,
    required double price,
    required String unit,
    int quantity = 1,
  }) {
    final existingIndex = state.items.indexWhere((item) => item.productId == productId);
    
    if (existingIndex >= 0) {
      // Update existing item quantity
      final updatedItems = [...state.items];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Add new item
      final newItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        name: name,
        image: image,
        price: price,
        quantity: quantity,
        unit: unit,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  // Remove item from cart
  void removeItem(String itemId) {
    final updatedItems = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
  }

  // Update item quantity
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  // Clear cart
  void clearCart() {
    state = const CartState();
  }

  // Get item by product ID
  CartItem? getItemByProductId(String productId) {
    try {
      return state.items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }
}

// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Helper providers
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalItems;
});

final cartTotalAmountProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).totalAmount;
});

final cartTotalQuantityProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalQuantity;
});
