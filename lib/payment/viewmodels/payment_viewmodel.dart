import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentState {
  final bool isLoading;
  final PaymentModel? payment;
  final String? error;

  PaymentState({this.isLoading = false, this.payment, this.error});
}

class PaymentViewModel extends StateNotifier<PaymentState> {
  final PaymentService _service;
  PaymentViewModel(this._service) : super(PaymentState());

  /// Initialize/create a payment for [serviceId] and [amount].
  /// Returns the created PaymentModel or null on failure.
  Future<PaymentModel?> initForService(int serviceId, double amount) async {
    state = PaymentState(isLoading: true);
    try {
      final payment = await _service.createPayment(serviceId, amount);
      state = PaymentState(payment: payment);
      return payment;
    } catch (e) {
      state = PaymentState(error: e.toString());
      return null;
    }
  }

  Future<void> confirm(String paymentId) async {
    state = PaymentState(isLoading: true, payment: state.payment);
    try {
      final confirmed = await _service.confirmPayment(paymentId);
      state = PaymentState(payment: confirmed);
    } catch (e) {
      state = PaymentState(error: e.toString(), payment: state.payment);
    }
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

final paymentViewModelProvider = StateNotifierProvider.autoDispose
    .family<PaymentViewModel, PaymentState, int>((ref, serviceId) {
  final svc = ref.read(paymentServiceProvider);
  return PaymentViewModel(svc);
});
