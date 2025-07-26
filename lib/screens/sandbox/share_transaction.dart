import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/services/profile_services.dart';
import 'package:kasir/services/transaction_services.dart';

import '../../models/profile_model.dart';

class SandboxShareTransaction extends StatefulWidget {
  const SandboxShareTransaction({
    required this.id,
    super.key,
  });

  final String id;

  @override
  State<SandboxShareTransaction> createState() =>
      _SandboxShareTransactionState();
}

class _SandboxShareTransactionState extends State<SandboxShareTransaction> {
  ProfileServices profileServices = ProfileServices();
  TransactionServices transactionServices = TransactionServices();

  Map<String, dynamic> product = {};
  List<dynamic> items = [];
  bool loading = false;

  Future<void> fetchData() async {
    setState(() {
      loading = true;
    });
    var resp = await transactionServices.detail(widget.id);
    if (resp!.statusCode == 200) {
      setState(() {
        product = resp!.data['data'] as Map<String, dynamic>;
        items = product['items'] as List<dynamic>;
      });

      getData();
    }
  }

  Future<dynamic> getData() async {
    var resp = await profileServices.profile();
    var data = Profile.fromJson(resp.data['data']);
    if (resp!.statusCode == 200) {
      setState(() {
        product = {...product, "store": data.toJson()};
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('shared transaction'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  product['store']['logo'],
                  scale: 12.sp,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                product['store']['store'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(product['store']['address'],
                  style: TextStyle(fontSize: 10.sp)),
            ),
            Center(
              child: Text("Whatsapp: ${product['store']['whatsapp']}",
                  style: TextStyle(fontSize: 10.sp)),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tanggal"),
                Text(DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now()))
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Text("No. Pesanan :"),
                SizedBox(width: 10.sp),
                Text(product['inv_number']),
              ],
            ),
            Row(
              children: [
                const Text("Pembayaran :"),
                SizedBox(width: 10.sp),
                Text(product['payment_type']),
              ],
            ),
            Row(
              children: [
                const Text("Kasir :"),
                SizedBox(width: 10.sp),
                Text(product['store']['name']),
              ],
            ),
            Row(
              children: [
                const Text("PPN :"),
                SizedBox(width: 10.sp),
                Text(CurrencyFormat.convertToIdr(product['ppn'] ?? 0, 0)),
              ],
            ),
            Row(
              children: [
                const Text("Sub Total :"),
                SizedBox(width: 10.sp),
                Text(CurrencyFormat.convertToIdr(product['sub_total'] ?? 0, 0)),
              ],
            ),
            Row(
              children: [
                const Text("Total :"),
                SizedBox(width: 10.sp),
                Text(CurrencyFormat.convertToIdr(product['total'] ?? 0, 0)),
              ],
            ),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 20.0,
                columns: const [
                  DataColumn(
                      label: Text('Produk', style: TextStyle(fontSize: 12))),
                  DataColumn(
                      label: Text('Qty', style: TextStyle(fontSize: 12))),
                  DataColumn(
                      label: Text('Total', style: TextStyle(fontSize: 12))),
                ],
                rows: items
                    .map(
                      (item) => DataRow(cells: [
                        DataCell(Text(item['product_name'])),
                        DataCell(Text(item['quantity'].toString())),
                        DataCell(Text(CurrencyFormat.convertToIdr(
                            item['total'] ?? 0, 0))),
                      ]),
                    )
                    .toList(),
              ),
            ),
            const Divider(),
            Center(
              child: Text("Terima Kasih, ${product['store']['store']}"),
            )
          ],
        ),
      ),
    );
  }
}
