import 'package:flutter/material.dart';
import 'package:tradie/payment/services/payment_service.dart';
import 'package:tradie/payment/models/payment_model.dart' as pm;
import '../models/payment_model.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentService _service;
  PaymentViewModel(this._service);

  PaymentModel? _paymentData;
  
  PaymentModel? get paymentData => _paymentData;

  Future<void> initializePayment() async {
    // Initialize without payment method
    _paymentData = PaymentModel(
      hourlyRate: 85.0,
      duration: 3,
      subtotal: 255.0,
      serviceFee: 26.0,
      estimatedTotal: 281.0,
      hasPaymentMethod: false,
    );
    notifyListeners();
  }

  void addPaymentMethod(String cardNumber, String cardType) {
    _paymentData = PaymentModel(
      cardNumber: cardNumber,
      cardType: cardType,
      hourlyRate: _paymentData!.hourlyRate,
      duration: _paymentData!.duration,
      subtotal: _paymentData!.subtotal,
      serviceFee: _paymentData!.serviceFee,
      estimatedTotal: _paymentData!.estimatedTotal,
      hasPaymentMethod: true,
    );
    notifyListeners();
  }

  final List<pm.PaymentModel> _savedMethods = [];
  List<pm.PaymentModel> get savedMethods => _savedMethods;

  String? _selectedPaymentId;
  String? get selectedPaymentId => _selectedPaymentId;

  void selectPaymentMethod(String? paymentId) {
    _selectedPaymentId = paymentId;
    notifyListeners();
  }

  Future<String?> onContinue({required int serviceId, required double amount}) async {
    if (_selectedPaymentId == null) return null;
    try {
      final resp = await _service.processPaymentRaw(serviceId, amount, paymentMethod: _selectedPaymentId);
      final requiresAction = resp['requires_action'] == true;
      final nextAction = resp['next_action_url'] as String?;
      if (requiresAction && nextAction != null) {
        return nextAction;
      }
      return null;
    } catch (e) {
      debugPrint('Payment processing error: $e');
      return null;
    }
  }

  // Removed onBack() - navigation is handled by UI via go_router

  void onAddPaymentMethod() {
    // Navigate to add payment method screen
    // For demo, let's simulate adding a card
    addPaymentMethod('**** **** **** 1231', 'VISA');
  }

  void addSavedMethod(pm.PaymentModel method) {
    _savedMethods.add(method);
    _selectedPaymentId = method.id;
    notifyListeners();
  }
}