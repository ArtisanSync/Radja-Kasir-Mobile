import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentCallbackPage extends ConsumerWidget {
  final Map<String, String> queryParameters;

  const PaymentCallbackPage({super.key, required this.queryParameters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final merchantOrderId = queryParameters['merchantOrderId'] ?? 'N/A';
    final result = queryParameters['result'] ?? 'N/A';
    final reference = queryParameters['reference'] ?? 'N/A';

    bool isSuccess = result.toLowerCase() == 'success';

    // Here you would typically call a provider to update the subscription status
    // For example: ref.read(subscriptionProvider.notifier).confirmSubscription(merchantOrderId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pembayaran'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.green : Colors.red,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? 'Pembayaran Berhasil!' : 'Pembayaran Gagal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Status pembayaran untuk pesanan Anda telah diperbarui.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow('Order ID:', merchantOrderId),
                      const SizedBox(height: 8),
                      _buildInfoRow('Status:', result),
                      const SizedBox(height: 8),
                      _buildInfoRow('Referensi:', reference),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to the main subscription page or home
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: theme.textTheme.titleMedium,
                ),
                child: const Text('Kembali ke Aplikasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
