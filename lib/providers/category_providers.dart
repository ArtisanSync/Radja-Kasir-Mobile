import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/providers/store_providers.dart';
import 'package:kasir/services/product_services.dart';

final productServicesProvider = Provider<ProductServices>((ref) {
  return ProductServices();
});

class CategoryState {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  bool get hasCategories => categories.isNotEmpty;
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final ProductServices _productServices;
  final String? _storeId;

  CategoryNotifier(this._productServices, this._storeId)
      : super(const CategoryState()) {
    if (_storeId != null) {
      loadCategories();
    }
  }
  Future<void> loadCategories() async {
    if (_storeId == null) {
      state = state.copyWith(isLoading: false, categories: []);
      return;
    }
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _productServices.listCategory(storeId: _storeId!);
      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        final categories =
            data.map((json) => CategoryModel.fromJson(json)).toList();
        categories
            .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        state = state.copyWith(categories: categories, isLoading: false);
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load categories',
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

  // Create new category
  Future<bool> createCategory(String name) async {
    if (_storeId == null) {
      state = state.copyWith(error: 'Toko aktif tidak ditemukan', isSubmitting: false);
      return false;
    }

    if (name.trim().isEmpty) {
      state = state.copyWith(error: 'Nama kategori tidak boleh kosong');
      return false;
    }

    if (state.categories.any((category) =>
        category.name.toLowerCase() == name.trim().toLowerCase())) {
      state = state.copyWith(error: 'Kategori dengan nama ini sudah ada');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final result = await _productServices.storeCategory(storeId: _storeId!, name: name.trim());
      if (result['success'] == true) {
        await refresh();
        state = state.copyWith(isSubmitting: false);
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to create category',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Network error occurred',
        isSubmitting: false,
      );
      return false;
    }
  }

  // Sisa fungsi tidak berubah (update, delete, etc.)
  Future<bool> updateCategory(String categoryId, String newName) async {
    if (newName.trim().isEmpty) {
      state = state.copyWith(error: 'Category name cannot be empty');
      return false;
    }

    if (state.categories.any((category) =>
        category.id != categoryId &&
        category.name.toLowerCase() == newName.trim().toLowerCase())) {
      state = state.copyWith(error: 'Category with this name already exists');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final result = await _productServices.updateCategory(
          {'name': newName.trim()}, categoryId);

      if (result['success'] == true) {
        await refresh();
        state = state.copyWith(isSubmitting: false);
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to update category',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Network error occurred',
        isSubmitting: false,
      );
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final result = await _productServices.removeCategory(categoryId);
      if (result['success'] == true) {
        await refresh();
        state = state.copyWith(isSubmitting: false);
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to delete category',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Network error occurred',
        isSubmitting: false,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await loadCategories();
  }
}

final categoryProvider =
    StateNotifierProvider.autoDispose<CategoryNotifier, CategoryState>((ref) {
  final activeStoreId = ref.watch(storeProvider.select((s) => s.currentStore?.id));
  final productServices = ref.watch(productServicesProvider);
  return CategoryNotifier(productServices, activeStoreId);
});