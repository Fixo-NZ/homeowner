import 'package:flutter/material.dart';
import 'package:tradie/paymentTransactions/views/payment_transactions_view.dart';

/// Deprecated shim: redirect to the new `PaymentTransactionsView` implementation.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PaymentTransactionsView();
  }
}