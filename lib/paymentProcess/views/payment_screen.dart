import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/payment_viewmodel.dart';
import 'package:tradie/payment/models/payment_model.dart' as pmModel;
import 'package:tradie/payment/viewmodels/payment_viewmodel.dart' as payment_vm;

final paymentProcessViewModelProvider = ChangeNotifierProvider<PaymentViewModel>((ref) {
  final svc = ref.read(payment_vm.paymentServiceProvider);
  final vm = PaymentViewModel(svc);
  vm.initializePayment();
  return vm;
});

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PaymentScreenContent();
  }
}

class PaymentScreenContent extends ConsumerWidget {
  const PaymentScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(paymentProcessViewModelProvider);
    final paymentData = viewModel.paymentData;

    if (paymentData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          'Book Tradie',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Steps
                    _buildProgressSteps(),
                    const SizedBox(height: 32),
                    
                    // Duration & Cost Section
                    const Text(
                      'Duration & Cost',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Estimate how long the job will take',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Estimated Duration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.access_time, size: 20, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Estimated Duration',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${paymentData.duration} hours',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Payment Method Section
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Conditional rendering based on saved payment methods
                    if (viewModel.savedMethods.isEmpty) ...[
                      // Add Payment Method Card
                      InkWell(
                          onTap: () async {
                          final result = await context.push('/payment/1?amount=10.0');
                          if (result == true) {
                            final vm = ref.read(paymentProcessViewModelProvider);
                            vm.onAddPaymentMethod();
                            // Add a minimal saved method locally so the UI shows it.
                            vm.addSavedMethod(
                              pmModel.PaymentModel(
                                id: 'local-${DateTime.now().millisecondsSinceEpoch}',
                                serviceId: 1,
                                amount: 10.0,
                                currency: 'AUD',
                                status: 'saved',
                                createdAt: DateTime.now(),
                                providerPayload: null,
                                cardBrand: 'VISA',
                                cardLast4: '1231',
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0000FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.credit_card,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Add an a wallet account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Warning Message
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Please select a payment method to continue',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Saved payment methods list
                      Column(
                        children: viewModel.savedMethods.map((pm) {
                          final isSelected = viewModel.selectedPaymentId == pm.id;
                          return ListTile(
                            onTap: () => viewModel.selectPaymentMethod(pm.id),
                            leading: Icon(Icons.credit_card, color: Colors.blue),
                            title: Text(pm.cardBrand ?? 'Card'),
                            subtitle: Text('**** ${pm.cardLast4 ?? ''}'),
                            trailing: Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                          );
                        }).toList(),
                      ),


                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Duration Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '1 hour',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '12 hours',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Cost Breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.attach_money, size: 20, color: Color(0xFF0000FF)),
                              SizedBox(width: 4),
                              Text(
                                'Cost Breakdown',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCostRow(
                            'Hourly Rate',
                            '\$${paymentData.hourlyRate.toStringAsFixed(0)}/hr',
                          ),
                          const SizedBox(height: 12),
                          _buildCostRow(
                            'Duration',
                            '${paymentData.duration} hours',
                          ),
                          const SizedBox(height: 12),
                          _buildCostRow(
                            'Subtotal',
                            '\$${paymentData.subtotal.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 12),
                          _buildCostRow(
                            'Service Fee (10%)',
                            '\$${paymentData.serviceFee.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Estimated Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\$${paymentData.estimatedTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Note Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE0B2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.note_outlined,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Note: This is an estimate',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Final cost will be based on actual time spent and materials used. The tradie will provide a final quote on-site.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Additional Notes Section
                    Row(
                      children: [
                        Icon(
                          Icons.edit_note_outlined,
                          color: const Color(0xFF0000FF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Additional Notes (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Text Input Field
                    TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Any specific requirements, access instructions, or important details...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Buttons
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/dashboard'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF0000FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: Color(0xFF0000FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                    onPressed: viewModel.selectedPaymentId != null 
                        ? () async {
                            final nextAction = await viewModel.onContinue(serviceId: 1, amount: 10.0);
                            if (nextAction != null) {
                              final uri = Uri.parse(nextAction);
                              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Could not open redirect URL')),
                                  );
                                }
                              }
                            } else {
                              if (context.mounted) {
                                context.go('/payment/success');
                              }
                            }
                          }
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: viewModel.selectedPaymentId != null 
                            ? const Color(0xFF0000FF) 
                            : const Color(0xFF9FA4C1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: const Color(0xFF9FA4C1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildStep('Details', true, const Color(0xFF00C853)),
        _buildConnector(true),
        _buildStep('Schedule', true, const Color(0xFF00C853)),
        _buildConnector(true),
        _buildStep('Duration', true, const Color(0xFF0000FF)),
        _buildConnector(false),
        _buildStep('Review', false, Colors.grey.shade300),
      ],
    );
  }

  Widget _buildStep(String label, bool isCompleted, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted && color == const Color(0xFF00C853)
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    label == 'Details' ? '1' : label == 'Schedule' ? '2' : label == 'Duration' ? '3' : '4',
                    style: TextStyle(
                      color: color == Colors.grey.shade300 ? Colors.grey : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color == Colors.grey.shade300 ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 30, left: 4, right: 4),
      color: isActive ? const Color(0xFF00C853) : Colors.grey.shade300,
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}