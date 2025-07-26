import 'dart:async';

import 'package:kasir/models/product_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> productDatabase() async {
  return openDatabase(join(await getDatabasesPath(), "product.db"),
      onCreate: (db, version) {
    return db.execute(
      "CREATE TABLE products(id INTEGER PRIMARY KEY, code CHAR, name CHAR, merk CHAR, category CHAR, price DOUBLE DEFAULT 0.00, discount INTEGER, tax INTEGER, is_favorite INTEGER DEFAULT 0)",
    );
  }, version: 2);
}

Future<Product> addProduct(Product product) async {
  print(product);
  final db = await productDatabase();
  await db.insert(
    'products',
    product.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  return product;
}

Future<Product> updateProduct(List id, Product product) async {
  final db = await productDatabase();
  await db.update(
    'products',
    product.toMap(),
    where: 'id = ?',
    whereArgs: id,
  );

  return product;
}

Future deleteProduct(int id) async {
  final db = await productDatabase();
  await db.delete(
    'products',
    where: 'id = ?',
    whereArgs: [id],
  );

  return id;
}

Future<List<Map>> readProducts() async {
  final db = await productDatabase();
  return db.query('products');
}

Future<Map<String, dynamic>?> getDataById(int id) async {
  final db = await productDatabase();
  final List<Map<String, dynamic>> maps = await db.query(
    'products',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return maps.first;
  } else {
    return null;
  }
}
