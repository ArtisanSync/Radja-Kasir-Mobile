import 'dart:convert';

import 'package:kasir/core/use_store.dart';

void main() async {
  // Test menyimpan dummy store data
  await Store.saveStore({
    'id': '6753c8e16043ddbe3a89779f',
    'name': 'My Store',
    'address': 'Test Address',
    'phone': '1234567890',
  });

  // Test menyimpan dummy user data
  await Store.saveUser({
    'id': '67522216e7b8b2d4e6ed4a14',
    'name': 'Test User',
    'email': 'test@example.com',
  });

  // Test get store
  final store = await Store.getStore();
  print('Store: $store');

  final user = await Store.getUser();
  print('User: $user');
}
