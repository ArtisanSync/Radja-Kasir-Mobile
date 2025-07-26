import 'package:flutter/material.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/services/service_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReportWebview extends StatefulWidget {
  const ReportWebview({
    required this.store,
    super.key,
  });

  final String store;
  @override
  State<ReportWebview> createState() => _ReportWebviewState();
}

class _ReportWebviewState extends State<ReportWebview> {
  late final WebViewController _controller;

  final String _baseUrl = ServiceUtils().webUrl;

  @override
  void initState() {
    super.initState();
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            print(progress);
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url
                .startsWith("$_baseUrl/report?store=${widget.store}")) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse("$_baseUrl/report?store=${widget.store}"));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Laporan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: const MenuBuilder(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
