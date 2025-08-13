import 'package:flutter/material.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/screens/report/sales_report_page.dart';
import 'package:kasir/screens/report/stock_report_page.dart';
import 'package:kasir/screens/report/dashboard_report_page.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavDrawer(),
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
        leading: const MenuBuilder(),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildMenuItem(
            title: 'Dashboard',
            subtitle: 'Ringkasan performa bisnis',
            icon: Icons.dashboard_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardReportPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 3),
          _buildMenuItem(
            title: 'Laporan Penjualan',
            subtitle: 'Detail transaksi dan pendapatan',
            icon: Icons.trending_up_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalesReportPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 3),
          _buildMenuItem(
            title: 'Laporan Stok',
            subtitle: 'Status inventori dan stok produk',
            icon: Icons.inventory_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StockReportPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: Colors.white,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.blue[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
