// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kasir/services/setting_store_services.dart';
import 'package:kasir/services/transaction_services.dart';
import 'package:kasir/store/cart_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/use_store.dart';

class ActionTransactionDraft extends StatefulWidget {
  const ActionTransactionDraft({
    super.key,
  });

  @override
  State<ActionTransactionDraft> createState() => _ActionTransactionDraftState();
}

class _ActionTransactionDraftState extends State<ActionTransactionDraft> {
  TransactionServices transactionServices = TransactionServices();
  StoreSettingServices storeSettingServices = StoreSettingServices();

  void store(BuildContext context, double total, List<dynamic> details) async {
    final store = await Store.getStore();

    var ppn = await storeSettingServices.lists();
    var nilaiPpn = (ppn.data['data']['ppn'] / 100) * total;

    Map<String, dynamic> body = {
      "store_id": store['id'],
      "store_name": store['name'],
      "customer_id": null,
      "customer_name": null,
      "payment_type": "-",
      "ppn": nilaiPpn,
      "sub_total": total,
      "total": (total + nilaiPpn),
      "status": "draft",
      "details": details,
    };

    var resp = await transactionServices.store(context, body);
    if (resp!.statusCode == 201) {
      Navigator.pop(context);
      Provider.of<CartProvider>(context, listen: false).resetCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> details = Provider.of<CartProvider>(context).list;
    double total = Provider.of<CartProvider>(context).calculateTotalQuantity();

    return ElevatedButton(
      onPressed: () => store(context, total, details),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
        side: const BorderSide(width: 1, color: Colors.black12),
        // shape:
      ),
      child: const Text('simpan'),
    );
  }
}
