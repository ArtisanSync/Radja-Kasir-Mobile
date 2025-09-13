import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/subscription_model.dart';
import 'package:kasir/services/subscription_services.dart';

// Subscription Services Provider
final subscriptionServicesProvider = Provider<SubscriptionServices>((ref) {
  return SubscriptionServices();
});

// Subscription State
class SubscriptionState {
  final List<SubscriptionPackage> packages;
  final UserSubscription? currentSubscription;
  final SubscriptionStatus? status;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.packages = const [],
    this.currentSubscription,
    this.status,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    List<SubscriptionPackage>? packages,
    UserSubscription? currentSubscription,
    SubscriptionStatus? status,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      packages: packages ?? this.packages,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasActiveSubscription => currentSubscription?.isActive ?? false;
  bool get isExpiring => currentSubscription?.isExpiring ?? false;
  String get currentPackageName =>
      currentSubscription?.package.displayName ?? 'No Package';
}

// Subscription Notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionServices _subscriptionServices;

  SubscriptionNotifier(this._subscriptionServices)
      : super(const SubscriptionState());

  // Load all packages
  Future<void> loadPackages() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _subscriptionServices.getPackages();

      if (result['success'] == true) {
        final Map<String, dynamic> dataMap = result['data'] ?? {};
        final List<dynamic> data = dataMap['allPackages'] ?? [];
        final packages =
            data.map((json) => SubscriptionPackage.fromJson(json)).toList();

        state = state.copyWith(packages: packages, isLoading: false);
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load packages',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Network error occurred: $e',
        isLoading: false,
      );
    }
  }

  // Load current subscription
  Future<void> loadMySubscription() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _subscriptionServices.getMySubscription();

      if (result['success'] == true && result['data'] != null) {
        final subscription = UserSubscription.fromJson(result['data']);
        state =
            state.copyWith(currentSubscription: subscription, isLoading: false);
      } else {
        state = state.copyWith(
          currentSubscription: null,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load subscription',
        isLoading: false,
      );
    }
  }

  // Check subscription status
  Future<void> checkStatus() async {
    try {
      final result = await _subscriptionServices.getSubscriptionStatus();

      if (result['success'] == true && result['data'] != null) {
        final status = SubscriptionStatus.fromJson(result['data']);
        state = state.copyWith(status: status);
      }
    } catch (e) {
      // Silent fail for status check
    }
  }

  // Load all subscription data
  Future<void> loadAll() async {
    // Load packages first (most important)
    await loadPackages();

    // Load other data separately so they don't affect packages loading
    try {
      await loadMySubscription();
    } catch (e) {
      // Don't let subscription loading error affect packages
    }

    try {
      await checkStatus();
    } catch (e) {
      // Don't let status check error affect packages
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Subscription Provider
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final subscriptionServices = ref.watch(subscriptionServicesProvider);
  return SubscriptionNotifier(subscriptionServices);
});
