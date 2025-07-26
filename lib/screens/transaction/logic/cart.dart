import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kasir/models/home_product.dart';
import 'package:provider/provider.dart';

import '../../../store/cart_provider.dart';

class CartActions {
  const CartActions();

  void addToChart(BuildContext context, ListProduct item) {
    List<dynamic> listCart =
        Provider.of<CartProvider>(context, listen: false).list;
    int idxCart = listCart.indexWhere((data) => data['id'] == item.variantId);

    Map<String, dynamic> newItem = {
      "id": item.variantId,
      "product_name": item.productName,
      "capital_price": item.capitalPrice,
      "unit_price": item.unitPrice,
      "quantity": 1,
      "dic_rp": item.dicRp,
      "dic_percent": item.dicPercent,
      "total_dic": item.dicRp! + (item.dicPercent! / 100) * item.unitPrice!,
      "total": item.unitPrice,
      "max_quantity": item.quantity
    };

    // print(newItem);
    if (item.quantity! > 0 && idxCart < 0) {
      Provider.of<CartProvider>(context, listen: false).addItem(newItem);
    } else if (idxCart >= 0) {
      if (listCart[idxCart]['quantity'] >= item.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah tidak menucukupi'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Provider.of<CartProvider>(context, listen: false).addItem(newItem);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah tidak menucukupi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void incrementQty(BuildContext context, dynamic id) {
    List<dynamic> listCart =
        Provider.of<CartProvider>(context, listen: false).list;
    int idxCart = listCart.indexWhere((data) => data['id'] == id);

    if (listCart[idxCart]['quantity'] >= listCart[idxCart]['max_quantity']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah tidak menucukupi'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Provider.of<CartProvider>(context, listen: false).incrementQuantity(id);
    }
  }
}
