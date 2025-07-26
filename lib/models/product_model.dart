class Product {
  final int? id;
  final String? code;
  final String name;
  final String merk;
  final String category;
  final double price;
  final int discount;
  final int tax;
  final int? is_favorite;

  const Product({
    this.id,
    this.code,
    required this.name,
    required this.merk,
    required this.category,
    required this.price,
    required this.discount,
    required this.tax,
    this.is_favorite,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'merk': merk,
      'price': price,
      'discount': discount,
      'tax': tax,
      'is_favorite': is_favorite,
    };
  }

  @override
  String toString() {
    return 'product {code: $code, name: $name, merk: $merk, price: $price, discount: $discount, tax: $tax, fav: $is_favorite}';
  }
}
