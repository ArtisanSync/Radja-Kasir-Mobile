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
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      store: json['store'],
      count:
          json['_count'] != null ? Map<String, int>.from(json['_count']) : null,
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

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'storeId': storeId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
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

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $name, productCount: $productCount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.storeId == storeId;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ storeId.hashCode;
}
