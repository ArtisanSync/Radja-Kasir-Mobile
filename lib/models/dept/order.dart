import 'dart:convert';

class Order {
  String? id;
  String? invNumber;
  String? total;

  Order({this.id, this.invNumber, this.total});

  @override
  String toString() {
    return 'Order(id: $id, invNumber: $invNumber, total: $total)';
  }

  factory Order.fromMap(Map<String, dynamic> data) => Order(
        id: data['id'] as String?,
        invNumber: data['inv_number'] as String?,
        total: data['total'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'inv_number': invNumber,
        'total': total,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Order].
  factory Order.fromJson(String data) {
    return Order.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Order] to a JSON string.
  String toJson() => json.encode(toMap());
}
