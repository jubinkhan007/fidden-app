// lib/features/business_owner/profile/screens/stripe_webview_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeWebViewScreen extends StatefulWidget {
  final String onboardingUrl;
  const StripeWebViewScreen({super.key, required this.onboardingUrl});

  @override
  State<StripeWebViewScreen> createState() => _StripeWebViewScreenState();
}

class _StripeWebViewScreenState extends State<StripeWebViewScreen> {
  late final WebViewController _controller;
  bool _popped = false;

  void _popOnce(bool completed) {
    if (_popped || !mounted) return;
    _popped = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(completed);
    });
  }

  bool _isOurDeepLink(Uri uri) =>
      uri.scheme == 'myapp' && uri.host == 'stripe';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (req) async {
            final uri = Uri.parse(req.url);

            // Keep normal web traffic in the WebView
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }

            // Only react to *our* deep links
            if (_isOurDeepLink(uri)) {
              // optional: let OS handle the link (not required for the pop)
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } catch (_) {/* ignore */ }

              // Decide result: /return => completed=true, /refresh => false
              final path = uri.path; // e.g. /return or /refresh
              _popOnce(path.startsWith('/return'));
              return NavigationDecision.prevent;
            }

            // Any other custom scheme: try to open externally but DO NOT pop
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            } catch (_) {/* ignore */ }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.onboardingUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect with Stripe')),
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
