import 'package:flutter/material.dart';
import 'package:kasir/services/report_services.dart';
import 'package:kasir/helpers/currency_format.dart';

class StockReportPage extends StatefulWidget {
  const StockReportPage({Key? key}) : super(key: key);

  @override
  State<StockReportPage> createState() => _StockReportPageState();
}

class _StockReportPageState extends State<StockReportPage> {
  final ReportServices _reportServices = ReportServices();
  Map<String, dynamic>? _reportData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _reportServices.getStockReport();
      
      if (result['success'] && result['data'] != null) {
        setState(() {
          _reportData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load stock report';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading stock report: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadReport() async {
    try {
      final success = await _reportServices.downloadStockReport();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download started. Please check your downloads folder.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download report'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Laporan Stok",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (_reportData != null)
            IconButton(
              onPressed: _downloadReport,
              icon: const Icon(Icons.download),
              tooltip: 'Download Excel',
            ),
          IconButton(
            onPressed: _loadReport,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReport,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadReport,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_reportData == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummarySection(),
          const SizedBox(height: 16),
          _buildProductsSection(),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final summary = _reportData!['summary'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Stok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Produk',
                  summary['totalProducts'].toString(),
                  Icons.inventory_2,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Total Varian',
                  summary['totalVariants'].toString(),
                  Icons.category,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Nilai Stok',
                  CurrencyFormat.convertToIdr(summary['totalStockValue'], 0),
                  Icons.attach_money,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Stok Menipis',
                  summary['lowStockItems'].toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    final products = _reportData!['products'] as List<dynamic>;

    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Tidak Ada Produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              'Belum ada produk yang terdaftar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Daftar Produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final product = products[index];
              return ExpansionTile(
                title: Text(
                  product['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${product['category']} • ${product['totalQuantity']} unit • ${CurrencyFormat.convertToIdr(product['totalStockValue'], 0)}',
                ),
                leading: product['isLowStock']
                    ? Icon(Icons.warning, color: Colors.orange[600])
                    : Icon(Icons.inventory_2, color: Colors.blue[600]),
                children: [
                  if (product['variants'] != null && (product['variants'] as List).isNotEmpty)
                    ...((product['variants'] as List).map((variant) => ListTile(
                          contentPadding: const EdgeInsets.only(left: 60, right: 16),
                          title: Text(variant['name']),
                          subtitle: Text('${variant['unit']} • Stok: ${variant['quantity']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormat.convertToIdr(variant['price'], 0),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Modal: ${CurrencyFormat.convertToIdr(variant['capitalPrice'], 0)}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        )))
                    else
                      const ListTile(
                        contentPadding: EdgeInsets.only(left: 60, right: 16),
                        title: Text('Tidak ada varian'),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
