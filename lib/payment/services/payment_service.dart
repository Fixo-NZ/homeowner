import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/payment_model.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  final Dio _dio = DioClient.instance.dio;

  /// Create a payment record in backend. Adjust endpoint to match your API.
  Future<PaymentModel> createPayment(int serviceId, double amount) async {
    final data = {'service_id': serviceId, 'amount': amount, 'currency': 'AUD'};
    final resp = await _dio.post(ApiConstants.paymentProcess, data: data);

    // Be flexible with response shapes: some APIs return the created payment
    // under a payment key or directly as the root map. Handle both.
    final respData = resp.data;
    if (respData is Map<String, dynamic>) {
      if (respData.containsKey('payment') &&
          respData['payment'] is Map<String, dynamic>) {
        return PaymentModel.fromJson(respData['payment']);
      }
      return PaymentModel.fromJson(respData);
    }

    throw DioException(
      requestOptions: resp.requestOptions,
      error: 'Unexpected response from payment process',
    );
  }

  /// Create a payment but specify a payment method (existing saved method or pm_xxx)
  Future<Map<String, dynamic>> processPaymentRaw(
    int serviceId,
    double amount, {
    String? paymentMethod,
  }) async {
    final data = {'service_id': serviceId, 'amount': amount, 'currency': 'AUD'};
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
    try {
      final resp = await _dio.get(ApiConstants.paymentsList);
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map<String, dynamic> && data.containsKey('payments')) {
        final list = data['payments'] as List<dynamic>;
        return list
            .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // If endpoint doesn't exist or fails, return empty list instead of crashing
      debugPrint('listPayments error: $e');
      return [];
    }
  }

  /// Save a payment method for the current user. Backend route: POST /payments/save-payment-method
  /// The backend now expects a POST request (no GET fallback).
  //   Future<PaymentModel?> savePaymentMethod({required String cardNumber, required String cardHolder, String? cardBrand, String? last4}) async {
  //     try {
  //       final params = <String, dynamic>{
  //         'card_number': cardNumber,
  //         'card_holder': cardHolder,
  //         // Provide last4 if available as a convenience
  //         'card_last4number': last4,
  //         'last4': last4,
  //       };
  //       if (cardBrand != null) params['card_brand'] = cardBrand;
  //       // Debugging: log request params
  //       debugPrint('savePaymentMethod request params: $params');

  //       // Also support tokenized payment method reference if passed as cardNumber
  //       if (cardNumber.startsWith('pm_')) {
  //         params['payment_method_id'] = cardNumber;
  //         params.remove('card_number');
  //       }

  //       // Always use POST for saving payment methods
  //       final resp = await _dio.post(ApiConstants.paymentsSave, data: params);

  //       debugPrint('savePaymentMethod response code: ${resp.statusCode}');
  //       debugPrint('savePaymentMethod response body: ${resp.data}');

  //       // If the server returned a validation error, surface it
  //       if (resp.statusCode != null && resp.statusCode! >= 400) {
  //         final body = resp.data;
  //         if (body is Map<String, dynamic>) {
  //           final msg = body['message'] ?? body['error'] ?? (body['errors'] is Map ? (body['errors'] as Map).values.join(', ') : null);
  //           final text = msg?.toString() ?? 'Unknown server error: ${resp.statusCode}';
  //           throw Exception(text);
  //         }
  //         throw Exception('Server returned status ${resp.statusCode}');
  //       }

  //       final data = resp.data;
  //       if (data is Map<String, dynamic>) {
  //         final candidate = data.containsKey('payment')
  //             ? data['payment']
  //             : (data.containsKey('data') ? data['data'] : data);
  //         if (candidate is Map<String, dynamic>) {
  //           try {
  //             return PaymentModel.fromJson(candidate);
  //           } catch (e) {
  //             debugPrint('savePaymentMethod parse error: $e');
  //             return null;
  //           }
  //         }
  //       }
  //       return null;
  //     } on DioException catch (e) {
  //       // Provide clearer message for UI: extract server-provided message if present
  //       if (e.response != null && e.response!.data is Map<String, dynamic>) {
  //         final body = e.response!.data as Map<String, dynamic>;
  //         final msg = body['message'] ?? body['error'] ?? (body['errors'] is Map ? (body['errors'] as Map).values.join(', ') : null);
  //         throw Exception(msg?.toString() ?? 'Validation failed');
  //       }
  //       rethrow;
  //     } catch (e) {
  //       debugPrint('savePaymentMethod error: $e');
  //       rethrow;
  //     }
  //   }

  /// 1️⃣ Ask backend to create SetupIntent
  /// This prepares Stripe to save a payment method without charging
  Future<String> getClientSecret() async {
    try {
      final resp = await _dio.post(ApiConstants.paymentProcess);

      if (resp.data == null || resp.data['client_secret'] == null) {
        throw Exception('Client secret not returned by backend');
      }

      debugPrint('✅ SetupIntent client_secret received: ${resp.data['client_secret']}');
      return resp.data['client_secret'];
    } catch (e) {
      debugPrint('❌ getClientSecret error: $e');
      rethrow;
    }
  }

  /// 2️⃣ Show Stripe card UI + confirm SetupIntent
  /// This collects the card from the user and saves it with Stripe, returning the payment_method_id
  Future<String> confirmCardSetup(String clientSecret) async {
    try {
      debugPrint('🔄 Confirming SetupIntent with client_secret: $clientSecret');
      
      final result = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
      );

      if (result.paymentMethodId.isEmpty) {
        debugPrint('❌ confirmCardSetup: unexpected result - $result');
        throw Exception('Stripe confirmSetupIntent did not return a payment method id');
      }

      debugPrint('✅ Payment method created: ${result.paymentMethodId}');
      return result.paymentMethodId;
    } catch (e) {
      debugPrint('❌ confirmCardSetup error: $e');
      rethrow;
    }
  }

  /// Save a payment method in backend.
  /// Accepts either raw card details (cardNumber, cardHolder, last4) or
  /// a token/payment method id (pm_xxx or pm_...). Returns the saved
  /// PaymentModel on success or `null` on failure.
  Future<PaymentModel?> savePaymentMethod({
    String? cardNumber,
    String? cardHolder,
    String? cardBrand,
    String? last4,
    String? paymentMethodId,
  }) async {
    try {
      final params = <String, dynamic>{};

      if (paymentMethodId != null && paymentMethodId.isNotEmpty) {
        params['payment_method_id'] = paymentMethodId;
      } else if (cardNumber != null && cardNumber.isNotEmpty) {
        // Support passing a token-like string as cardNumber (e.g., 'pm_...')
        if (cardNumber.startsWith('pm_')) {
          params['payment_method_id'] = cardNumber;
        } else {
          params['card_number'] = cardNumber;
          params['card_holder'] = cardHolder;
          if (cardBrand != null) params['card_brand'] = cardBrand;
          if (last4 != null) params['last4'] = last4;
        }
      } else {
        // Nothing to send
        debugPrint('savePaymentMethod called without data');
        return null;
      }

      debugPrint('savePaymentMethod request params: $params');

      final resp = await _dio.post(ApiConstants.paymentsSave, data: params);

      debugPrint('savePaymentMethod response: ${resp.statusCode} ${resp.data}');

      if (resp.statusCode != null && resp.statusCode! >= 400) {
        debugPrint('savePaymentMethod server error: ${resp.statusCode} ${resp.data}');
        return null;
      }

      final data = resp.data;
      if (data is Map<String, dynamic>) {
        // Backend returns { "message": "...", "payment": { ... } }
        // Try to extract the payment object
        final candidate = data.containsKey('payment')
            ? data['payment']
            : (data.containsKey('data') ? data['data'] : data);
        
        if (candidate is Map<String, dynamic>) {
          try {
            final payment = PaymentModel.fromJson(candidate);
            debugPrint('✅ Payment method saved: ${payment.id}');
            return payment;
          } catch (e) {
            debugPrint('savePaymentMethod parse error: $e. Candidate: $candidate');
            // If parsing fails, return a minimal PaymentModel with what we have
            try {
              return PaymentModel(
                id: candidate['id']?.toString() ?? '',
                serviceId: 0,
                amount: 0,
                currency: 'AUD',
                status: candidate['status'] ?? 'saved',
                createdAt: DateTime.now(),
                cardBrand: candidate['card_brand']?.toString(),
                cardLast4: candidate['card_last4number']?.toString(),
              );
            } catch (fallbackError) {
              debugPrint('Fallback PaymentModel creation failed: $fallbackError');
              return null;
            }
          }
        }
      }

      return null;
    } on DioException catch (e) {
      debugPrint('savePaymentMethod DioException: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      debugPrint('savePaymentMethod error: $e');
      return null;
    }
  }

  /// Confirm an existing payment. Adjust endpoint as required.
  Future<PaymentModel> confirmPayment(String paymentId) async {
    // If your API has a confirm endpoint, update ApiConstants or replace the path below.
    // No dedicated confirm route; use update instead to change status or confirm on the backend.
    throw UnimplementedError(
      'No dedicated confirm endpoint. Use updatePayment instead.',
    );
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
  Future<PaymentModel> updatePayment(
    String paymentId,
    Map<String, dynamic> data,
  ) async {
    final resp = await _dio.put('/payments/$paymentId/update', data: data);
    return PaymentModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Process a payment and save to payments table
  Future<Map<String, dynamic>?> processPayment({
    required double amount,
    required String description,
  }) async {
    try {
      debugPrint('💳 Calling backend to process payment: \$$amount');
      
      final data = {
        'amount': amount,
        'description': description,
        'currency': 'AUD',
      };
      
      final resp = await _dio.post('/payment/charge-saved-card', data: data);
      
      debugPrint('✅ Payment response: ${resp.data}');
      
      return resp.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('❌ Payment processing error: $e');
      rethrow;
    }
  }

  /// Get the first saved card for the user
  Future<Map<String, dynamic>?> getFirstSavedCard() async {
    try {
      debugPrint('🔍 Fetching saved cards from /saved-cards');
      
      final resp = await _dio.get('/saved-cards');
      
      final data = resp.data;
      List<dynamic> cards = [];
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('data')) {
          cards = data['data'] as List<dynamic>;
        } else if (data.containsKey('cards')) {
          cards = data['cards'] as List<dynamic>;
        }
      } else if (data is List) {
        cards = data;
      }
      
      if (cards.isEmpty) {
        debugPrint('⚠️  No saved cards found');
        return null;
      }
      
      final firstCard = cards.first as Map<String, dynamic>;
      debugPrint('✅ Found saved card: ${firstCard['card_last4number']}');
      
      return firstCard;
    } catch (e) {
      debugPrint('❌ Error fetching saved cards: $e');
      return null;
    }
  }

  /// Charge a saved card for a booking payment (variant: accepts just the payment ID)
  /// Backend will use the stored payment amount and booking ID
  Future<Map<String, dynamic>?> chargeSavedCard({
    String? paymentId,
    double? amount,
    int? bookingId,
    String? paymentMethodId,
  }) async {
    try {
      // If only paymentId is provided, use that
      if (paymentId != null && amount == null && bookingId == null && paymentMethodId == null) {
        debugPrint('💳 Charging saved card using Payment ID: $paymentId');
        
        final data = {
          'payment_id': paymentId,
          'currency': 'AUD',
        };
        
        debugPrint('📤 Sending request data: $data');
        
        final resp = await _dio.post('/payment/charge-saved-card', data: data);
        
        debugPrint('📥 Response status: ${resp.statusCode}');
        debugPrint('📥 Response body: ${resp.data}');
        
        final responseData = resp.data as Map<String, dynamic>;
        
        // Check for success in multiple ways (different response formats)
        final isSuccessful = 
          responseData['status'] == 'succeeded' ||
          responseData['message']?.toString().toLowerCase().contains('success') == true ||
          responseData['success'] == true;
        
        if (isSuccessful) {
          debugPrint('✅ Card charged successfully');
          return responseData;
        } else {
          debugPrint('❌ Charge failed: ${responseData['message'] ?? 'Unknown error'}');
          return null;
        }
      }
      
      // Original method: require all parameters
      if (amount == null || bookingId == null || paymentMethodId == null) {
        throw Exception('Missing required parameters for charging saved card');
      }

      debugPrint('💳 Charging saved card');
      debugPrint('   Booking ID: $bookingId');
      debugPrint('   Amount: \$$amount');
      debugPrint('   Payment Method: $paymentMethodId');
      
      final data = {
        'payment_method_id': paymentMethodId,
        'amount': amount,
        'booking_id': bookingId,
        'currency': 'AUD',
      };
      
      debugPrint('📤 Sending request data: $data');
      
      final resp = await _dio.post('/payment/charge-saved-card', data: data);
      
      debugPrint('📥 Response status: ${resp.statusCode}');
      debugPrint('📥 Response body: ${resp.data}');
      
      final responseData = resp.data as Map<String, dynamic>;
      
      // Check for success in multiple ways (different response formats)
      final isSuccessful = 
        responseData['status'] == 'succeeded' ||
        responseData['status'] == 'succeeded' ||
        responseData['message']?.toString().toLowerCase().contains('success') == true ||
        responseData['success'] == true;
      
      if (isSuccessful) {
        debugPrint('✅ Payment successful');
      } else {
        debugPrint('⚠️  Payment response received but status unclear: $responseData');
      }
      
      return responseData;
    } on DioException catch (e) {
      debugPrint('❌ Charge DioException');
      debugPrint('   Status: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      debugPrint('   Message: ${e.message}');
      
      // Extract error message from response
      if (e.response?.data is Map<String, dynamic>) {
        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMsg = errorData['message'] ?? errorData['error'] ?? e.message;
        throw Exception('Payment failed: $errorMsg');
      }
      
      throw Exception('Payment failed: ${e.message}');
    } catch (e) {
      debugPrint('❌ Payment charging error: $e');
      rethrow;
    }
  }

  /// Get payment history for the current user
  Future<Map<String, dynamic>?> getPaymentHistory() async {
    try {
      debugPrint('📜 Fetching payment history');
      
      final resp = await _dio.get(ApiConstants.paymentsHistory);
      
      debugPrint('📥 Payment history response: ${resp.data}');
      
      return resp.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('❌ Error fetching payment history: $e');
      return null;
    }
  }
}