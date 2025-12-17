# Stripe StripeConstants Explanation

Your `StripeConstants` file contains the **publishable key** that enables Stripe integration in Flutter.

## What Is It?

```dart
class StripeConstants {
  static const String publishableKey = 
    'pk_test_51SFDSSJO8ywAD8tRBDlI6hcTCEoHt133dbzto2W2kB6zHr0EJWMR6D5WcZHlhPTcugchfMWG1rF1NkOVXvcmM7o400pdjXcdol';
  
  static const String merchantDisplayName = 'Tradie App';
}
```

### `publishableKey`
- **What**: Your Stripe test/production public key
- **Starts with**: `pk_test_` (test) or `pk_live_` (production)
- **Safe to share**: YES - this is meant to be public
- **Where it's used**:
  - Flutter app initialization: `Stripe.publishableKey = StripeConstants.publishableKey;`
  - Tells Stripe "this payment is for my account"

### `merchantDisplayName`
- **What**: Your business name shown in payment dialogs
- **Example**: When user enters card, they'll see "Tradie App" in the payment form
- **Used by**: Stripe payment UI

---

## How It Works

### 1. App Initialization (main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeStripe();  // ← Sets up publishableKey
  runApp(...);
}
```

### 2. Stripe Service (lib/core/services/stripe_service.dart)
```dart
Future<void> initializeStripe() async {
  Stripe.publishableKey = StripeConstants.publishableKey;
  await Stripe.instance.applySettings();
  debugPrint('✅ Stripe initialized successfully');
}
```

### 3. In Payment Flow
When user saves a card:
```dart
final result = await Stripe.instance.confirmSetupIntent(
  paymentIntentClientSecret: clientSecret,
  params: PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
);
// Stripe knows this is for YOUR account (via publishableKey)
// Returns: payment_method_id like "pm_1234567890"
```

---

## Keys You Need

### Public Keys (Safe - Put In App)
- `pk_test_xxxxx` - Test mode public key ✅ (what you have now)
- `pk_live_xxxxx` - Production public key ✅ (use this in production)

### Secret Keys (NEVER In App!)
- `sk_test_xxxxx` - Test mode secret key ⚠️ Keep on backend only
- `sk_live_xxxxx` - Production secret key ⚠️ Keep on backend only

---

## Where to Find Yours

1. Go to [https://dashboard.stripe.com](https://dashboard.stripe.com)
2. Login to your account
3. Go to **Developers** → **API Keys**
4. You'll see:
   - Publishable key: `pk_test_...` ← Copy this to Flutter
   - Secret key: `sk_test_...` ← Keep on backend only

---

## Summary

| Item | Location | Safe? |
|------|----------|-------|
| `pk_test_51SFDSS...` | Flutter app (`StripeConstants`) | ✅ Yes |
| `sk_test_xxx` | Backend server only | ⚠️ NO |
| `pk_live_xxx` | Flutter production app | ✅ Yes |
| `sk_live_xxx` | Backend production server only | ⚠️ NO |

Your setup is correct! The publishable key is meant to be in your app. The payment method ID from Stripe is what your backend needs to charge later.

