/// Stripe configuration constants for the application.
/// 
/// IMPORTANT: For production, store the publishable key securely (e.g., in a config server).
/// Do NOT hardcode sensitive keys in production builds.
class StripeConstants {
  /// Stripe Publishable Key - required to initialize Stripe SDK
  /// This is safe to expose on the client side
  static const String publishableKey =
      'pk_test_51SFDSSJO8ywAD8tRBDlI6hcTCEoHt133dbzto2W2kB6zHr0EJWMR6D5WcZHlhPTcugchfMWG1rF1NkOVXvcmM7o400pdjXcdol';

  /// Stripe Merchant Display Name (shown in payment dialogs)
  static const String merchantDisplayName = 'Tradie App';
}
