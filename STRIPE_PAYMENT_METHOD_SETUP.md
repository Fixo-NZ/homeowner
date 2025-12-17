# Payment Method Setup Flow - Stripe Integration Guide

## Overview
Your app now uses **Stripe's SetupIntent** to securely save payment methods. This ensures Stripe handles card tokenization (converting raw card data into a secure `payment_method_id`).

## How It Works

### 🏗️ Architecture
```
Flutter App                    Your Backend               Stripe
   ↓                              ↓                         ↓
1. Show Card Form
   (CardConfirmationScreen)
   ↓
2. Request SetupIntent
   client_secret ──────────→ Backend API ──────────→ Stripe API
   ←──────────────────────────────────────────────── return client_secret
   ↓
3. Collect Card Details
   (Stripe UI shows within Flutter app)
   ↓
4. Confirm SetupIntent
   (Flutter Stripe SDK) ─────────────────────→ Stripe tokenizes card
   ←─────────────────────────────────────── returns payment_method_id
   ↓
5. Save Payment Method ID
   payment_method_id ─────→ Backend API ─→ Backend stores pm_xxx securely
   ↓
6. Success! Now backend has pm_xxx for future charges
```

---

## What Each Part Does

### 1. **Stripe Constants** (`lib/core/constants/stripe_constants.dart`)
```dart
static const String publishableKey = 'pk_test_51SFDSSJO8ywAD8tRBDlI6hcTCEoHt133dbzto2W2kB6zHr0EJWMR6D5WcZHlhPTcugchfMWG1rF1NkOVXvcmM7o400pdjXcdol';
```
- Contains your **public** Stripe key (safe to share)
- **NOT** your secret key (keep that only on your backend)

### 2. **Stripe Service** (`lib/core/services/stripe_service.dart`)
```dart
Future<void> initializeStripe() async {
  Stripe.publishableKey = StripeConstants.publishableKey;
  await Stripe.instance.applySettings();
}
```
- Initializes Stripe once when app starts
- Configured in `main.dart`: `await initializeStripe();`

### 3. **Payment Service Methods** (`lib/payment/services/payment_service.dart`)

#### Step 1: Get Client Secret
```dart
Future<String> getClientSecret() async {
  final resp = await _dio.post(ApiConstants.paymentProcess);
  return resp.data['client_secret'];
}
```
**What backend should do:**
- Call Stripe API to create a SetupIntent
- Return the `client_secret` to Flutter

**Backend Example (Node.js with Express):**
```javascript
app.post('/api/payments', async (req, res) => {
  const intent = await stripe.setupIntents.create();
  res.json({ client_secret: intent.client_secret });
});
```

#### Step 2: Confirm Card Setup
```dart
Future<String> confirmCardSetup(String clientSecret) async {
  final result = await Stripe.instance.confirmSetupIntent(
    paymentIntentClientSecret: clientSecret,
    params: PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
  );
  return result.paymentMethodId;  // This is the pm_xxx ID
}
```
**What happens:**
- Shows native Stripe UI to user
- User enters card details (NOT seen by your app)
- Stripe returns `payment_method_id` like `pm_1234567890`

#### Step 3: Save Payment Method
```dart
Future<PaymentModel?> savePaymentMethod({
  String? paymentMethodId,
  String? cardHolder,
}) async {
  final params = {
    'payment_method_id': paymentMethodId,  // e.g., pm_1234567890
    'card_holder': cardHolder,
  };
  final resp = await _dio.post(ApiConstants.paymentsSave, data: params);
  return PaymentModel.fromJson(resp.data);
}
```
**What backend should do:**
- Receive `payment_method_id` from Flutter
- Store it in your database linked to the user
- Use it later for charging: `stripe.paymentIntents.create({ payment_method: 'pm_xxx' })`

---

## Complete Flow in CardConfirmationScreen

```dart
Future<void> _handleConfirmPayment() async {
  final svc = ref.read(paymentServiceProvider);

  // Step 1️⃣: Get SetupIntent client_secret
  final clientSecret = await svc.getClientSecret();

  // Step 2️⃣: Show Stripe UI and get payment_method_id
  final paymentMethodId = await svc.confirmCardSetup(clientSecret);

  // Step 3️⃣: Send payment_method_id to backend
  final saved = await svc.savePaymentMethod(
    paymentMethodId: paymentMethodId,
    cardHolder: widget.cardHolder,
  );

  if (saved != null) {
    // Success! Navigate to success screen
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => AccountSetupSuccessScreen(...)
    ));
  }
}
```

---

## Key Points

### ✅ What Your Backend Needs to Do

1. **Create SetupIntent**
   ```
   POST /api/payments
   Response: { client_secret: "seti_xxx" }
   ```

2. **Receive Payment Method ID**
   ```
   POST /api/payments/save-payment-method
   Body: { payment_method_id: "pm_xxx", card_holder: "John Doe" }
   Response: { payment_method_id: "pm_xxx", ... }
   ```

3. **Store payment_method_id** in your database
   - Link it to the user's account
   - Use it for future payments

4. **Example Backend (Laravel)**:
   ```php
   // Create SetupIntent
   Route::post('/payments', function () {
     $intent = \Stripe\SetupIntent::create();
     return response()->json(['client_secret' => $intent->client_secret]);
   });

   // Save Payment Method
   Route::post('/payments/save-payment-method', function (Request $request) {
     $paymentMethodId = $request->input('payment_method_id');
     // Store in database
     auth()->user()->payment_methods()->create([
       'stripe_payment_method_id' => $paymentMethodId,
     ]);
     return response()->json(['success' => true]);
   });
   ```

### ⚠️ Important Security Notes

1. **NEVER** send raw card numbers to your backend
   - Stripe SDK handles this securely
   - Only send `payment_method_id`

2. **NEVER** store `payment_method_id` or `client_secret` in SharedPreferences
   - They're temporary/sensitive
   - Only store user tokens after successful auth

3. **Secret Key** goes ONLY on your backend
   - If `pk_test_...` is visible, that's OK (it's public)
   - If `sk_test_...` is visible, **ROTATE IT IMMEDIATELY** ⚠️

### 🔍 Testing

1. **Test Card Numbers** (in Stripe test mode):
   - `4242 4242 4242 4242` - Success
   - `4000 0025 0000 0003` - 3D Secure (SCA) required
   - `5555 5555 5555 4444` - Mastercard

2. **Check Logs** for debugging:
   ```
   ✅ SetupIntent client_secret received: seti_xxx
   🔄 Confirming SetupIntent with client_secret: seti_xxx
   ✅ Payment method created: pm_xxx
   💾 Saving payment method to backend with ID: pm_xxx
   ```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Client secret not returned" | Backend `/payments` endpoint doesn't call Stripe or return wrong field |
| "confirmSetupIntent returned empty paymentMethodId" | Stripe SDK not initialized, or user cancelled |
| "payment_method_id is null" | Check `savePaymentMethod` response shape |
| 400 error when saving | Backend validation failed, check error message in response |

---

## Next Steps

1. ✅ Flutter code is ready
2. ⏳ Update your **backend** to:
   - Create SetupIntents
   - Accept and store `payment_method_id`
   - Use stored `payment_method_id` for charging

3. Test end-to-end with a test card

