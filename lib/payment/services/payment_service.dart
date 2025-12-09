import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/payment_model.dart';

class PaymentService {
  final Dio _dio = DioClient.instance.dio;

  /// Create a payment record in backend. Adjust endpoint to match your API.
  Future<PaymentModel> createPayment(int serviceId, double amount) async {
    final data = {
      'service_id': serviceId,
      'amount': amount,
      'currency': 'AUD',
    };
    final resp = await _dio.post(ApiConstants.paymentProcess, data: data);

    // Be flexible with response shapes: some APIs return the created payment
    // under a `payment` key or directly as the root map. Handle both.
    final respData = resp.data;
    if (respData is Map<String, dynamic>) {
      if (respData.containsKey('payment') && respData['payment'] is Map<String, dynamic>) {
        return PaymentModel.fromJson(respData['payment'] as Map<String, dynamic>);
      }
      return PaymentModel.fromJson(respData as Map<String, dynamic>);
    }

    throw DioException(requestOptions: resp.requestOptions, error: 'Unexpected response from payment process');
  }

  /// Confirm an existing payment. Adjust endpoint as required.
  Future<PaymentModel> confirmPayment(String paymentId) async {
    // If your API has a confirm endpoint, update ApiConstants or replace the path below.
    final resp = await _dio.post('/payments/$paymentId/confirm');
    return PaymentModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Optional: fetch payment by id
  Future<PaymentModel> getPayment(String paymentId) async {
    final resp = await _dio.get('/payments/$paymentId');
    return PaymentModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
