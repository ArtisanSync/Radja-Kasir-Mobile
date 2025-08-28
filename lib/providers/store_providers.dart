import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/store_model.dart';
import 'package:kasir/services/store_services.dart';

// Store Services Provider
final storeServicesProvider = Provider<StoreServices>((ref) {
  return StoreServices();
});

// Store State
class StoreState {
  final List<StoreModel> stores;
  final StoreModel? currentStore;
  final bool isLoading;
  final String? error;

  const StoreState({
    this.stores = const [],
    this.currentStore,
    this.isLoading = false,
    this.error,
  });

  StoreState copyWith({
    List<StoreModel>? stores,
    StoreModel? currentStore,
    bool? isLoading,
    String? error,
  }) {
    return StoreState(
      stores: stores ?? this.stores,
      currentStore: currentStore ?? this.currentStore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasStores => stores.isNotEmpty;
}

// Store Notifier
class StoreNotifier extends StateNotifier<StoreState> {
  final StoreServices _storeServices;

  StoreNotifier(this._storeServices) : super(const StoreState());

  // Load my stores
  Future<void> loadMyStores() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _storeServices.getMyStores();

      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        final stores = data.map((json) => StoreModel.fromJson(json)).toList();

        state = state.copyWith(stores: stores, isLoading: false);
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load stores',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Network error occurred',
        isLoading: false,
      );
    }
  }

  // Load store detail
  Future<void> loadStoreDetail(String storeId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _storeServices.getStoreDetail(storeId);

      if (result['success'] == true && result['data'] != null) {
        final store = StoreModel.fromJson(result['data']);
        state = state.copyWith(currentStore: store, isLoading: false);
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load store details',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load store details: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Create first store
  Future<Map<String, dynamic>> createFirstStore(
      Map<String, dynamic> storeData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _storeServices.createFirstStore(storeData);

      if (result['success'] == true) {
        await loadMyStores();
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to create store',
          isLoading: false,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        error: 'Network error occurred',
        isLoading: false,
      );

      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  // Create additional store
  Future<Map<String, dynamic>> createStore(
      Map<String, dynamic> storeData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _storeServices.createStore(storeData);

      if (result['success'] == true) {
        await loadMyStores();
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to create store',
          isLoading: false,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        error: 'Network error occurred',
        isLoading: false,
      );

      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  // Update store
  Future<Map<String, dynamic>> updateStore(
      String storeId, Map<String, dynamic> updateData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _storeServices.updateStore(storeId, updateData);

      if (result['success'] == true) {
        if (state.currentStore?.id == storeId) {
          final updatedStore = StoreModel.fromJson(result['data']);
          state = state.copyWith(currentStore: updatedStore);
        }

        // Reload stores to reflect changes
        await loadMyStores();
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to update store',
          isLoading: false,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        error: 'Network error occurred',
        isLoading: false,
      );

      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  // Delete store
  Future<Map<String, dynamic>> deleteStore(String storeId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _storeServices.deleteStore(storeId);

      if (result['success'] == true) {
        final updatedStores =
            [...state.stores].where((store) => store.id != storeId).toList();

        state = state.copyWith(stores: updatedStores, isLoading: false);

        if (state.currentStore?.id == storeId) {
          state = state.copyWith(currentStore: null);
        }
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to delete store',
          isLoading: false,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        error: 'Network error occurred',
        isLoading: false,
      );

      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Store Provider
final storeProvider = StateNotifierProvider<StoreNotifier, StoreState>((ref) {
  final storeServices = ref.watch(storeServicesProvider);
  return StoreNotifier(storeServices);
});
