import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/payment_model.dart';

class AccountSetupSuccessScreen extends StatelessWidget {
  final String accountType;
  final String accountOwner;
  final String cardLast4;
  final PaymentModel? savedPayment;

  const AccountSetupSuccessScreen({
    super.key,
    this.accountType = 'Homeowner',
    this.accountOwner = 'John Doe',
    this.cardLast4 = '1231',
    this.savedPayment,
  });

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
          'Account Setup',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Success Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4CAF50),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xFF4CAF50),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Welcome Message
                      const Text(
                        'Welcome Aboard!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your account has been successfully created',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Account Details Cards
                      _buildDetailCard(
                        icon: Icons.person_outline,
                        iconColor: const Color(0xFF9B8CE8),
                        label: 'Account Type',
                        value: accountType,
                      ),
                      const SizedBox(height: 12),

                      _buildDetailCard(
                        icon: Icons.account_circle_outlined,
                        iconColor: const Color(0xFF5C6BC0),
                        label: 'Account Owner',
                        value: accountOwner,
                      ),
                      const SizedBox(height: 12),

                      _buildDetailCard(
                        icon: Icons.credit_card,
                        iconColor: const Color(0xFF66BB6A),
                        label: 'Payment Method',
                        value: 'BNZ',
                        subtitle: '**** **** **** $cardLast4',
                      ),
                      const SizedBox(height: 32),

                      // What's Next Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'What\'s Next?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Next Steps Checklist
                      _buildChecklistItem(
                        'Browse and connect with trusted tradespeople',
                      ),
                      const SizedBox(height: 12),
                      _buildChecklistItem(
                        'Post your first project or request a quote',
                      ),
                      const SizedBox(height: 12),
                      _buildChecklistItem(
                        'Set up notifications and preferences',
                      ),
                    ],
                  ),
                ),
              ),

              // Get Started Button
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop this screen and return the savedPayment to CardConfirmationScreen
                    // CardConfirmationScreen will then navigate to transactions using GoRouter
                    Navigator.of(context).pop(savedPayment);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
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

  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFF66BB6A),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}