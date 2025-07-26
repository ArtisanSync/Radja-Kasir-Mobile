import 'dart:convert';

DeptModel deptModelFromJson(String str) => DeptModel.fromJson(json.decode(str));

String deptModelToJson(DeptModel data) => json.encode(data.toJson());

class DeptModel {
  List<Datum>? data;

  DeptModel({
    this.data,
  });

  factory DeptModel.fromJson(Map<String, dynamic> json) => DeptModel(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? id;
  int? customerId;
  String? customerName;
  String? phone;
  int? total;
  bool? paid;
  String? created;

  Datum(
      {this.id,
      this.customerId,
      this.customerName,
      this.phone,
      this.total,
      this.paid,
      this.created});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        customerId: json["customer_id"],
        customerName: json["customer_name"],
        phone: json["phone"],
        total: json["total"],
        paid: json["paid"],
        created: json["created"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "customer_name": customerName,
        "phone": phone,
        "total": total,
        "paid": paid,
        "created": created,
      };
}
