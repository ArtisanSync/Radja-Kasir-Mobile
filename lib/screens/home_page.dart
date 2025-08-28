import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/components/modern_text_field.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/providers/cart_providers.dart';
import 'package:kasir/providers/product_providers.dart';
import 'package:kasir/providers/category_providers.dart';
import 'package:kasir/screens/cart/cart_page.dart';
import 'package:kasir/screens/product/product_detail.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          drawer: const NavDrawer(currentRoute: 'home'),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              "Radja Kasir",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Colors.black87,
              ),
            ),
            bottom: const TabBar(
              labelColor: Colors.black87,
              indicatorColor: Colors.black87,
              unselectedLabelColor: Colors.black54,
              tabs: [
                Tab(text: 'Produk'),
                Tab(text: 'Favorit'),
              ],
            ),
            leading: const MenuBuilder(),
            actions: [
              ButtonCartWithBadge(
                cartCount: cartCount,
              ),
              const SizedBox(width: 10),
            ],
            centerTitle: true,
          ),
          body: const SafeArea(
            child: TabBarView(
              children: [
                ProductTabContent(),
                FavoriteTabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Product Card untuk home page dengan add to cart
class HomeProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const HomeProductCard({
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
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          theme.colorScheme.surfaceVariant.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: product.image != null
                          ? CachedNetworkImage(
                              imageUrl: product.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.surfaceVariant.withOpacity(0.4),
                                      theme.colorScheme.surfaceVariant.withOpacity(0.2),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.image_outlined,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 32,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.errorContainer.withOpacity(0.3),
                                      theme.colorScheme.errorContainer.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: theme.colorScheme.onErrorContainer,
                                  size: 32,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.surfaceVariant.withOpacity(0.4),
                                    theme.colorScheme.surfaceVariant.withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: onFavoriteToggle,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              product.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: product.isFavorite
                                  ? Colors.red.shade400
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!product.hasStock)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.error.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Habis',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onError,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                  else if (product.isLowStock)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade400, Colors.orange.shade600],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Menipis',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Gap(12),

            Text(
              product.name,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Gap(8),

            if (product.category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondaryContainer.withOpacity(0.8),
                      theme.colorScheme.secondaryContainer.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  product.category!.name,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const Gap(12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    CurrencyFormat.formatPrice(
                        double.tryParse(product.displayPrice) ?? 0.0),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: product.hasStock 
                          ? [
                              theme.colorScheme.primaryContainer,
                              theme.colorScheme.primaryContainer.withOpacity(0.8),
                            ]
                          : [
                              theme.colorScheme.errorContainer,
                              theme.colorScheme.errorContainer.withOpacity(0.8),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: product.hasStock 
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.error.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    product.hasStock ? '${product.totalQuantity}' : 'Habis',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: product.hasStock 
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const Gap(12),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: product.hasStock
                    ? () {
                        // Use variant ID instead of product ID for backend compatibility
                        final variantId = product.variants.isNotEmpty
                            ? product.variants.first.id
                            : product.id!;
                        cartNotifier.addItem(
                          productId: variantId,
                          name: product.name,
                          image: product.image ?? '',
                          price: double.tryParse(product.displayPrice) ?? 0.0,
                          unit: product.displayUnit,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    '${product.name} ditambahkan ke keranjang',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: product.hasStock
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceVariant,
                  foregroundColor: product.hasStock
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  elevation: product.hasStock ? 2 : 0,
                  shadowColor: product.hasStock 
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(double.infinity, 44),
                ),
                icon: Icon(
                  product.hasStock 
                      ? Icons.add_shopping_cart_rounded
                      : Icons.remove_shopping_cart_outlined,
                  size: 18,
                ),
                label: Text(
                  product.hasStock ? 'Tambah ke Keranjang' : 'Stok Habis',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

// Product Tab Content
class ProductTabContent extends ConsumerStatefulWidget {
  const ProductTabContent({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductTabContent> createState() => _ProductTabContentState();
}

class _ProductTabContentState extends ConsumerState<ProductTabContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final categoryState = ref.watch(categoryProvider);

    return Column(
      children: [
        // Search and Filter Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const Gap(12),
              // Category Filter
              if (categoryState.isLoading)
                const SizedBox.shrink()
              else if (categoryState.error != null)
                const SizedBox.shrink()
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Semua'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                      ),
                      const Gap(8),
                      ...categoryState.categories.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: _selectedCategory == category.id.toString(),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category.id.toString() : null;
                            });
                          },
                        ),
                      )),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Products Grid
        Expanded(
          child: Builder(
            builder: (context) {
              if (productState.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (productState.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const Gap(16),
                      Text(
                        'Gagal memuat produk',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        productState.error ?? 'Terjadi kesalahan',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(productProvider.notifier).refresh();
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              
              // Filter products based on search and category
              final filteredProducts = productState.products.where((product) {
                final matchesSearch = _searchQuery.isEmpty ||
                    product.name.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchesCategory = _selectedCategory == null ||
                    product.category?.id.toString() == _selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/no data.json',
                        width: 200,
                        height: 200,
                      ),
                      const Gap(16),
                      Text(
                        'Tidak ada produk ditemukan',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: HomeProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetail(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            onFavoriteToggle: () {
                              // TODO: Implement favorite toggle
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Favorite Tab Content
class FavoriteTabContent extends ConsumerWidget {
  const FavoriteTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement favorite products logic
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/no data.json',
            width: 200,
            height: 200,
          ),
          const Gap(16),
          Text(
            'Belum ada produk favorit',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const Gap(8),
          Text(
            'Tambahkan produk ke favorit untuk melihatnya di sini',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Button Cart with Badge
class ButtonCartWithBadge extends StatelessWidget {
  final int cartCount;

  const ButtonCartWithBadge({
    Key? key,
    required this.cartCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartPage(),
              ),
            );
          },
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.black87,
          ),
        ),
        if (cartCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                cartCount > 99 ? '99+' : cartCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
            