import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Store {
  const Store._();

  static const String _tokenKey = "TOKEN";

  static Future<void> setToken(String token) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_tokenKey);
  }

  static Future<void> saveUser(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString('USER', jsonString);
  }

  static Future<void> saveStore(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString('STORE', jsonString);
  }

  static Future<void> saveSubscribe(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString('SUBSCRIBE', jsonString);
  }

  static Future<void> savePackageSubscribe(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString('PACKAGE_SUBSCRIBE', jsonString);
  }

  static Future<dynamic> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('USER');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  static Future<dynamic> getPackageSubscribe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('PACKAGE_SUBSCRIBE');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  static Future<dynamic> getStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('STORE');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  static Future<dynamic> getSubscribe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('SUBSCRIBE');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  static Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }
}
