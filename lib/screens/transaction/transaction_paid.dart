import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kasir/core/print_function.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/screens/home_page.dart';
import 'package:kasir/services/transaction_services.dart';
import 'package:kasir/utlis/pdf_utils.dart';
import 'package:kasir/utlis/share_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/profile_model.dart';
import '../../services/profile_services.dart';

class TransactionPaidScreen extends StatefulWidget {
  const TransactionPaidScreen({
    required this.id,
    Key? key,
  }) : super(key: key);

  final String id;

  @override
  State<TransactionPaidScreen> createState() => _TransactionPaidScreenState();
}

class _TransactionPaidScreenState extends State<TransactionPaidScreen> {
  ProfileServices profileServices = ProfileServices();
  TransactionServices transactionServices = TransactionServices();
  Map<String, dynamic> order = {};
  List<dynamic> items = [];
  bool loading = false;

  Future<dynamic> getData() async {
    var resp = await profileServices.profile();
    var data = Profile.fromJson(resp.data['data']);
    if (resp!.statusCode == 200) {
      setState(() {
        order = {...order, "store": data.toJson()};
        loading = false;
      });
    }
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
    });
    var resp = await transactionServices.detail(widget.id);
    if (resp!.statusCode == 200) {
      order = resp!.data['data'] as Map<String, dynamic>;
      items = order['items'] as List<dynamic>;
      getData();
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
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green[700],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Berhasil",
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      CurrencyFormat.convertToIdr(order['total'] ?? 0, 0),
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: AppColor.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("No. invoice",
                                  style: TextStyle(fontSize: 14.sp)),
                              Text("${order['inv_number']}",
                                  style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Pembayaran",
                                  style: TextStyle(fontSize: 14.sp)),
                              Text("${order['payment_type']}",
                                  style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("PPN", style: TextStyle(fontSize: 14.sp)),
                              Text(
                                  CurrencyFormat.convertToIdr(
                                      order['ppn'] ?? 0, 0),
                                  style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Sub Total",
                                  style: TextStyle(fontSize: 14.sp)),
                              Text(
                                  CurrencyFormat.convertToIdr(
                                      order['sub_total'] ?? 0, 0),
                                  style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total", style: TextStyle(fontSize: 14.sp)),
                              Text(
                                  CurrencyFormat.convertToIdr(
                                      order['total'] ?? 0, 0),
                                  style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Diterima",
                                  style: TextStyle(fontSize: 14.sp)),
                              Text(
                                  CurrencyFormat.convertToIdr(
                                      order['amount_receive'] ?? 0, 0),
                                  style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Kembalian",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  CurrencyFormat.convertToIdr(
                                      order != null
                                          ? (order['amount_receive'] -
                                              order["total"])
                                          : 0,
                                      0),
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 30),
                          ActionsWidget(order: order)
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

class ActionsWidget extends StatelessWidget {
  const ActionsWidget({
    required this.order,
    Key? key,
  }) : super(key: key);

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      width: double.infinity,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              XFile file = await PDFUtils.generateReceipt(order);
              await ShareUtils().shareFile(file);
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
                Icon(Icons.share),
                SizedBox(width: 10),
                Text('Share'),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage()),
                    );
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
                      Text('Kembali'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
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
            ],
          ),
        ],
      ),
    );
  }
}
