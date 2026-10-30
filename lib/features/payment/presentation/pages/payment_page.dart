import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/payment_constants.dart';
import '../../models/payment_result.dart';
import '../../models/payment_session.dart';

/// Shows the aamarPay checkout in a WebView.
///
/// When the gateway redirects to one of our callback URLs (success, fail or
/// cancel), the page closes and returns a [PaymentResult] to the caller.
class PaymentPage extends StatefulWidget {
  final PaymentSession session;

  const PaymentPage({super.key, required this.session});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _finished = false;
  String? _loadError;

  String get _transactionId => widget.session.transactionId;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          // Android does not report POST redirects to onNavigationRequest,
          // so the callback URL is also checked when a page starts loading.
          onPageStarted: _handleUrl,
          onNavigationRequest: (request) => _handleUrl(request.url)
              ? NavigationDecision.prevent
              : NavigationDecision.navigate,
          onWebResourceError: (error) {
            if (error.isForMainFrame == false || !mounted || _finished) return;
            setState(() => _loadError = error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.session.paymentUrl));
  }

  /// Returns true when [url] is one of our callback URLs.
  bool _handleUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host != PaymentConstants.callbackHost) return false;

    if (url.startsWith(PaymentConstants.successUrl)) {
      _finish(PaymentResult.success(_transactionId));
    } else if (url.startsWith(PaymentConstants.cancelUrl)) {
      _finish(PaymentResult.cancelled(_transactionId));
    } else {
      _finish(
        PaymentResult.failed(_transactionId, 'The payment was not completed.'),
      );
    }
    return true;
  }

  void _finish(PaymentResult result) {
    if (_finished || !mounted) return;
    _finished = true;
    context.pop(result);
  }

  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel payment?'),
        content: const Text(
          'Your order will not be placed if you leave before paying.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep paying'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (leave == true) _finish(PaymentResult.cancelled(_transactionId));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Cancel payment',
            icon: const Icon(Icons.close),
            onPressed: _confirmExit,
          ),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 18),
              SizedBox(width: 8),
              Text('Secure payment'),
            ],
          ),
          bottom: _progress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress / 100,
                    minHeight: 2,
                  ),
                )
              : null,
        ),
        body: _loadError == null
            ? WebViewWidget(controller: _controller)
            : _LoadError(
                message: _loadError!,
                onRetry: () {
                  setState(() => _loadError = null);
                  _controller.reload();
                },
              ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Could not open the payment page',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
