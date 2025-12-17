import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentTransactionScreen extends ConsumerStatefulWidget {
  final PaymentModel? preSelectedPayment;

  const PaymentTransactionScreen({
    super.key,
    this.preSelectedPayment,
  });

  @override
  ConsumerState<PaymentTransactionScreen> createState() =>
      _PaymentTransactionScreenState();
}

class _PaymentTransactionScreenState
    extends ConsumerState<PaymentTransactionScreen> {
  late PaymentModel? _selectedPayment;
  bool _isLoading = false;
  List<PaymentModel> _savedPayments = [];

  @override
  void initState() {
    super.initState();
    _selectedPayment = widget.preSelectedPayment;
    _loadSavedPayments();
  }

  Future<void> _loadSavedPayments() async {
    setState(() => _isLoading = true);
    try {
      final service = PaymentService();
      final payments = await service.listPayments();
      setState(() {
        _savedPayments = payments;
        // If no pre-selected payment, use the first one
        if (_selectedPayment == null && _savedPayments.isNotEmpty) {
          _selectedPayment = _savedPayments.first;
        }
      });
    } catch (e) {
      debugPrint('Error loading saved payments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load payment methods: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final service = PaymentService();

      // Charge the saved card using the payment ID
      if (_selectedPayment!.id.isNotEmpty) {
        debugPrint('💳 Processing payment for ID: ${_selectedPayment!.id}');

        final response = await service.chargeSavedCard(
          paymentId: _selectedPayment!.id,
        );

        if (response != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment successful! Your booking is confirmed.'),
                backgroundColor: Colors.green,
              ),
            );
            debugPrint('✅ Payment processed successfully');
            // Navigate back to dashboard or booking confirmation
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              }
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment processing failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('❌ Payment error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text(
          'Make Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading && _savedPayments.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9B8CE8),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Method Selection
                    const Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Saved Payment Cards List
                    if (_savedPayments.isNotEmpty)
                      ..._buildPaymentCardsList()
                    else if (!_isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No payment methods saved',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Payment Summary
                    if (_selectedPayment != null) ...[
                      const SizedBox(height: 32),
                      _buildPaymentSummary(),
                    ],

                    const SizedBox(height: 32),

                    // Make Payment Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _selectedPayment == null)
                            ? null
                            : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B8CE8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          disabledBackgroundColor:
                              const Color(0xFF9B8CE8).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Make Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildPaymentCardsList() {
    return _savedPayments.map((payment) {
      final isSelected = _selectedPayment?.id == payment.id;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: GestureDetector(
          onTap: () => setState(() => _selectedPayment = payment),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF9B8CE8)
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? const Color(0xFF9B8CE8).withValues(alpha: 0.05)
                  : Colors.white,
            ),
            child: Row(
              children: [
                // Radio Button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF9B8CE8)
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Color(0xFF9B8CE8),
                            size: 20,
                          ),
                        )
                      : const SizedBox(),
                ),
                const SizedBox(width: 16),

                // Card Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Brand and Last 4
                      Row(
                        children: [
                          Icon(
                            _getCardIcon(payment.cardBrand),
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            payment.cardBrand ?? 'Card',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '**** **** **** ${payment.cardLast4 ?? 'XXXX'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Created Date
                      Text(
                        _formatDateFromDateTime(payment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                if (isSelected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B8CE8).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9B8CE8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '\$${_selectedPayment?.amount.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Currency:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                _selectedPayment?.currency ?? 'AUD',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${_selectedPayment?.cardBrand ?? 'Card'} •••• ${_selectedPayment?.cardLast4 ?? 'XXXX'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCardIcon(String? brand) {
    switch (brand?.toUpperCase()) {
      case 'VISA':
        return Icons.credit_card;
      case 'MASTERCARD':
        return Icons.credit_card;
      case 'AMEX':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  String _formatDateFromDateTime(DateTime dateTime) {
    return 'Added on ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
