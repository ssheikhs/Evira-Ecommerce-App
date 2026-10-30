/// aamarPay sandbox configuration.
///
/// The store id and signature key below are aamarPay's public sandbox
/// credentials, so they are safe to keep in the repository. Never commit
/// live credentials; pass them with `--dart-define` instead.
class PaymentConstants {
  PaymentConstants._();

  static const String sandboxBaseUrl = 'https://sandbox.aamarpay.com';
  static const String initiateEndpoint = '/jsonpost.php';

  static const String storeId = String.fromEnvironment(
    'AAMARPAY_STORE_ID',
    defaultValue: 'aamarpaytest',
  );
  static const String signatureKey = String.fromEnvironment(
    'AAMARPAY_SIGNATURE_KEY',
    defaultValue: 'dbb74894e82415a2f7ff0ec3a97e4183',
  );

  static const String currency = 'USD';
  static const String country = 'Bangladesh';

  /// The gateway redirects to these URLs when a payment ends. They never
  /// load: the payment WebView catches them and closes itself.
  static const String callbackHost = 'evira.app';
  static const String successUrl = 'https://$callbackHost/payment/success';
  static const String failUrl = 'https://$callbackHost/payment/fail';
  static const String cancelUrl = 'https://$callbackHost/payment/cancel';
}
