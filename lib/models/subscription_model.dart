class SubscriptionPackage {
  final String id;
  final String name;
  final String displayName;
  final double price;
  final int maxUsers;
  final int maxMembers;
  final int maxStores;
  final Map<String, dynamic>? features;
  final bool isActive;

  SubscriptionPackage({
    required this.id,
    required this.name,
    required this.displayName,
    required this.price,
    required this.maxUsers,
    required this.maxMembers,
    required this.maxStores,
    this.features,
    required this.isActive,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      maxUsers: json['maxUsers'] ?? 1,
      maxMembers: json['maxMembers'] ?? 3,
      maxStores: json['maxStores'] ?? 1,
      features: json['features'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'price': price,
      'maxUsers': maxUsers,
      'maxMembers': maxMembers,
      'maxStores': maxStores,
      'features': features,
      'isActive': isActive,
    };
  }
}

class UserSubscription {
  final String id;
  final String userId;
  final String packageId;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final bool isTrial;
  final bool autoRenew;
  final bool isNewUserPromo;
  final int paidMonths;
  final int bonusMonths;
  final int totalMonths;
  final SubscriptionPackage package;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.isTrial,
    required this.autoRenew,
    required this.isNewUserPromo,
    required this.paidMonths,
    required this.bonusMonths,
    required this.totalMonths,
    required this.package,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      packageId: json['packageId'] ?? '',
      status: json['status'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      isTrial: json['isTrial'] ?? false,
      autoRenew: json['autoRenew'] ?? false,
      isNewUserPromo: json['isNewUserPromo'] ?? false,
      paidMonths: json['paidMonths'] ?? 1,
      bonusMonths: json['bonusMonths'] ?? 0,
      totalMonths: json['totalMonths'] ?? 1,
      package: SubscriptionPackage.fromJson(json['package'] ?? {}),
    );
  }

  int get daysLeft {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  bool get isExpiring => daysLeft <= 7 && daysLeft > 0;
  bool get isExpired => daysLeft <= 0;
  bool get isActive => status == 'ACTIVE' || status == 'TRIAL';
}

class SubscriptionStatus {
  final bool isActive;
  final String status;
  final UserSubscription? subscription;
  final int? daysLeft;
  final bool isExpiring;
  final bool hasAccess;
  final Map<String, dynamic>? accessDetails;

  SubscriptionStatus({
    required this.isActive,
    required this.status,
    this.subscription,
    this.daysLeft,
    required this.isExpiring,
    required this.hasAccess,
    this.accessDetails,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isActive: json['isActive'] ?? false,
      status: json['status'] ?? 'NO_SUBSCRIPTION',
      subscription: json['subscription'] != null 
          ? UserSubscription.fromJson(json['subscription']) 
          : null,
      daysLeft: json['daysLeft'],
      isExpiring: json['isExpiring'] ?? false,
      hasAccess: json['hasAccess'] ?? false,
      accessDetails: json['accessDetails'],
    );
  }
}