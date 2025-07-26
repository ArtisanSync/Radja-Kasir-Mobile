// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:kasir/components/text_input.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/models/category_model.dart';
import 'package:kasir/providers/db_category.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  TextEditingController _name = TextEditingController();
  var _category = readCategory();
  int? _categoryId;

  void submit(BuildContext context) async {
    if (_categoryId == null) {
      store(context);
    } else {
      update(context);
    }
  }

  // delete data
  void delete(int id) async {
    try {
      await deleteCategory(id);
      setState(() {
        _category = readCategory();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // store data
  void store(BuildContext context) async {
    Map<String, dynamic> store = await Store.getStore();
    final body = CategoryModel(name: _name.text, storeId: store['id']);
    try {
      await addCategory(body);
      _name.clear();
      setState(() {
        _category = readCategory();
      });
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // update data
  void update(BuildContext context) async {
    try {
      await updateCategory(
        _categoryId as int,
        CategoryModel(name: _name.text),
      );
      _name.clear();
      setState(() {
        _category = readCategory();
      });
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Kategori produk",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _openForm(context),
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _category,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  var i = snapshot.data?[index];
                  return ListTile(
                    title: Text("${i?['name']}"),
                    trailing: IconButton(
                      onPressed: () => delete(i?['id']),
                      icon: Icon(Icons.delete_forever),
                    ),
                    onTap: () {
                      setState(() {
                        _categoryId = i?['id'];
                        _name.text = i?['name'];
                      });
                      _openForm(context);
                    },
                  );
                },
              );
            }
            return Center(
              child: Text('Kategory kosong'),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextInput(label: 'Nama Kategori', controller: _name),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Simpan'),
              onPressed: () => submit(context),
            ),
          ],
        );
      },
    );
  }
}
