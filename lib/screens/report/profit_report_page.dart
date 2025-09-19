import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/report_sales_model.dart';
import 'package:kasir/services/report_services.dart';

// Provider to fetch the profit report
final profitReportProvider = FutureProvider.autoDispose
    .family<SalesReportModel, Map<String, String?>>((ref, params) async {
  final reportService = ReportServices();
  final response = await reportService.getProfitReport(
    period: params['period']!,
    startDate: params['startDate'],
    endDate: params['endDate'],
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

  @override
  Widget build(BuildContext context) {
    final params = {
      'period': _period,
      'startDate': _dateRange?.start.toIso8601String(),
      'endDate': _dateRange?.end.toIso8601String(),
    };
    final report = ref.watch(profitReportProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Profit'),
      ),
      body: report.when(
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Total Profit: ${data.summary.totalProfit}'),
              // Add more widgets to display the report data
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
