import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/product/product_edit.dart';
import 'package:kasir/screens/product_variant/edit_variant.dart';
import 'package:kasir/screens/product_variant/form_variant.dart';
import 'package:kasir/services/product_services.dart';

class DetailProductPage extends StatefulWidget {
  const DetailProductPage({
    required this.id,
    super.key,
  });

  final String id;
  @override
  State<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  ProductServices productServices = ProductServices();
  Map<String, dynamic> product = {};
  List<dynamic> variant = [];

  Future<void> fecthData() async {
    try {
      var resp = await productServices.detailProduct(widget.id);
      setState(() {
        product = resp['data'] as Map<String, dynamic>;
        variant = resp['data']!['variants'] as List<dynamic>;
      });
      print(resp);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fecthData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Detail",
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
              Route form = MaterialPageRoute(
                builder: (context) => ProductEditScreen(
                  id: widget.id,
                ),
              );
              Navigator.push(context, form).then(
                (value) => fecthData(),
              );
            },
            icon: const Icon(
              Icons.edit,
              color: AppColor.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () async {
              if (await confirm(context)) {
                final resp = await productServices.destroyProduct(widget.id);
                Navigator.pop(context);
              } else {
                return print('cancel');
              }
            },
            icon: const Icon(
              Icons.delete,
              color: AppColor.textPrimary,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Infolist(
                  label: 'Nama produk',
                  content: "${product["name"] ?? "-"}",
                ),
                const SizedBox(height: 10),
                Infolist(
                  label: 'Kategori',
                  content: "${product["category"] ?? "-"}",
                ),
                const SizedBox(height: 10),
                Infolist(
                  label: 'Brand/Merk',
                  content: "${product["brand"] ?? "-"}",
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Infolist(
                      label: 'Varian Produk',
                      content: variant.isNotEmpty
                          ? "Daftar varian"
                          : "Daftar kosong",
                    ),
                    TextButton(
                      onPressed: () {
                        Route form = MaterialPageRoute(
                          builder: (context) => FormProductVariant(
                            productId: widget.id,
                          ),
                        );
                        Navigator.push(context, form).then(
                          (value) => fecthData(),
                        );
                      },
                      child: const Row(
                        children: [Icon(Icons.add), Text('Tambah')],
                      ),
                    ),
                  ],
                ),
                variant.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: variant.length,
                        itemBuilder: (context, index) {
                          var item = variant[index];
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            color: index % 2 != 0 ? Colors.grey[100] : null,
                            child: Table(
                              columnWidths: const <int, TableColumnWidth>{
                                0: FlexColumnWidth(),
                                1: FlexColumnWidth(),
                                2: FixedColumnWidth(64),
                                3: FixedColumnWidth(64),
                              },
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(children: [
                                  Infolist(
                                    label: "Nama",
                                    content: "${item['name']}",
                                  ),
                                  Infolist(
                                    label: "Harga",
                                    content: "${item['price']}",
                                  ),
                                  Infolist(
                                    label: "Qty",
                                    content: "${item['quantity']}",
                                  ),
                                  IconButton(
                                      onPressed: () =>
                                          _actionButtons(context, item['id']),
                                      icon: const Icon(Icons.more_vert))
                                ])
                              ],
                            ),
                          );
                        },
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.archive_outlined,
                                size: 70,
                                color: AppColor.textPrimary,
                              ),
                              Text(
                                'Varian produk kosong',
                                style: TextStyle(
                                    color: Color.fromRGBO(115, 115, 115, 1)),
                              ),
                            ],
                          ),
                        ),
                      )
              ],
            )
          ],
        ),
        onRefresh: () => fecthData(),
      ),
    );
  }

  void _actionButtons(context, id) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  Route detail = MaterialPageRoute(
                    builder: (context) => VariantEditPage(id: id),
                  );

                  Navigator.push(context, detail).then(
                    (value) => fecthData(),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: () async {
                  if (await confirm(context)) {
                    await productServices
                        .destroyVariant(id)
                        .then((value) => fecthData());
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class Infolist extends StatelessWidget {
  const Infolist({
    super.key,
    required this.label,
    required this.content,
  });

  final String label;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColor.textPrimary),
          ),
          Text(content),
        ],
      ),
    );
  }
}
