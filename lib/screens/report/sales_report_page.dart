import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir/models/report_sales_model.dart';
import 'package:kasir/services/report_services.dart';
import 'package:kasir/helpers/currency_format.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final ReportServices _reportServices = ReportServices();
  SalesReportModel? _reportData;
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'realtime';
  DateTimeRange? _customDateRange;

  final List<Map<String, String>> _periods = [
    {'value': 'realtime', 'label': 'Bulan Ini'},
    {'value': '1', 'label': '1 Bulan Lalu'},
    {'value': '6', 'label': '6 Bulan Lalu'},
    {'value': '12', 'label': '12 Bulan Lalu'},
    {'value': 'custom', 'label': 'Pilih Tanggal'},
  ];

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
      String? startDate;
      String? endDate;
      
      if (_selectedPeriod == 'custom' && _customDateRange != null) {
        startDate = DateFormat('yyyy-MM-dd').format(_customDateRange!.start);
        endDate = DateFormat('yyyy-MM-dd').format(_customDateRange!.end);
      }

      final result = await _reportServices.getSalesReport(
        period: _selectedPeriod == 'custom' ? 'realtime' : _selectedPeriod,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (result['success'] && result['data'] != null) {
        setState(() {
          _reportData = SalesReportModel.fromJson(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load sales report';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading sales report: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = 'custom';
      });
      _loadReport();
    }
  }

  Future<void> _downloadReport() async {
    try {
      String? startDate;
      String? endDate;
      
      if (_selectedPeriod == 'custom' && _customDateRange != null) {
        startDate = DateFormat('yyyy-MM-dd').format(_customDateRange!.start);
        endDate = DateFormat('yyyy-MM-dd').format(_customDateRange!.end);
      }

      final success = await _reportServices.downloadSalesReport(
        period: _selectedPeriod == 'custom' ? 'realtime' : _selectedPeriod,
        startDate: startDate,
        endDate: endDate,
      );

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
          "Laporan Penjualan",
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
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReport,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Periode Laporan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _periods.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final period = _periods[index];
                final isSelected = _selectedPeriod == period['value'];
                
                return FilterChip(
                  label: Text(
                    period['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.blue[600],
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (period['value'] == 'custom') {
                      _selectDateRange();
                    } else {
                      setState(() {
                        _selectedPeriod = period['value']!;
                        _customDateRange = null;
                      });
                      _loadReport();
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.blue[600],
                  side: BorderSide(color: Colors.blue[300]!),
                );
              },
            ),
          ),
          if (_customDateRange != null) ...[
            const SizedBox(height: 8),
            Text(
              'Custom Range: ${DateFormat('dd/MM/yyyy').format(_customDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_customDateRange!.end)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
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
          _buildTransactionsSection(),
          const SizedBox(height: 16),
          _buildTopProductsSection(),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final summary = _reportData!.summary;
    
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
          Text(
            'Ringkasan Periode: ${_reportData!.dateRange.start} - ${_reportData!.dateRange.end}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Penjualan',
                  CurrencyFormat.convertToIdr(summary.totalRevenue, 0),
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Transaksi',
                  summary.totalTransactions.toString(),
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Item Terjual',
                  summary.totalItems.toString(),
                  Icons.shopping_cart,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Rata-rata',
                  CurrencyFormat.convertToIdr(summary.averageTransaction, 0),
                  Icons.calculate,
                  Colors.purple,
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

  Widget _buildTransactionsSection() {
    if (_reportData!.transactions.isEmpty) {
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
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Tidak Ada Transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              'Belum ada transaksi pada periode ini',
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
              'Daftar Transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reportData!.transactions.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final transaction = _reportData!.transactions[index];
              return ListTile(
                title: Text(
                  transaction.invoiceNumber,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${transaction.date} • ${transaction.customer}'),
                    Text('${transaction.items} item • ${transaction.paymentMethod}'),
                  ],
                ),
                trailing: Text(
                  CurrencyFormat.convertToIdr(transaction.total, 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                onTap: () {
                  // TODO: Navigate to transaction detail
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection() {
    if (_reportData!.topProducts.isEmpty) {
      return const SizedBox.shrink();
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
              'Produk Terlaris',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reportData!.topProducts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final product = _reportData!.topProducts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  product.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${product.category} • ${product.totalQuantity} ${product.unit} • ${product.transactions} transaksi',
                ),
                trailing: Text(
                  CurrencyFormat.convertToIdr(product.totalRevenue, 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
