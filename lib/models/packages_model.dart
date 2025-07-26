class UserSubsModel {
  final Subscibe? subscibe;
  final Package? package;

  UserSubsModel({this.subscibe, this.package});

  factory UserSubsModel.fromJson(Map<String, dynamic> json) {
    return UserSubsModel(
      subscibe:
          json['subscibe'] != null ? Subscibe.fromJson(json['subscibe']) : null,
      package:
          json['package'] != null ? Package.fromJson(json['package']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (subscibe != null) {
      data['subscibe'] = subscibe!.toJson();
    }
    if (package != null) {
      data['package'] = package!.toJson();
    }
    return data;
  }
}

class Subscibe {
  String? startDate;
  String? endDate;

  Subscibe({this.startDate, this.endDate});

  factory Subscibe.fromJson(Map<String, dynamic> json) {
    return Subscibe(
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    return data;
  }
}

class Package {
  String? name;
  Meta? meta;

  Package({this.name, this.meta});

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      name: json['name'] as String?,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class Meta {
  int? member;
  int? productLimit;
  bool? addableMember;
  bool? isLimitProduct;

  Meta({
    this.member,
    this.productLimit,
    this.addableMember,
    this.isLimitProduct,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      member: json['member'] as int?,
      productLimit: json['product_limit'] as int?,
      addableMember: json['addable_member'] as bool?,
      isLimitProduct: json['is_limit_product'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['member'] = member;
    data['product_limit'] = productLimit;
    data['addable_member'] = addableMember;
    data['is_limit_product'] = isLimitProduct;
    return data;
  }
}
