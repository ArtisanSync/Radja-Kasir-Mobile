// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/services/transaction_services.dart';

// Transaction Services Provider
final transactionServicesProvider = Provider<TransactionServices>((ref) {
  return TransactionServices();
});

// Transaction Item Model
class TransactionItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? unit;
  final String? category;
  final String? image;

  const TransactionItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.unit,
    this.category,
    this.image,
  });

  double get totalPrice => price * quantity;

  TransactionItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? unit,
    String? category,
    String? image,
  }) {
    return TransactionItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variantId': productId,
      'quantity': quantity,
    };
  }

  factory TransactionItem.fromProduct(Product product, int quantity) {
    return TransactionItem(
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: quantity,
      unit: product.unit?.name,
      category: product.category?.name,
      image: product.image,
    );
  }
}

// Customer Information Model
class CustomerInfo {
  final String name;
  final String phone;
  final String address;
  final String? notes;

  const CustomerInfo({
    required this.name,
    required this.phone,
    required this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'company': null,
      'whatsapp': phone, // Use phone as whatsapp for now
    };
  }
}

// Payment Information Model
class PaymentInfo {
  final String method; // 'cash', 'credit', 'other' 
  final double totalAmount;
  final double? receivedAmount;
  final double? changeAmount;
  final String? referenceNumber;
  final String? notes;
  final CustomerInfo? customerInfo;
  final String? otherPaymentType; // For other payment methods

  const PaymentInfo({
    required this.method,
    required this.totalAmount,
    this.receivedAmount,
    this.changeAmount,
    this.referenceNumber,
    this.notes,
    this.customerInfo,
    this.otherPaymentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'total_amount': totalAmount,
      'received_amount': receivedAmount,
      'change_amount': changeAmount,
      'reference_number': referenceNumber,
      'notes': notes,
      'customer_info': customerInfo?.toJson(),
      'other_payment_type': otherPaymentType,
    };
  }
}

// Transaction State
class TransactionState {
  final String? transactionNumber;
  final List<TransactionItem> items;
  final PaymentInfo? paymentInfo;
  final bool isProcessing;
  final bool isCompleted;
  final String? error;
  final DateTime? createdAt;

  const TransactionState({
    this.transactionNumber,
    this.items = const [],
    this.paymentInfo,
    this.isProcessing = false,
    this.isCompleted = false,
    this.error,
    this.createdAt,
  });

  TransactionState copyWith({
    String? transactionNumber,
    List<TransactionItem>? items,
    PaymentInfo? paymentInfo,
    bool? isProcessing,
    bool? isCompleted,
    String? error,
    DateTime? createdAt,
  }) {
    return TransactionState(
      transactionNumber: transactionNumber ?? this.transactionNumber,
      items: items ?? this.items,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      isProcessing: isProcessing ?? this.isProcessing,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get hasItems => items.isNotEmpty;
}

// Transaction Notifier
class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionServices _transactionServices;

  TransactionNotifier(this._transactionServices)
      : super(const TransactionState());

  // Initialize new transaction
  void initializeTransaction(List<TransactionItem> items) {
    final transactionNumber = _generateTransactionNumber();
    state = TransactionState(
      transactionNumber: transactionNumber,
      items: items,
      createdAt: DateTime.now(),
    );
  }

  // Process cash payment
  Future<bool> processCashPayment({
    required double receivedAmount,
    String? notes,
  }) async {
    if (state.items.isEmpty) {
      state = state.copyWith(error: 'No items in transaction');
      return false;
    }

    final changeAmount = receivedAmount - state.totalAmount;
    if (changeAmount < 0) {
      state = state.copyWith(error: 'Insufficient payment amount');
      return false;
    }

    final paymentInfo = PaymentInfo(
      method: 'cash',
      totalAmount: state.totalAmount,
      receivedAmount: receivedAmount,
      changeAmount: changeAmount,
      notes: notes,
    );

    return await _processPayment(paymentInfo);
  }

  // Process credit payment
  Future<bool> processCreditPayment({
    required CustomerInfo customerInfo,
    String? notes,
  }) async {
    if (state.items.isEmpty) {
      state = state.copyWith(error: 'No items in transaction');
      return false;
    }

    final paymentInfo = PaymentInfo(
      method: 'credit',
      totalAmount: state.totalAmount,
      customerInfo: customerInfo,
      notes: notes,
    );

    return await _processPayment(paymentInfo);
  }

  // Process other payment
  Future<bool> processOtherPayment({
    required String paymentType,
    required String referenceNumber,
    String? notes,
  }) async {
    if (state.items.isEmpty) {
      state = state.copyWith(error: 'No items in transaction');
      return false;
    }

    final paymentInfo = PaymentInfo(
      method: 'other',
      totalAmount: state.totalAmount,
      otherPaymentType: paymentType,
      referenceNumber: referenceNumber,
      notes: notes,
    );

    return await _processPayment(paymentInfo);
  }

  // Internal method to process payment
  Future<bool> _processPayment(PaymentInfo paymentInfo) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      // Prepare transaction data according to backend format
      final transactionData = {
        'items': state.items.map((item) => item.toJson()).toList(),
        'paymentMethod': _mapPaymentMethod(paymentInfo.method),
        'notes': paymentInfo.notes,
      };

      // Add payment-specific data
      if (paymentInfo.method == 'cash') {
        transactionData['amountPaid'] = paymentInfo.receivedAmount;
      } else if (paymentInfo.method == 'credit') {
        transactionData['customerData'] = paymentInfo.customerInfo?.toJson();
      }

      // Call transaction service
      final result =
          await _transactionServices.createTransaction(transactionData);

      if (result['success'] == true) {
        state = state.copyWith(
          paymentInfo: paymentInfo,
          isProcessing: false,
          isCompleted: true,
        );

        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to process payment',
          isProcessing: false,
        );

        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Network error: ${e.toString()}',
        isProcessing: false,
      );

      return false;
    }
  }

  // Map payment method to backend format
  String _mapPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'TUNAI';
      case 'credit':
        return 'KASBON';
      default:
        return 'TUNAI';
    }
  }

  // Clear transaction
  void clearTransaction() {
    state = const TransactionState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Generate transaction number
  String _generateTransactionNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'TRX${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }

  // Update transaction items (if needed)
  void updateItems(List<TransactionItem> items) {
    state = state.copyWith(items: items);
  }
}

// Transaction Provider
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final transactionServices = ref.watch(transactionServicesProvider);
  return TransactionNotifier(transactionServices);
});

// Helper providers
final transactionTotalAmountProvider = Provider<double>((ref) {
  return ref.watch(transactionProvider).totalAmount;
});

final transactionItemCountProvider = Provider<int>((ref) {
  return ref.watch(transactionProvider).totalItems;
});

final transactionHasItemsProvider = Provider<bool>((ref) {
  return ref.watch(transactionProvider).hasItems;
});

final transactionIsProcessingProvider = Provider<bool>((ref) {
  return ref.watch(transactionProvider).isProcessing;
});

final transactionIsCompletedProvider = Provider<bool>((ref) {
  return ref.watch(transactionProvider).isCompleted;
});
