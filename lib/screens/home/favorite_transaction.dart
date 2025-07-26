import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kasir/models/home_product.dart';
import '../../helpers/colors_theme.dart';
import '../../helpers/currency_format.dart';
import '../../services/home_services.dart';
import '../transaction/logic/cart.dart';
import 'package:kasir/screens/product/form/select_category.dart';

class FavoriteTransaction extends StatefulWidget {
  const FavoriteTransaction({super.key});

  @override
  State<FavoriteTransaction> createState() => _FavoriteTransactionState();
}

class _FavoriteTransactionState extends State<FavoriteTransaction> {
  final TextEditingController _search = TextEditingController();
  HomeServices homeServices = HomeServices();
  List<ListProduct> products = [];
  List<ListProduct> filteredProducts = [];
  bool view = true;
  String? categoryId;
  String? categoryLable;

  Future<void> fetchProduct() async {
    var resp = await homeServices.favorite({"category": categoryId});
    var data = HomeProduct.fromJson(resp.data);
    setState(() {
      products = data.data!;
      filteredProducts = data.data!;
    });
  }

  void filterProducts(String query) {
    if (query.isNotEmpty) {
      var res = products
          .where((product) => product.productName
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      setState(() {
        filteredProducts = res;
      });
    } else {
      setState(() {
        filteredProducts = products;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    // grid view product
    GridView gridView() {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // number of items in each row
          mainAxisSpacing: 8.0, // spacing between rows
          crossAxisSpacing: 8.0, // spacing between columns
        ),
        padding: const EdgeInsets.all(8.0), // padding around the grid
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          var item = filteredProducts[index];
          var price = item.unitPrice;
          return InkWell(
            onTap: () {
              CartActions cartActions = const CartActions();
              cartActions.addToChart(context, item);
            },
            child: Container(
              decoration: BoxDecoration(
                border: const Border.fromBorderSide(
                  BorderSide(width: 0.5, color: AppColor.light),
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                image: DecorationImage(
                  image: NetworkImage("${item.image}"),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ), // color of grid items
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.9),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.productName}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyFormat.convertToIdr(price, 0),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white),
                            ),
                            CircleAvatar(
                              backgroundColor: item.quantity! > 2
                                  ? Colors.green
                                  : Colors.amber[800],
                              radius: 10.sp,
                              child: Text(
                                "${item.quantity}",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // list view product
    ListView listView() {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          var item = filteredProducts[index];
          var price = item.unitPrice;

          return InkWell(
            onTap: () {
              CartActions cartActions = const CartActions();
              cartActions.addToChart(context, item);
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black12),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 60.sp,
                    width: 60.sp,
                    // color: Colors.black,
                    decoration: BoxDecoration(
                      border: const Border.fromBorderSide(
                        BorderSide(width: 0.5, color: AppColor.light),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                      image: DecorationImage(
                        image: NetworkImage("${item.image}"),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      ),
                    ), // c
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${item.productName}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Price : ${CurrencyFormat.convertToIdr(price ?? 0, 0)}",
                                style: TextStyle(fontSize: 12.sp),
                              ),
                              Text(
                                "QTY : ${item.quantity}",
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: TextFormField(
              controller: _search,
              onChanged: (value) {
                filterProducts(value);
              },
              decoration: const InputDecoration(
                hintText: 'Cari produk',
                border: OutlineInputBorder(
                  // borderSide: BorderSide(width: 0.3),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusColor: Colors.black12,
                hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColor.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     const Text("Tampilan produk"),
          //     const SizedBox(
          //       width: 10,
          //     ),
          //     IconButton(
          //         onPressed: () {
          //           setState(() {
          //             view = !view;
          //           });
          //         },
          //         icon: Icon(view ? Icons.grid_view : Icons.view_list)),
          //   ],
          // ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.dg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectCategory(),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            categoryId = result['id'] as String;
                            categoryLable = result['name'] as String;
                          });
                        }

                        fetchProduct();
                      },
                      icon: const Icon(Icons.filter_alt),
                    ),
                    Text(
                      "Kategori ${categoryLable != null ? categoryLable : ''}",
                    ),
                    categoryId != null
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                categoryId = null;
                                categoryLable = null;
                              });
                              fetchProduct();
                            },
                            icon: const Icon(
                              Icons.close,
                            ),
                          )
                        : const SizedBox()
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      view = !view;
                    });
                  },
                  icon: Icon(view ? Icons.grid_view : Icons.view_list),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          view
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: listView(),
                )
              : gridView(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
