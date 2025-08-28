class StoreModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? logo;
  final String? stamp;
  final String storeType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? counts;
  final Map<String, dynamic>? user;

  StoreModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.phone,
    this.whatsapp,
    this.email,
    this.logo,
    this.stamp,
    required this.storeType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.counts,
    this.user,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      email: json['email'],
      logo: json['logo'],
      stamp: json['stamp'],
      storeType: json['storeType'] ?? 'RETAIL',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt']) 
        : DateTime.now(),
      counts: json['_count'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'logo': logo,
      'stamp': stamp,
      'storeType': storeType,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}