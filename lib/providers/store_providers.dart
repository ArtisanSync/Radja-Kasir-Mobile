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
      final localUser = await Store.getUser();
      if (localUser == null) {
        throw Exception("Sesi pengguna tidak ditemukan. Silakan login ulang.");
      }
      
      final userRole = localUser['role'] ?? 'USER';
      List<StoreModel> stores = [];
      StoreModel? activeStore;
      if (userRole == 'MEMBER') {
        final List<dynamic> memberStoresData = localUser['storeMembers'] ?? [];
        if (memberStoresData.isNotEmpty) {
          stores = memberStoresData
              .map((data) => StoreModel.fromJson(data['store']))
              .toList();
        }
      } else { // OWNER
        final List<dynamic> ownerStoresData = localUser['stores'] ?? [];
        if (ownerStoresData.isNotEmpty) {
          stores = ownerStoresData
              .map((data) => StoreModel.fromJson(data))
              .toList();
        }
      }
      if (stores.isEmpty && userRole != 'MEMBER') {
        final result = await _storeServices.getMyStores();
        if (result['success'] == true) {
          final List<dynamic> data = result['data'] ?? [];
          stores = data.map((json) => StoreModel.fromJson(json)).toList();
        }
      }
      if (stores.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final currentStoreJson = prefs.getString(_currentStoreKey);
        if (currentStoreJson != null) {
            final storeMap = jsonDecode(currentStoreJson);
            try {
                activeStore = stores.firstWhere((s) => s.id == storeMap['id']);
            } catch(e) {
                activeStore = null;
            }
        }
        if (activeStore == null) {
          activeStore = stores.first;
        }
        await _saveCurrentStoreToPrefs(activeStore);
      }
      
      state = state.copyWith(
        stores: stores,
        currentStore: activeStore,
        isLoading: false,
      );

    } catch (e) {
      state = state.copyWith(
          error: 'Gagal memuat data toko: ${e.toString()}', isLoading: false);
    }
  }
  
  Future<void> switchStore(StoreModel newStore) async {
    await _saveCurrentStoreToPrefs(newStore);
    state = state.copyWith(currentStore: newStore);
  }

  Future<void> _saveCurrentStoreToPrefs(StoreModel store) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentStoreKey, jsonEncode(store.toJson()));
    await Store.saveStore(store.toJson()); 
  }
  Future<void> loadStoreDetail(String storeId) async { /* ... */ }
  Future<Map<String, dynamic>> createFirstStore(Map<String, dynamic> storeData, XFile? logo) async { /* ... */ return {}; }
  Future<Map<String, dynamic>> createStore(Map<String, dynamic> storeData, XFile? logo) async { /* ... */ return {}; }
  Future<Map<String, dynamic>> updateStore(String storeId, Map<String, dynamic> updateData, XFile? logo) async { /* ... */ return {}; }
  Future<Map<String, dynamic>> deleteStore(String storeId) async { /* ... */ return {}; }
  void clearError() { state = state.copyWith(error: null); }
}

final storeProvider = StateNotifierProvider<StoreNotifier, StoreState>((ref) {
  final storeServices = ref.watch(storeServicesProvider);
  return StoreNotifier(storeServices);
});