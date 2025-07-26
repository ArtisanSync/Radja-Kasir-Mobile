// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kasir/components/text_input.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/models/merk_model.dart';
import 'package:kasir/providers/db_merk.dart';

class ProductMerkScreen extends StatefulWidget {
  const ProductMerkScreen({super.key});

  @override
  State<ProductMerkScreen> createState() => _ProductMerkScreenState();
}

class _ProductMerkScreenState extends State<ProductMerkScreen> {
  TextEditingController _name = TextEditingController();
  var _merks = readMerk();
  int? merkId;

  void submit(BuildContext context) {
    if (merkId == null) {
      store(context);
    } else {
      update(context);
    }
  }

  void store(context) async {
    Map<String, dynamic> store = await Store.getStore();
    final body = MerkModel(name: _name.text, storeId: store['id']);
    try {
      await addMerk(body);
      _name.clear();
      setState(() {
        _merks = readMerk();
      });
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // update data
  void update(BuildContext context) async {
    try {
      await updateMerk(
        merkId as int,
        MerkModel(name: _name.text),
      );
      _name.clear();

      setState(() {
        _merks = readMerk();
        merkId = null;
      });
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void delete(int id) async {
    try {
      await deleteMerk(id);
      setState(() {
        _merks = readMerk();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _merks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                var i = snapshot.data?[index];
                return ListTile(
                  title: Text("${i?['name']}"),
                  trailing: IconButton(
                    onPressed: () => delete(i?['id']),
                    icon: Icon(
                      Icons.delete_forever,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      merkId = i?['id'];
                      _name.text = i?['name'];
                    });
                    _openForm(context);
                  },
                );
              },
            );
          }
          return Center(
            child: Text('Merk kosong'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _openForm(context),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          content: Container(
            height: 160,
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextInput(label: 'Nama Merk', controller: _name),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Batal')),
                    TextButton(
                        onPressed: () => submit(context),
                        child: Text('Submit')),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
