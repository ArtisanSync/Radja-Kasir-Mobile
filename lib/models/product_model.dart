import 'dart:convert';

class Product {
  final String? id;
  final String name;
  final String? code;
  final String? brand;
  final String? image;
  final String? categoryId;
  final CategoryModel? category;
  final bool isActive;
  final bool isFavorite;
  final List<ProductVariant> variants;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    this.code,
    this.brand,
    this.image,
    this.categoryId,
    this.category,
    required this.isActive,
    required this.isFavorite,
    required this.variants,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  int get totalQuantity => variants.fold(0, (sum, item) => sum + item.quantity);
  bool get hasStock => totalQuantity > 0;
  bool get isLowStock => hasStock && totalQuantity < 10;
  String get displayUnit => variants.isNotEmpty ? (variants.first.unit?.name ?? '') : '';
  // [PERBAIKAN] Tambahkan kembali getter displayPrice
  String get displayPrice => variants.isNotEmpty ? variants.first.finalPrice : '0';


  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
      brand: json['brand'],
      image: json['image'],
      categoryId: json['categoryId'],
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      isActive: json['isActive'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      variants: json['variants'] != null
          ? List<ProductVariant>.from(json['variants'].map((x) => ProductVariant.fromJson(x)))
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ProductVariant {
  final String id;
  final String? name;
  final int quantity;
  final String capitalPrice;
  final String price;
  final int tax;
  final String discountRp;
  final int discountPercent;
  final String unitId;
  final UnitModel? unit;

  ProductVariant({
    required this.id,
    this.name,
    required this.quantity,
    required this.capitalPrice,
    required this.price,
    required this.tax,
    required this.discountRp,
    required this.discountPercent,
    required this.unitId,
    this.unit,
  });

  String get finalPrice {
    double originalPrice = double.tryParse(price) ?? 0.0;
    double discountAmount = double.tryParse(discountRp) ?? 0.0;
    double finalDiscount = originalPrice - discountAmount;
    if (discountPercent > 0) {
      finalDiscount = finalDiscount - (finalDiscount * discountPercent / 100);
    }
    return finalDiscount.toStringAsFixed(0); // Dibulatkan tanpa desimal
  }

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      name: json['name'],
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      capitalPrice: json['capitalPrice']?.toString() ?? '0',
      price: json['price']?.toString() ?? '0',
      tax: int.tryParse(json['tax']?.toString() ?? '0') ?? 0,
      discountRp: json['discountRp']?.toString() ?? '0',
      discountPercent: int.tryParse(json['discountPercent']?.toString() ?? '0') ?? 0,
      unitId: json['unitId'],
      unit: json['unit'] != null ? UnitModel.fromJson(json['unit']) : null,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final int productCount;

  CategoryModel({required this.id, required this.name, this.productCount = 0});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      productCount: json['_count']?['products'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class UnitModel {
  final String id;
  final String name;

  UnitModel({required this.id, required this.name});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class ProductPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ProductPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ProductPagination.fromJson(Map<String, dynamic> json) {
    return ProductPagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}