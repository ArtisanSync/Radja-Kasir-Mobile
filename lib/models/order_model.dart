import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  String status;
  int message;
  List<Datum> data;

  Order({
    required this.status,
    required this.message,
    required this.data,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String id;
  String invNumber;
  dynamic customer;
  String paymentType;
  String total;
  String status;
  String created;

  Datum({
    required this.id,
    required this.invNumber,
    required this.customer,
    required this.paymentType,
    required this.total,
    required this.status,
    required this.created,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        invNumber: json["inv_number"],
        customer: json["customer"],
        paymentType: json["payment_type"],
        total: json["total"],
        status: json["status"],
        created: json["created"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "inv_number": invNumber,
        "customer": customer,
        "payment_type": paymentType,
        "total": total,
        "status": status,
        "created": created,
      };
}
