import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kasir/providers/product_provider.dart';
import 'package:kasir/providers/category_provider.dart';
import 'package:kasir/screens/product/modern_form_product.dart';

class FormProduct extends StatelessWidget {
  const FormProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
      ],
      child: const ModernFormProduct(),
    );
  }
}
