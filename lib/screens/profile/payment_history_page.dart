import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentHistoryPage extends ConsumerWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Dummy data for now
    final List<Map<String, String>> paymentHistory = [
      {
        'package': 'PRO - 1 Bulan',
        'date': '14 Sep 2025',
        'amount': '150.000',
        'status': 'Success',
      },
      {
        'package': 'STANDARD - 3 Bulan',
        'date': '10 Jun 2025',
        'amount': '120.000',
        'status': 'Success',
      },
      {
        'package': 'BUSINESS - 12 Bulan',
        'date': '1 Jan 2025',
        'amount': '1.000.000',
        'status': 'Success',
      },
      {
        'package': 'PRO - 1 Bulan',
        'date': '14 Sep 2025',
        'amount': '150.000',
        'status': 'Failed',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: paymentHistory.length,
        itemBuilder: (context, index) {
          final payment = paymentHistory[index];
          final isSuccess = payment['status'] == 'Success';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSuccess
                    ? Colors.green.withOpacity(0.5)
                    : Colors.red.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                color: isSuccess ? Colors.green : Colors.red,
                size: 40,
              ),
              title: Text(
                payment['package']!,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${payment['date']} - Rp ${payment['amount']}',
                style: theme.textTheme.bodyMedium,
              ),
              trailing: Text(
                payment['status']!,
                style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
