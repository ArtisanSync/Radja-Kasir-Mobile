import 'dart:convert';

class OrderDetail {
  int? id;
  int? variantId;
  String? productName;
  int? unitPrice;
  int? quantity;
  int? total;

  OrderDetail({
    this.id,
    this.variantId,
    this.productName,
    this.unitPrice,
    this.quantity,
    this.total,
  });

  @override
  String toString() {
    return 'OrderDetail(id: $id, variantId: $variantId, productName: $productName, unitPrice: $unitPrice, quantity: $quantity, total: $total)';
  }

  factory OrderDetail.fromMap(Map<String, dynamic> data) => OrderDetail(
        id: data['id'] as int?,
        variantId: data['variant_id'] as int?,
        productName: data['product_name'] as String?,
        unitPrice: data['unit_price'] as int?,
        quantity: data['quantity'] as int?,
        total: data['total'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'variant_id': variantId,
        'product_name': productName,
        'unit_price': unitPrice,
        'quantity': quantity,
        'total': total,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [OrderDetail].
  factory OrderDetail.fromJson(String data) {
    return OrderDetail.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [OrderDetail] to a JSON string.
  String toJson() => json.encode(toMap());
}
