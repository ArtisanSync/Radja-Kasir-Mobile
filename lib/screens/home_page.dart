import 'package:flutter/material.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/home/favorite_transaction.dart';
import 'package:kasir/screens/home/product_transaction.dart';
import 'package:kasir/screens/transaction/history_page.dart';
import 'package:kasir/screens/transaction/transaction_page.dart';
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

  void fetchPackage() async {
    final resp = await api.subcribe();
    if (resp.statusCode == 200) {
      await Store.savePackageSubscribe(resp.data!['data']);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
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
          drawer: NavDrawer(),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              "Radja Kasir",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            bottom: const TabBar(
              labelColor: Colors.black87,
              indicatorColor: Colors.black87,
              unselectedLabelColor: Colors.black54,
              tabs: [
                // Tab(
                //   text: 'Manual',
                // ),
                Tab(
                  text: 'Produk',
                ),
                Tab(
                  text: 'Favorit',
                ),
              ],
            ),
            leading: const MenuBuilder(),
            actions: [
              ButtonCartWithBadge(
                cartCount: cartCount,
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
            centerTitle: true,
          ),
          body: const SafeArea(
            child: TabBarView(
              children: [
                // ManualTransaction(), // manual transaction page
                ProductTransaction(),
                FavoriteTransaction()
              ],
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
        cartCount > 0
            ? Positioned(
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
                    cartCount.toString(), // Nomor yang ingin ditampilkan
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : const SizedBox(),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TransactionPage(),
              ),
            );
          },
          icon: const Icon(
            Icons.local_mall_outlined,
            color: AppColor.textPrimary,
          ),
        ),
      ],
    );
  }
}
