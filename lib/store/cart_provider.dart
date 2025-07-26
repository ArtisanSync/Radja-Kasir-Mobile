import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  List<dynamic> cart = [];

  List<dynamic> get list => cart;

  double calculateTotalQuantity() {
    double total = 0;
    for (var item in cart) {
      total += (item['total'] - item['total_dic']) as double;
    }
    return total;
  }

  void addItem(Map<String, dynamic> newItem) {
    int index = cart.indexWhere((item) => item['id'] == newItem['id']);
    if (index != -1) {
      var totalRp = cart[index]['unit_price'] * (cart[index]['quantity'] + 1);
      var dicRp = cart[index]['dic_rp'] * (cart[index]['quantity'] + 1);
      var dicPercent = cart[index]['dic_percent'];

      cart[index]['quantity']++;
      cart[index]['total'] = totalRp;
      cart[index]['total_dic'] = dicRp + (dicPercent / 100) * totalRp;
    } else {
      cart.add(newItem);
    }
    notifyListeners();
  }

  void remove(int id) {
    cart.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  void incrementQuantity(int id) {
    int index = cart.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      cart[index]['quantity']++;

      var totalRp = cart[index]['unit_price'] * cart[index]['quantity'];
      var dicRp = cart[index]['dic_rp'] * cart[index]['quantity'];
      var dicPercent = cart[index]['dic_percent'];

      cart[index]['total'] = totalRp;
      cart[index]['total_dic'] = dicRp + (dicPercent / 100) * totalRp;
      notifyListeners();
    }
  }

  void decrementQuantity(int id) {
    int index = cart.indexWhere((item) => item['id'] == id);
    if (index != -1 && cart[index]['quantity'] > 1) {
      cart[index]['quantity']--;

      var totalRp = cart[index]['unit_price'] * cart[index]['quantity'];
      var dicRp = cart[index]['dic_rp'] * cart[index]['quantity'];
      var dicPercent = cart[index]['dic_percent'];

      cart[index]['total'] = totalRp;
      cart[index]['total_dic'] = dicRp + (dicPercent / 100) * totalRp;

      notifyListeners();
    }
  }

  void resetCart() {
    cart = [];
    notifyListeners();
  }
}
