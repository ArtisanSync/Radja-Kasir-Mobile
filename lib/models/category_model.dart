class CategoryModel {
  final int? id;
  final String name;
  final String? storeId;

  const CategoryModel({
    this.id,
    required this.name,
    this.storeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'storeId': storeId,
    };
  }

  @override
  String toString() {
    return 'product {name: $name}';
  }
}
