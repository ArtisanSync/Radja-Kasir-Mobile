import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/providers/store_providers.dart';
import 'package:kasir/services/product_services.dart';

final productServicesProvider = Provider<ProductServices>((ref) {
  return ProductServices();
});

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
  final String? _storeId;

  ProductNotifier(this._productServices, this._storeId)
      : super(const ProductState()) {
    if (_storeId != null) {
      loadProducts(refresh: true);
    }
  }

  Future<void> loadProducts({
    bool refresh = false,
    String? search,
    String? categoryId,
    bool? isFavorite,
    bool? lowStock,
  }) async {
    if (_storeId == null) {
      state = state.copyWith(isLoading: false, products: []);
      return;
    }
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
      final response = await _productServices.listProduct(
        storeId: _storeId!,
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
        
        final updatedProducts = (refresh || state.currentPage == 1)
            ? newProducts
            : [...state.products, ...newProducts];

        final pagination = data['pagination'] != null
            ? ProductPagination.fromJson(data['pagination'])
            : const ProductPagination(total: 0, page: 1, limit: 20, totalPages: 1);

        state = state.copyWith(
          products: updatedProducts,
          pagination: pagination,
          isLoading: false,
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Gagal memuat produk',
          isLoading: false,
          isLoadingMore: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error: $e',
        isLoading: false,
        isLoadingMore: false,
      );
    }
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
    if (_storeId == null) {
      state = state.copyWith(isLoading: false, error: "Toko aktif tidak ditemukan.");
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    final result = await _productServices.storeProduct(
      storeId: _storeId!,
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

    if (result['success'] == true) {
      await refresh();
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result['message'] ?? "Gagal membuat produk");
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
    state = state.copyWith(isLoading: true, error: null);
    final result = await _productServices.updateProduct(
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
    if (result['success'] == true) {
      await refresh();
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result['message'] ?? "Gagal memperbarui produk");
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _productServices.destroyProduct(id);
    if (result['success'] == true) {
      await refresh();
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result['message'] ?? "Gagal menghapus produk");
      return false;
    }
  }

  Future<bool> toggleFavorite(String id) async {
    final result = await _productServices.setFavorite(id);
    if (result['success'] == true) {
      await refresh();
      return true;
    } else {
      state = state.copyWith(error: result['message'] ?? "Gagal mengubah favorit");
      return false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (!state.canLoadMore || state.isLoadingMore) return;
    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadProducts();
  }

  Future<void> searchProducts(String query) async {
    await loadProducts(refresh: true, search: query);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }
}

// Provider utama
final productProvider =
    StateNotifierProvider.autoDispose<ProductNotifier, ProductState>((ref) {
  final activeStoreId = ref.watch(storeProvider.select((s) => s.currentStore?.id));
  final productServices = ref.watch(productServicesProvider);
  return ProductNotifier(productServices, activeStoreId);
});

// Units Provider
final unitsProvider = FutureProvider.autoDispose<List<UnitModel>>((ref) async {
  final productServices = ref.watch(productServicesProvider);
  final response = await productServices.getUnits();
  if (response['success'] == true && response['data'] != null) {
    final unitList = response['data'] as List;
    return unitList.map((json) => UnitModel.fromJson(json)).toList();
  } else {
    return [];
  }
});