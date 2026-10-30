import 'package:flutter/foundation.dart';

/// A payment started at the gateway: open [paymentUrl] to let the user pay.
@immutable
class PaymentSession {
  final String transactionId;
  final String paymentUrl;

  const PaymentSession({required this.transactionId, required this.paymentUrl});
}
