import 'package:flutter/material.dart';
import 'package:kasir/models/packages_model.dart';
import 'package:kasir/screens/product/form_product.dart';

class ActionProduct {
  void addProductWithPackage(
      UserSubsModel userSubs, List<dynamic> products, ctx) {
    var subs = userSubs.subscibe;
    var package = userSubs.package;
    if (subs?.endDate != null) {
      String _subsEnd = subs?.endDate as String;
      DateTime _currentDate = DateTime.now();
      DateTime _endDate = DateTime.parse(_subsEnd);
      if (_currentDate.isBefore(_endDate)) {
        var _packageMeta = package?.meta;
        if (_packageMeta?.isLimitProduct != null) {
          print(_packageMeta?.isLimitProduct);
          if (_packageMeta?.isLimitProduct == true) {
            if (int.parse(_packageMeta?.productLimit as String) >
                products.length) {
              Route detail = MaterialPageRoute(
                builder: (ctx) => const FormProduct(),
              );

              Navigator.push(ctx, detail).then(
                (value) => {},
              );
            } else {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                    content: Text('Anda mencapai limit penambahan produk')),
              );
            }
          } else {
            Route detail = MaterialPageRoute(
              builder: (ctx) => const FormProduct(),
            );

            Navigator.push(ctx, detail).then(
              (value) => {},
            );
          }
        } else {
          print(_packageMeta?.isLimitProduct);
        }
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Paket anda kadaluarsa')),
        );
      }
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Anda tidak memiliki paket aktif.')),
      );
    }
    //  2. Check package add able product
  }
}
