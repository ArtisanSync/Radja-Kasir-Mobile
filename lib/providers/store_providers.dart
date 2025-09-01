import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/models/store_model.dart';
import 'package:kasir/services/store_services.dart';
import 'package:kasir/helpers/store.dart';

final storeServicesProvider = Provider<StoreServices>((ref) {
  return StoreServices();
});

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
}

class StoreNotifier extends StateNotifier<StoreState> {
  final StoreServices _storeServices;
  StoreNotifier(this._storeServices) : super(const StoreState());

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

  Future<Map<String, dynamic>> createFirstStore(Map<String, dynamic> storeData, XFile? logo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _storeServices.createFirstStore(storeData, logo);
      if (result['success'] == true) {
        await Store.saveStore(result['data']);
        await loadMyStores();
      } else {
        state = state.copyWith(error: result['message'] ?? 'Failed to create store', isLoading: false);
      }
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Network error occurred', isLoading: false);
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  Future<Map<String, dynamic>> createStore(Map<String, dynamic> storeData, XFile? logo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _storeServices.createStore(storeData, logo);
      if (result['success'] == true) {
        await loadMyStores();
      } else {
        state = state.copyWith(error: result['message'] ?? 'Failed to create store', isLoading: false);
      }
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Network error occurred', isLoading: false);
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  Future<Map<String, dynamic>> updateStore(String storeId, Map<String, dynamic> updateData, XFile? logo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _storeServices.updateStore(storeId, updateData, logo);
      if (result['success'] == true) {
        await loadMyStores();
      } else {
        state = state.copyWith(error: result['message'] ?? 'Failed to update store', isLoading: false);
      }
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Network error occurred', isLoading: false);
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  Future<Map<String, dynamic>> deleteStore(String storeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _storeServices.deleteStore(storeId);
      if (result['success'] == true) {
        final updatedStores = [...state.stores].where((store) => store.id != storeId).toList();
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
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final storeProvider = StateNotifierProvider<StoreNotifier, StoreState>((ref) {
  final storeServices = ref.watch(storeServicesProvider);
  return StoreNotifier(storeServices);
});