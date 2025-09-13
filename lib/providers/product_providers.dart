import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/services/product_services.dart';
import 'package:kasir/core/use_store.dart';

// Product Services Provider
final productServicesProvider = Provider<ProductServices>((ref) {
  return ProductServices();
});

// Product State Classes
class ProductState {
  final List<Product> products;
  final ProductPagination? pagination;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String searchQuery;
  final String? selectedCategoryId;
  final bool? showFavorites;
  final bool? showLowStock;
  final int currentPage;

  const ProductState({
    this.products = const [],
    this.pagination,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategoryId,
    this.showFavorites,
    this.showLowStock,
    this.currentPage = 1,
  });

  ProductState copyWith({
    List<Product>? products,
    ProductPagination? pagination,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? searchQuery,
    String? selectedCategoryId,
    bool? showFavorites,
    bool? showLowStock,
    int? currentPage,
  }) {
    return ProductState(
      products: products ?? this.products,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      showFavorites: showFavorites ?? this.showFavorites,
      showLowStock: showLowStock ?? this.showLowStock,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool get hasError => error != null;
  bool get hasProducts => products.isNotEmpty;
  bool get canLoadMore =>
      pagination != null && currentPage < pagination!.totalPages;
  int get totalProducts => pagination?.total ?? 0;
  List<Product> get favoriteProducts =>
      products.where((p) => p.isFavorite).toList();
  List<Product> get lowStockProducts =>
      products.where((p) => p.isLowStock).toList();
}

// Product Notifier
class ProductNotifier extends StateNotifier<ProductState> {
  final ProductServices _productServices;
  ProductNotifier(this._productServices) : super(const ProductState());

  Future<void> loadProducts({
    bool refresh = false,
    String? search,
    String? categoryId,
    bool? isFavorite,
    bool? lowStock,
  }) async {
    if (refresh) {
      state = state.copyWith(currentPage: 1, products: []);
    }
    state = state.copyWith(
      isLoading: refresh || state.currentPage == 1,
      isLoadingMore: !refresh && state.currentPage > 1,
      error: null,
      searchQuery: search ?? state.searchQuery,
      selectedCategoryId: categoryId ?? state.selectedCategoryId,
      showFavorites: isFavorite ?? state.showFavorites,
      showLowStock: lowStock ?? state.showLowStock,
    );
    try {
      final store = await Store.getStore();
      if (store == null || store['id'] == null) {
        state = state.copyWith(
          error: 'Store information not found. Please login again.',
          isLoading: false,
          isLoadingMore: false,
        );
        return;
      }
      final response = await _productServices.listProduct(
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        categoryId: state.selectedCategoryId,
        page: state.currentPage,
        limit: 20,
        isFavorite: state.showFavorites,
        lowStock: state.showLowStock,
      );
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final productList = (data['products'] ?? []) as List;
        final newProducts =
            productList.map((json) => Product.fromJson(json)).toList();

        List<Product> updatedProducts;
        if (refresh || state.currentPage == 1) {
          updatedProducts = newProducts;
        } else {
          updatedProducts = [...state.products, ...newProducts];
        }

        final pagination = data['pagination'] != null
            ? ProductPagination.fromJson(data['pagination'])
            : const ProductPagination(
                total: 0, page: 1, limit: 20, totalPages: 1);

        state = state.copyWith(
          products: updatedProducts,
          pagination: pagination,
          isLoading: false,
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Failed to load products',
          isLoading: false,
          isLoadingMore: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading products: $e',
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> loadMoreProducts() async {
    if (!state.canLoadMore || state.isLoadingMore) return;
    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadProducts();
  }

  Future<bool> createProduct({
    required String name,
    String? code,
    String? brand,
    String? categoryId,
    XFile? imageFile,
    required String unitId,
    required int quantity,
    required String capitalPrice,
    required String price,
    int tax = 0,
    String discountRp = '0',
    int discountPercent = 0,
  }) async {
    try {
      final response = await _productServices.storeProduct(
        name: name,
        code: code,
        brand: brand,
        categoryId: categoryId,
        imageFile: imageFile,
        unitId: unitId,
        quantity: quantity,
        capitalPrice: capitalPrice,
        price: price,
        tax: tax,
        discountRp: discountRp,
        discountPercent: discountPercent,
      );
      if (response['success'] == true) {
        await refresh();
        return true;
      } else {
        state = state.copyWith(error: response['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error creating product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(
    String id, {
    String? name,
    String? code,
    String? brand,
    String? categoryId,
    XFile? imageFile,
    bool? active,
    bool? isFavorite,
    String? unitId,
    int? quantity,
    String? capitalPrice,
    String? price,
    int? tax,
    String? discountRp,
    int? discountPercent,
  }) async {
    try {
      final response = await _productServices.updateProduct(
        id,
        name: name,
        code: code,
        brand: brand,
        categoryId: categoryId,
        imageFile: imageFile,
        active: active,
        isFavorite: isFavorite,
        unitId: unitId,
        quantity: quantity,
        capitalPrice: capitalPrice,
        price: price,
        tax: tax,
        discountRp: discountRp,
        discountPercent: discountPercent,
      );
      if (response['success'] == true) {
        final index = state.products.indexWhere((p) => p.id == id);
        if (index != -1 && response['data'] != null) {
          final updatedProduct = Product.fromJson(response['data']);
          final updatedProducts = [...state.products];
          updatedProducts[index] = updatedProduct;

          state = state.copyWith(products: updatedProducts);
        }
        return true;
      } else {
        state = state.copyWith(error: response['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final response = await _productServices.destroyProduct(id);
      if (response['success'] == true) {
        final updatedProducts = state.products.where((p) => p.id != id).toList();

        state = state.copyWith(
          products: updatedProducts,
          pagination: state.pagination?.copyWith(
            total: state.pagination!.total - 1,
          ),
        );

        return true;
      } else {
        state = state.copyWith(error: response['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error deleting product: $e');
      return false;
    }
  }

  Future<bool> toggleFavorite(String id) async {
    try {
      final response = await _productServices.setFavorite(id);
      if (response['success'] == true) {
        final index = state.products.indexWhere((p) => p.id == id);
        if (index != -1 && response['data'] != null) {
          final updatedProduct = Product.fromJson(response['data']);
          final updatedProducts = [...state.products];
          updatedProducts[index] = updatedProduct;

          state = state.copyWith(products: updatedProducts);
        }
        return true;
      } else {
        state = state.copyWith(error: response['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error toggling favorite: $e');
      return false;
    }
  }

  Future<void> searchProducts(String query) async {
    state = state.copyWith(searchQuery: query, currentPage: 1);
    await loadProducts(refresh: true, search: query);
  }

  Future<void> filterByCategory(String? categoryId) async {
    state = state.copyWith(selectedCategoryId: categoryId, currentPage: 1);
    await loadProducts(refresh: true, categoryId: categoryId);
  }

  Future<void> filterFavorites(bool? showFavorites) async {
    state = state.copyWith(showFavorites: showFavorites, currentPage: 1);
    await loadProducts(refresh: true, isFavorite: showFavorites);
  }

  Future<void> filterLowStock(bool? showLowStock) async {
    state = state.copyWith(showLowStock: showLowStock, currentPage: 1);
    await loadProducts(refresh: true, lowStock: showLowStock);
  }

  Future<void> clearFilters() async {
    state = const ProductState();
    await loadProducts(refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }
}

// Product Provider
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final productServices = ref.watch(productServicesProvider);
  return ProductNotifier(productServices);
});

// Units Provider
final unitsProvider = FutureProvider<List<UnitModel>>((ref) async {
  final productServices = ref.watch(productServicesProvider);
  final response = await productServices.getUnits();

  if (response['success'] == true && response['data'] != null) {
    final unitList = response['data'] as List;
    return unitList.map((json) => UnitModel.fromJson(json)).toList();
  } else {
    return [];
  }
});