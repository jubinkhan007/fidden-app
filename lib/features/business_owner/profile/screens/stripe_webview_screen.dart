//lib/features/business_owner/profile/screens/stripe_webview_screen.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebViewScreen extends StatefulWidget {
  const StripeWebViewScreen({super.key, required this.onboardingUrl});

  final String onboardingUrl;

  @override
  State<StripeWebViewScreen> createState() => _StripeWebViewScreenState();
}

class _StripeWebViewScreenState extends State<StripeWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  void _maybeFinish(String url) {
    // match the exact return URL you set on your backend
    if (url.startsWith('https://fidden.com/return')) {
      Navigator.of(context).pop(true); // <-- tell caller we finished
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _maybeFinish, // catch early
          onUrlChange: (c) => _maybeFinish(c.url!), // catch JS redirects
          onNavigationRequest: (r) {
            _maybeFinish(r.url); // catch normal nav
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.onboardingUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connect with Stripe")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
