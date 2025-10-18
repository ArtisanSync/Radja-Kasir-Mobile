import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/subscription_model.dart';
import 'package:kasir/providers/payment_provider.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPaymentPage extends ConsumerStatefulWidget {
  final SubscriptionPackage package;

  const SubscriptionPaymentPage({super.key, required this.package});

  @override
  ConsumerState<SubscriptionPaymentPage> createState() =>
      _SubscriptionPaymentPageState();
}

class _SubscriptionPaymentPageState
    extends ConsumerState<SubscriptionPaymentPage> {
  void _handlePayment(BuildContext context) async {
    final paymentNotifier = ref.read(paymentProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final paymentUrl = await paymentNotifier.createSubscriptionPayment(
      package: widget.package,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (paymentUrl != null) {
      if (kIsWeb) {
        // On Web, open in a new tab
        final opened = await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.platformDefault);
        if (!opened) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membuka pembayaran di browser'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        // Mobile: use in-app WebView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebView(url: paymentUrl),
          ),
        );
      } else {
        // Desktop (Windows, macOS, Linux): open external browser
        final opened = await launchUrl(Uri.parse(paymentUrl),
            mode: LaunchMode.externalApplication);
        if (opened) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembayaran dibuka di browser. Selesaikan di sana.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membuka pembayaran di browser'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'Konfirmasi Pembayaran',
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
          const Spacer(),
          _buildBottomSection(theme),
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
            'Anda akan berlangganan:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.package.displayName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Total Pembayaran',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormat.convertToIdr(widget.package.price, 0),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            '/ ${widget.package.duration} bulan',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handlePayment(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          child: const Text('Lanjutkan Pembayaran'),
        ),
      ),
    );
  }
}

class PaymentWebView extends StatefulWidget {
  final String url;
  const PaymentWebView({Key? key, required this.url}) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onPageStarted: (String url) {
          setState(() {
            _isLoading = true;
          });
        }, onPageFinished: (String url) {
          setState(() {
            _isLoading = false;
          });
          if (url.startsWith('http://localhost:3000/payment/success') ||
              url.contains('payment/success')) {
            Navigator.popUntil(context, (route) => route.isFirst);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Pembayaran sedang diproses. Status langganan akan segera diperbarui.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }, onWebResourceError: (WebResourceError error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat halaman: ${error.description}'),
              backgroundColor: Colors.red,
            ),
          );
        }),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
