import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _storeKey = 'store';
  static const String _subscribeKey = 'subscribe';
  
  // Token management
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<bool> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_tokenKey, token);
  }

  static Future<bool> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_tokenKey);
  }

  // User management
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<bool> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_userKey);
  }

  // Store management
  static Future<Map<String, dynamic>?> getStore() async {
    final prefs = await SharedPreferences.getInstance();
    final storeJson = prefs.getString(_storeKey);
    if (storeJson != null) {
      return jsonDecode(storeJson) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> saveStore(Map<String, dynamic> store) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_storeKey, jsonEncode(store));
  }

  static Future<bool> removeStore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_storeKey);
  }

  // Subscribe management
  static Future<Map<String, dynamic>?> getSubscribe() async {
    final prefs = await SharedPreferences.getInstance();
    final subscribeJson = prefs.getString(_subscribeKey);
    if (subscribeJson != null) {
      return jsonDecode(subscribeJson) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> saveSubscribe(Map<String, dynamic> subscribe) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_subscribeKey, jsonEncode(subscribe));
  }

  static Future<bool> removeSubscribe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_subscribeKey);
  }

  // Clear all data
  static Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_storeKey);
    await prefs.remove(_subscribeKey);
    return true;
  }
}