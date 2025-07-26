import 'package:flutter/material.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/screens/transaction/action_payment/action_cash.dart';
import 'package:kasir/screens/transaction/action_payment/action_dept.dart';
import 'package:kasir/screens/transaction/action_payment/action_others.dart';
import 'package:kasir/screens/transaction/actions/transaction_delete.dart';

class TransactionPayment extends StatefulWidget {
  const TransactionPayment({required this.order, Key? key}) : super(key: key);

  final Map<String, dynamic> order;

  @override
  State<TransactionPayment> createState() => _TransactionPaymentState();
}

class _TransactionPaymentState extends State<TransactionPayment> {
  List<dynamic> itemsPaymentOther = [
    {"value": "transfer", "label": "Transfer"},
    {"value": "debit", "label": "Debit"},
    {"value": "vis", "label": "VISA"},
    {"value": "master_card", "label": "Master Card"},
    {"value": "e_ovo", "label": "OVO"},
    {"value": "e_dana", "label": "DANA"},
    {"value": "e_gopay", "label": "GO-PAY"},
    {"value": "e_linkaja", "label": "LinkAja"},
    {"value": "e_shopeepay", "label": "ShopeePay"},
    {"value": "q_ris", "label": "QRIS"},
    {"value": "lainnya", "label": "LAINNYA"},
  ];
  openOthers() {
    return showModalBottomSheet(
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Wrap(
          children: itemsPaymentOther.map((e) {
            return ListTile(
              title: Text('${e['label']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActionPayOthers(
                      order: widget.order,
                      type: e,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Pembayaran",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Total Tagihan"),
                  Text(
                    CurrencyFormat.convertToIdr(widget.order['total'] ?? 0, 0),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Text(
                "Pilih Pembayaran",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const Divider(height: 0),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActionPayCash(order: widget.order),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                width: double.infinity,
                color: Colors.white,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Tunai"), Icon(Icons.chevron_right)],
                ),
              ),
            ),
            const Divider(height: 0),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ActionDept(order: widget.order)),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                width: double.infinity,
                color: Colors.white,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Kasbon"), Icon(Icons.chevron_right)],
                ),
              ),
            ),
            const Divider(height: 0),
            InkWell(
              onTap: () => openOthers(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                width: double.infinity,
                color: Colors.white,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pembayaran Lainnya"),
                        Text(
                          "Pembayaran hanya sebangai label",
                          style: TextStyle(
                              fontSize: 10, color: AppColor.textPrimary),
                        ),
                      ],
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const Divider(height: 0),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Text(
                "Lainnya",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
            const Divider(height: 0),
            ActionTransactionDelete(id: widget.order['id']),
            const Divider(height: 0),
          ],
        ),
      ),
    );
  }
}
