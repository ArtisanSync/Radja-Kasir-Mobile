class TransactionModel {
  final String id;
  final String transactionNumber;
  final String storeId;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<TransactionItemModel> items;
  final PaymentInfoModel? paymentInfo;
  final CustomerInfoModel? customerInfo;

  const TransactionModel({
    required this.id,
    required this.transactionNumber,
    required this.storeId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.items,
    this.paymentInfo,
    this.customerInfo,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      transactionNumber: json['transaction_number'] ?? '',
      storeId: json['store_id'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => TransactionItemModel.fromJson(item))
          .toList(),
      paymentInfo: json['payment_info'] != null 
          ? PaymentInfoModel.fromJson(json['payment_info'])
          : null,
      customerInfo: json['customer_info'] != null 
          ? CustomerInfoModel.fromJson(json['customer_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'store_id': storeId,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'payment_info': paymentInfo?.toJson(),
      'customer_info': customerInfo?.toJson(),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? transactionNumber,
    String? storeId,
    double? totalAmount,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TransactionItemModel>? items,
    PaymentInfoModel? paymentInfo,
    CustomerInfoModel? customerInfo,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      storeId: storeId ?? this.storeId,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      customerInfo: customerInfo ?? this.customerInfo,
    );
  }

  bool get isPaid => status == 'paid' || status == 'completed';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
  bool get isCashPayment => paymentMethod == 'cash';
  bool get isCreditPayment => paymentMethod == 'credit';
  bool get isOtherPayment => paymentMethod == 'other';
}

class TransactionItemModel {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double totalPrice;
  final String? unit;
  final String? category;
  final String? image;
  final String? notes;

  const TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    this.unit,
    this.category,
    this.image,
    this.notes,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      unit: json['unit'],
      category: json['category'],
      image: json['image'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'total_price': totalPrice,
      'unit': unit,
      'category': category,
      'image': image,
      'notes': notes,
    };
  }

  TransactionItemModel copyWith({
    String? id,
    String? transactionId,
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    double? totalPrice,
    String? unit,
    String? category,
    String? image,
    String? notes,
  }) {
    return TransactionItemModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      image: image ?? this.image,
      notes: notes ?? this.notes,
    );
  }
}

class PaymentInfoModel {
  final String id;
  final String transactionId;
  final String method;
  final double totalAmount;
  final double? receivedAmount;
  final double? changeAmount;
  final String? referenceNumber;
  final String? notes;
  final String? otherPaymentType;
  final DateTime createdAt;

  const PaymentInfoModel({
    required this.id,
    required this.transactionId,
    required this.method,
    required this.totalAmount,
    this.receivedAmount,
    this.changeAmount,
    this.referenceNumber,
    this.notes,
    this.otherPaymentType,
    required this.createdAt,
  });

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) {
    return PaymentInfoModel(
      id: json['id'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      method: json['method'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      receivedAmount: json['received_amount'] != null 
          ? (json['received_amount']).toDouble() 
          : null,
      changeAmount: json['change_amount'] != null 
          ? (json['change_amount']).toDouble() 
          : null,
      referenceNumber: json['reference_number'],
      notes: json['notes'],
      otherPaymentType: json['other_payment_type'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'method': method,
      'total_amount': totalAmount,
      'received_amount': receivedAmount,
      'change_amount': changeAmount,
      'reference_number': referenceNumber,
      'notes': notes,
      'other_payment_type': otherPaymentType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PaymentInfoModel copyWith({
    String? id,
    String? transactionId,
    String? method,
    double? totalAmount,
    double? receivedAmount,
    double? changeAmount,
    String? referenceNumber,
    String? notes,
    String? otherPaymentType,
    DateTime? createdAt,
  }) {
    return PaymentInfoModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      method: method ?? this.method,
      totalAmount: totalAmount ?? this.totalAmount,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      otherPaymentType: otherPaymentType ?? this.otherPaymentType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCashPayment => method == 'cash';
  bool get isCreditPayment => method == 'credit';
  bool get isOtherPayment => method == 'other';
  String get displayPaymentMethod {
    switch (method) {
      case 'cash':
        return 'Tunai';
      case 'credit':
        return 'Kasbon';
      case 'other':
        return otherPaymentType ?? 'Pembayaran Lainnya';
      default:
        return method;
    }
  }
}

class CustomerInfoModel {
  final String id;
  final String transactionId;
  final String name;
  final String phone;
  final String address;
  final String? notes;
  final DateTime createdAt;

  const CustomerInfoModel({
    required this.id,
    required this.transactionId,
    required this.name,
    required this.phone,
    required this.address,
    this.notes,
    required this.createdAt,
  });

  factory CustomerInfoModel.fromJson(Map<String, dynamic> json) {
    return CustomerInfoModel(
      id: json['id'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CustomerInfoModel copyWith({
    String? id,
    String? transactionId,
    String? name,
    String? phone,
    String? address,
    String? notes,
    DateTime? createdAt,
  }) {
    return CustomerInfoModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Transaction Pagination Model
class TransactionPagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const TransactionPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory TransactionPagination.fromJson(Map<String, dynamic> json) {
    return TransactionPagination(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
      itemsPerPage: json['items_per_page'] ?? 20,
      hasNextPage: json['has_next_page'] ?? false,
      hasPreviousPage: json['has_previous_page'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }
}

// Transaction Summary Model for reports
class TransactionSummary {
  final int totalTransactions;
  final double totalRevenue;
  final double totalCashPayments;
  final double totalCreditPayments;
  final double totalOtherPayments;
  final int totalItems;
  final DateTime periodStart;
  final DateTime periodEnd;

  const TransactionSummary({
    required this.totalTransactions,
    required this.totalRevenue,
    required this.totalCashPayments,
    required this.totalCreditPayments,
    required this.totalOtherPayments,
    required this.totalItems,
    required this.periodStart,
    required this.periodEnd,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalTransactions: json['total_transactions'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalCashPayments: (json['total_cash_payments'] ?? 0).toDouble(),
      totalCreditPayments: (json['total_credit_payments'] ?? 0).toDouble(),
      totalOtherPayments: (json['total_other_payments'] ?? 0).toDouble(),
      totalItems: json['total_items'] ?? 0,
      periodStart: DateTime.parse(json['period_start'] ?? DateTime.now().toIso8601String()),
      periodEnd: DateTime.parse(json['period_end'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_transactions': totalTransactions,
      'total_revenue': totalRevenue,
      'total_cash_payments': totalCashPayments,
      'total_credit_payments': totalCreditPayments,
      'total_other_payments': totalOtherPayments,
      'total_items': totalItems,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }
}