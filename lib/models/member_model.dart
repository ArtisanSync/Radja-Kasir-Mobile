import 'dart:convert';

Member memberFromJson(String str) => Member.fromJson(json.decode(str));

String memberToJson(Member data) => json.encode(data.toJson());

class Member {
  List<ListMember>? data;

  Member({
    this.data,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        data: json["data"] == null
            ? []
            : List<ListMember>.from(
                json["data"]!.map((x) => ListMember.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ListMember {
  int? id;
  String? name;
  String? email;
  List<String>? roles;

  ListMember({
    this.id,
    this.name,
    this.email,
    this.roles,
  });

  factory ListMember.fromJson(Map<String, dynamic> json) => ListMember(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        roles: json["roles"] == null
            ? []
            : List<String>.from(json["roles"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
      };
}
