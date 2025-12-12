import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/payment_viewmodel.dart';
import 'package:tradie/features/auth/viewmodels/auth_viewmodel.dart';
import 'card_setup_screen.dart';

class PaymentScreen extends ConsumerWidget {
  final int serviceId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.serviceId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(paymentViewModelProvider(serviceId).notifier);
    final state = ref.watch(paymentViewModelProvider(serviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with Purple Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF9B8CE8),
                    const Color(0xFF9B8CE8).withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Stack(
                children: [
                  // Close button
                  Positioned(
                    right: 16,
                    top: 16,
                    child: GestureDetector(
                      onTap: () => context.go('/dashboard'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // Header content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    child: Column(
                      children: [
                        // Credit card icon container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.credit_card_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Add Payment Method',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Verify your payment to unlock instant bookings and\nexclusive homeowner benefits',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Benefits List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Instant Bookings
                    _buildBenefitCard(
                      icon: Icons.flash_on_rounded,
                      iconColor: const Color(0xFF9B8CE8),
                      title: 'Instant Bookings',
                      description: 'Book services immediately without delays',
                    ),
                    const SizedBox(height: 16),
                    
                    // Secure Payments
                    _buildBenefitCard(
                      icon: Icons.security_rounded,
                      iconColor: const Color(0xFF9B8CE8),
                      title: 'Secure Payments',
                      description: 'Bank-level encryption protects your data',
                    ),
                    const SizedBox(height: 16),
                    
                    // Protected Transactions
                    _buildBenefitCard(
                      icon: Icons.verified_user_rounded,
                      iconColor: const Color(0xFF9B8CE8),
                      title: 'Protected Transactions',
                      description: 'Fraud protection on all payments',
                    ),
                    const SizedBox(height: 24),

                    // Security Notice (Green Box)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF81C784),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF4CAF50),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your security is our priority',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'We never store your full payment details. All transactions are encrypted and compliant with PCI DSS standards',
                                  style: TextStyle(
                                    color: const Color(0xFF2E7D32).withValues(alpha: 0.8),
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

                    // Show error if any
                    if (state.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primary Button - Add Payment Method
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              // Initialize/create payment and get canonical data back.
                              final created = await vm.initForService(serviceId, amount);

                              // Use canonical amount and any provider payload returned from backend.
                              final displayAmount = created?.amount ?? amount;
                              final providerPayload = created?.providerPayload;

                              if (!context.mounted) return;

                              // get current logged-in user's name to prefill cardholder
                              final userName = ref.read(authViewModelProvider).user?.fullName;

                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CardSetupScreen(
                                    serviceId: serviceId,
                                    amount: displayAmount,
                                    paymentId: created?.id,
                                    // pass masked card/account data to show in UI if backend provided it
                                    maskedCard: providerPayload?['masked_pan'] as String?,
                                    cardBrand: providerPayload?['card_brand'] as String?,
                                    accountLast4: providerPayload?['account_last4'] as String?,
                                    cardHolderInitial: userName,
                                  ),
                                ),
                              );

                              // If card added successfully, close this screen too
                              if (result == true && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B8CE8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        disabledBackgroundColor: const Color(0xFF9B8CE8).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Add Payment Method',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Maybe Later Button
                  TextButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text(
                      'Maybe Later',
                      style: TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Helper text
                  Text(
                    'You can set up payment later in your\naccount settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
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
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // helper removed; navigation to CardSetupScreen is performed inline
}