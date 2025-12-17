import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../payment/models/payment_model.dart';
import '../viewmodels/payment_transactions_viewmodel.dart';
import '../widgets/transaction_card.dart';

class PaymentTransactionsView extends StatefulWidget {
  final PaymentModel? preSelectedPayment;

  const PaymentTransactionsView({
    Key? key,
    this.preSelectedPayment,
  }) : super(key: key);

  @override
  State<PaymentTransactionsView> createState() => _PaymentTransactionsViewState();
}

class _PaymentTransactionsViewState extends State<PaymentTransactionsView> {
  late PaymentTransactionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 PaymentTransactionsView initState called');
    debugPrint('📦 widget.preSelectedPayment: ${widget.preSelectedPayment}');
    if (widget.preSelectedPayment != null) {
      debugPrint('   ✅ Has preSelectedPayment: ${widget.preSelectedPayment!.cardBrand} •••• ${widget.preSelectedPayment!.cardLast4}');
    } else {
      debugPrint('   ⚠️ No preSelectedPayment provided');
    }
    _viewModel = PaymentTransactionsViewModel(
      preSelectedPayment: widget.preSelectedPayment,
    );
    debugPrint('✅ ViewModel created, calling loadBookings()...');
    // Call immediately (no need to wait for post frame callback)
    _viewModel.loadBookings().then((_) {
      debugPrint('✅ loadBookings() completed successfully');
      debugPrint('   Upcoming: ${_viewModel.upcomingCount}');
      debugPrint('   History: ${_viewModel.historyCount}');
    }).catchError((e) {
      debugPrint('❌ loadBookings() failed: $e');
      debugPrint('   Error: ${_viewModel.error}');
    });
  }

  @override
  void dispose() {
    debugPrint('🗑️ PaymentTransactionsView dispose called');
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ PaymentTransactionsView.build() called');
    debugPrint('   _viewModel: $_viewModel');
    debugPrint('   _viewModel.isLoading: ${_viewModel.isLoading}');
    debugPrint('   _viewModel.transactions.length: ${_viewModel.transactions.length}');
    
    return ChangeNotifierProvider<PaymentTransactionsViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E3A8A),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF2563EB),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Top bar
                      Row(
                        children: [
                          InkWell(
                            onTap: () => context.go('/dashboard'),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Payment Transactions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Color(0xFFB8B8B8),
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search bookings',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFB8B8B8),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tabs
                      Consumer<PaymentTransactionsViewModel>(
                        builder: (context, viewModel, child) {
                          return Row(
                            children: [
                              _buildTab(
                                context,
                                'Upcoming',
                                viewModel.upcomingCount,
                                viewModel.selectedTab == 'Upcoming',
                                () => viewModel.setSelectedTab('Upcoming'),
                              ),
                              const SizedBox(width: 12),
                              _buildTab(
                                context,
                                'History',
                                viewModel.historyCount,
                                viewModel.selectedTab == 'History',
                                () => viewModel.setSelectedTab('History'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Transaction list
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Consumer<PaymentTransactionsViewModel>(
                      builder: (context, viewModel, child) {
                        debugPrint('🔄 Consumer rebuilding:');
                        debugPrint('   isLoading: ${viewModel.isLoading}');
                        debugPrint('   error: ${viewModel.error}');
                        debugPrint('   transactions: ${viewModel.transactions.length}');
                        debugPrint('   selectedTab: ${viewModel.selectedTab}');
                        
                        // Loading state
                        if (viewModel.isLoading) {
                          debugPrint('   → Showing loading indicator');
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                            ),
                          );
                        }

                        // Error state
                        if (viewModel.error != null) {
                          debugPrint('   → Showing error: ${viewModel.error}');
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  viewModel.error ?? 'Error loading bookings',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }

                        // Empty state
                        if (viewModel.transactions.isEmpty) {
                          debugPrint('   → Showing empty state for tab: ${viewModel.selectedTab}');
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  viewModel.selectedTab == 'Upcoming'
                                      ? Icons.calendar_today
                                      : Icons.history,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  viewModel.selectedTab == 'Upcoming'
                                      ? 'No upcoming payments'
                                      : 'No payment history',
                                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }

                        // List with data
                        debugPrint('   → Showing ${viewModel.transactions.length} transactions');
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: viewModel.transactions.length,
                          itemBuilder: (context, index) {
                            return TransactionCard(
                              transaction: viewModel.transactions[index],
                              onMakePayment: viewModel.transactions[index].status == 'upcoming'
                                  ? () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      messenger.showSnackBar(const SnackBar(
                                        content: Text('Processing payment...'),
                                        duration: Duration(seconds: 2),
                                      ));
                                      
                                      final success = await viewModel.processPayment(index);
                                      
                                      if (success) {
                                        messenger.showSnackBar(const SnackBar(
                                          content: Text('✅ Payment successful!'),
                                          backgroundColor: Colors.green,
                                        ));
                                      } else {
                                        messenger.showSnackBar(SnackBar(
                                          content: Text(viewModel.error ?? 'Payment failed'),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    }
                                  : null,
                            );
                          },
                        );
                      },
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

  Widget _buildTab(
    BuildContext context,
    String label,
    int count,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}