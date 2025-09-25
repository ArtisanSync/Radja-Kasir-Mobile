import 'dart:convert';

class MemberModel {
  final String id;
  final String role;
  final DateTime joinedAt;
  final User user;

  MemberModel({
    required this.id,
    required this.role,
    required this.joinedAt,
    required this.user,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      role: json['role'] ?? 'CASHIER',
      joinedAt: DateTime.parse(json['joinedAt']),
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }
}

class InvitationModel {
  final String id;
  final String invitedEmail;
  final String invitedName;
  final String role;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;

  InvitationModel({
    required this.id,
    required this.invitedEmail,
    required this.invitedName,
    required this.role,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'],
      invitedEmail: json['invitedEmail'],
      invitedName: json['invitedName'],
      role: json['role'],
      status: json['status'],
      expiresAt: DateTime.parse(json['expiresAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}