import 'dart:convert';

DeptDetail deptDetailFromJson(String str) =>
    DeptDetail.fromJson(json.decode(str));

String deptDetailToJson(DeptDetail data) => json.encode(data.toJson());

class DeptDetail {
  String? id;
  String? customerName;
  String? phone;
  int? total;
  bool? paid;
  Order? order;
  List<OrderDetail>? orderDetails;

  DeptDetail({
    this.id,
    this.customerName,
    this.phone,
    this.total,
    this.paid,
    this.order,
    this.orderDetails,
  });

  factory DeptDetail.fromJson(Map<String, dynamic> json) => DeptDetail(
        id: json["id"],
        customerName: json["customer_name"],
        phone: json["phone"],
        total: json["total"],
        paid: json["paid"],
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
        orderDetails: json["order_details"] == null
            ? []
            : List<OrderDetail>.from(
                json["order_details"]!.map((x) => OrderDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_name": customerName,
        "phone": phone,
        "total": total,
        "paid": paid,
        "order": order?.toJson(),
        "order_details": orderDetails == null
            ? []
            : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
      };
}

class Order {
  String? id;
  String? invNumber;
  String? total;

  Order({
    this.id,
    this.invNumber,
    this.total,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        invNumber: json["inv_number"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "inv_number": invNumber,
        "total": total,
      };
}

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

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        id: json["id"],
        variantId: json["variant_id"],
        productName: json["product_name"],
        unitPrice: json["unit_price"],
        quantity: json["quantity"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "variant_id": variantId,
        "product_name": productName,
        "unit_price": unitPrice,
        "quantity": quantity,
        "total": total,
      };
}
