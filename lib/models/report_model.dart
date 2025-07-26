import 'dart:convert';

Report reportFromJson(String str) => Report.fromJson(json.decode(str));

String reportToJson(Report data) => json.encode(data.toJson());

class Report {
  Data? data;

  Report({
    this.data,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class Data {
  Recap? recap;
  List<ListOrder>? list;

  Data({
    this.recap,
    this.list,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        recap: json["recap"] == null ? null : Recap.fromJson(json["recap"]),
        list: json["list"] == null
            ? []
            : List<ListOrder>.from(
                json["list"]!.map((x) => ListOrder.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "recap": recap?.toJson(),
        "list": list == null
            ? []
            : List<dynamic>.from(list!.map((x) => x.toJson())),
      };
}

class ListOrder {
  String? id;
  String? invNumber;
  String? paymentType;
  int? total;
  String? status;

  ListOrder({
    this.id,
    this.invNumber,
    this.paymentType,
    this.total,
    this.status,
  });

  factory ListOrder.fromJson(Map<String, dynamic> json) => ListOrder(
        id: json["id"],
        invNumber: json["inv_number"],
        paymentType: json["payment_type"],
        total: json["total"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "inv_number": invNumber,
        "payment_type": paymentType,
        "total": total,
        "status": status,
      };
}

class Recap {
  int? totalOrder;
  int? total;
  int? paid;
  int? draft;
  int? product;

  Recap({
    this.totalOrder,
    this.total,
    this.paid,
    this.draft,
    this.product,
  });

  factory Recap.fromJson(Map<String, dynamic> json) => Recap(
        totalOrder: json["total_order"],
        total: json["total"],
        paid: json["paid"],
        draft: json["draft"],
        product: json["product"],
      );

  Map<String, dynamic> toJson() => {
        "total_order": totalOrder,
        "total": total,
        "paid": paid,
        "draft": draft,
        "product": product,
      };
}
