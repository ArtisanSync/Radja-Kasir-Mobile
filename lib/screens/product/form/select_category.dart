// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:kasir/services/product_services.dart';

class SelectCategory extends StatefulWidget {
  SelectCategory({
    super.key,
  });

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  ProductServices productServices = ProductServices();
  List<dynamic> categories = [];
  bool loading = false;

  void fetchCategory() async {
    setState(() {
      loading = true;
    });
    try {
      var resp = await productServices.listCategory();
      setState(() {
        categories = resp['data'] as List<dynamic>;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Pilih Kategori",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var item = categories[index];
                return ListTile(
                  title: Text('${item!['name']}'),
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                );
              },
            ),
    );
  }
}
