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
        return PaymentModel.fromJson(respData['payment']);
      }
      return PaymentModel.fromJson(respData);
    }

    throw DioException(requestOptions: resp.requestOptions, error: 'Unexpected response from payment process');
  }

  /// Create a payment but specify a payment method (existing saved method or pm_xxx)
  Future<Map<String, dynamic>> processPaymentRaw(int serviceId, double amount, {String? paymentMethod}) async {
    final data = {
      'service_id': serviceId,
      'amount': amount,
      'currency': 'AUD',
    };
    if (paymentMethod != null) {
      data['payment_method'] = paymentMethod;
    }
    final resp = await _dio.post(ApiConstants.paymentProcess, data: data);
    return resp.data as Map<String, dynamic>;
  }

  /// List saved card/payment methods for the currently authenticated homeowner.
  /// Note: The backend currently does not expose a GET /payments list route.
  /// If you add it in the backend, reintroduce this method. For now, return an empty list.
  Future<List<PaymentModel>> listPayments() async {
    return [];
  }

  /// Confirm an existing payment. Adjust endpoint as required.
  Future<PaymentModel> confirmPayment(String paymentId) async {
    // If your API has a confirm endpoint, update ApiConstants or replace the path below.
    // No dedicated confirm route; use update instead to change status or confirm on the backend.
    throw UnimplementedError('No dedicated confirm endpoint. Use updatePayment instead.');
  }

  /// Optional: fetch payment by id
  Future<PaymentModel> getPayment(String paymentId) async {
    // No GET /payments/{id} route documented in backend routes; fallback to throw
    throw UnimplementedError('GET /payments/{id} is not available on the API.');
  }

  /// View decrypted payment data for a saved payment record
  Future<Map<String, dynamic>> viewDecryptedPayment(String paymentId) async {
    final resp = await _dio.get('/payments/$paymentId/decrypt');
    return resp.data as Map<String, dynamic>;
  }

  /// Delete a saved payment method
  Future<void> deletePayment(String paymentId) async {
    await _dio.delete('/payments/$paymentId/delete');
  }

  /// Update a saved payment record
  Future<PaymentModel> updatePayment(String paymentId, Map<String, dynamic> data) async {
    final resp = await _dio.put('/payments/$paymentId/update', data: data);
    return PaymentModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
