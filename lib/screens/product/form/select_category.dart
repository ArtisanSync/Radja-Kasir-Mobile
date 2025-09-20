// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/providers/category_providers.dart';

class SelectCategory extends ConsumerWidget {
  SelectCategory({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryProvider);
    final List<CategoryModel> categories = categoryState.categories;
    final bool loading = categoryState.isLoading;

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
                  title: Text(item.name),
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                );
              },
            ),
    );
  }
}