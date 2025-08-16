import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/services/product_services.dart';

// Product Services Provider - DEFINISI INI YANG HILANG!
final productServicesProvider = Provider<ProductServices>((ref) {
  return ProductServices();
});

// Category State
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

// Category Notifier
class CategoryNotifier extends StateNotifier<CategoryState> {
  final ProductServices _productServices;

  CategoryNotifier(this._productServices) : super(const CategoryState());

  // Load categories from API
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _productServices.listCategory();
      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        final categories = data.map((json) => CategoryModel.fromJson(json)).toList();
        categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        
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
    if (name.trim().isEmpty) {
      state = state.copyWith(error: 'Category name cannot be empty');
      return false;
    }

    // Check for duplicate names
    if (state.categories.any((category) =>
        category.name.toLowerCase() == name.trim().toLowerCase())) {
      state = state.copyWith(error: 'Category with this name already exists');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final result = await _productServices.storeCategory(name.trim());
      if (result['success'] == true) {
        // Add the new category to local list
        final newCategory = CategoryModel.fromJson(result['data']);
        final categories = [...state.categories, newCategory];
        categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        
        state = state.copyWith(
          categories: categories,
          isSubmitting: false,
        );
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

  // Update category
  Future<bool> updateCategory(String categoryId, String newName) async {
    if (newName.trim().isEmpty) {
      state = state.copyWith(error: 'Category name cannot be empty');
      return false;
    }

    // Check for duplicate names (excluding current category)
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
        // Update local category
        final index = state.categories.indexWhere((c) => c.id == categoryId);
        if (index != -1) {
          final categories = [...state.categories];
          categories[index] = categories[index].copyWith(name: newName.trim());
          categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          
          state = state.copyWith(categories: categories, isSubmitting: false);
        }
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

  // Delete category
  Future<bool> deleteCategory(String categoryId) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final result = await _productServices.removeCategory(categoryId);
      if (result['success'] == true) {
        // Remove from local list
        final categories = state.categories.where((category) => category.id != categoryId).toList();
        state = state.copyWith(categories: categories, isSubmitting: false);
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

  // Get category by ID
  CategoryModel? getCategoryById(String categoryId) {
    try {
      return state.categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Search categories
  List<CategoryModel> searchCategories(String query) {
    if (query.isEmpty) return state.categories;

    return state.categories
        .where((category) =>
            category.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get categories with product count
  List<CategoryModel> getCategoriesWithProducts() {
    return state.categories.where((category) => category.productCount > 0).toList();
  }

  // Get empty categories
  List<CategoryModel> getEmptyCategories() {
    return state.categories.where((category) => category.productCount == 0).toList();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh categories
  Future<void> refresh() async {
    await loadCategories();
  }
}

// Category Provider
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final productServices = ref.watch(productServicesProvider);
  return CategoryNotifier(productServices);
});
