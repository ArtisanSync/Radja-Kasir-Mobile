import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kasir/components/text_input.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/report_model.dart';
import 'package:kasir/services/report_services.dart';

class ReportDailyPage extends StatefulWidget {
  const ReportDailyPage({Key? key}) : super(key: key);

  @override
  State<ReportDailyPage> createState() => _ReportDailyPageState();
}

class _ReportDailyPageState extends State<ReportDailyPage> {
  ReportServices reportServices = ReportServices();
  Recap recap = Recap();
  DateTime _selectedDate = DateTime.now();
  String dateString = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> fetchData() async {
    var resp = await reportServices.daily({'date': dateString});
    var data = Report.fromJson(resp.data);
    setState(() {
      recap = data.data?.recap as Recap;
    });
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
    fetchData();
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
        title: Text(
          "Laporan Harian",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => fetchData(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateString),
                      ElevatedButton(
                        onPressed: () => selectDate(context),
                        style: ElevatedButton.styleFrom(elevation: 0),
                        child: const Row(
                          children: [
                            Icon(Icons.calendar_month),
                            SizedBox(width: 10),
                            Text("Pilih tanggal"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.sp, horizontal: 20.sp),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1, color: AppColor.light),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Penjualan"),
                        Text(CurrencyFormat.convertToIdr(recap.total ?? 0, 0),
                            style: TextStyle(
                                fontSize: 22.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.sp, horizontal: 20.sp),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1, color: AppColor.light),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Produk Terjual"),
                        Text(recap.product.toString() ?? '0',
                            style: TextStyle(
                                fontSize: 22.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.sp, horizontal: 20.sp),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1, color: AppColor.light),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Transaksi"),
                        Text(recap.totalOrder.toString() ?? '0',
                            style: TextStyle(
                                fontSize: 22.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
