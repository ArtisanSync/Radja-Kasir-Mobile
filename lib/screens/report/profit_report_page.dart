import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/report_sales_model.dart';
import 'package:kasir/services/report_services.dart';

// Stable parameter for provider (avoid new Map on every build)
class ReportQuery {
  final String period;
  final String? startDate;
  final String? endDate;
  const ReportQuery({required this.period, this.startDate, this.endDate});
  @override
  bool operator ==(Object other) =>
      other is ReportQuery &&
      other.period == period &&
      other.startDate == startDate &&
      other.endDate == endDate;
  @override
  int get hashCode => Object.hash(period, startDate, endDate);
}

// Provider to fetch the profit report
final profitReportProvider = FutureProvider.autoDispose
    .family<SalesReportModel, ReportQuery>((ref, query) async {
  final reportService = ReportServices();
  final response = await reportService.getProfitReport(
    period: query.period,
    startDate: query.startDate,
    endDate: query.endDate,
  );

  if (response['success'] == true && response['data'] != null) {
    return SalesReportModel.fromJson(response['data']);
  } else {
    throw Exception(response['message'] ?? 'Failed to load profit report');
  }
});

class ProfitReportPage extends ConsumerStatefulWidget {
  const ProfitReportPage({super.key});

  @override
  ConsumerState<ProfitReportPage> createState() => _ProfitReportPageState();
}

class _ProfitReportPageState extends ConsumerState<ProfitReportPage> {
  String _period = 'realtime';
  DateTimeRange? _dateRange;
  late ReportQuery _query; // keep stable instance

  // Tambah daftar periode untuk chip
  final List<Map<String, String>> _periods = const [
    {'value': 'realtime', 'label': 'Bulan Ini'},
    {'value': '1', 'label': '1 Bulan Lalu'},
    {'value': '6', 'label': '6 Bulan Lalu'},
    {'value': '12', 'label': '12 Bulan Lalu'},
    {'value': 'custom', 'label': 'Pilih Tanggal'},
  ];

  @override
  void initState() {
    super.initState();
    _query = const ReportQuery(period: 'realtime');
  }

  // Buat query berdasarkan periode & tanggal custom
  ReportQuery _makeQuery() {
    if (_period == 'custom' && _dateRange != null) {
      final startDate = DateFormat('yyyy-MM-dd').format(_dateRange!.start);
      final endDate = DateFormat('yyyy-MM-dd').format(_dateRange!.end);
      return ReportQuery(period: 'realtime', startDate: startDate, endDate: endDate);
    }
    return ReportQuery(period: _period);
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _period = 'custom';
        _query = _makeQuery();
      });
      // Paksa refresh provider
      ref.refresh(profitReportProvider(_query));
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(profitReportProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Profit'),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(profitReportProvider(_query)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: report.when(
              data: (data) => _buildSummaryBody(data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorBody(err.toString()),
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
                final isSelected = _period == period['value'];
                return ChoiceChip(
                  label: Text(period['label']!),
                  selected: isSelected,
                  onSelected: (selected) async {
                    if (period['value'] == 'custom') {
                      await _selectDateRange();
                    } else {
                      setState(() {
                        _period = period['value']!;
                        _dateRange = null;
                        _query = _makeQuery();
                      });
                      ref.refresh(profitReportProvider(_query));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBody(SalesReportModel report) {
    final summary = report.summary;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Profit',
                  value: CurrencyFormat.convertToIdr(summary.totalProfit, 0),
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Pendapatan',
                  value: CurrencyFormat.convertToIdr(summary.totalRevenue, 0),
                  icon: Icons.payments,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Transaksi',
                  value: summary.totalTransactions.toString(),
                  icon: Icons.receipt_long,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Rata-rata',
                  value: CurrencyFormat.convertToIdr(summary.averageTransaction, 0),
                  icon: Icons.calculate,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBody(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
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
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(profitReportProvider(_query)),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
