// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:kasir/components/text_input.dart';
import 'package:kasir/screens/product_information/category/category_builder.dart';
import 'package:kasir/services/product_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ProductCategoryScreen extends StatefulWidget {
  const ProductCategoryScreen({super.key});

  @override
  State<ProductCategoryScreen> createState() => ProductCategoryScreenState();
}

class ProductCategoryScreenState extends State<ProductCategoryScreen> {
  TextEditingController _name = TextEditingController();
  ProductServices productServices = ProductServices();
  List<dynamic> categories = [];
  bool loading = false;
  bool submit = false;

  void fetchCategory() async {
    context.loaderOverlay.show();
    setState(() {
      loading = true;
    });
    try {
      var resp = await productServices.listCategory();
      List data = resp['data'] as List;
      setState(() {
        categories = data;
        loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan! coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CategoryBuilder(
        categories: categories,
        loader: loading,
        refresh: () => fetchCategory(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => form(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future form() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kategori'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                TextInput(label: "Nama kategori", controller: _name),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (!submit) {
                  setState(() {
                    submit = true;
                  });
                  try {
                    var resp = await productServices.storeCategory(_name.text);
                    print(resp);
                    fetchCategory();
                    Navigator.pop(context);
                    setState(() {
                      _name.clear();
                      submit = false;
                    });
                  } catch (e) {
                    setState(() {
                      submit = false;
                    });
                    print(e);
                  }
                }
              },
              child: Text(submit ? 'Menyimpan..' : 'Simpan'),
            )
          ],
        );
      },
    );
  }
}
