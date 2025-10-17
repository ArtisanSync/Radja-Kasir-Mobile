import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  const Store._();

  static const String _tokenKey = "TOKEN";
  // Compatibility keys with helpers/store.dart
  static const String _tokenKeyLower = 'token';
  static const String _userKeyUpper = 'USER';
  static const String _userKeyLower = 'user';
  static const String _storeKeyUpper = 'STORE';
  static const String _storeKeyLower = 'store';
  static const String _subscribeKeyUpper = 'SUBSCRIBE';
  static const String _subscribeKeyLower = 'subscribe';
  static const String _packageSubscribeKeyUpper = 'PACKAGE_SUBSCRIBE';
  static const String _packageSubscribeKeyLower = 'package_subscribe';

  // Save Token
  static Future<void> setToken(String token) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
    // Write lowercase key for compatibility
    await preferences.setString(_tokenKeyLower, token);
  }

  // Get Token
  static Future<String?> getToken() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_tokenKey) ?? preferences.getString(_tokenKeyLower);
  }

  // Save User Data
  static Future<void> saveUser(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString(_userKeyUpper, jsonString);
    // Write lowercase key for compatibility
    await prefs.setString(_userKeyLower, jsonString);
  }

  // Save Store Data
  static Future<void> saveStore(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString(_storeKeyUpper, jsonString);
    // Write lowercase key for compatibility
    await prefs.setString(_storeKeyLower, jsonString);
  }

  // Save Subscription Data
  static Future<void> saveSubscribe(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString(_subscribeKeyUpper, jsonString);
    // Write lowercase key for compatibility
    await prefs.setString(_subscribeKeyLower, jsonString);
  }

  // Save Package Subscription Data
  static Future<void> savePackageSubscribe(Object responseObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(responseObject);
    await prefs.setString(_packageSubscribeKeyUpper, jsonString);
    // Also write lowercase variant if used anywhere
    await prefs.setString(_packageSubscribeKeyLower, jsonString);
  }

  // Get User Data
  static Future<dynamic> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_userKeyUpper) ?? prefs.getString(_userKeyLower);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Get Package Subscription Data
  static Future<dynamic> getPackageSubscribe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_packageSubscribeKeyUpper) ?? prefs.getString(_packageSubscribeKeyLower);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Get Store Data
  static Future<dynamic> getStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_storeKeyUpper) ?? prefs.getString(_storeKeyLower);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Get Subscription Data
  static Future<dynamic> getSubscribe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_subscribeKeyUpper) ?? prefs.getString(_subscribeKeyLower);
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