import 'package:flutter/material.dart';
import 'package:kasir/core/print_function.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/screens/sandbox/share_transaction.dart';
import 'package:kasir/screens/transaction/transaction_payment.dart';
import 'package:kasir/services/profile_services.dart';
import 'package:kasir/services/transaction_services.dart';
import 'package:kasir/utlis/share_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/profile_model.dart';
import '../../utlis/pdf_utils.dart';

class TransactionDetail extends StatefulWidget {
  const TransactionDetail({
    required this.id,
    super.key,
  });

  final String id;

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
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
        product = {...product, "store": data.toJson(), "items": items};
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
        backgroundColor: Colors.white,
        title: const Text(
          "Detail Transaksi",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                print("share");
                XFile file = await PDFUtils.generateReceipt(product);
                await ShareUtils().shareFile(file);
                print(file);
              },
              icon: const Icon(Icons.share)),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "No. Pesanan",
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "${product['inv_number']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Jenis Pembayaran",
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "${product['payment_type']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "PPN",
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                CurrencyFormat.convertToIdr(
                                    product['ppn'] ?? 0, 0),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sub Total",
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                CurrencyFormat.convertToIdr(
                                    product['sub_total'] ?? 0, 0),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                CurrencyFormat.convertToIdr(
                                    product['total'] ?? 0, 0),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Status",
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "${product['status']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "List Items",
                            style:
                                TextStyle(fontSize: 18, color: Colors.black26),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columnSpacing: 20.0,
                            columns: const [
                              DataColumn(
                                  label: Text('Produk',
                                      style: TextStyle(fontSize: 12))),
                              DataColumn(
                                  label: Text('Qty',
                                      style: TextStyle(fontSize: 12))),
                              DataColumn(
                                  label: Text('Disc',
                                      style: TextStyle(fontSize: 12))),
                              DataColumn(
                                  label: Text('Total',
                                      style: TextStyle(fontSize: 12))),
                            ],
                            rows: items
                                .map(
                                  (item) => DataRow(cells: [
                                    DataCell(Text(item['product_name'])),
                                    DataCell(Text(item['quantity'].toString())),
                                    DataCell(Text(CurrencyFormat.convertToIdr(
                                        item['discount'] ?? 0, 0))),
                                    DataCell(Text(CurrencyFormat.convertToIdr(
                                        item['total'] - item['discount'] ?? 0,
                                        0))),
                                  ]),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 30)
                      ],
                    ),
                  ),
                ),
                ActionsTransactionDetail(
                  order: product,
                ),
              ],
            ),
    );
  }
}

class ActionsTransactionDetail extends StatelessWidget {
  const ActionsTransactionDetail({
    required this.order,
    Key? key,
  }) : super(key: key);
  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Print print = const Print();
                print.base(order);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                side: const BorderSide(width: 1, color: Colors.black12),
                // shape:
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.print, size: 18),
                  SizedBox(width: 5),
                  Text('Print'),
                ],
              ),
            ),
          ),

          // XFile file = await PDFUtils.generateReceipt(order);
          //     await ShareUtils().shareFile(file);
          order['status'] == 'draft'
              ? const SizedBox(width: 10)
              : const SizedBox(),
          order['status'] == 'draft'
              ? Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TransactionPayment(order: order)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.green,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wallet,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text('Bayar', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
