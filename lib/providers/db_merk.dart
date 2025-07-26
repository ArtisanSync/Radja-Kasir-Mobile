import 'dart:async';
import 'package:kasir/models/merk_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDatabase() async {
  return openDatabase(join(await getDatabasesPath(), "merk.db"),
      onCreate: (db, version) {
    return db.execute(
      'CREATE TABLE merks(id INTEGER PRIMARY KEY, name CHAR, storeId INTEGER)',
    );
  }, version: 1);
}

Future<List<Map>> readMerk() async {
  final db = await initDatabase();
  return db.query('merks');
}

Future<MerkModel> addMerk(MerkModel merk) async {
  final db = await initDatabase();
  await db.insert(
    'merks',
    merk.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  return merk;
}

Future<MerkModel> updateMerk(int id, MerkModel merk) async {
  final db = await initDatabase();
  await db.update(
    'merks',
    {'name': merk.name},
    where: 'id = ?',
    whereArgs: [id],
  );

  return merk;
}

Future deleteMerk(int id) async {
  final db = await initDatabase();
  await db.delete(
    'merks',
    where: 'id = ?',
    whereArgs: [id],
  );

  return id;
}
