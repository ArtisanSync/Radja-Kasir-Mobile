import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
  String? id;
  String? name;
  String? email;
  String? avatar;
  String? businessName;
  String? businessType;
  String? businessAddress;
  String? whatsapp;
  String? phone;
  String? storeLogo;
  bool? isActive;
  String? role;
  String? emailVerifiedAt;
  String? lastLoginAt;

  Profile({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.businessName,
    this.businessType,
    this.businessAddress,
    this.whatsapp,
    this.phone,
    this.storeLogo,
    this.isActive,
    this.role,
    this.emailVerifiedAt,
    this.lastLoginAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        avatar: json["avatar"],
        businessName: json["businessName"],
        businessType: json["businessType"],
        businessAddress: json["businessAddress"],
        whatsapp: json["whatsapp"],
        phone: json["phone"],
        storeLogo: json["storeLogo"],
        isActive: json["isActive"],
        role: json["role"],
        emailVerifiedAt: json["emailVerifiedAt"],
        lastLoginAt: json["lastLoginAt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "avatar": avatar,
        "businessName": businessName,
        "businessType": businessType,
        "businessAddress": businessAddress,
        "whatsapp": whatsapp,
        "phone": phone,
        "storeLogo": storeLogo,
        "isActive": isActive,
        "role": role,
        "emailVerifiedAt": emailVerifiedAt,
        "lastLoginAt": lastLoginAt,
      };
}