// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:kasir/screens/product_information/category_product.dart';
// import 'package:kasir/screens/product_information/merk_product.dart';

class ProductInformationPage extends StatefulWidget {
  const ProductInformationPage({super.key});

  @override
  State<ProductInformationPage> createState() => _ProductInformationPageState();
}

class _ProductInformationPageState extends State<ProductInformationPage> {
  TextEditingController _categoryName = TextEditingController();

  int tabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: tabIndex,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                "Kategori",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            body: SafeArea(child: ProductCategoryScreen())),
      ),
    );
  }
}
