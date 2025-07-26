import 'dart:async';
import 'package:kasir/models/category_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDatabase() async {
  return openDatabase(join(await getDatabasesPath(), "category.db"),
      onCreate: (db, version) {
    return db.execute(
      'CREATE TABLE categories(id INTEGER PRIMARY KEY, name CHAR, storeId INTEGER)',
    );
  }, version: 1);
}

Future<List<Map>> readCategory() async {
  final db = await initDatabase();
  return db.query('categories');
}

Future<CategoryModel> addCategory(CategoryModel categories) async {
  final db = await initDatabase();
  await db.insert(
    'categories',
    categories.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  return categories;
}

Future<CategoryModel> updateCategory(int id, CategoryModel categories) async {
  final db = await initDatabase();
  await db.update(
    'categories',
    {'name': categories.name},
    where: 'id = ?',
    whereArgs: [id],
  );

  return categories;
}

Future deleteCategory(int id) async {
  final db = await initDatabase();
  await db.delete(
    'categories',
    where: 'id = ?',
    whereArgs: [id],
  );

  return id;
}
