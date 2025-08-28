import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  const Store._();

  static const String _tokenKey = "TOKEN";

  // Save Token
  static Future<void> setToken(String token) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
  }

  // Get Token
  static Future<String?> getToken() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_tokenKey);
  }

  // Save User Data
  static Future<void> saveUser(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString('USER', jsonString);
  }

  // Save Store Data
  static Future<void> saveStore(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString('STORE', jsonString);
  }

  // Save Subscription Data
  static Future<void> saveSubscribe(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString('SUBSCRIBE', jsonString);
  }

  // Save Package Subscription Data
  static Future<void> savePackageSubscribe(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString('PACKAGE_SUBSCRIBE', jsonString);
  }

  // Get User Data
  static Future<dynamic> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('USER');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Get Package Subscription Data
  static Future<dynamic> getPackageSubscribe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('PACKAGE_SUBSCRIBE');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Get Store Data
  static Future<dynamic> getStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('STORE');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Get Subscription Data
  static Future<dynamic> getSubscribe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('SUBSCRIBE');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Clear all saved data
  static Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }
}