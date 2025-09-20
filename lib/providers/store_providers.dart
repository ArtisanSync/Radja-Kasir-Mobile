import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/models/store_model.dart';
import 'package:kasir/services/store_services.dart';
import 'package:kasir/helpers/store.dart';
import 'package:shared_preferences/shared_preferences.dart';
const String _currentStoreKey = 'current_active_store';

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

        final prefs = await SharedPreferences.getInstance();
        final currentStoreJson = prefs.getString(_currentStoreKey);
        StoreModel? activeStore;
        if (currentStoreJson != null) {
          final storeMap = jsonDecode(currentStoreJson);
          try {
            activeStore = stores.firstWhere((s) => s.id == storeMap['id']);
          } catch (e) {
            activeStore = null;
          }
        }
        if (activeStore == null && stores.isNotEmpty) {
          activeStore = stores.first;
        }
        if (activeStore != null) {
          await _saveCurrentStoreToPrefs(activeStore);
        }

        state = state.copyWith(
          stores: stores,
          currentStore: activeStore,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
            error: result['message'] ?? 'Gagal memuat toko', isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
          error: 'Terjadi kesalahan: ${e.toString()}', isLoading: false);
    }
  }

  Future<void> switchStore(StoreModel newStore) async {
    await _saveCurrentStoreToPrefs(newStore);
    state = state.copyWith(currentStore: newStore);
  }

  // Helper untuk menyimpan data toko aktif ke SharedPreferences
  Future<void> _saveCurrentStoreToPrefs(StoreModel store) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentStoreKey, jsonEncode(store.toJson()));
    await Store.saveStore(store.toJson()); 
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
            error: result['message'] ?? 'Gagal memuat detail toko', isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
          error: 'Gagal memuat detail toko: ${e.toString()}', isLoading: false);
    }
  }

  Future<Map<String, dynamic>> createFirstStore(Map<String, dynamic> storeData, XFile? logo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _storeServices.createFirstStore(storeData, logo);
      if (result['success'] == true) {
        await loadMyStores();
      } else {
        state = state.copyWith(error: result['message'] ?? 'Gagal membuat toko', isLoading: false);
      }
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Terjadi kesalahan jaringan', isLoading: false);
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  Future<Map<String, dynamic>> createStore(Map<String, dynamic> storeData, XFile? logo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _storeServices.createStore(storeData, logo);
      if (result['success'] == true) {
        await loadMyStores();
      } else {
        state = state.copyWith(error: result['message'] ?? 'Gagal membuat toko', isLoading: false);
      }
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Terjadi kesalahan jaringan', isLoading: false);
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  Future<Map<String, dynamic>> updateStore(String storeId, Map<String, dynamic> updateData, XFile? logo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _storeServices.updateStore(storeId, updateData, logo);
      if (result['success'] == true) {
        await loadMyStores();
      } else {
        state = state.copyWith(error: result['message'] ?? 'Gagal memperbarui toko', isLoading: false);
      }
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Terjadi kesalahan jaringan', isLoading: false);
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  Future<Map<String, dynamic>> deleteStore(String storeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _storeServices.deleteStore(storeId);
      if (result['success'] == true) {
        await loadMyStores();
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Gagal menghapus toko',
          isLoading: false,
        );
      }
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Terjadi kesalahan jaringan', isLoading: false);
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
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