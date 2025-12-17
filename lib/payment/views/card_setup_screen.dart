import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'account_setup_success_screen.dart';
import '../models/payment_model.dart' as payment_models;
import '../services/payment_service.dart';
import 'package:go_router/go_router.dart';

class CardSetupScreen extends ConsumerStatefulWidget {
  final int serviceId;
  final double amount;
  final String? paymentId;
  final String? maskedCard;
  final String? cardBrand;
  final String? accountLast4;
  final String? cardHolderInitial;

  const CardSetupScreen({
    super.key,
    required this.serviceId,
    required this.amount,
    this.paymentId,
    this.maskedCard,
    this.cardBrand,
    this.accountLast4,
    this.cardHolderInitial,
  });

  @override
  ConsumerState<CardSetupScreen> createState() => _CardSetupScreenState();
}

class _CardSetupScreenState extends ConsumerState<CardSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  
  bool _isDefaultPayment = false;
  bool _isLoading = false;
  bool _cardComplete = false;
  
  // Stripe card data
  CardFieldInputDetails? _cardFieldData;

  @override
  void dispose() {
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Prefill card holder name with logged-in user's name if provided
    if (widget.cardHolderInitial != null && widget.cardHolderInitial!.isNotEmpty) {
      _cardHolderController.text = widget.cardHolderInitial!;
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Add Your Card',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure payment with Stripe',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Card Visual Preview
                _buildCardVisual(),
                const SizedBox(height: 32),

                // Cardholder Name Input
                TextFormField(
                  controller: _cardHolderController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Cardholder Name',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    hintText: 'John Doe',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF9B8CE8),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cardholder name';
                    }
                    if (value.length < 3) {
                      return 'Name is too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Stripe CardField for secure card collection
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CardField(
                    onCardChanged: (card) {
                      setState(() {
                        _cardFieldData = card;
                        _cardComplete = card?.complete ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Security Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF90CAF9),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF1976D2),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your card details are encrypted and securely transmitted to Stripe',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Set as Default Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Set as default payment method',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Switch(
                      value: _isDefaultPayment,
                      onChanged: (value) {
                        setState(() {
                          _isDefaultPayment = value;
                        });
                      },
                      activeThumbColor: const Color(0xFF9B8CE8),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Add Card Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_cardComplete) ? null : _handleAddCard,
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Add Card',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardVisual() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('lib/assets/images/BNZ.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Amount at top
            Text(
              '\$${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Bottom section with card details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card number (from Stripe)
                Text(
                  _cardFieldData != null ? '**** **** **** ${_cardFieldData!.last4}' : '**** **** **** ****',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Cardholder name and expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Holder',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _cardHolderController.text.isEmpty
                              ? (widget.cardHolderInitial ?? 'Card Holder')
                              : _cardHolderController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Expires',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _cardFieldData != null 
                            ? '${_cardFieldData!.expiryMonth}/${_cardFieldData!.expiryYear}'
                            : 'MM/YY',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_cardComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete card details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate card data
      if (_cardFieldData == null || !_cardComplete) {
        throw Exception('Card details incomplete');
      }

      // Initialize payment service
      final paymentService = PaymentService();

      // ✅ Step 1: Request a SetupIntent client_secret from backend
      debugPrint('📝 Requesting SetupIntent from backend...');
      final clientSecret = await paymentService.getClientSecret();

      // ✅ Step 2: Confirm card with Stripe using SetupIntent
      debugPrint('💳 Confirming card with Stripe...');
      final paymentMethodId = await paymentService.confirmCardSetup(clientSecret);

      // ✅ Step 3: Save the payment_method_id to backend
      debugPrint('💾 Saving payment method to backend with ID: $paymentMethodId');
      final savedPayment = await paymentService.savePaymentMethod(
        paymentMethodId: paymentMethodId,
        cardHolder: _cardHolderController.text,
      );

      if (savedPayment == null) {
        throw Exception('Failed to save payment method to backend');
      }

      // Navigate to success screen with saved payment data
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountSetupSuccessScreen(
              cardLast4: savedPayment.cardLast4 ?? '****',
              savedPayment: savedPayment,
            ),
          ),
        );

        // If setup was successful, pop back and navigate to transactions
        if (result != null && result is payment_models.PaymentModel && mounted) {
          debugPrint('✅ User clicked Get Started, navigating to transactions');
          Navigator.of(context).popUntil((route) => route.isFirst);
          
          // Delay to ensure we're back at root
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              try {
                GoRouter.of(context).go('/payment/transactions', extra: result);
              } catch (e) {
                debugPrint('❌ Could not navigate to transactions: $e');
              }
            }
          });
        } else if (result == true && mounted) {
          Navigator.pop(context, true);
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
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}