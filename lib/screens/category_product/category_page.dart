// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:kasir/components/text_input.dart';
import 'package:kasir/services/product_services.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  TextEditingController _name = TextEditingController();
  Future<List<dynamic>>? _category;
  int? _categoryId;
  final ProductServices _productServices = ProductServices();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _category = _fetchCategories();
    });
  }

  Future<List<dynamic>> _fetchCategories() async {
    final result = await _productServices.listCategory();
    if (result['success'] == true) {
      return result['data'] ?? [];
    } else {
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Failed to load categories')),
        );
      }
      return [];
    }
  }

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
      final result = await _productServices.removeCategory(id.toString());
      if (result['success'] == true) {
        _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(result['message'] ?? 'Category deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(result['message'] ?? 'Failed to delete category')),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting category')),
        );
      }
    }
  }

  // store data
  void store(BuildContext context) async {
    try {
      final result = await _productServices.storeCategory(_name.text);
      if (result['success'] == true) {
        _name.clear();
        _loadCategories();
        Navigator.of(context).pop();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(result['message'] ?? 'Category created successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(result['message'] ?? 'Failed to create category')),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating category')),
        );
      }
    }
  }

  // update data
  void update(BuildContext context) async {
    try {
      final result = await _productServices.updateCategory(
        {'name': _name.text},
        _categoryId.toString(),
      );
      if (result['success'] == true) {
        _name.clear();
        _loadCategories();
        Navigator.of(context).pop();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(result['message'] ?? 'Category updated successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(result['message'] ?? 'Failed to update category')),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating category')),
        );
      }
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
            onPressed: () => _openForm(context, isEdit: false),
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _category,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error loading categories'),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadCategories,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
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
                      _openForm(context, isEdit: true);
                    },
                  );
                },
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada kategori'),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _openForm(context, isEdit: false),
                    child: Text('Tambah Kategori'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {bool isEdit = false}) {
    // Reset form for new category
    if (!isEdit) {
      _categoryId = null;
      _name.clear();
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
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
