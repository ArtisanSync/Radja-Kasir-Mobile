class SalesReportModel {
  final String period;
  final DateRange dateRange;
  final StoreInfo store;
  final SalesSummary summary;
  final List<TransactionData> transactions;
  final List<DailyData> dailyData;
  final List<TopProduct> topProducts;

  SalesReportModel({
    required this.period,
    required this.dateRange,
    required this.store,
    required this.summary,
    required this.transactions,
    required this.dailyData,
    required this.topProducts,
  });

  static List<dynamic> _toList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value;
    if (value is Map) return value.values.toList();
    return const [];
  }

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    // Handle topProducts which may be a Map with lists (most/leastProfitable)
    final dynamic tp = json['topProducts'] ?? json['top_products'];
    final List<Map<String, dynamic>> tpList = <Map<String, dynamic>>[];
    if (tp is List) {
      for (final item in tp) {
        if (item is Map<String, dynamic>) tpList.add(item);
      }
    } else if (tp is Map) {
      for (final value in tp.values) {
        if (value is List) {
          for (final item in value) {
            if (item is Map<String, dynamic>) tpList.add(item);
          }
        }
      }
    }

    return SalesReportModel(
      period: json['period'] ?? '',
      dateRange: DateRange.fromJson(json['dateRange'] ?? {}),
      store: StoreInfo.fromJson(json['store'] ?? {}),
      summary: SalesSummary.fromJson(json['summary'] ?? {}),
      transactions: _toList(json['transactions'] ?? json['list'])
          .whereType<Map<String, dynamic>>()
          .map((x) => TransactionData.fromJson(x))
          .toList(),
      dailyData: _toList(json['dailyData'] ?? json['daily_data'])
          .whereType<Map<String, dynamic>>()
          .map((x) => DailyData.fromJson(x))
          .toList(),
      topProducts: tpList.map((x) => TopProduct.fromJson(x)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'dateRange': dateRange.toJson(),
      'store': store.toJson(),
      'summary': summary.toJson(),
      'transactions': transactions.map((x) => x.toJson()).toList(),
      'dailyData': dailyData.map((x) => x.toJson()).toList(),
      'topProducts': topProducts.map((x) => x.toJson()).toList(),
    };
  }
}

class DateRange {
  final String start;
  final String end;

  DateRange({required this.start, required this.end});

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}

class StoreInfo {
  final String id;
  final String name;

  StoreInfo({required this.id, required this.name});

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class SalesSummary {
  final int totalTransactions;
  final double totalRevenue;
  final double totalProfit;
  final double totalTax;
  final double totalDiscount;
  final double averageTransaction;
  final int totalItems;

  SalesSummary({
    required this.totalTransactions,
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalTax,
    required this.totalDiscount,
    required this.averageTransaction,
    required this.totalItems,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      totalTransactions: json['totalTransactions'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0).toDouble(),
      totalTax: (json['totalTax'] ?? 0).toDouble(),
      totalDiscount: (json['totalDiscount'] ?? 0).toDouble(),
      averageTransaction: (json['averageTransaction'] ?? 0).toDouble(),
      totalItems: json['totalItems'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTransactions': totalTransactions,
      'totalRevenue': totalRevenue,
      'totalProfit': totalProfit,
      'totalTax': totalTax,
      'totalDiscount': totalDiscount,
      'averageTransaction': averageTransaction,
      'totalItems': totalItems,
    };
  }
}

class TransactionData {
  final String id;
  final String invoiceNumber;
  final String date;
  final String customer;
  final int items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final List<TransactionDetail> details;

  TransactionData({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.customer,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.details,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      date: json['date'] ?? '',
      customer: json['customer'] ?? '',
      items: json['items'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      details: (json['details'] as List<dynamic>? ?? [])
          .map((x) => TransactionDetail.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'date': date,
      'customer': customer,
      'items': items,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'details': details.map((x) => x.toJson()).toList(),
    };
  }
}

class TransactionDetail {
  final String product;
  final String variant;
  final int quantity;
  final double price;
  final double subtotal;

  TransactionDetail({
    required this.product,
    required this.variant,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      product: json['product'] ?? '',
      variant: json['variant'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'variant': variant,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

class DailyData {
  final String date;
  final double revenue;
  final int transactions;
  final int items;

  DailyData({
    required this.date,
    required this.revenue,
    required this.transactions,
    required this.items,
  });

  factory DailyData.fromJson(Map<String, dynamic> json) {
    return DailyData(
      date: json['date'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      transactions: json['transactions'] ?? 0,
      items: json['items'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'revenue': revenue,
      'transactions': transactions,
      'items': items,
    };
  }
}

class TopProduct {
  final String productId;
  final String variantId;
  final String name;
  final String productName;
  final String category;
  final String unit;
  final int totalQuantity;
  final double totalRevenue;
  final int transactions;

  TopProduct({
    required this.productId,
    required this.variantId,
    required this.name,
    required this.productName,
    required this.category,
    required this.unit,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.transactions,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['productId'] ?? '',
      variantId: json['variantId'] ?? '',
      name: json['name'] ?? '',
      productName: json['productName'] ?? '',
      category: json['category'] ?? '',
      unit: json['unit'] ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      transactions: json['transactions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'variantId': variantId,
      'name': name,
      'productName': productName,
      'category': category,
      'unit': unit,
      'totalQuantity': totalQuantity,
      'totalRevenue': totalRevenue,
      'transactions': transactions,
    };
  }
}

// Dashboard Summary Model
class DashboardSummaryModel {
  final PeriodSummary currentPeriod;
  final PeriodSummary previousPeriod;
  final GrowthSummary growth;
  final List<TopProduct> topProducts;
  final List<DailyData> dailyData;

  DashboardSummaryModel({
    required this.currentPeriod,
    required this.previousPeriod,
    required this.growth,
    required this.topProducts,
    required this.dailyData,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      currentPeriod: PeriodSummary.fromJson(json['currentPeriod'] ?? {}),
      previousPeriod: PeriodSummary.fromJson(json['previousPeriod'] ?? {}),
      growth: GrowthSummary.fromJson(json['growth'] ?? {}),
      topProducts: (json['topProducts'] as List<dynamic>? ?? [])
          .map((x) => TopProduct.fromJson(x))
          .toList(),
      dailyData: (json['dailyData'] as List<dynamic>? ?? [])
          .map((x) => DailyData.fromJson(x))
          .toList(),
    );
  }
}

class PeriodSummary {
  final double revenue;
  final int transactions;
  final int items;
  final double averageTransaction;

  PeriodSummary({
    required this.revenue,
    required this.transactions,
    required this.items,
    required this.averageTransaction,
  });

  factory PeriodSummary.fromJson(Map<String, dynamic> json) {
    return PeriodSummary(
      revenue: (json['revenue'] ?? 0).toDouble(),
      transactions: json['transactions'] ?? 0,
      items: json['items'] ?? 0,
      averageTransaction: (json['averageTransaction'] ?? 0).toDouble(),
    );
  }
}

class GrowthSummary {
  final double revenue;
  final double transactions;
  final double items;
  final double averageTransaction;

  GrowthSummary({
    required this.revenue,
    required this.transactions,
    required this.items,
    required this.averageTransaction,
  });

  factory GrowthSummary.fromJson(Map<String, dynamic> json) {
    return GrowthSummary(
      revenue: (json['revenue'] ?? 0).toDouble(),
      transactions: (json['transactions'] ?? 0).toDouble(),
      items: (json['items'] ?? 0).toDouble(),
      averageTransaction: (json['averageTransaction'] ?? 0).toDouble(),
    );
  }
}
