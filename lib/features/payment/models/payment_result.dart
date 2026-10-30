import 'package:flutter/foundation.dart';

enum PaymentOutcome { success, failed, cancelled }

/// What the payment page returns when it closes.
@immutable
class PaymentResult {
  final PaymentOutcome outcome;
  final String transactionId;
  final String? message;

  const PaymentResult._(this.outcome, this.transactionId, [this.message]);

  const PaymentResult.success(String transactionId)
    : this._(PaymentOutcome.success, transactionId);

  const PaymentResult.failed(String transactionId, [String? message])
    : this._(PaymentOutcome.failed, transactionId, message);

  const PaymentResult.cancelled(String transactionId)
    : this._(PaymentOutcome.cancelled, transactionId);

  bool get isSuccess => outcome == PaymentOutcome.success;
}
