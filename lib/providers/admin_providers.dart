import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/services/admin_services.dart';
import 'package:kasir/models/admin_models.dart';

final adminServicesProvider = Provider<AdminServices>((ref) {
  return AdminServices();
});

class AdminDashboardState {
  final AdminDashboardStats? stats;
  final bool isLoading;
  final String? error;

  const AdminDashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  AdminDashboardState copyWith({
    AdminDashboardStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return AdminDashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminDashboardNotifier extends StateNotifier<AdminDashboardState> {
  final AdminServices _adminServices;

  AdminDashboardNotifier(this._adminServices) : super(const AdminDashboardState());

  Future<void> loadDashboardStats() async {
    developer.log('Loading dashboard stats...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _adminServices.getDashboardStats();
      
      developer.log('Dashboard service result: $result');
      
      if (result['success'] == true && result['data'] != null) {
        try {
          final stats = AdminDashboardStats.fromJson(result['data']);
          developer.log('Successfully parsed dashboard stats');
          state = state.copyWith(stats: stats, isLoading: false, error: null);
        } catch (parseError) {
          developer.log('Error parsing dashboard stats: $parseError');
          state = state.copyWith(
            error: 'Failed to parse dashboard data: ${parseError.toString()}',
            isLoading: false,
          );
        }
      } else {
        final errorMessage = result['message'] ?? 'Failed to load dashboard';
        developer.log('Dashboard service returned error: $errorMessage');
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
      }
    } catch (e) {
      developer.log('Exception in loadDashboardStats: $e');
      state = state.copyWith(
        error: 'Network error: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    await loadDashboardStats();
  }
}

final adminDashboardProvider = StateNotifierProvider<AdminDashboardNotifier, AdminDashboardState>((ref) {
  final adminServices = ref.watch(adminServicesProvider);
  return AdminDashboardNotifier(adminServices);
});

class SubscribersState {
  final List<AdminSubscriber> subscribers;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? packageFilter;
  final bool expiringOnlyFilter;

  const SubscribersState({
    this.subscribers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.packageFilter,
    this.expiringOnlyFilter = false,
  });

  SubscribersState copyWith({
    List<AdminSubscriber>? subscribers,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? packageFilter,
    bool? expiringOnlyFilter,
  }) {
    return SubscribersState(
      subscribers: subscribers ?? this.subscribers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      packageFilter: packageFilter ?? this.packageFilter,
      expiringOnlyFilter: expiringOnlyFilter ?? this.expiringOnlyFilter,
    );
  }

  List<AdminSubscriber> get filteredSubscribers {
    var filtered = subscribers;
    
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((subscriber) =>
        subscriber.name.toLowerCase().contains(query) ||
        subscriber.email.toLowerCase().contains(query) ||
        (subscriber.businessName?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    if (expiringOnlyFilter) {
      filtered = filtered.where((subscriber) => subscriber.isExpiringSoon).toList();
    }
    
    return filtered;
  }
}

class SubscribersNotifier extends StateNotifier<SubscribersState> {
  final AdminServices _adminServices;

  SubscribersNotifier(this._adminServices) : super(const SubscribersState());

  Future<void> loadSubscribers() async {
    developer.log('Loading subscribers...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _adminServices.getAllSubscribers(
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        packageType: state.packageFilter,
        expiringOnly: state.expiringOnlyFilter ? true : null,
      );
      
      developer.log('Subscribers service result: $result');
      
      if (result['success'] == true) {
        try {
          final subscribersData = result['data'] as List? ?? [];
          final subscribers = subscribersData
              .map((json) => AdminSubscriber.fromJson(json))
              .toList();
          
          developer.log('Successfully parsed ${subscribers.length} subscribers');
          state = state.copyWith(subscribers: subscribers, isLoading: false, error: null);
        } catch (parseError) {
          developer.log('Error parsing subscribers: $parseError');
          state = state.copyWith(
            error: 'Failed to parse subscribers data: ${parseError.toString()}',
            isLoading: false,
          );
        }
      } else {
        final errorMessage = result['message'] ?? 'Failed to load subscribers';
        developer.log('Subscribers service returned error: $errorMessage');
        state = state.copyWith(
          error: errorMessage,
          isLoading: false,
        );
      }
    } catch (e) {
      developer.log('Exception in loadSubscribers: $e');
      state = state.copyWith(
        error: 'Network error: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<bool> extendUserSubscription(String userId, int additionalDays) async {
    try {
      final result = await _adminServices.extendUserSubscription(userId, additionalDays);
      
      if (result['success'] == true) {
        await loadSubscribers();
        return true;
      } else {
        state = state.copyWith(error: result['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to extend subscription: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final result = await _adminServices.deleteUserAccount(userId);
      
      if (result['success'] == true) {
        await loadSubscribers();
        return true;
      } else {
        state = state.copyWith(error: result['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete user: ${e.toString()}');
      return false;
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updatePackageFilter(String? packageType) {
    state = state.copyWith(packageFilter: packageType);
    loadSubscribers();
  }

  void updateExpiringFilter(bool expiringOnly) {
    state = state.copyWith(expiringOnlyFilter: expiringOnly);
    loadSubscribers();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final subscribersProvider = StateNotifierProvider<SubscribersNotifier, SubscribersState>((ref) {
  final adminServices = ref.watch(adminServicesProvider);
  return SubscribersNotifier(adminServices);
});
