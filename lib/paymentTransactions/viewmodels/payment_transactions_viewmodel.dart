import 'package:flutter/material.dart';
import '../models/payment_transaction.dart';
import '../services/booking_service.dart';
import '../../payment/models/payment_model.dart';
import '../../payment/services/payment_service.dart';

class PaymentTransactionsViewModel extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final PaymentService _paymentService = PaymentService();
  
  PaymentModel? _preSelectedPayment;
  bool _disposed = false;
  
  String _selectedTab = 'Upcoming';
  bool _isLoading = false;
  String? _error;
  
  // Getters
  PaymentModel? get preSelectedPayment => _preSelectedPayment;
  String get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get upcomingCount => _upcomingTransactions.length;
  int get historyCount => _historyTransactions.length;
  
  void setSelectedTab(String tab) {
    _selectedTab = tab;
    _safeNotifyListeners();
  }
  
  List<PaymentTransaction> get transactions {
    if (_selectedTab == 'Upcoming') {
      return _upcomingTransactions;
    } else {
      return _historyTransactions;
    }
  }
  
  List<PaymentTransaction> _upcomingTransactions = [];
  List<PaymentTransaction> _historyTransactions = [];

  // Constructor
  PaymentTransactionsViewModel({PaymentModel? preSelectedPayment}) {
    _preSelectedPayment = preSelectedPayment;
    debugPrint('🏗️ PaymentTransactionsViewModel initialized');
    if (_preSelectedPayment != null) {
      debugPrint('✅ Pre-selected payment received: ${_preSelectedPayment!.cardBrand} •••• ${_preSelectedPayment!.cardLast4}');
    } else {
      debugPrint('⚠️ No pre-selected payment provided');
    }
  }
  
  /// Helper method to safely notify listeners only if not disposed
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  
  /// Load bookings from backend and populate upcoming transactions
  Future<void> loadBookings() async {
    debugPrint('📚 loadBookings() called');
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();
    
    try {
      // Load from both bookings and payments endpoints
      final bookingsData = await _bookingService.getBookingsHistory();
      
      // Convert upcoming bookings to PaymentTransactions
      final upcomingBookings = (bookingsData['upcoming'] as List?) ?? [];
      _upcomingTransactions = upcomingBookings
          .map((booking) => _convertBookingToTransaction(booking, status: 'upcoming'))
          .toList();
      
      // Convert past bookings to PaymentTransactions
      final pastBookings = (bookingsData['past'] as List?) ?? [];
      _historyTransactions = pastBookings
          .map((booking) => _convertBookingToTransaction(booking, status: 'past'))
          .toList();
      
      // Also load from payments table to show manually added payments
      try {
        final paymentsResponse = await _paymentService.getPaymentHistory();
        if (paymentsResponse != null) {
          debugPrint('📥 Payment history response type: ${paymentsResponse.runtimeType}');
          debugPrint('📥 Full response: $paymentsResponse');
          
          // Handle different response formats
          List<dynamic> payments = [];
          
          if (paymentsResponse['payments'] is List) {
            payments = paymentsResponse['payments'] as List<dynamic>;
          } else if (paymentsResponse['data'] is List) {
            payments = paymentsResponse['data'] as List<dynamic>;
          }
          
          debugPrint('📥 Received ${payments.length} payments from /payments/history');
          
          if (payments.isNotEmpty) {
            // Convert payments to PaymentTransactions
            final paymentTransactions = payments
                .map((payment) => _convertPaymentToTransaction(payment as Map<String, dynamic>))
                .toList();
            
            // Add to history (these are already completed payments)
            _historyTransactions.addAll(paymentTransactions);
            
            debugPrint('✅ Added ${paymentTransactions.length} completed payments to history');
          } else {
            debugPrint('⚠️  No payments returned from endpoint');
          }
        } else {
          debugPrint('⚠️  Payment history response was null');
        }
      } catch (e) {
        debugPrint('❌ Error loading payment history: $e');
        // Continue anyway - bookings data is still loaded
      }
      
      debugPrint('✅ Loaded ${_upcomingTransactions.length} upcoming and ${_historyTransactions.length} past transactions');
      
      _isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Failed to load bookings: $e';
      _isLoading = false;
      debugPrint('❌ Error loading bookings: $e');
      _safeNotifyListeners();
    }
  }
  
  /// Convert booking data to PaymentTransaction format
  PaymentTransaction _convertBookingToTransaction(Map<String, dynamic> booking, {required String status}) {
    final tradie = booking['tradie'] as Map<String, dynamic>?;
    final service = booking['service'] as Map<String, dynamic>?;
    final bookingStart = booking['booking_start'] as String? ?? '';
    final bookingId = booking['id'] as int?;  // Extract booking ID
    
    // Get total_price from booking - handle both string and numeric values
    double amount = 0.0;
    final totalPriceValue = booking['total_price'];
    if (totalPriceValue != null) {
      if (totalPriceValue is num) {
        amount = totalPriceValue.toDouble();
      } else if (totalPriceValue is String) {
        amount = double.tryParse(totalPriceValue) ?? 0.0;
      }
    }
    
    // Build full tradie name
    final firstName = tradie?['first_name'] ?? '';
    final lastName = tradie?['last_name'] ?? '';
    final tradieName = '$firstName $lastName'.trim().isEmpty ? 'Unknown' : '$firstName $lastName'.trim();
    
    debugPrint('📋 Booking ID: $bookingId | Booking: $tradieName | Total Price: $amount');
    
    return PaymentTransaction(
      customerName: tradieName,
      serviceType: 'Booked Payment',
      serviceDescription: service?['description'] ?? 'Service',
      date: _formatDate(bookingStart),
      location: tradie?['city'] ?? tradie?['state'] ?? 'Location',
      totalPayment: amount,
      status: status,
      bookingId: bookingId,
    );
  }
  
  /// Convert payment record to PaymentTransaction format
  PaymentTransaction _convertPaymentToTransaction(Map<String, dynamic> payment) {
    final booking = payment['booking'] as Map<String, dynamic>?;
    final tradie = booking?['tradie'] as Map<String, dynamic>?;
    final service = booking?['service'] as Map<String, dynamic>?;
    final bookingStart = booking?['booking_start'] as String? ?? DateTime.now().toIso8601String();
    final bookingId = payment['booking_id'] as int?;
    
    // Get amount from payment
    double amount = 0.0;
    final amountValue = payment['amount'];
    if (amountValue != null) {
      if (amountValue is num) {
        amount = amountValue.toDouble();
      } else if (amountValue is String) {
        amount = double.tryParse(amountValue) ?? 0.0;
      }
    }
    
    // Build full tradie name
    final firstName = tradie?['first_name'] ?? 'Unknown';
    final lastName = tradie?['last_name'] ?? 'Tradie';
    final tradieName = '$firstName $lastName'.trim().isEmpty ? 'Unknown Tradie' : '$firstName $lastName'.trim();
    
    debugPrint('💳 Payment ID: ${payment['id']} | Tradie: $tradieName | Amount: $amount | Booking Start: $bookingStart');
    
    return PaymentTransaction(
      customerName: tradieName,
      serviceType: 'Completed Payment',
      serviceDescription: service?['description'] ?? 'Payment',
      date: _formatDate(bookingStart),
      location: tradie?['city'] ?? tradie?['state'] ?? 'Location',
      totalPayment: amount,
      status: 'completed',
      bookingId: bookingId,
    );
  }
  
  /// Format date string to readable format
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[date.month - 1];
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$month ${date.day}, ${date.year} at $hour:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return dateString;
    }
  }
  
  /// Mark transaction as completed (move from upcoming to history)
  void completeTransaction(int index) {
    if (index >= 0 && index < _upcomingTransactions.length) {
      final transaction = _upcomingTransactions[index];
      final completedTransaction = PaymentTransaction(
        customerName: transaction.customerName,
        serviceType: 'Completed Payment',
        serviceDescription: transaction.serviceDescription,
        date: transaction.date,
        location: transaction.location,
        totalPayment: transaction.totalPayment,
        status: 'completed',
        bookingId: transaction.bookingId,
        paymentMethodId: transaction.paymentMethodId,
      );
      
      _upcomingTransactions.removeAt(index);
      _historyTransactions.insert(0, completedTransaction);
      
      debugPrint('✅ Transaction completed and moved to history');
      _safeNotifyListeners();
    }
  }
  
  /// Process payment for a transaction
  Future<bool> processPayment(int upcomingIndex) async {
    try {
      if (upcomingIndex < 0 || upcomingIndex >= _upcomingTransactions.length) {
        _error = 'Invalid transaction';
        _safeNotifyListeners();
        return false;
      }
      
      final transaction = _upcomingTransactions[upcomingIndex];
      
      debugPrint('💳 Processing payment for: ${transaction.customerName}');
      debugPrint('   Booking ID: ${transaction.bookingId}');
      debugPrint('   Amount: \$${transaction.totalPayment.toStringAsFixed(2)}');
      
      // Use pre-selected payment if available, otherwise fetch from backend
      PaymentModel? paymentMethod;
      
      if (_preSelectedPayment != null) {
        debugPrint('✅ Using pre-selected payment: ${_preSelectedPayment!.cardBrand} •••• ${_preSelectedPayment!.cardLast4}');
        paymentMethod = _preSelectedPayment;
      } else {
        debugPrint('ℹ️ No pre-selected payment, fetching first saved card...');
        final savedCard = await _paymentService.getFirstSavedCard();
        
        if (savedCard == null) {
          _error = 'No saved payment method found. Please add a card first.';
          _safeNotifyListeners();
          return false;
        }
        
        // Convert to PaymentModel for consistency
        paymentMethod = PaymentModel(
          id: savedCard['id']?.toString() ?? '',
          serviceId: 0,
          amount: transaction.totalPayment,
          currency: 'AUD',
          status: 'pending',
          createdAt: DateTime.now(),
          cardBrand: savedCard['card_brand']?.toString(),
          cardLast4: savedCard['card_last4number']?.toString(),
        );
      }
      
      if (paymentMethod == null || paymentMethod.id.isEmpty) {
        _error = 'Payment method is invalid';
        _safeNotifyListeners();
        return false;
      }
      
      debugPrint('   Payment Method: ${paymentMethod.cardBrand} •••• ${paymentMethod.cardLast4}');
      
      // Check if we have the Stripe payment_method_id
      if (paymentMethod.paymentMethodId == null || paymentMethod.paymentMethodId!.isEmpty) {
        _error = 'Payment method ID is missing. Please add a card first.';
        debugPrint('❌ Error: paymentMethodId is null or empty');
        debugPrint('   PaymentModel: id=${paymentMethod.id}, paymentMethodId=${paymentMethod.paymentMethodId}');
        _safeNotifyListeners();
        return false;
      }
      
      debugPrint('   Stripe Payment Method ID: ${paymentMethod.paymentMethodId}');
      
      // Call backend to process payment with payment method ID
      try {
        final response = await _paymentService.chargeSavedCard(
          paymentMethodId: paymentMethod.paymentMethodId,
          bookingId: transaction.bookingId,
          amount: transaction.totalPayment,
        );
        
        debugPrint('✅ Payment response received: $response');
        
        // Check if payment requires authentication
        final requiresAction = response?['requires_action'] == true ||
          response?['status'] == 'requires_action' ||
          response?['status'] == 'requires_source_action';
        
        if (requiresAction) {
          // Payment requires 3D Secure authentication
          _error = '🔐 Payment Authentication Required: Please complete the authentication process for your card and try again.';
          debugPrint('⚠️ Payment requires authentication');
          debugPrint('   Status: ${response?['status']}');
          debugPrint('   Client Secret: ${response?['client_secret']}');
          _safeNotifyListeners();
          return false;
        }
        
        // Check if payment was successful
        final isSuccess = 
          response != null && (
            response['status'] == 'succeeded' ||
            response['message']?.toString().toLowerCase().contains('success') == true ||
            response['success'] == true
          );
        
        if (isSuccess) {
          debugPrint('✅ Payment processed and saved to database');
          
          // Move transaction to completed
          completeTransaction(upcomingIndex);
          
          return true;
        } else {
          _error = response?['message']?.toString() ?? 'Payment processing failed';
          _safeNotifyListeners();
          return false;
        }
      } catch (paymentError) {
        _error = paymentError.toString();
        debugPrint('❌ Payment error: $paymentError');
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Payment failed: $e';
      debugPrint('❌ Payment error: $e');
      _safeNotifyListeners();
      return false;
    }
  }
}