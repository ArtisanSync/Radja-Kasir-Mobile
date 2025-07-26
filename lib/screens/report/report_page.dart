import 'package:flutter/material.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/screens/report/report_day.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Laporan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: MenuBuilder(),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportDailyPage(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              color: Colors.white,
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Penjualan',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.chevron_right)
                  ]),
            ),
          ),
          const SizedBox(height: 3),
          InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              color: Colors.white,
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keuntungan',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.chevron_right)
                  ]),
            ),
          ),
          const SizedBox(height: 3),
          InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              color: Colors.white,
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stok',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.chevron_right)
                  ]),
            ),
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }
}
