# Complete Code Flow - Payment Method Saving

## User Taps "Add Card" Button

### 1️⃣ CardConfirmationScreen - _handleConfirmPayment()

```dart
Future<void> _handleConfirmPayment() async {
  setState(() => _isLoading = true);
  
  try {
    final svc = ref.read(paymentServiceProvider);

    // STEP 1: Request SetupIntent from backend
    debugPrint('📝 Requesting SetupIntent from backend...');
    final clientSecret = await svc.getClientSecret();
    // Returns: "seti_1234567890_secret_xxx"

    // STEP 2: Show Stripe UI and collect card
    debugPrint('💳 Showing Stripe payment form...');
    final paymentMethodId = await svc.confirmCardSetup(clientSecret);
    // Returns: "pm_1234567890"

    // STEP 3: Save payment method to backend
    debugPrint('💾 Saving payment method to backend with ID: $paymentMethodId');
    final saved = await svc.savePaymentMethod(
      paymentMethodId: paymentMethodId,
      cardHolder: widget.cardHolder,
    );

    if (saved != null) {
      // Success! Show success screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccountSetupSuccessScreen(...)
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } else {
      // Failed to save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save payment method'))
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: $e'))
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

## PaymentService Methods

### Method 1: getClientSecret()

```dart
/// Requests SetupIntent from backend
Future<String> getClientSecret() async {
  try {
    // Call your backend API
    final resp = await _dio.post(ApiConstants.paymentProcess);

    if (resp.data == null || resp.data['client_secret'] == null) {
      throw Exception('Client secret not returned by backend');
    }

    debugPrint('✅ SetupIntent client_secret received: ${resp.data['client_secret']}');
    return resp.data['client_secret'];
  } catch (e) {
    debugPrint('❌ getClientSecret error: $e');
    rethrow;
  }
}
```

**Backend should return:**
```json
{
  "client_secret": "seti_1234567890_secret_xxx"
}
```

---

### Method 2: confirmCardSetup()

```dart
/// Confirms SetupIntent and returns payment_method_id
Future<String> confirmCardSetup(String clientSecret) async {
  try {
    debugPrint('🔄 Confirming SetupIntent with client_secret: $clientSecret');
    
    // This shows Stripe card input UI to user
    final result = await Stripe.instance.confirmSetupIntent(
      paymentIntentClientSecret: clientSecret,
      params: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData()
      ),
    );

    if (result.paymentMethodId.isEmpty) {
      throw Exception('Stripe confirmSetupIntent did not return a payment method id');
    }

    debugPrint('✅ Payment method created: ${result.paymentMethodId}');
    return result.paymentMethodId;  // e.g., "pm_1234567890"
  } catch (e) {
    debugPrint('❌ confirmCardSetup error: $e');
    rethrow;
  }
}
```

**Stripe returns:**
```
paymentMethodId: "pm_1234567890"
```

---

### Method 3: savePaymentMethod()

```dart
/// Saves payment_method_id to backend
Future<PaymentModel?> savePaymentMethod({
  String? cardNumber,
  String? cardHolder,
  String? cardBrand,
  String? last4,
  String? paymentMethodId,
}) async {
  try {
    final params = <String, dynamic>{};

    if (paymentMethodId != null && paymentMethodId.isNotEmpty) {
      // NEW WAY: Send only the payment_method_id
      params['payment_method_id'] = paymentMethodId;
    } else if (cardNumber != null && cardNumber.isNotEmpty) {
      // OLD WAY: Send raw card details (avoided)
      if (cardNumber.startsWith('pm_')) {
        params['payment_method_id'] = cardNumber;
      } else {
        params['card_number'] = cardNumber;
        params['card_holder'] = cardHolder;
        if (cardBrand != null) params['card_brand'] = cardBrand;
        if (last4 != null) params['last4'] = last4;
      }
    } else {
      debugPrint('savePaymentMethod called without data');
      return null;
    }

    debugPrint('savePaymentMethod request params: $params');

    // Send to backend
    final resp = await _dio.post(ApiConstants.paymentsSave, data: params);

    debugPrint('savePaymentMethod response: ${resp.statusCode} ${resp.data}');

    if (resp.statusCode != null && resp.statusCode! >= 400) {
      return null;
    }

    final data = resp.data;
    if (data is Map<String, dynamic>) {
      final candidate = data.containsKey('payment')
          ? data['payment']
          : (data.containsKey('data') ? data['data'] : data);
      if (candidate is Map<String, dynamic>) {
        return PaymentModel.fromJson(candidate);
      }
    }

    return null;
  } catch (e) {
    debugPrint('savePaymentMethod error: $e');
    return null;
  }
}
```

**Sends to backend:**
```json
{
  "payment_method_id": "pm_1234567890",
  "card_holder": "John Doe"
}
```

**Backend should return:**
```json
{
  "payment": {
    "id": 123,
    "stripe_payment_method_id": "pm_1234567890",
    "card_holder": "John Doe",
    "status": "saved"
  }
}
```

---

## What Your Backend Does

### Step 1: Create SetupIntent
```php
// Laravel Example
Route::post('/api/payments', function () {
    // Create a Stripe SetupIntent
    $intent = \Stripe\SetupIntent::create();
    
    return response()->json([
        'client_secret' => $intent->client_secret
    ]);
});
```

**Response:**
```
client_secret: "seti_1234567890_secret_xxx"
```

### Step 2: Store Payment Method
```php
// Laravel Example
Route::post('/api/payments/save-payment-method', function (Request $request) {
    $paymentMethodId = $request->input('payment_method_id');
    $cardHolder = $request->input('card_holder');
    $user = auth()->user();
    
    // Verify with Stripe
    $pm = \Stripe\PaymentMethod::retrieve($paymentMethodId);
    
    // Store in your database
    $payment = $user->payments()->create([
        'stripe_payment_method_id' => $paymentMethodId,
        'card_holder' => $cardHolder,
        'card_last4' => $pm->card->last4,
        'card_brand' => $pm->card->brand,
        'status' => 'saved'
    ]);
    
    return response()->json([
        'payment' => [
            'id' => $payment->id,
            'stripe_payment_method_id' => $paymentMethodId,
            'card_holder' => $cardHolder,
            'status' => 'saved'
        ]
    ]);
});
```

---

## Console Output When Saving

```
📝 Requesting SetupIntent from backend...
✅ SetupIntent client_secret received: seti_1234567890_secret_xxx
💳 Showing Stripe payment form...
(User enters card in UI)
✅ Payment method created: pm_1234567890
💾 Saving payment method to backend with ID: pm_1234567890
savePaymentMethod request params: {payment_method_id: pm_1234567890, card_holder: John Doe}
savePaymentMethod response: 200 {payment: {...}}
```

---

## Error Cases

### Error 1: Backend not returning client_secret
```
❌ getClientSecret error: Client secret not returned by backend
```
**Fix:** Backend POST /api/payments endpoint not implemented or returning wrong field

### Error 2: User cancelled card entry
```
❌ confirmCardSetup error: Stripe operation cancelled by user
```
**Fix:** User cancelled payment form - show try again option

### Error 3: Backend validation error
```
❌ savePaymentMethod error: Invalid payment method
```
**Fix:** Backend validation failing - check error response from backend

---

## Summary

1. **User taps "Confirm & Continue"**
2. **Flutter requests SetupIntent** → Backend creates it → Returns client_secret
3. **Flutter shows Stripe UI** → User enters card → Stripe tokenizes → Returns pm_xxx
4. **Flutter sends pm_xxx to backend** → Backend stores it in database
5. **Success!** Card saved, ready for future charges

No raw card numbers ever exposed! ✅

