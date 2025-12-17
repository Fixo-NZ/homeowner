import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'account_setup_success_screen.dart';
import '../models/payment_model.dart' as payment_models;

import 'package:tradie/payment/viewmodels/payment_viewmodel.dart';

class CardConfirmationScreen extends ConsumerStatefulWidget {
  final int serviceId;
  final double amount;
  final String cardNumber;
  final String cardHolder;
  final String? paymentId;
  // expiry and cvv removed by request

  const CardConfirmationScreen({
    super.key,
    required this.serviceId,
    required this.amount,
    required this.cardNumber,
    required this.cardHolder,
    this.paymentId,
  });

  @override
  ConsumerState<CardConfirmationScreen> createState() =>
      _CardConfirmationScreenState();
}

class _CardConfirmationScreenState
    extends ConsumerState<CardConfirmationScreen> {
  bool _isLoading = false;
  bool _cardComplete = false;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Set Up Your Wallet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Stripe CardField for secure card collection
              CardField(
                onCardChanged: (card) {
                  setState(() {
                    _cardComplete = card?.complete ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),

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
                      Icons.info_outline,
                      color: Color(0xFF1976D2),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Security Notice',
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your payment information will be encrypted and stored securely. We use industry-standard security measures to protect your data.',
                            style: TextStyle(
                            color: const Color(0xFF1976D2).withValues(alpha: 0.8),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Confirm & Continue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_cardComplete) ? null : _handleConfirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor:
                        const Color(0xFF1A237E).withValues(alpha: 0.5),
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.lock_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Confirm & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<void> _handleConfirmPayment() async {
    // Validate card is complete BEFORE starting
    if (!_cardComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete card details'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final svc = ref.read(paymentServiceProvider);

      // ✅ Step 1: Request a SetupIntent client_secret from backend
      debugPrint('📝 Requesting SetupIntent from backend...');
      final clientSecret = await svc.getClientSecret();

      // ✅ Step 2: Confirm card with Stripe (CardField MUST be mounted)
      // The CardField widget is still visible on screen, so Stripe can collect it
      debugPrint('💳 Confirming card with Stripe...');
      final paymentMethodId = await svc.confirmCardSetup(clientSecret);

      // ✅ Step 3: Save the payment_method_id to your backend
      debugPrint('💾 Saving payment method to backend with ID: $paymentMethodId');
      final saved = await svc.savePaymentMethod(
        paymentMethodId: paymentMethodId,
        cardHolder: widget.cardHolder,
      );

      if (saved != null) {
        if (mounted) {
          debugPrint('✅ Payment saved successfully, navigating to success screen');
          // Push success screen via Navigator (since we're already in Navigator context)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountSetupSuccessScreen(
                accountType: 'Homeowner',
                accountOwner: widget.cardHolder,
                cardLast4: _getLastFourDigits(widget.cardNumber),
                savedPayment: saved,
              ),
            ),
          ).then((result) {
            // After success screen completes, handle the result
            if (mounted) {
              if (result != null && result is payment_models.PaymentModel) {
                debugPrint('✅ User clicked Get Started, got savedPayment back, now popping to root and navigating to transactions');
                // Pop this confirmation screen and the card setup screen
                Navigator.of(context).popUntil((route) => route.isFirst);
                
                // Use a small delay to ensure we're back at root, then navigate via GoRouter
                Future.delayed(const Duration(milliseconds: 100), () {
                  try {
                    if (mounted) {
                      GoRouter.of(context).go('/payment/transactions', extra: result);
                    }
                  } catch (e) {
                    debugPrint('❌ Could not navigate to transactions: $e');
                    // Fallback to dashboard
                    try {
                      GoRouter.of(context).go('/dashboard');
                    } catch (e2) {
                      debugPrint('❌ Could not navigate to dashboard either: $e2');
                    }
                  }
                });
              } else {
                debugPrint('⚠️ Success screen closed without result, just popping');
                Navigator.pop(context);
              }
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not save payment method. Check logs for details.'),
              backgroundColor: Colors.red,
            ),
          );
          debugPrint('savePaymentMethod failed: received null');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('❌ Confirmation error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getLastFourDigits(String cardNumber) {
    final cleaned = cardNumber.replaceAll(' ', '');
    if (cleaned.length < 4) return cleaned;
    return cleaned.substring(cleaned.length - 4);
  }
}