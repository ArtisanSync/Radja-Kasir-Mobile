import 'dart:convert';

HomeProduct homeProductFromJson(String str) =>
    HomeProduct.fromJson(json.decode(str));

String homeProductToJson(HomeProduct data) => json.encode(data.toJson());

class HomeProduct {
  String? status;
  dynamic message;
  List<ListProduct>? data;

  HomeProduct({
    this.status,
    this.message,
    this.data,
  });

  factory HomeProduct.fromJson(Map<String, dynamic> json) => HomeProduct(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<ListProduct>.from(
                json["data"]!.map((x) => ListProduct.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ListProduct {
  int? variantId;
  String? productName;
  int? capitalPrice;
  int? unitPrice;
  int? dicRp;
  int? dicPercent;
  int? quantity;
  String? category;
  int? categoryId;
  bool? isFavorite;
  String? image;

  ListProduct({
    this.variantId,
    this.productName,
    this.capitalPrice,
    this.unitPrice,
    this.quantity,
    this.dicRp,
    this.dicPercent,
    this.category,
    this.categoryId,
    this.isFavorite,
    this.image,
  });

  factory ListProduct.fromJson(Map<String, dynamic> json) => ListProduct(
        variantId: json["variant_id"],
        productName: json["product_name"],
        capitalPrice: json["capital_price"],
        unitPrice: json["unit_price"],
        quantity: json["quantity"],
        dicRp: json["dic_rp"],
        dicPercent: json["dic_percent"],
        category: json["category"],
        categoryId: json["category_id"],
        isFavorite: json["is_favorite"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "variant_id": variantId,
        "product_name": productName,
        "capital_price": capitalPrice,
        "unit_price": unitPrice,
        "quantity": quantity,
        "dic_rp": dicRp,
        "dic_percent": dicPercent,
        "category": category,
        "category_id": categoryId,
        "is_favorite": isFavorite,
        "image": image,
      };
}
