import 'package:flutter/material.dart';
import 'package:kasir/services/transaction_services.dart';

import '../../home_page.dart';

class ActionTransactionDelete extends StatefulWidget {
  const ActionTransactionDelete({
    required this.id,
    Key? key,
  }) : super(key: key);

  final String id;

  @override
  State<ActionTransactionDelete> createState() =>
      _ActionTransactionDeleteState();
}

class _ActionTransactionDeleteState extends State<ActionTransactionDelete> {
  TransactionServices transactionServices = TransactionServices();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var resp = await transactionServices.destroy(widget.id);
        if (resp!.statusCode == 201) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        width: double.infinity,
        color: Colors.white,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hapus Transaksi"),
              ],
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
