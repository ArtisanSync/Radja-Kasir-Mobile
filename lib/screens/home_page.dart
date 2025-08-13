import 'package:flutter/material.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/services/setting_services.dart';
import 'package:kasir/store/cart_provider.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final api = SettingServices();

  Future<void> fetchPackage() async {
    try {
      final resp = await api.subcribe();
      if (resp.statusCode == 200) {
        await Store.savePackageSubscribe(resp.data!['data']);
      }
    } catch (e) {
      print('Error fetching package: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPackage();
  }

  @override
  Widget build(BuildContext context) {
    int cartCount = context.watch<CartProvider>().list.length;

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          drawer: const NavDrawer(),
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
              IconButton(
                onPressed: () {
                  // Placeholder untuk History Page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('History page coming soon'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColor.textPrimary,
                ),
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

// Widget placeholder untuk tab Produk
class ProductTabContent extends StatelessWidget {
  const ProductTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Produk Tab',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Content akan ditambahkan nanti',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget placeholder untuk tab Favorit
class FavoriteTabContent extends StatelessWidget {
  const FavoriteTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Favorit Tab',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Content akan ditambahkan nanti',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonCartWithBadge extends StatelessWidget {
  const ButtonCartWithBadge({
    required this.cartCount,
    super.key,
  });

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            // Placeholder untuk Transaction Page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cart/Transaction page coming soon'),
                backgroundColor: Colors.blue,
              ),
            );
          },
          icon: const Icon(
            Icons.local_mall_outlined,
            color: AppColor.textPrimary,
          ),
        ),
        if (cartCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                cartCount.toString(),
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
