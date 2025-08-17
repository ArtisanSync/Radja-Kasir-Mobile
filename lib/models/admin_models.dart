import 'dart:developer' as developer;

class AdminDashboardStats {
  final AdminOverview overview;
  final AdminRevenue? revenue;
  final List<PackageDistribution> packageDistribution;
  final DateTime timestamp;

  AdminDashboardStats({
    required this.overview,
    this.revenue,
    required this.packageDistribution,
    required this.timestamp,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('Parsing AdminDashboardStats from: $json');
      
      final overview = AdminOverview.fromJson(json['overview'] ?? {});
      final revenue = json['revenue'] != null ? AdminRevenue.fromJson(json['revenue']) : null;
      
      final packageDistributionList = <PackageDistribution>[];
      if (json['packageDistribution'] is List) {
        for (var item in json['packageDistribution']) {
          packageDistributionList.add(PackageDistribution.fromJson(item));
        }
      }
      
      final timestampStr = json['timestamp'] ?? '';
      final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();
      
      developer.log('Successfully parsed AdminDashboardStats');
      
      return AdminDashboardStats(
        overview: overview,
        revenue: revenue,
        packageDistribution: packageDistributionList,
        timestamp: timestamp,
      );
    } catch (e) {
      developer.log('Error parsing AdminDashboardStats: $e');
      rethrow;
    }
  }
}

class AdminOverview {
  final int totalUsers;
  final int activeSubscriptions;
  final int expiredSubscriptions;
  final int totalStores;
  final int totalMembers;
  final int totalPayments;
  final int expiringSoon;

  AdminOverview({
    required this.totalUsers,
    required this.activeSubscriptions,
    required this.expiredSubscriptions,
    required this.totalStores,
    required this.totalMembers,
    required this.totalPayments,
    required this.expiringSoon,
  });

  factory AdminOverview.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('Parsing AdminOverview from: $json');
      
      return AdminOverview(
        totalUsers: _parseIntSafely(json['totalUsers']),
        activeSubscriptions: _parseIntSafely(json['activeSubscriptions']),
        expiredSubscriptions: _parseIntSafely(json['expiredSubscriptions']),
        totalStores: _parseIntSafely(json['totalStores']),
        totalMembers: _parseIntSafely(json['totalMembers']),
        totalPayments: _parseIntSafely(json['totalPayments']),
        expiringSoon: _parseIntSafely(json['expiringSoon']),
      );
    } catch (e) {
      developer.log('Error parsing AdminOverview: $e');
      rethrow;
    }
  }
}

class AdminRevenue {
  final double totalRevenue;
  final int totalTransactions;
  final double averageRevenue;

  AdminRevenue({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.averageRevenue,
  });

  factory AdminRevenue.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('Parsing AdminRevenue from: $json');
      
      return AdminRevenue(
        totalRevenue: _parseDoubleSafely(json['totalRevenue']),
        totalTransactions: _parseIntSafely(json['totalTransactions']),
        averageRevenue: _parseDoubleSafely(json['averageRevenue']),
      );
    } catch (e) {
      developer.log('Error parsing AdminRevenue: $e');
      rethrow;
    }
  }
}

class PackageDistribution {
  final String packageName;
  final String displayName;
  final int count;

  PackageDistribution({
    required this.packageName,
    required this.displayName,
    required this.count,
  });

  factory PackageDistribution.fromJson(Map<String, dynamic> json) {
    try {
      return PackageDistribution(
        packageName: json['packageName']?.toString() ?? '',
        displayName: json['displayName']?.toString() ?? '',
        count: _parseIntSafely(json['count']),
      );
    } catch (e) {
      developer.log('Error parsing PackageDistribution: $e');
      rethrow;
    }
  }
}

class AdminSubscriber {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? businessName;
  final String? businessType;
  final bool isActive;
  final AdminSubscription? currentSubscription;
  final int daysLeft;
  final bool isExpiringSoon;
  final int totalStores;
  final int totalMembers;
  final int totalProducts;
  final int successfulPayments;

  AdminSubscriber({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.businessName,
    this.businessType,
    required this.isActive,
    this.currentSubscription,
    required this.daysLeft,
    required this.isExpiringSoon,
    required this.totalStores,
    required this.totalMembers,
    required this.totalProducts,
    required this.successfulPayments,
  });

  factory AdminSubscriber.fromJson(Map<String, dynamic> json) {
    try {
      return AdminSubscriber(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        avatar: json['avatar']?.toString(),
        businessName: json['businessName']?.toString(),
        businessType: json['businessType']?.toString(),
        isActive: json['isActive'] == true,
        currentSubscription: json['currentSubscription'] != null
            ? AdminSubscription.fromJson(json['currentSubscription'])
            : null,
        daysLeft: _parseIntSafely(json['daysLeft']),
        isExpiringSoon: json['isExpiringSoon'] == true,
        totalStores: _parseIntSafely(json['totalStores']),
        totalMembers: _parseIntSafely(json['totalMembers']),
        totalProducts: _parseIntSafely(json['totalProducts']),
        successfulPayments: _parseIntSafely(json['successfulPayments']),
      );
    } catch (e) {
      developer.log('Error parsing AdminSubscriber: $e');
      rethrow;
    }
  }
}

class AdminSubscription {
  final String id;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final bool isTrial;
  final AdminPackage package;

  AdminSubscription({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.isTrial,
    required this.package,
  });

  factory AdminSubscription.fromJson(Map<String, dynamic> json) {
    try {
      return AdminSubscription(
        id: json['id']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
        isTrial: json['isTrial'] == true,
        package: AdminPackage.fromJson(json['package'] ?? {}),
      );
    } catch (e) {
      developer.log('Error parsing AdminSubscription: $e');
      rethrow;
    }
  }
}

class AdminPackage {
  final String id;
  final String name;
  final String displayName;
  final double price;
  final int maxUsers;
  final int maxMembers;
  final int maxStores;

  AdminPackage({
    required this.id,
    required this.name,
    required this.displayName,
    required this.price,
    required this.maxUsers,
    required this.maxMembers,
    required this.maxStores,
  });

  factory AdminPackage.fromJson(Map<String, dynamic> json) {
    try {
      return AdminPackage(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        displayName: json['displayName']?.toString() ?? '',
        price: _parseDoubleSafely(json['price']),
        maxUsers: _parseIntSafely(json['maxUsers']),
        maxMembers: _parseIntSafely(json['maxMembers']),
        maxStores: _parseIntSafely(json['maxStores']),
      );
    } catch (e) {
      developer.log('Error parsing AdminPackage: $e');
      rethrow;
    }
  }
}

// Helper functions for safe parsing
int _parseIntSafely(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDoubleSafely(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
