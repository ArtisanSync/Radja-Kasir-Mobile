import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/components/modern_buttons.dart';
import 'package:kasir/components/modern_text_field.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/providers/product_providers.dart';
import 'package:kasir/providers/category_providers.dart';
import 'package:kasir/providers/cart_providers.dart';
import 'package:kasir/screens/product/form_product.dart';
import 'package:kasir/screens/product/product_detail.dart';
import 'package:kasir/screens/home_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategoryId;
  bool _showFavoritesOnly = false;
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupScrollListener();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts(refresh: true);
      ref.read(categoryProvider.notifier).loadCategories();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 
          _scrollController.position.maxScrollExtent) {
        ref.read(productProvider.notifier).loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategoryManagementSheet(),
    ).then((_) {
      ref.read(categoryProvider.notifier).loadCategories();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(20),
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(8),
                Text(
                  'Filter Produk',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const Gap(24),
            
            Consumer(
              builder: (context, ref, _) {
                final categoryState = ref.watch(categoryProvider);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Semua'),
                          selected: _selectedCategoryId == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = null;
                            });
                          },
                        ),
                        ...categoryState.categories.map(
                          (category) => FilterChip(
                            label: Text(category.name),
                            selected: _selectedCategoryId == category.id,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategoryId = selected ? category.id : null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            
            const Gap(24),
            
            Column(
              children: [
                SwitchListTile(
                  title: const Text('Hanya Favorit'),
                  value: _showFavoritesOnly,
                  onChanged: (value) {
                    setState(() {
                      _showFavoritesOnly = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Stok Menipis'),
                  value: _showLowStockOnly,
                  onChanged: (value) {
                    setState(() {
                      _showLowStockOnly = value;
                    });
                  },
                ),
              ],
            ),
            
            const Gap(24),
            
            Row(
              children: [
                Expanded(
                  child: ModernOutlinedButton(
                    text: 'Reset',
                    onPressed: () {
                      setState(() {
                        _selectedCategoryId = null;
                        _showFavoritesOnly = false;
                        _showLowStockOnly = false;
                      });
                      ref.read(productProvider.notifier).clearFilters();
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ModernButton(
                    text: 'Terapkan',
                    onPressed: () {
                      ref.read(productProvider.notifier).loadProducts(
                        refresh: true,
                        categoryId: _selectedCategoryId,
                        isFavorite: _showFavoritesOnly ? true : null,
                        lowStock: _showLowStockOnly ? true : null,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            
            Gap(MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.colorScheme.onSurface,
          ),
          tooltip: 'Kembali',
        ),
        title: Text(
          'Produk & Stok',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showCategoryBottomSheet,
            icon: Icon(
              Icons.category,
              color: theme.colorScheme.onSurface,
            ),
            tooltip: 'Kelola Kategori',
          ),
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Icon(
              Icons.tune,
              color: theme.colorScheme.onSurface,
            ),
            tooltip: 'Filter',
          ),
          IconButton(
            onPressed: productState.isLoading 
                ? null 
                : () => ref.read(productProvider.notifier).refresh(),
            icon: productState.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onSurface,
                      ),
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: theme.colorScheme.onSurface,
                  ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: ModernSearchField(
              controller: _searchController,
              hint: 'Cari produk...',
              onChanged: (value) {
                ref.read(productProvider.notifier).searchProducts(value);
              },
              onClear: () {
                ref.read(productProvider.notifier).searchProducts('');
              },
            ),
          ),
          
          Expanded(
            child: _buildProductGrid(context, productState, theme),
          ),
        ],
      ),
      floatingActionButton: ModernFloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormProduct(),
            ),
          ).then((_) {
            ref.read(productProvider.notifier).refresh();
          });
        },
        icon: const Icon(Icons.add),
        label: 'Tambah Produk',
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductState state, ThemeData theme) {
    if (state.isLoading && state.products.isEmpty) {
      return _buildLoadingGrid();
    }

    if (state.hasError && state.products.isEmpty) {
      return _buildErrorState(context, theme);
    }

    if (state.products.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(productProvider.notifier).refresh();
      },
      child: AnimationLimiter(
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: state.products.length + (state.isLoadingMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= state.products.length) {
              return const ProductShimmerCard();
            }

            return AnimationConfiguration.staggeredGrid(
              position: index,
              columnCount: 2,
              duration: const Duration(milliseconds: 375),
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: ProductCard(
                    product: state.products[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetail(
                            product: state.products[index],
                          ),
                        ),
                      ).then((_) {
                        ref.read(productProvider.notifier).refresh();
                      });
                    },
                    onFavoriteToggle: () {
                      ref.read(productProvider.notifier).toggleFavorite(
                        state.products[index].id!,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/Loading.json',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const Gap(16),
          Text(
            'Memuat produk...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ERROR STATE - HAPUS TOMBOL "KEMBALI KE HOME"
  Widget _buildErrorState(BuildContext context, ThemeData theme) {
    final productState = ref.watch(productProvider);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Sign for error.json',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const Gap(16),
            Text(
              'Terjadi Kesalahan',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              productState.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(24),
            // HANYA SATU TOMBOL - COBA LAGI
            ModernButton(
              text: 'Coba Lagi',
              onPressed: () {
                ref.read(productProvider.notifier).clearError();
                ref.read(productProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              isExpanded: false,
            ),
            // HAPUS TOMBOL "KEMBALI KE HOME" - TIDAK DIPERLUKAN KARENA SUDAH ADA BACK BUTTON DI APPBAR
          ],
        ),
      ),
    );
  }

  // EMPTY STATE - HAPUS TOMBOL "KEMBALI KE HOME"
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/no data.json',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const Gap(16),
            Text(
              'Belum Ada Produk',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'Mulai dengan menambahkan produk pertama Anda',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(24),
            // HANYA SATU TOMBOL - TAMBAH PRODUK
            ModernButton(
              text: 'Tambah Produk',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormProduct(),
                  ),
                ).then((_) {
                  ref.read(productProvider.notifier).refresh();
                });
              },
              icon: const Icon(Icons.add),
              isExpanded: false,
            ),
            // HAPUS TOMBOL "KEMBALI KE HOME" - TIDAK DIPERLUKAN KARENA SUDAH ADA BACK BUTTON DI APPBAR
          ],
        ),
      ),
    );
  }
}

// Product Card dengan Add to Cart
class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartNotifier = ref.read(cartProvider.notifier);

    return GestureDetector(
      onTap: onTap,
      child: ModernCard(
        padding: const EdgeInsets.all(12),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.image != null
                          ? CachedNetworkImage(
                              imageUrl: product.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                child: Icon(
                                  Icons.image,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                child: Icon(
                                  Icons.broken_image,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.image,
                              size: 40,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                    ),
                  ),
                  
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          product.isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: product.isFavorite 
                              ? Colors.red 
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  
                  if (!product.hasStock)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Habis',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onError,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else if (product.isLowStock)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Menipis',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const Gap(8),
            
            Text(
              product.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const Gap(4),
            
            if (product.category != null)
              Text(
                product.category!.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            
            const Gap(4),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    CurrencyFormat.formatPrice(double.tryParse(product.displayPrice) ?? 0.0),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${product.totalQuantity}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const Gap(8),
            
            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton.icon(
                onPressed: product.hasStock ? () {
                  cartNotifier.addItem(
                    productId: product.id!,
                    name: product.name,
                    image: product.image ?? '',
                    price: double.tryParse(product.displayPrice) ?? 0.0,
                    unit: product.displayUnit,
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} ditambahkan ke keranjang'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                } : null,
                icon: Icon(
                  Icons.add_shopping_cart,
                  size: 14,
                ),
                label: Text(
                  'Tambah',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: product.hasStock 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceVariant,
                  foregroundColor: product.hasStock
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Category Management Sheet tetap sama
class CategoryManagementSheet extends ConsumerStatefulWidget {
  const CategoryManagementSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoryManagementSheet> createState() => _CategoryManagementSheetState();
}

class _CategoryManagementSheetState extends ConsumerState<CategoryManagementSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Kategori',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nameController.clear();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isNotEmpty) {
                final success = await ref
                    .read(categoryProvider.notifier)
                    .createCategory(_nameController.text.trim());
                
                Navigator.of(context).pop();
                _nameController.clear();
                
                if (success) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Dialog(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/animations/Check Mark.json',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                              repeat: false,
                            ),
                            const Gap(16),
                            const Text(
                              'Kategori Berhasil Ditambahkan!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryState = ref.watch(categoryProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.category,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const Gap(12),
                Text(
                  'Kelola Kategori',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showAddCategoryDialog,
                  icon: Icon(
                    Icons.add,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Tambah Kategori',
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ModernSearchField(
              controller: _searchController,
              hint: 'Cari kategori...',
            ),
          ),

          const Gap(16),

          Expanded(
            child: categoryState.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/Loading.json',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                        const Gap(16),
                        const Text('Memuat kategori...'),
                      ],
                    ),
                  )
                : categoryState.categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/no data.json',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                            const Gap(16),
                            Text(
                              'Belum ada kategori',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Gap(8),
                            ElevatedButton.icon(
                              onPressed: _showAddCategoryDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Kategori'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categoryState.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryState.categories[index];
                          return ModernCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.category,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    size: 20,
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${category.productCount} produk',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        // TODO: Edit category
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // TODO: Delete category
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: theme.colorScheme.error,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
