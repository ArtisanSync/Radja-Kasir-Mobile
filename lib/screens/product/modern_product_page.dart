import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kasir/providers/product_provider.dart';
import 'package:kasir/providers/category_provider.dart';
import 'package:kasir/models/modern_product_model.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/screens/product_information/product_information.dart';
import 'package:kasir/screens/product/modern_form_product.dart';
import 'package:kasir/screens/product/modern_product_detail.dart';
import 'package:kasir/services/store_services.dart';
import 'package:kasir/core/use_store.dart';

class ModernProductPage extends StatefulWidget {
  const ModernProductPage({super.key});

  @override
  State<ModernProductPage> createState() => _ModernProductPageState();
}

class _ModernProductPageState extends State<ModernProductPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final StoreServices _storeServices = StoreServices();

  String _selectedFilter = 'all'; // all, favorites, low_stock

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() async {
    // Check if store data exists, if not initialize it
    final store = await Store.getStore();
    if (store == null || store['id'] == null) {
      await _storeServices.initializeStore();
    }

    // Load products and units
    if (mounted) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.loadProducts(refresh: true);
      provider.loadUnits();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (provider.canLoadMore && !provider.isLoadingMore) {
        provider.loadMoreProducts();
      }
    }
  }

  void _onSearch(String query) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.searchProducts(query);
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    final provider = Provider.of<ProductProvider>(context, listen: false);
    switch (filter) {
      case 'favorites':
        provider.filterFavorites(true);
        break;
      case 'low_stock':
        provider.filterLowStock(true);
        break;
      default:
        provider.clearFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Produk",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: const MenuBuilder(),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductInformationPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.category_rounded,
              color: AppColor.primary,
            ),
          ),
          IconButton(
            onPressed: () {
              final provider =
                  Provider.of<ProductProvider>(context, listen: false);
              provider.refresh();
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColor.primary,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: const InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon:
                          Icon(Icons.search_rounded, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              // Filter Chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('all', 'Semua', Icons.grid_view_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        'favorites', 'Favorit', Icons.favorite_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        'low_stock', 'Stok Rendah', Icons.warning_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasProducts) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColor.primary,
              ),
            );
          }

          if (provider.hasError && !provider.hasProducts) {
            return _buildErrorWidget(provider.error!, provider);
          }

          if (!provider.hasProducts) {
            return _buildEmptyWidget();
          }

          return Column(
            children: [
              // Stats Card
              _buildStatsCard(provider),
              // Products List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refresh,
                  color: AppColor.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.products.length +
                        (provider.canLoadMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.products.length) {
                        return _buildLoadingMoreWidget();
                      }

                      return _buildProductCard(
                        provider.products[index],
                        provider,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                      create: (context) => ProductProvider()),
                  ChangeNotifierProvider(
                      create: (context) => CategoryProvider()),
                ],
                child: const ModernFormProduct(),
              ),
            ),
          );

          if (result == true) {
            final provider =
                Provider.of<ProductProvider>(context, listen: false);
            provider.refresh();
          }
        },
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Produk'),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColor.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColor.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selectedColor: AppColor.primary,
      backgroundColor: Colors.white,
      elevation: 0,
      pressElevation: 0,
      side: BorderSide(
        color: isSelected ? AppColor.primary : Colors.grey[300]!,
        width: 1,
      ),
      onSelected: (selected) {
        if (selected) _onFilterChanged(value);
      },
    );
  }

  Widget _buildStatsCard(ProductProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Produk',
              provider.totalProducts.toString(),
              Icons.inventory_2_rounded,
              Colors.blue,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[200],
          ),
          Expanded(
            child: _buildStatItem(
              'Favorit',
              provider.favoriteProducts.length.toString(),
              Icons.favorite_rounded,
              Colors.red,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[200],
          ),
          Expanded(
            child: _buildStatItem(
              'Stok Rendah',
              provider.lowStockProducts.length.toString(),
              Icons.warning_rounded,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, ProductProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModernProductDetail(productId: product.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported_rounded,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.grey,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Product Details
                    Row(
                      children: [
                        if (product.code != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.code!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (product.brand != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.brand!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Stock and Price
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_rounded,
                          size: 14,
                          color: product.isLowStock ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stok: ${product.totalQuantity} ${product.displayUnit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.isLowStock
                                ? Colors.red
                                : Colors.grey[600],
                            fontWeight:
                                product.isLowStock ? FontWeight.w500 : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.attach_money_rounded,
                          size: 14,
                          color: Colors.grey,
                        ),
                        Text(
                          'Rp ${product.displayPrice}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Column(
                children: [
                  // Favorite Button
                  IconButton(
                    onPressed: () {
                      provider.toggleFavorite(product.id);
                    },
                    icon: Icon(
                      product.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: product.isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  // More Actions Button
                  IconButton(
                    onPressed: () {
                      _showProductOptions(context, product, provider);
                    },
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColor.primary,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, ProductProvider provider) {
    final isStoreError = error.contains('Store information not found');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isStoreError
                  ? Icons.warning_rounded
                  : Icons.error_outline_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isStoreError ? 'Terjadi Kesalahan' : 'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                if (isStoreError) {
                  // Re-initialize store and then refresh
                  await _storeServices.initializeStore();
                }
                provider.refresh();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(isStoreError ? 'Coba Lagi' : 'Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Produk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan produk pertama Anda untuk mulai berjualan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                            create: (context) => ProductProvider()),
                        ChangeNotifierProvider(
                            create: (context) => CategoryProvider()),
                      ],
                      child: const ModernFormProduct(),
                    ),
                  ),
                );

                if (result == true) {
                  final provider =
                      Provider.of<ProductProvider>(context, listen: false);
                  provider.refresh();
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Produk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductOptions(
      BuildContext context, ProductModel product, ProductProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    _buildOptionTile(
                      icon: Icons.visibility_rounded,
                      title: 'Lihat Detail',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ModernProductDetail(productId: product.id),
                          ),
                        );
                      },
                    ),
                    _buildOptionTile(
                      icon: Icons.edit_rounded,
                      title: 'Edit Produk',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider(
                                    create: (context) => ProductProvider()),
                                ChangeNotifierProvider(
                                    create: (context) => CategoryProvider()),
                              ],
                              child: ModernFormProduct(product: product),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildOptionTile(
                      icon: product.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      title: product.isFavorite
                          ? 'Hapus dari Favorit'
                          : 'Tambah ke Favorit',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        provider.toggleFavorite(product.id);
                      },
                    ),
                    _buildOptionTile(
                      icon: Icons.delete_rounded,
                      title: 'Hapus Produk',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context, product, provider);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColor.primary),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.black87),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, ProductModel product, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Hapus Produk'),
          content: Text(
              'Apakah Anda yakin ingin menghapus produk "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await provider.deleteProduct(product.id);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Produk "${product.name}" berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'Gagal menghapus produk'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
