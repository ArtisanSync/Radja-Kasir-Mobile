import 'package:flutter/material.dart';
import 'package:kasir/models/category_model.dart';
import 'package:kasir/services/product_services.dart';

class CategoryProvider extends ChangeNotifier {
  final ProductServices _productServices = ProductServices();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _isSubmitting = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSubmitting => _isSubmitting;
  bool get hasCategories => _categories.isNotEmpty;

  // Load categories from API
  Future<void> loadCategories() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _productServices.listCategory();
      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        _categories = data.map((json) => CategoryModel.fromJson(json)).toList();
        _sortCategories();
      } else {
        _setError(result['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      _setError('Network error occurred');
      debugPrint('Error loading categories: $e');
    }

    _setLoading(false);
  }

  // Create new category
  Future<bool> createCategory(String name) async {
    if (name.trim().isEmpty) {
      _setError('Category name cannot be empty');
      return false;
    }

    // Check for duplicate names
    if (_categories.any((category) =>
        category.name.toLowerCase() == name.trim().toLowerCase())) {
      _setError('Category with this name already exists');
      return false;
    }

    _setSubmitting(true);
    _setError(null);

    try {
      final result = await _productServices.storeCategory(name.trim());
      if (result['success'] == true) {
        // Add the new category to local list
        final newCategory = CategoryModel.fromJson(result['data']);
        _categories.add(newCategory);
        _sortCategories();
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to create category');
        return false;
      }
    } catch (e) {
      _setError('Network error occurred');
      debugPrint('Error creating category: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Update category
  Future<bool> updateCategory(String categoryId, String newName) async {
    if (newName.trim().isEmpty) {
      _setError('Category name cannot be empty');
      return false;
    }

    // Check for duplicate names (excluding current category)
    if (_categories.any((category) =>
        category.id != categoryId &&
        category.name.toLowerCase() == newName.trim().toLowerCase())) {
      _setError('Category with this name already exists');
      return false;
    }

    _setSubmitting(true);
    _setError(null);

    try {
      final result = await _productServices
          .updateCategory({'name': newName.trim()}, categoryId);

      if (result['success'] == true) {
        // Update local category
        final index = _categories.indexWhere((c) => c.id == categoryId);
        if (index != -1) {
          _categories[index] =
              _categories[index].copyWith(name: newName.trim());
          _sortCategories();
          notifyListeners();
        }
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to update category');
        return false;
      }
    } catch (e) {
      _setError('Network error occurred');
      debugPrint('Error updating category: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Delete category
  Future<bool> deleteCategory(String categoryId) async {
    _setSubmitting(true);
    _setError(null);

    try {
      final result = await _productServices.removeCategory(categoryId);
      if (result['success'] == true) {
        // Remove from local list
        _categories.removeWhere((category) => category.id == categoryId);
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to delete category');
        return false;
      }
    } catch (e) {
      _setError('Network error occurred');
      debugPrint('Error deleting category: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Get category by ID
  CategoryModel? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Search categories
  List<CategoryModel> searchCategories(String query) {
    if (query.isEmpty) return _categories;

    return _categories
        .where((category) =>
            category.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get categories with product count
  List<CategoryModel> getCategoriesWithProducts() {
    return _categories.where((category) => category.productCount > 0).toList();
  }

  // Get empty categories
  List<CategoryModel> getEmptyCategories() {
    return _categories.where((category) => category.productCount == 0).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _sortCategories() {
    _categories
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh categories
  Future<void> refresh() async {
    await loadCategories();
  }
}
