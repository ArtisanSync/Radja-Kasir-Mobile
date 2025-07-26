import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
  String? name;
  String? email;
  String? store;
  String? storeType;
  String? address;
  String? whatsapp;
  String? logo;
  String? stamp;

  Profile({
    this.name,
    this.email,
    this.store,
    this.storeType,
    this.address,
    this.whatsapp,
    this.logo,
    this.stamp,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        name: json["name"],
        email: json["email"],
        store: json["store"],
        storeType: json["store_type"],
        address: json["address"],
        whatsapp: json["whatsapp"],
        logo: json["logo"],
        stamp: json["stamp"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "store": store,
        "store_type": storeType,
        "address": address,
        "whatsapp": whatsapp,
        "logo": logo,
        "stamp": stamp,
      };
}
