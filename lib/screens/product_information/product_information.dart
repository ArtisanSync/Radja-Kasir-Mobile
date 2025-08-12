// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:kasir/screens/category_product/final_category_page.dart';
import 'package:kasir/screens/product_information/merk_product.dart';

class ProductInformationPage extends StatefulWidget {
  const ProductInformationPage({super.key});

  @override
  State<ProductInformationPage> createState() => _ProductInformationPageState();
}

class _ProductInformationPageState extends State<ProductInformationPage> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return const FinalCategoryPage();
  }
}
