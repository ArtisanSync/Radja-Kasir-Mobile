import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/report_sales_model.dart';
import 'package:kasir/services/report_services.dart';

// Provider to fetch the margin report
final marginReportProvider = FutureProvider.autoDispose
    .family<SalesReportModel, Map<String, String?>>((ref, params) async {
  final reportService = ReportServices();
  final response = await reportService.getMarginReport(
    period: params['period']!,
    startDate: params['startDate'],
    endDate: params['endDate'],
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

  @override
  Widget build(BuildContext context) {
    final params = {
      'period': _period,
      'startDate': _dateRange?.start.toIso8601String(),
      'endDate': _dateRange?.end.toIso8601String(),
    };
    final report = ref.watch(marginReportProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Margin'),
      ),
      body: report.when(
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Example: Displaying total revenue as margin for now
              Text('Total Margin (Revenue): ${data.summary.totalRevenue}'),
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
