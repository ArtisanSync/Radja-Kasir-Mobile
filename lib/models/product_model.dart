class Product {
  final String? id;
  final String? categoryId;
  final String storeId;
  final String? image;
  final String name;
  final String? code;
  final String? brand;
  final bool active;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryModel? category;
  final StoreModel? store;
  final List<ProductVariant> variants;

  const Product({
    this.id,
    this.categoryId,
    required this.storeId,
    this.image,
    required this.name,
    this.code,
    this.brand,
    this.active = true,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.store,
    this.variants = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      categoryId: json['categoryId'],
      storeId: json['storeId'] ?? '',
      image: json['image'],
      name: json['name'] ?? '',
      code: json['code'],
      brand: json['brand'],
      active: json['active'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      store: json['store'] != null ? StoreModel.fromJson(json['store']) : null,
      variants: json['variants'] != null
          ? (json['variants'] as List).map((v) => ProductVariant.fromJson(v)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'storeId': storeId,
      'image': image,
      'name': name,
      'code': code,
      'brand': brand,
      'active': active,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (category != null) 'category': category!.toJson(),
      if (store != null) 'store': store!.toJson(),
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }

  Product copyWith({
    String? id,
    String? categoryId,
    String? storeId,
    String? image,
    String? name,
    String? code,
    String? brand,
    bool? active,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    CategoryModel? category,
    StoreModel? store,
    List<ProductVariant>? variants,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      image: image ?? this.image,
      name: name ?? this.name,
      code: code ?? this.code,
      brand: brand ?? this.brand,
      active: active ?? this.active,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      store: store ?? this.store,
      variants: variants ?? this.variants,
    );
  }

  // Helper getters
  int get totalQuantity => variants.fold(0, (sum, variant) => sum + variant.quantity);
  String get displayPrice => variants.isNotEmpty ? variants.first.price.toString() : '0';
  String get displayUnit => variants.isNotEmpty ? variants.first.unit?.name ?? 'PCS' : 'PCS';
  bool get hasStock => totalQuantity > 0;
  bool get isLowStock => totalQuantity <= 10;
}

class ProductVariant {
  final String id;
  final String productId;
  final String unitId;
  final String? image;
  final String name;
  final int quantity;
  final String capitalPrice;
  final String price;
  final int tax;
  final String discountRp;
  final int discountPercent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UnitModel? unit;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.unitId,
    this.image,
    required this.name,
    required this.quantity,
    required this.capitalPrice,
    required this.price,
    this.tax = 0,
    this.discountRp = '0',
    this.discountPercent = 0,
    required this.createdAt,
    required this.updatedAt,
    this.unit,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      unitId: json['unitId'] ?? '',
      image: json['image'],
      name: json['name'] ?? 'Default',
      quantity: json['quantity'] ?? 0,
      capitalPrice: json['capitalPrice'] ?? '0',
      price: json['price'] ?? '0',
      tax: json['tax'] ?? 0,
      discountRp: json['discountRp'] ?? '0',
      discountPercent: json['discountPercent'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      unit: json['unit'] != null ? UnitModel.fromJson(json['unit']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'unitId': unitId,
      'image': image,
      'name': name,
      'quantity': quantity,
      'capitalPrice': capitalPrice,
      'price': price,
      'tax': tax,
      'discountRp': discountRp,
      'discountPercent': discountPercent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (unit != null) 'unit': unit!.toJson(),
    };
  }

  double get finalPrice {
    double basePrice = double.tryParse(price) ?? 0;
    double discountAmount = double.tryParse(discountRp) ?? 0;
    double percentDiscount = basePrice * (discountPercent / 100);
    return basePrice - discountAmount - percentDiscount;
  }
}

class UnitModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UnitModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CategoryModel {
  final String? id;
  final String name;
  final String? storeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? store;
  final Map<String, int>? count;

  const CategoryModel({
    this.id,
    required this.name,
    this.storeId,
    this.createdAt,
    this.updatedAt,
    this.store,
    this.count,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      storeId: json['storeId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      store: json['store'],
      count: json['_count'] != null ? Map<String, int>.from(json['_count']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'storeId': storeId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'store': store,
      '_count': count,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? storeId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? store,
    Map<String, int>? count,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      store: store ?? this.store,
      count: count ?? this.count,
    );
  }

  int get productCount => count?['products'] ?? 0;
}

class StoreModel {
  final String id;
  final String userId;
  final String name;
  final String? storeType;
  final String? address;
  final String? whatsapp;
  final String? logo;
  final String? stamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoreModel({
    required this.id,
    required this.userId,
    required this.name,
    this.storeType,
    this.address,
    this.whatsapp,
    this.logo,
    this.stamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      storeType: json['storeType'],
      address: json['address'],
      whatsapp: json['whatsapp'],
      logo: json['logo'],
      stamp: json['stamp'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'storeType': storeType,
      'address': address,
      'whatsapp': whatsapp,
      'logo': logo,
      'stamp': stamp,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }

  ProductPagination copyWith({
    int? total,
    int? page,
    int? limit,
    int? totalPages,
  }) {
    return ProductPagination(
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
