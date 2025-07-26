import 'dart:convert';

import 'order.dart';
import 'order_detail.dart';

class Dept {
  String? id;
  String? customerName;
  String? phone;
  int? total;
  bool? paid;
  Order? order;
  List<OrderDetail>? orderDetails;

  Dept({
    this.id,
    this.customerName,
    this.phone,
    this.total,
    this.paid,
    this.order,
    this.orderDetails,
  });

  @override
  String toString() {
    return 'Dept(id: $id, customerName: $customerName, phone: $phone, total: $total, paid: $paid, order: $order, orderDetails: $orderDetails)';
  }

  factory Dept.fromMap(Map<String, dynamic> data) => Dept(
        id: data['id'] as String?,
        customerName: data['customer_name'] as String?,
        phone: data['phone'] as String?,
        total: data['total'] as int?,
        paid: data['paid'] as bool?,
        order: data['order'] == null
            ? null
            : Order.fromMap(data['order'] as Map<String, dynamic>),
        orderDetails: (data['order_details'] as List<dynamic>?)
            ?.map((e) => OrderDetail.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'customer_name': customerName,
        'phone': phone,
        'total': total,
        'paid': paid,
        'order': order?.toMap(),
        'order_details': orderDetails?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Dept].
  factory Dept.fromJson(String data) {
    return Dept.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Dept] to a JSON string.
  String toJson() => json.encode(toMap());
}
