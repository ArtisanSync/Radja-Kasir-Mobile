import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/order_model.dart';
import 'package:kasir/screens/transaction/transaction_detail.dart';
import 'package:kasir/services/transaction_services.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TransactionServices transactionServices = TransactionServices();

  List<Datum> history = [];

  Future<void> fetchData() async {
    var resp = await transactionServices.list();
    var data = Order.fromJson(resp.data);
    if (resp!.statusCode == 200) {
      setState(() {
        history = data.data;
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
            "History",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () => fetchData(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                var item = history[index];
                return InkWell(
                  onTap: () {
                    Route detail = MaterialPageRoute(
                      builder: (context) => TransactionDetail(id: item.id),
                    );

                    Navigator.push(context, detail).then(
                      (value) => fetchData(),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.3, color: Colors.black26),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.invNumber,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Total : ${item.total}",
                              style: TextStyle(fontSize: 14.sp),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.status,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: item.status == 'draft'
                                    ? Colors.blue
                                    : Colors.green,
                              ),
                            ),
                            Text(item.created),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }
}
