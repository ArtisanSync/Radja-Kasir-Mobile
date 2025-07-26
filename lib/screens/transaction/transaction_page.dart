import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/screens/transaction/logic/cart.dart';
import 'package:kasir/store/cart_provider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import 'actions/transaction_draft.dart';
import 'actions/transaction_paid.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    double totalTransaksi = Provider.of<CartProvider>(
      context,
    ).calculateTotalQuantity();

    int totalCart = Provider.of<CartProvider>(context).list.length;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Keranjang ",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).resetCart();
            },
            icon: const Icon(Icons.delete_forever_outlined),
          )
        ],
      ),
      body: LoaderOverlay(
        overlayOpacity: 0.2,
        overlayColor: Colors.black12,
        useDefaultLoading: false,
        overlayWidget: const Center(
          child: SpinKitDoubleBounce(
            color: Colors.black,
            size: 50.0,
          ),
        ),
        child: Column(
          children: [
            totalCart > 0
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cartProvider.list.length,
                              itemBuilder: (context, index) {
                                var item = cartProvider.list[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black12),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${item['product_name']}",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                CurrencyFormat.convertToIdr(
                                                    item['unit_price'], 0),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                " =  ${CurrencyFormat.convertToIdr(item['total'] - item['total_dic'], 0)}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    Colors.blue[100],
                                                radius: 16,
                                                child: IconButton(
                                                  onPressed: () {
                                                    CartActions cart =
                                                        const CartActions();
                                                    int id = item['id'];
                                                    cart.incrementQty(
                                                        context, id);
                                                  },
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(item['quantity'].toString()),
                                              const SizedBox(width: 10),
                                              CircleAvatar(
                                                backgroundColor:
                                                    Colors.red[100],
                                                radius: 16,
                                                child: IconButton(
                                                  onPressed: () {
                                                    int id = item['id'];
                                                    Provider.of<CartProvider>(
                                                      context,
                                                      listen: false,
                                                    ).decrementQuantity(id);
                                                  },
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.red[50],
                                            radius: 16,
                                            child: IconButton(
                                              onPressed: () {
                                                int id = item['id'];
                                                Provider.of<CartProvider>(
                                                        context,
                                                        listen: false)
                                                    .remove(id);
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 14,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.sizeOf(context).height / 4),
                    width: double.infinity,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_mall_outlined,
                          size: 70,
                          color: Colors.black54,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Keranjang Kosong',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        Text(
                          'Pilih produk pada halaman sebelumnya.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
            totalCart > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        top: BorderSide(width: 1, color: Colors.black12),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(bottom: 10),
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Text("Discount"),
                        //       TextButton(
                        //         onPressed: () {},
                        //         child: Icon(Icons.percent_rounded, size: 18,),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const Divider(height: 0),
                        // const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyFormat.convertToIdr(totalTransaksi, 0),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ActionTransactionDraft(),
                                  SizedBox(width: 10),
                                  ActionTransactionPaid(),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
