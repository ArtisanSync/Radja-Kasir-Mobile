import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/subscription_model.dart';
import 'package:kasir/providers/payment_provider.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/payment_model.dart';

class SubscriptionPaymentPage extends ConsumerStatefulWidget {
  final SubscriptionPackage package;

  const SubscriptionPaymentPage({super.key, required this.package});

  @override
  ConsumerState<SubscriptionPaymentPage> createState() =>
      _SubscriptionPaymentPageState();
}

class _SubscriptionPaymentPageState
    extends ConsumerState<SubscriptionPaymentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(paymentProvider.notifier)
          .loadPaymentMethods(widget.package.price.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentState = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            CupertinoIcons.back,
            color: theme.colorScheme.onSurface,
          ),
        ),
        title: Text(
          'Pilih Pembayaran',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPackageSummary(theme),
          Expanded(
            child: paymentState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : paymentState.error != null
                    ? Center(child: Text('Error: ${paymentState.error}'))
                    : _buildPaymentMethods(theme, paymentState.paymentMethods),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSummary(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
        children: [
          Text(
            'Paket ${widget.package.name}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormat.convertToIdr(widget.package.price, 0),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            '/ ${widget.package.duration} bulan',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(ThemeData theme, List<PaymentMethod> methods) {
    if (methods.isEmpty) {
      return const Center(child: Text('Metode pembayaran tidak tersedia.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: methods.length,
      itemBuilder: (context, index) {
        final method = methods[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: Image.network(
              method.image,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.payment, size: 40),
            ),
            title: Text(method.name,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text(
                'Biaya: ${CurrencyFormat.convertToIdr(double.tryParse(method.fee) ?? 0, 0)}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _handlePayment(method);
            },
          ),
        );
      },
    );
  }

  void _handlePayment(PaymentMethod method) async {
    // TODO: Replace with actual user data from your app's state
    const email = 'testing@radjakasir.com';
    const phoneNumber = '081234567890';
    const customerName = 'Radja Kasir User';

    final paymentNotifier = ref.read(paymentProvider.notifier);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final paymentResponse = await paymentNotifier.createSubscriptionPayment(
      package: widget.package,
      email: email,
      phoneNumber: phoneNumber,
      paymentMethod: method.code,
      customerName: customerName,
    );

    Navigator.pop(context); // Close loading dialog

    if (paymentResponse != null && paymentResponse.paymentUrl != null) {
      final Uri url = Uri.parse(paymentResponse.paymentUrl!);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak bisa membuka URL: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              ref.read(paymentProvider).error ?? 'Gagal membuat pembayaran.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
