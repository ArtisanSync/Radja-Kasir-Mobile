// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kasir/components/text_input.dart';
import 'package:kasir/services/product_services.dart';

class CategoryBuilder extends StatefulWidget {
  const CategoryBuilder(
      {super.key,
      required this.categories,
      required this.loader,
      required this.refresh});

  final List categories;
  final bool loader;
  final Function refresh;

  @override
  State<CategoryBuilder> createState() => _CategoryBuilderState();
}

class _CategoryBuilderState extends State<CategoryBuilder> {
  TextEditingController _name = TextEditingController();

  ProductServices productServices = ProductServices();
  bool loading = false;

  Future destroy(BuildContext context, String id) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Peringatan'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                    'Menghapus data ini akan berdampak pada data produk anda.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () async {
                // print(id);
                if (!loading) {
                  setState(() {
                    loading = true;
                  });
                  try {
                    await productServices.removeCategory(id);
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context);
                    widget.refresh();
                  } catch (e) {
                    setState(() {
                      loading = false;
                    });
                  }
                }
              },
              child: Text(
                loading ? 'Menghapus data' : 'Hapus',
                style: TextStyle(color: Colors.black38),
              ),
            )
          ],
        );
      },
    );
  }

  Future edit(BuildContext context, Map<String, dynamic> category) {
    setState(() {
      _name.text = category['name'];
      loading = false;
    });
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ubah kategori'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                TextInput(label: "Nama kategori", controller: _name)
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (!loading) {
                  setState(() {
                    loading = true;
                  });
                  try {
                    final res = await productServices
                        .updateCategory({"name": _name.text}, category['id']);
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context);
                    widget.refresh();
                  } catch (e) {
                    setState(() {
                      loading = false;
                    });
                  }
                }
              },
              child: Text(
                loading ? 'Menyimpan..' : 'Simpan',
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.loader
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              var item = widget.categories[index];
              return Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    width: double.infinity,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${item['name']}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => edit(context, item),
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 15,
                              ),
                            ),
                            IconButton(
                              onPressed: () => destroy(context, item['id']),
                              icon: Icon(
                                Icons.delete,
                                color: Colors.black45,
                                size: 15,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          );
  }
}
