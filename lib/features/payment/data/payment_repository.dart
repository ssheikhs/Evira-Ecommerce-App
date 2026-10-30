import '../../../core/constants/payment_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../models/payment_session.dart';

/// Starts payments with an online gateway.
abstract class PaymentRepository {
  Future<PaymentSession> createPayment({
    required String transactionId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    required String customerCity,
    required String description,
  });
}

/// aamarPay sandbox integration using the JSON initiate API
/// (`POST /jsonpost.php`), which returns a hosted `payment_url`.
class AamarPayRepository implements PaymentRepository {
  final DioClient dioClient;

  AamarPayRepository({required this.dioClient});

  @override
  Future<PaymentSession> createPayment({
    required String transactionId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    required String customerCity,
    required String description,
  }) async {
    final response = await dioClient.post(
      PaymentConstants.initiateEndpoint,
      data: {
        'store_id': PaymentConstants.storeId,
        'signature_key': PaymentConstants.signatureKey,
        'tran_id': transactionId,
        'amount': amount.toStringAsFixed(2),
        'currency': PaymentConstants.currency,
        'desc': description,
        'cus_name': customerName.trim(),
        'cus_email': customerEmail.trim(),
        'cus_phone': customerPhone.trim(),
        'cus_add1': customerAddress.trim(),
        'cus_city': customerCity.trim(),
        'cus_country': PaymentConstants.country,
        'success_url': PaymentConstants.successUrl,
        'fail_url': PaymentConstants.failUrl,
        'cancel_url': PaymentConstants.cancelUrl,
        'type': 'json',
      },
    );

    final data = response.data;
    if (data is Map && data['result']?.toString() == 'true') {
      final url = data['payment_url']?.toString() ?? '';
      if (url.isNotEmpty) {
        return PaymentSession(transactionId: transactionId, paymentUrl: url);
      }
    }

    throw ApiException(_errorFrom(data));
  }

  /// aamarPay returns errors as a map of field -> message.
  String _errorFrom(dynamic data) {
    if (data is Map && data.isNotEmpty) {
      final messages = data.values
          .where((value) => value != null && value.toString() != 'false')
          .map((value) => value.toString())
          .toList();
      if (messages.isNotEmpty) {
        return 'Payment could not start: ${messages.join(', ')}';
      }
    }
    return 'Payment could not start. Please try again.';
  }
}
