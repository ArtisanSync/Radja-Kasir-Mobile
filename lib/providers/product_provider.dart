import 'package:flutter/foundation.dart';
import 'package:kasir/models/modern_product_model.dart';
import 'package:kasir/services/modern_product_services.dart';

class ProductProvider extends ChangeNotifier {
  final ModernProductServices _productServices = ModernProductServices();

  // State variables
  List<ProductModel> _products = [];
  List<UnitModel> _units = [];
  ProductPagination? _pagination;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool? _showFavorites;
  bool? _showLowStock;
  int _currentPage = 1;

  // Getters
  List<ProductModel> get products => _products;
  List<UnitModel> get units => _units;
  ProductPagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  bool? get showFavorites => _showFavorites;
  bool? get showLowStock => _showLowStock;
  int get currentPage => _currentPage;

  // Helper getters
  bool get hasError => _error != null;
  bool get hasProducts => _products.isNotEmpty;
  bool get canLoadMore =>
      _pagination != null && _currentPage < _pagination!.totalPages;
  int get totalProducts => _pagination?.total ?? 0;
  List<ProductModel> get favoriteProducts =>
      _products.where((p) => p.isFavorite).toList();
  List<ProductModel> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();

  // Load products with optional filters
  Future<void> loadProducts({
    bool refresh = false,
    String? search,
    String? categoryId,
    bool? isFavorite,
    bool? lowStock,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _products.clear();
    }

    _isLoading = refresh || _currentPage == 1;
    _isLoadingMore = !refresh && _currentPage > 1;
    _error = null;

    // Update filters
    _searchQuery = search ?? _searchQuery;
    _selectedCategoryId = categoryId ?? _selectedCategoryId;
    _showFavorites = isFavorite ?? _showFavorites;
    _showLowStock = lowStock ?? _showLowStock;

    notifyListeners();

    try {
      final response = await _productServices.getProducts(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        categoryId: _selectedCategoryId,
        page: _currentPage,
        limit: 20,
        isFavorite: _showFavorites,
        lowStock: _showLowStock,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final productList = data['products'] as List;
        final newProducts =
            productList.map((json) => ProductModel.fromJson(json)).toList();

        if (refresh || _currentPage == 1) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }

        _pagination = ProductPagination.fromJson(data['pagination']);
      } else {
        _error = response['message'] ?? 'Failed to load products';
      }
    } catch (e) {
      _error = 'Error loading products: $e';
      debugPrint('Error in loadProducts: $e');
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (!canLoadMore || _isLoadingMore) return;

    _currentPage++;
    await loadProducts();
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String id) async {
    _error = null;
    notifyListeners();

    try {
      final response = await _productServices.getProductById(id);

      if (response['success'] == true && response['data'] != null) {
        return ProductModel.fromJson(response['data']);
      } else {
        _error = response['message'] ?? 'Product not found';
        return null;
      }
    } catch (e) {
      _error = 'Error loading product: $e';
      debugPrint('Error in getProductById: $e');
      return null;
    } finally {
      notifyListeners();
    }
  }

  // Create new product
  Future<bool> createProduct({
    required String name,
    String? code,
    String? brand,
    String? categoryId,
    String? image,
    required String unitId,
    required int quantity,
    required String capitalPrice,
    required String price,
    int tax = 0,
    String discountRp = '0',
    int discountPercent = 0,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final response = await _productServices.createProduct(
        name: name,
        code: code,
        brand: brand,
        categoryId: categoryId,
        image: image,
        unitId: unitId,
        quantity: quantity,
        capitalPrice: capitalPrice,
        price: price,
        tax: tax,
        discountRp: discountRp,
        discountPercent: discountPercent,
      );

      if (response['success'] == true) {
        // Refresh products list
        await loadProducts(refresh: true);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create product';
        return false;
      }
    } catch (e) {
      _error = 'Error creating product: $e';
      debugPrint('Error in createProduct: $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Update product
  Future<bool> updateProduct(
    String id, {
    String? name,
    String? code,
    String? brand,
    String? categoryId,
    String? image,
    bool? active,
    bool? isFavorite,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final response = await _productServices.updateProduct(
        id,
        name: name,
        code: code,
        brand: brand,
        categoryId: categoryId,
        image: image,
        active: active,
        isFavorite: isFavorite,
      );

      if (response['success'] == true) {
        // Update product in local list
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1 && response['data'] != null) {
          _products[index] = ProductModel.fromJson(response['data']);
          notifyListeners();
        }
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update product';
        return false;
      }
    } catch (e) {
      _error = 'Error updating product: $e';
      debugPrint('Error in updateProduct: $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    _error = null;
    notifyListeners();

    try {
      final response = await _productServices.deleteProduct(id);

      if (response['success'] == true) {
        // Remove product from local list
        _products.removeWhere((p) => p.id == id);
        // Update pagination
        if (_pagination != null) {
          _pagination = _pagination!.copyWith(
            total: _pagination!.total - 1,
          );
        }
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete product';
        return false;
      }
    } catch (e) {
      _error = 'Error deleting product: $e';
      debugPrint('Error in deleteProduct: $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String id) async {
    final product = _products.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Product not found'),
    );

    return await updateProduct(id, isFavorite: !product.isFavorite);
  }

  // Load units
  Future<void> loadUnits() async {
    _error = null;
    notifyListeners();

    try {
      final response = await _productServices.getUnits();

      if (response['success'] == true && response['data'] != null) {
        final unitList = response['data'] as List;
        _units = unitList.map((json) => UnitModel.fromJson(json)).toList();
      } else {
        _error = response['message'] ?? 'Failed to load units';
      }
    } catch (e) {
      _error = 'Error loading units: $e';
      debugPrint('Error in loadUnits: $e');
    }

    notifyListeners();
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await loadProducts(refresh: true, search: query);
  }

  // Filter by category
  Future<void> filterByCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;
    _currentPage = 1;
    await loadProducts(refresh: true, categoryId: categoryId);
  }

  // Filter favorites
  Future<void> filterFavorites(bool? showFavorites) async {
    _showFavorites = showFavorites;
    _currentPage = 1;
    await loadProducts(refresh: true, isFavorite: showFavorites);
  }

  // Filter low stock
  Future<void> filterLowStock(bool? showLowStock) async {
    _showLowStock = showLowStock;
    _currentPage = 1;
    await loadProducts(refresh: true, lowStock: showLowStock);
  }

  // Clear filters
  Future<void> clearFilters() async {
    _searchQuery = '';
    _selectedCategoryId = null;
    _showFavorites = null;
    _showLowStock = null;
    _currentPage = 1;
    await loadProducts(refresh: true);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh products
  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }
}

extension ProductPaginationExtension on ProductPagination {
  ProductPagination copyWith({
    int? total,
    int? page,
    int? limit,
    int? totalPages,
  }) {
    return ProductPagination(
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
