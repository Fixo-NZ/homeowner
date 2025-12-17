import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../constants/stripe_constants.dart';

/// Initializes Stripe SDK with the publishable key
/// Call this once at app startup
Future<void> initializeStripe() async {
  try {
    Stripe.publishableKey = StripeConstants.publishableKey;
    await Stripe.instance.applySettings();
    debugPrint('✅ Stripe initialized successfully');
  } catch (e) {
    debugPrint('❌ Stripe initialization error: $e');
  }
}
