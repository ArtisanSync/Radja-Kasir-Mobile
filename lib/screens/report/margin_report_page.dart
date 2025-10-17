import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/report_sales_model.dart';
import 'package:kasir/services/report_services.dart';
import 'package:intl/intl.dart';
import 'package:kasir/helpers/currency_format.dart';

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

// Provider to fetch the margin report
final marginReportProvider = FutureProvider.autoDispose
    .family<SalesReportModel, ReportQuery>((ref, query) async {
  final reportService = ReportServices();
  final response = await reportService.getMarginReport(
    period: query.period,
    startDate: query.startDate,
    endDate: query.endDate,
  );

  if (response['success'] == true && response['data'] != null) {
    return SalesReportModel.fromJson(response['data']);
  } else {
    throw Exception(response['message'] ?? 'Failed to load margin report');
  }
});

class MarginReportPage extends ConsumerStatefulWidget {
  const MarginReportPage({super.key});

  @override
  ConsumerState<MarginReportPage> createState() => _MarginReportPageState();
}

class _MarginReportPageState extends ConsumerState<MarginReportPage> {
  String _period = 'realtime';
  DateTimeRange? _dateRange;
  late ReportQuery _query;

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

  ReportQuery _makeQuery() {
    if (_period == 'custom' && _dateRange != null) {
      final start = DateFormat('yyyy-MM-dd').format(_dateRange!.start);
      final end = DateFormat('yyyy-MM-dd').format(_dateRange!.end);
      return ReportQuery(period: 'realtime', startDate: start, endDate: end);
    }
    return ReportQuery(period: _period);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
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
      ref.refresh(marginReportProvider(_query));
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(marginReportProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Margin'),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(marginReportProvider(_query)),
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _periods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                      ref.refresh(marginReportProvider(_query));
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
    final marginValue = summary.totalProfit;
    final revenue = summary.totalRevenue;
    final marginPercent = revenue > 0 ? (marginValue / revenue * 100.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Margin Total',
                  value: CurrencyFormat.convertToIdr(marginValue, 0),
                  icon: Icons.stacked_line_chart,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Pendapatan',
                  value: CurrencyFormat.convertToIdr(revenue, 0),
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
                  title: 'Margin (%)',
                  value: '${marginPercent.toStringAsFixed(2)}%',
                  icon: Icons.pie_chart,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Transaksi',
                  value: summary.totalTransactions.toString(),
                  icon: Icons.receipt_long,
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
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(marginReportProvider(_query)),
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
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
