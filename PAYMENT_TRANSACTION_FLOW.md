# Payment Transaction Flow

## Overview
The payment transaction flow handles charging a saved payment method (credit card) and completing a payment for a booking.

---

## Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. User navigates to PaymentTransactionScreen                   │
│    - Either from AccountSetupSuccessScreen (pre-selected card)   │
│    - Or from a booking payment request                           │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. initState() called                                           │
│    - Store preSelectedPayment (if passed from success screen)    │
│    - Call _loadSavedPayments()                                   │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. _loadSavedPayments()                                         │
│    - PaymentService.listPayments()                              │
│    - Backend GET /saved-cards                                   │
│    - Fetch all saved payment methods for user                   │
│    - If preSelectedPayment exists: use it                       │
│    - Else: use first saved card                                 │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. UI Renders                                                    │
│    ┌─────────────────────────────────────────────────────────┐  │
│    │ Back Button (→ Dashboard)                               │  │
│    │                                                          │  │
│    │ Select Payment Method                                   │  │
│    │ ┌────────────────────────────────────────────────────┐ │  │
│    │ │ ● [Selected] Visa •••• 4242 (PRE-SELECTED)        │ │  │
│    │ │   Added on 17/12/2025                              │ │  │
│    │ │                                                     │ │  │
│    │ │ ○ Mastercard •••• 5555                             │ │  │
│    │ │   Added on 15/12/2025                              │ │  │
│    │ └────────────────────────────────────────────────────┘ │  │
│    │                                                          │  │
│    │ Payment Summary                                         │  │
│    │ Amount:          $150.00                               │  │
│    │ Currency:        AUD                                   │  │
│    │ Payment Method:  Visa •••• 4242                        │  │
│    │                                                          │  │
│    │ [Make Payment Button]                                   │  │
│    │ [Cancel Button]                                         │  │
│    └─────────────────────────────────────────────────────────┘  │
└──────────────────────┬──────────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │ User Action?                 │
        │                              │
        ▼                              ▼
   Select Card                    Click Make Payment
        │                              │
        │ (Update _selectedPayment)    │
        │                              ▼
        │                    ┌─────────────────────────┐
        │                    │ 5. _processPayment()    │
        │                    │ - Check if card selected│
        │                    │ - Set _isLoading = true │
        │                    └──────────┬──────────────┘
        │                               │
        │                               ▼
        │                    ┌─────────────────────────────────┐
        │                    │ 6. PaymentService.              │
        │                    │    chargeSavedCard(             │
        │                    │      paymentId: payment.id      │
        │                    │    )                            │
        │                    └──────────┬────────────────────┘
        │                               │
        │                               ▼
        │                    ┌──────────────────────────────────────┐
        │                    │ 7. Backend API Call                  │
        │                    │ POST /payment/charge-saved-card      │
        │                    │ Body: { payment_id: "..." }          │
        │                    │                                       │
        │                    │ Backend Actions:                      │
        │                    │ 1. Retrieve payment record            │
        │                    │ 2. Get saved card & booking info      │
        │                    │ 3. Create Stripe PaymentIntent       │
        │                    │ 4. Process charge                    │
        │                    │ 5. Save to payments table            │
        │                    │ 6. Update booking status to          │
        │                    │    'completed'                       │
        │                    │ 7. Return response                   │
        │                    └──────────┬───────────────────────────┘
        │                               │
        │                    ┌──────────┴──────────┐
        │                    │ Response Received?  │
        │                    │                     │
        │                    ▼                     ▼
        │             Success (200)          Error (400/500)
        │                    │                     │
        │                    ▼                     ▼
        │       ┌─────────────────────┐   ┌──────────────────────┐
        │       │ 8. Show Success     │   │ 8. Show Error        │
        │       │ "Payment            │   │ "Payment processing  │
        │       │  successful!..."    │   │  failed. Try again"  │
        │       └────────┬────────────┘   └──────────────────────┘
        │                │
        │                ▼
        │       ┌─────────────────────┐
        │       │ 9. Wait 1 second    │
        │       └────────┬────────────┘
        │                │
        │                ▼
        │       ┌─────────────────────┐
        │       │ 10. Navigate to     │
        │       │ Dashboard           │
        │       │ (popUntil first)    │
        │       └────────┬────────────┘
        │                │
        └────────────────┴──────────────────────────────────────────┐
                                                                     │
                                                                     ▼
                                                          ┌──────────────────┐
                                                          │ Dashboard Screen │
                                                          │ (Booking Updated)│
                                                          └──────────────────┘
