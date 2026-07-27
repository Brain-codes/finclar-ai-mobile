import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../shared/widgets/app_loading_overlay.dart';
import '../utils/extensions/context_extensions.dart';
import 'logger_service.dart';

/// Runs Paystack's inline checkout inside a WebView using the **public** key.
///
/// The secret key must never reach the client, so the transaction is not
/// initialized here — Paystack's inline JS accepts the public key directly and
/// hands back a reference, which the caller posts to
/// `POST /subscriptions/checkout/verify` for server-side verification.
///
/// Returns the transaction reference, or `null` if the user closed checkout.
class PaystackCheckoutService {
  static const String _channel = 'FinclarPaystack';

  static Future<String?> start(
    BuildContext context, {
    required String publicKey,
    required String email,
    required int amountMinor,
    required String currency,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _PaystackCheckoutPage(
          publicKey: publicKey,
          email: email,
          amountMinor: amountMinor,
          currency: currency,
        ),
      ),
    );
  }

  static String buildHtml({
    required String publicKey,
    required String email,
    required int amountMinor,
    required String currency,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<script src="https://js.paystack.co/v1/inline.js"></script>
</head>
<body>
<script>
  function post(payload) {
    $_channel.postMessage(JSON.stringify(payload));
  }
  try {
    var handler = PaystackPop.setup({
      key: '${_escape(publicKey)}',
      email: '${_escape(email)}',
      amount: $amountMinor,
      currency: '${_escape(currency)}',
      callback: function (response) {
        post({ status: 'success', reference: response.reference });
      },
      onClose: function () {
        post({ status: 'closed' });
      }
    });
    handler.openIframe();
  } catch (e) {
    post({ status: 'error', message: String(e) });
  }
</script>
</body>
</html>
''';
  }

  static String _escape(String value) =>
      value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}

class _PaystackCheckoutPage extends StatefulWidget {
  final String publicKey;
  final String email;
  final int amountMinor;
  final String currency;

  const _PaystackCheckoutPage({
    required this.publicKey,
    required this.email,
    required this.amountMinor,
    required this.currency,
  });

  @override
  State<_PaystackCheckoutPage> createState() => _PaystackCheckoutPageState();
}

class _PaystackCheckoutPageState extends State<_PaystackCheckoutPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _didFinish = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        PaystackCheckoutService._channel,
        onMessageReceived: _onMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            Log.e('Paystack checkout failed to load: ${error.description}');
            _finish(null);
          },
        ),
      )
      ..loadHtmlString(
        PaystackCheckoutService.buildHtml(
          publicKey: widget.publicKey,
          email: widget.email,
          amountMinor: widget.amountMinor,
          currency: widget.currency,
        ),
        // Origin MUST be checkout.paystack.com: the inline popup embeds an
        // iframe from that host which sends X-Frame-Options: SAMEORIGIN. Any
        // other baseUrl makes the frame cross-origin and the WebView blocks it
        // with ERR_BLOCKED_BY_RESPONSE.
        baseUrl: 'https://checkout.paystack.com',
      );
  }

  void _onMessage(JavaScriptMessage message) {
    final payload = json.decode(message.message) as Map<String, dynamic>;
    switch (payload['status']) {
      case 'success':
        Log.d('Paystack checkout succeeded');
        _finish(payload['reference'] as String?);
      case 'closed':
        Log.d('Paystack checkout closed by user');
        _finish(null);
      case 'error':
        Log.e('Paystack checkout error: ${payload['message']}');
        _finish(null);
    }
  }

  // Guarded because onClose can fire alongside callback on some flows.
  void _finish(String? reference) {
    if (_didFinish || !mounted) return;
    _didFinish = true;
    Navigator.of(context).pop(reference);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const AppLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}
