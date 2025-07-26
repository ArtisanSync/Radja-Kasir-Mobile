import 'package:flutter/material.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/screens/product_variant/stock_update_variant.dart';
import 'package:kasir/services/product_services.dart';

class ProductStockDetailPage extends StatefulWidget {
  const ProductStockDetailPage({
    required this.id,
    Key? key,
  }) : super(key: key);

  final String id;

  @override
  State<ProductStockDetailPage> createState() => _ProductStockDetailPageState();
}

class _ProductStockDetailPageState extends State<ProductStockDetailPage> {
  ProductServices productServices = ProductServices();
  List<dynamic> variant = [];
  bool _loading = true;

  Future<void> fetchData() async {
    var resp = await productServices.detailProduct(widget.id);
    setState(() {
      variant = resp['data']['variants'] as List<dynamic>;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Produk Stok",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: ListView.separated(
          itemCount: variant.length,
          separatorBuilder: (context, index) =>
              Container(height: 1, color: Colors.grey[300]),
          itemBuilder: (context, index) {
            var item = variant[index];
            if (variant.length > 0) {
              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${item['product_name']}, ${item['name']}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            CurrencyFormat.convertToIdr(item['price'] ?? 0, 0)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "${item['quantity']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        const SizedBox(width: 20),
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 18,
                          child: IconButton(
                            onPressed: () {
                              Route detail = MaterialPageRoute(
                                  builder: (context) =>
                                      UpdateStockVariant(variant: item));

                              Navigator.push(context, detail).then(
                                (value) => fetchData(),
                              );
                            },
                            icon: const Icon(
                              Icons.data_saver_on,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        // const SizedBox(width: 10),
                        // CircleAvatar(
                        //   backgroundColor: Colors.amber[800],
                        //   radius: 18,
                        //   child: IconButton(
                        //     onPressed: () {},
                        //     icon: const Icon(
                        //       Icons.percent,
                        //       color: Colors.white,
                        //       size: 18,
                        //     ),
                        //   ),
                        // )
                      ],
                    )
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text("data kosong"),
              );
            }
          },
        ),
      ),
    );
  }
}
