import 'package:flutter/material.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/models/packages_model.dart';
import 'package:kasir/screens/product/detail_product.dart';
import 'package:kasir/screens/product/form_product.dart';
import 'package:kasir/screens/product_information/product_information.dart';
import 'package:kasir/screens/product_stock/stock_detail.dart';
import 'package:kasir/services/product_services.dart';
import 'package:kasir/actions/add_product.dart';
import 'package:kasir/services/user_services.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  UserSubsModel? subscriptionModel;

  ProductServices productServices = ProductServices();
  UserServices userServices = UserServices();
  ActionProduct actionProduct = ActionProduct();

  // UserSubsModel? _subscription; // Removed - not needed for Express.js backend

  bool loading = false;
  List<dynamic> products = [];
  String mode = 'list';

  Future<void> fetchProduct() async {
    setState(() {
      loading = true;
    });
    var resp = await productServices.listProduct();
    if (resp['success'] == true) {
      setState(() {
        if (resp['data'] != null && resp['data']['products'] != null) {
          products = resp['data']['products'] as List<dynamic>;
        } else {
          products = [];
        }
      });
    }
    setState(() {
      loading = false;
    });
  }

  // Method fetchPackageStore() removed - not needed for Express.js backend
  // Express.js backend doesn't use the same package/subscription system
  /*
  Future<void> fetchPackageStore() async {
    try {
      var userStore = await Store.getUser();
      if (userStore == null || userStore['id'] == null) {
        print('User store data not found');
        return;
      }
      
      // Use profile endpoint instead of package endpoint
      var resp = await userServices.profile();
      if (resp.data != null && resp.data['data'] != null) {
        // Create UserSubsModel from profile data
        var profileData = resp.data['data'];
        var subscriptionData = {
          'id': profileData['id'],
          'isMember': profileData['isMember'] ?? false,
          'isSubscribe': profileData['isSubscribe'] ?? false,
          'subscribes': profileData['subscribes'] ?? [],
          'storeMembers': profileData['storeMembers'] ?? [],
        };
        
        UserSubsModel subsData = UserSubsModel.fromJson(subscriptionData);
        if (mounted) {
          setState(() {
            _subscription = subsData;
          });
        }
      }
    } catch (e) {
      print('Error fetching package store: $e');
      // Create default subscription data if API fails
      if (mounted) {
        setState(() {
          _subscription = UserSubsModel.fromJson({
            'id': 'default',
            'isMember': false,
            'isSubscribe': false,
            'subscribes': [],
            'storeMembers': [],
          });
        });
      }
    }
  }
  */

  @override
  void initState() {
    super.initState();
    fetchProduct();
    // fetchPackageStore(); // Removed - not needed for Express.js backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Produk",
          style: TextStyle(
            fontSize: 16,
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
                    builder: (context) => const ProductInformationPage()),
              );
            },
            icon: const Icon(
              Icons.category,
              color: AppColor.textPrimary,
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchProduct(),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                shrinkWrap: false,
                itemCount: products.length,
                separatorBuilder: (context, index) =>
                    Container(height: 1, color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  var item = products[index];
                  if (products.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // product info
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${item['name']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      "Qty: ${item['qty']}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColor.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      "Variant: ${item['total_variant']}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColor.textPrimary,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: item['favorite']
                                      ? Colors.amber[700]
                                      : Colors.amber[50],
                                  child: IconButton(
                                    onPressed: () async {
                                      var resp = await productServices
                                          .setFavorite(item['id']);
                                      if (resp['success'] == true) {
                                        fetchProduct();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.star_border_outlined,
                                      color: item['favorite']
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    highlightColor: Colors.amber,
                                    iconSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.blue[50],
                                  child: IconButton(
                                    onPressed: () {
                                      Route detail = MaterialPageRoute(
                                        builder: (context) =>
                                            ProductStockDetailPage(
                                                id: item['id']),
                                      );

                                      Navigator.push(context, detail).then(
                                        (value) => fetchProduct(),
                                      );
                                    },
                                    icon:
                                        const Icon(Icons.inventory_2_outlined),
                                    iconSize: 16,
                                    highlightColor: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.green[50],
                                  child: IconButton(
                                    onPressed: () async {
                                      Route detail = MaterialPageRoute(
                                        builder: (context) =>
                                            DetailProductPage(id: item['id']),
                                      );

                                      Navigator.push(context, detail).then(
                                        (value) => fetchProduct(),
                                      );
                                    },
                                    icon: const Icon(
                                        Icons.remove_red_eye_outlined),
                                    iconSize: 18,
                                    highlightColor: Colors.green,
                                  ),
                                ),
                              ],
                            )
                          ]),
                    );
                  } else {
                    return const ProductEmptyAction();
                  }
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simplified navigation - bypass package checking for now
          // Since Express.js backend may not have the same package system
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormProduct()),
          ).then((value) {
            if (value == true) {
              fetchProduct(); // Refresh products after adding
            }
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ProductEmptyAction extends StatelessWidget {
  const ProductEmptyAction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Data Kosong \nTambahkan produk',
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormProduct()),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: const BorderSide(color: Colors.green, width: 0.5),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            child: const Text('Tambah Produk'),
          )
        ],
      ),
    );
  }
}
