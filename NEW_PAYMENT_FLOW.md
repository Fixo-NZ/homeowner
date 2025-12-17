# New Payment Flow: Card Save → Upcoming Transactions

## ✅ Updated Flow

Instead of:
```
Add Card → Success Screen → Payment Method Selector → Make Payment
```

Now:
```
Add Card → Success Screen → Upcoming Transactions List → Make Payment with Pre-Selected Card
```

---

## Complete Flow

### 1. Add Payment Method
- User navigates to card setup screen
- Enters card details
- Taps "Confirm & Continue"
- Card is saved to backend & Stripe

### 2. Success Screen (AccountSetupSuccessScreen)
- Shows "Welcome Aboard!"
- Displays saved card details
  - Account Type: Homeowner
  - Account Owner: [User Name]
  - Payment Method: [Card Brand] •••• [Last 4]
- Shows "What's Next?" checklist
- **Taps "Get Started"** → Navigates to `/payment/transactions` with saved card

### 3. Payment Transactions Screen (NEW BEHAVIOR)
**Shows UPCOMING BOOKINGS that need payment:**

```
┌─────────────────────────────────────────────┐
│ Payment Transactions          [←]            │
├─────────────────────────────────────────────┤
│                                              │
│ [Upcoming] [History]                        │
│                                              │
│ ┌──────────────────────────────────────────┐│
│ │ 👤 John Tradie           [⭐ Pending]    ││
│ │    Booked Payment                        ││
│ │    Roof Repair Service                   ││
│ │    Dec 20, 2025 • Sydney                 ││
│ │    Total: $250.00         [Make Payment] ││
│ └──────────────────────────────────────────┘│
│                                              │
│ ┌──────────────────────────────────────────┐│
│ │ 👤 Jane Tradie           [⭐ Pending]    ││
│ │    Booked Payment                        ││
│ │    Plumbing Service                      ││
│ │    Dec 25, 2025 • Melbourne              ││
│ │    Total: $150.00         [Make Payment] ││
│ └──────────────────────────────────────────┘│
│                                              │
└─────────────────────────────────────────────┘
```

### 4. Make Payment
User clicks "Make Payment" button on a booking

**Backend Process:**
1. Pre-selected payment card is used automatically
2. No need to select payment method again
3. Backend charges the card:
   - Looks up payment record
   - Gets saved card details
   - Creates Stripe PaymentIntent
   - Charges the card
4. Updates booking status to "completed"
5. Moves transaction from "Upcoming" to "History"

### 5. Payment Confirmation
- Success message: "✅ Payment successful!"
- Transaction moves to History tab
- User can see completed payment with ✓ badge

---

## Code Changes

### 1. **AccountSetupSuccessScreen**
```dart
onPressed: () {
  // Navigate to Payment Transactions with pre-selected payment
  context.go('/payment/transactions', extra: savedPayment);
}
```

### 2. **PaymentTransactionsView**
```dart
class PaymentTransactionsView extends StatefulWidget {
  final PaymentModel? preSelectedPayment;  // NEW: Accept pre-selected card
  
  const PaymentTransactionsView({
    Key? key,
    this.preSelectedPayment,  // NEW
  }) : super(key: key);
```

### 3. **PaymentTransactionsViewModel**
```dart
class PaymentTransactionsViewModel extends ChangeNotifier {
  PaymentModel? _preSelectedPayment;  // NEW: Store pre-selected card
  
  PaymentTransactionsViewModel({PaymentModel? preSelectedPayment}) {
    _preSelectedPayment = preSelectedPayment;
  }
  
  Future<bool> processPayment(int upcomingIndex) async {
    // NEW: Use pre-selected payment if available
    if (_preSelectedPayment != null) {
      debugPrint('✅ Using pre-selected payment');
      paymentMethod = _preSelectedPayment;
    } else {
      // Fallback: Fetch first saved card from backend
      debugPrint('ℹ️ Fetching first saved card');
      final savedCard = await _paymentService.getFirstSavedCard();
    }
    
    // Charge the card
    final response = await _paymentService.chargeSavedCard(
      paymentId: paymentMethod.id,
    );
  }
}
```

---

## User Experience Improvements

### Before
1. Add card
2. See success screen
3. Navigate to payment method selector
4. Choose payment method (even though only one exists)
5. See payment summary
6. Make payment

**Issue**: Extra steps, confusing UI flow, no connection between card and bookings

### After
1. Add card
2. See success screen
3. **See upcoming bookings that need payment**
4. Click "Make Payment" on desired booking
5. **Card is used automatically** (no selection needed)
6. Payment processed
7. Booking moves to completed

**Benefits**:
- ✅ Clearer purpose: shows what you're paying for
- ✅ Streamlined: no unnecessary selection screens
- ✅ Contextual: pre-selected card is automatically used
- ✅ Seamless: directly connected to bookings

---

## Technical Details

### Route Navigation
```dart
// AccountSetupSuccessScreen
context.go('/payment/transactions', extra: savedPayment);

// Routes configuration (GoRouter)
GoRoute(
  path: '/payment/transactions',
  builder: (context, state) {
    final preSelectedPayment = state.extra as PaymentModel?;
    return PaymentTransactionsView(
      preSelectedPayment: preSelectedPayment,
    );
  },
),
```

### Payment Processing Logic

**When user clicks "Make Payment":**

```dart
// processPayment() method
if (_preSelectedPayment != null) {
  // Use pre-selected card
  paymentMethod = _preSelectedPayment;
} else {
  // Fallback to fetching from backend
  final savedCard = await _paymentService.getFirstSavedCard();
  paymentMethod = PaymentModel(...);
}

// Charge using payment ID
final response = await _paymentService.chargeSavedCard(
  paymentId: paymentMethod.id,  // Backend handles amount & booking
);

// If successful, move transaction to history
if (isSuccess) {
  completeTransaction(upcomingIndex);
}
```

### Backend Endpoint
```
POST /payment/charge-saved-card
Body: { payment_id: "..." }

Backend Actions:
1. Fetch Payment record (contains amount, service_id)
2. Get SavedCards (payment method details)
3. Create Stripe PaymentIntent
4. Charge card
5. Update Payment status
6. Update Booking status to 'completed'
```

---

## Testing Checklist

- [ ] Add new payment method → sees success screen
- [ ] Click "Get Started" → navigates to upcoming transactions
- [ ] Upcoming transactions list loads correctly
- [ ] Shows all pending bookings with amount and service
- [ ] Click "Make Payment" on a booking
- [ ] Payment processes without asking for payment method
- [ ] Success message displayed
- [ ] Booking moves from "Upcoming" to "History"
- [ ] Booking shows "✓ Completed" badge
- [ ] Can make multiple payments with same card
- [ ] History tab shows all completed payments

---

## Summary

The new flow is much more intuitive:
- **Shows what you're paying for** (bookings/services) instead of abstract payment methods
- **Pre-selects the newly saved card** automatically
- **Reduces friction** by eliminating unnecessary selection screens
- **Provides immediate context** about upcoming payments

This creates a seamless experience where saving a card immediately leads to making payments for pending bookings!