```

---

## Component Breakdown

### 1. **PaymentTransactionScreen** (`payment_transaction_screen.dart`)
**Purpose**: Main UI screen for selecting and processing payment

**Key Methods**:
- `initState()`: Initialize screen, load saved payments
- `_loadSavedPayments()`: Fetch all saved cards from backend
- `_processPayment()`: Charge the selected card
- `_buildPaymentCardsList()`: Render list of saved payment methods
- `_buildPaymentSummary()`: Show payment details

**State Variables**:
- `_selectedPayment`: Currently selected card (pre-selected if passed)
- `_savedPayments`: List of all saved payment methods
- `_isLoading`: Loading state during API calls

---

### 2. **PaymentService** (`payment_service.dart`)
**Purpose**: Handle all API communication for payments

**Key Methods**:
```dart
// Load all saved payment methods
Future<List<PaymentModel>> listPayments()

// Charge a saved card (NEW - flexible overload)
Future<Map<String, dynamic>?> chargeSavedCard({
  String? paymentId,
  double? amount,
  int? bookingId,
  String? paymentMethodId,
})
```

**Charge Card Logic**:
1. If only `paymentId` provided: Backend uses stored booking_id and amount
2. Backend extracts: Saved card, booking details, payment amount
3. Creates Stripe PaymentIntent with off_session usage
4. Charges card automatically
5. Updates booking status to 'completed'
6. Returns response

---

### 3. **PaymentModel** (`payment_model.dart`)
**Purpose**: Data structure for payment/card information

**Key Fields**:
```dart
id              // Payment record ID
serviceId       // Service being paid for
amount          // Payment amount
currency        // Currency (AUD)
status          // Payment status (pending, succeeded, failed)
createdAt       // When card was saved
cardBrand       // Visa, Mastercard, etc
cardLast4       // Last 4 digits
bookingId       // Associated booking (NEW)
```

---

## Backend Flow (Laravel)

### Endpoint: `POST /payment/charge-saved-card`

**Request**:
```json
{
  "payment_id": "abc123",
  "currency": "AUD"
}
```

**Backend Process**:
1. Validate payment_id exists
2. Retrieve Payment record (contains service_id, amount)
3. Get SavedCards record (contains customer_id, encrypted card data)
4. Get Booking details (to update status)
5. Create Stripe PaymentIntent:
   ```php
   PaymentIntent::create([
     'amount' => $amount * 100,
     'currency' => 'aud',
     'customer' => $customerId,
     'payment_method' => $paymentMethodId,
     'off_session' => true,
     'confirm' => true,
   ])
   ```
6. Update Payment table: `status = 'succeeded'`
7. Update Booking table: `status = 'completed'`
8. Return success response

**Response**:
```json
{
  "status": "succeeded",
  "message": "Payment processed successfully",
  "payment": {
    "id": "pay123",
    "status": "succeeded",
    "amount": 150.00,
    "booking_id": 42
  }
}
```

---

## User Interactions

### Scenario 1: New Card Save → Immediate Payment
```
1. Add Payment Method Screen
2. Enter card details
3. Confirm & Continue
4. AccountSetupSuccessScreen (shows card)
5. Click "Get Started"
6. → PaymentTransactionScreen (card PRE-SELECTED)
7. Click "Make Payment"
8. → Dashboard (booking completed)
```

### Scenario 2: Use Existing Card
```
1. User navigates to PaymentTransactionScreen
2. Sees list of saved cards
3. Selects a card (if different from pre-selected)
4. Clicks "Make Payment"
5. → Dashboard (booking completed)
```

### Scenario 3: Error Handling
```
1. User clicks "Make Payment"
2. API returns error (card declined, etc)
3. Show error message: "Payment processing failed..."
4. User can retry with same or different card
5. No navigation away from screen
```

---

## Key Features

✅ **Pre-Selected Card**: Newly added card is automatically selected  
✅ **Card List**: Users can switch between saved payment methods  
✅ **Payment Summary**: Shows amount, currency, and card details  
✅ **Error Handling**: Clear error messages on failure  
✅ **Loading States**: Shows spinner during API calls  
✅ **Navigation**: Back button returns to dashboard, success returns to dashboard  
✅ **Offline Support**: Uses payment_id (no real-time booking sync needed)  

---

## Integration Points

1. **AccountSetupSuccessScreen** → Passes `preSelectedPayment` parameter
2. **PaymentService** → Calls `chargeSavedCard()` 
3. **Backend API** → `POST /payment/charge-saved-card`
4. **Navigation** → `context.go('/dashboard')` via go_router
5. **Stripe** → Off-session payment (saved card charging)

---

## Testing Checklist

- [ ] Load PaymentTransactionScreen with pre-selected card
- [ ] Card is highlighted/selected
- [ ] Can switch to different card
- [ ] Payment summary shows correct details
- [ ] Click "Make Payment" → loading spinner appears
- [ ] Backend charges card successfully
- [ ] Success message shown
- [ ] Booking status updated to completed
- [ ] Navigates back to dashboard
- [ ] Error message shown on payment failure
- [ ] Can retry after error
- [ ] Back button navigates to dashboard
