// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/providers/cart_providers.dart';
import 'package:kasir/providers/product_providers.dart';
import 'package:kasir/screens/cart/cart_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// Define your static colors
const Color primary = Color(0xFF00ADFE);
const Color badgeYellow = Color(0xFFFACC15);

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          drawer: const NavDrawer(currentRoute: 'home'),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "Radja Kasir",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 20,
              ),
            ),
            bottom: TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Produk'),
                Tab(text: 'Favorit'),
              ],
            ),
            leading: const MenuBuilder(),
            actions: [
              const ButtonCartWithBadge(),
              const SizedBox(width: 12),
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

  const HomeProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: product.image != null
                    ? CachedNetworkImage(
                        imageUrl: product.image!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Icon(
                            Icons.store,
                            color: primary.withOpacity(0.5),
                            size: 40,
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: theme.colorScheme.onErrorContainer,
                            size: 40,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.store,
                          size: 40,
                          color: primary.withOpacity(0.5),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    'Stok: ${product.totalQuantity}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    CurrencyFormat.formatPrice(
                        double.tryParse(product.displayPrice) ?? 0.0),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductTabContent extends ConsumerStatefulWidget {
  const ProductTabContent({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductTabContent> createState() => _ProductTabContentState();
}

class _ProductTabContentState extends ConsumerState<ProductTabContent> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load products when the tab is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts(refresh: true);
    });
  }

  void _onRefresh() async {
    await ref.read(productProvider.notifier).loadProducts(refresh: true);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final filteredProducts = productState.products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const Gap(16),
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: productState.isLoading && _searchQuery.isEmpty
                ? Center(
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
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : productState.error != null
                    ? Center(
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
                              'Terjadi Kesalahan',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              productState.error!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : filteredProducts.isEmpty
                        ? Center(
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
                                  _searchQuery.isEmpty
                                      ? 'Belum Ada Produk'
                                      : 'Produk tidak ditemukan',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const Gap(8),
                                  Text(
                                    'Tambahkan produk pertama Anda untuk mulai berjualan',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ]
                              ],
                            ),
                          )
                        : SmartRefresher(
                            controller: _refreshController,
                            onRefresh: _onRefresh,
                            header: const WaterDropHeader(),
                            child: AnimationLimiter(
                              child: GridView.builder(
                                padding: const EdgeInsets.only(bottom: 16),
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
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
                                            if (product.hasStock) {
                                              final cartNotifier = ref.read(
                                                  cartProvider.notifier);
                                              final variantId = product
                                                      .variants.isNotEmpty
                                                  ? product.variants.first.id
                                                  : product.id!;
                                              cartNotifier.addItem(
                                                productId: variantId,
                                                name: product.name,
                                                image: product.image ?? '',
                                                price: double.tryParse(product
                                                        .displayPrice) ??
                                                    0.0,
                                                unit: product.displayUnit,
                                              );

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                      const Gap(12),
                                                      Expanded(
                                                        child: Text(
                                                          '${product.name} ditambahkan ke keranjang',
                                                          style: GoogleFonts
                                                              .inter(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      Colors.green.shade600,
                                                  behavior: SnackBarBehavior
                                                      .floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  margin:
                                                      const EdgeInsets.all(16),
                                                  duration: const Duration(
                                                      seconds: 2),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class FavoriteTabContent extends StatelessWidget {
  const FavoriteTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                'assets/animations/no data.json',
                width: 120,
                height: 120,
              ),
            ),
            const Gap(24),
            Text(
              'Belum Ada Favorit',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const Gap(12),
            Text(
              'Produk yang Anda favoritkan akan muncul di sini.\nMulai jelajahi produk dan tambahkan ke favorit!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonCartWithBadge extends ConsumerWidget {
  const ButtonCartWithBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final totalItems = cartState.totalQuantity;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          if (totalItems > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  totalItems > 99 ? '99+' : '$totalItems',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}