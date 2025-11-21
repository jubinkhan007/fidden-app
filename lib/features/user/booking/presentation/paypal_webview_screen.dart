// lib/features/user/booking/presentation/screens/paypal_webview_screen.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:fidden/core/commom/widgets/custom_app_bar.dart'; // Adjust import path

class PayPalWebViewScreen extends StatefulWidget {
  final String url;
  const PayPalWebViewScreen({super.key, required this.url});

  @override
  State<PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<PayPalWebViewScreen> {
  late final WebViewController _controller;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // 1. Intercept the Return URL (Matches backend settings)
            if (request.url.startsWith('https://example.com/paypal-return')) {
              _finish(true);
              return NavigationDecision.prevent;
            }
            // 2. Intercept Cancel URL
            if (request.url.startsWith('https://example.com/paypal-cancel')) {
              _finish(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _finish(bool success) {
    if (_isDone) return;
    _isDone = true;
    Get.back(result: success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay with PayPal"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(result: false)
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}