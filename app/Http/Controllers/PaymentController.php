<?php

namespace App\Http\Controllers;

use Stripe\Stripe;
use App\Models\Payment;
use App\Models\SavedCards;
use Stripe\PaymentIntent;
use Stripe\PaymentMethod;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Crypt;

class PaymentController extends Controller
{
    /**
     * Get saved cards for the authenticated user
     * Called by: GET /saved-cards
     */
    public function getSavedCards(Request $request)
    {
        try {
            $user = $request->user();
            
            $savedCards = SavedCards::where('homeowner_id', $user->id)
                ->select('id', 'payment_method_id', 'card_brand', 'card_last4number', 'exp_month', 'exp_year')
                ->get();

            Log::info('Fetched saved cards', [
                'user_id' => $user->id,
                'count' => $savedCards->count(),
            ]);

            return response()->json([
                'data' => $savedCards,
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching saved cards', ['error' => $e->getMessage()]);
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function processPayment(Request $request)
    {

        try {
            // Set Stripe secret key from .env
            \Stripe\Stripe::setApiKey(env('STRIPE_SECRET'));

            $user = $request->user();
            // Step 1: Check if the user already has a Stripe customer via savedCards table
            $existingPayment = SavedCards::where('homeowner_id', $user->id)
                ->whereNotNull('customer_id')
                ->first();

            if ($existingPayment) {
                // Retrieve the Stripe Customer from the existing payment
                $customer = \Stripe\Customer::retrieve($existingPayment->customer_id);
            } else {
                // Create a new Stripe Customer
                $customer = \Stripe\Customer::create([
                    'email' => $user->email,
                    'name' => $user->first_name . ' ' . $user->last_name,
                ]);
            }

            $setupIntent = \Stripe\SetupIntent::create([
                'customer' => $customer->id,
                'payment_method_types' => ['card'],
                'usage' => 'off_session',
            ]);

            return response()->json([
                'client_secret' => $setupIntent->client_secret,
            ]);
        } catch (\Stripe\Exception\CardException $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function savePaymentMethod(Request $request)
    {
        $request->validate([
            'payment_method_id' => 'required|string',
            'card_holder' => 'nullable|string',
        ]);

        $user = $request->user();
        \Stripe\Stripe::setApiKey(env('STRIPE_SECRET'));

        try {
            // Step 1: Retrieve the Stripe Customer from the savedCards table
            $existingPayment = SavedCards::where('homeowner_id', $user->id)
                ->whereNotNull('customer_id')
                ->first();

            if ($existingPayment) {
                $customerId = $existingPayment->customer_id;
                $customer = \Stripe\Customer::retrieve($customerId);
            } else {
                // Safety check: If somehow no customer exists, create one
                $customer = \Stripe\Customer::create([
                    'email' => $user->email,
                    'name' => $user->first_name . ' ' . $user->last_name,
                ]);
                $customerId = $customer->id;
            }

            // Step 2: Retrieve the PaymentMethod
            $paymentMethod = \Stripe\PaymentMethod::retrieve($request->payment_method_id);

            // Step 3: Attach the PaymentMethod to the Customer if not already attached
            if (!$paymentMethod->customer) {
                $paymentMethod->attach([
                    'customer' => $customerId,
                ]);
            }

            // Step 4: Encrypt card details
            $encryptBrand = Crypt::encryptString($paymentMethod->card->brand);
            $encryptLast4 = Crypt::encryptString($paymentMethod->card->last4);
            $encExpMonth = Crypt::encryptString($paymentMethod->card->exp_month);
            $encExpYear = Crypt::encryptString($paymentMethod->card->exp_year);

            // Step 5: Save the payment method in DB
            $savedCard = SavedCards::create([
                'homeowner_id' => $user->id,
                'customer_id' => $customerId,
                'payment_method_id' => $paymentMethod->id,
                'card_brand' => $encryptBrand,
                'card_last4number' => $encryptLast4,
                'exp_month' => $encExpMonth,
                'exp_year' => $encExpYear,
            ]);

            Log::info('Payment method saved successfully', [
                'user_id' => $user->id,
                'saved_card_id' => $savedCard->id,
                'payment_method_id' => $paymentMethod->id,
            ]);

            return response()->json([
                'message' => 'Payment method saved successfully',
                'payment' => [
                    'id' => (string) $savedCard->id,
                    'status' => 'saved',
                    'card_brand' => $paymentMethod->card->brand,
                    'card_last4number' => $paymentMethod->card->last4,
                    'created_at' => $savedCard->created_at->toIso8601String(),
                ]
            ]);
        } catch (\Stripe\Exception\CardException $e) {
            Log::error('Stripe Card Error in savePaymentMethod', ['error' => $e->getMessage()]);
            return response()->json(['error' => $e->getMessage()], 400);
        } catch (\Exception $e) {
            Log::error('Error saving payment method', ['error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }


    public function chargeSavedCard(Request $request)
{
    $request->validate([
        'payment_method_id' => 'required|string',
        'amount' => 'required|numeric|min:0.5',
        'booking_id' => 'required|integer|exists:bookings,id',
        'currency' => 'nullable|string|size:3',
    ]);

    try {
        Stripe::setApiKey(config('services.stripe.secret'));
        $user = $request->user();

        // Retrieve the payment method from Stripe to get the actual customer it belongs to
        $paymentMethod = PaymentMethod::retrieve($request->payment_method_id);

        if (!$paymentMethod->customer) {
            Log::warning('Payment method has no customer attached', [
                'payment_method_id' => $request->payment_method_id,
            ]);
            return response()->json([
                'message' => 'Payment method is not properly set up. Please save the card again.',
                'status' => 'failed'
            ], 422);
        }

        // Use the actual customer from the payment method, not from SavedCards
        $customerId = $paymentMethod->customer;

        // Create PaymentIntent with the correct customer
        $intent = PaymentIntent::create([
            'amount' => (int) ($request->amount * 100),
            'currency' => $request->currency ?? 'aud',
            'customer' => $customerId,  // ← Use the actual Stripe customer
            'payment_method' => $request->payment_method_id,
            'off_session' => true,
            'confirm' => true,
        ]);

        // Save transaction with booking reference
        $payment = Payment::create([
            'homeowner_id' => $user->id,
            'booking_id' => $request->booking_id,
            'customer_id' => $customerId,
            'payment_method_id' => $request->payment_method_id,
            'amount' => $request->amount,
            'currency' => $request->currency ?? 'aud',
            'card_brand' => $paymentMethod->card->brand,
            'card_last4number' => $paymentMethod->card->last4,
            'status' => $intent->status,
        ]);

        // Update booking status if payment succeeded
        $booking = \App\Models\Booking::find($request->booking_id);
        if ($booking && $intent->status === 'succeeded') {
            $booking->update(['status' => 'completed']);
        }

        // Handle different payment intent statuses
        if ($intent->status === 'requires_action' || $intent->status === 'requires_source_action') {
            // Payment requires authentication (3D Secure, etc.)
            Log::info('Payment requires authentication', [
                'user_id' => $user->id,
                'booking_id' => $request->booking_id,
                'payment_intent' => $intent->id,
                'status' => $intent->status,
            ]);

            return response()->json([
                'message' => 'Payment requires authentication. Please complete the authentication in the app.',
                'status' => $intent->status,
                'client_secret' => $intent->client_secret,
                'payment_intent' => $intent->id,
                'payment_id' => $payment->id,
                'requires_action' => true,
            ]);
        } else if ($intent->status === 'succeeded') {
            // Payment successful
            Log::info('Payment processed successfully', [
                'user_id' => $user->id,
                'booking_id' => $request->booking_id,
                'payment_intent' => $intent->id,
                'status' => $intent->status,
            ]);

            return response()->json([
                'message' => 'Payment successful',
                'status' => $intent->status,
                'payment_intent' => $intent->id,
                'payment_id' => $payment->id,
            ]);
        } else {
            // Other statuses (processing, etc.)
            return response()->json([
                'message' => 'Payment processing',
                'status' => $intent->status,
                'payment_intent' => $intent->id,
                'payment_id' => $payment->id,
            ]);
        }

    } catch (\Stripe\Exception\CardException $e) {
        Log::error('Stripe Card Error', ['error' => $e->getMessage()]);
        return response()->json(['message' => $e->getMessage(), 'status' => 'failed'], 400);
    } catch (\Exception $e) {
        Log::error('Payment Error', ['error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
        return response()->json(['message' => $e->getMessage(), 'status' => 'failed'], 500);
    }
}

    public function deletePayment(Request $request, $id)
    {

        $user = $request->user();

        $payment = \App\Models\Payment::where('id', $id)
            ->where('homeowner_id', $user->id)
            ->first();

        if (!$payment) {
            return response()->json([
                'success' => false,
                'message' => 'Payment not found or you do not have access to this record.',
            ], 404);
        }

        // Only allow if the user is the owner
        if ($user->id !== $payment->homeowner_id && $user->role !== 'admin') {
            return response()->json(['error' => 'Unauthorized access'], 403);
        }

        $payment->delete();

        return response()->json([
            'success' => true,
            'message' => 'Payment deleted successfully.',
        ]);
    }
    public function updatePayment(Request $request, $id)
    {
        $user = $request->user();

        $payment = \App\Models\Payment::where('id', $id)
            ->where('homeowner_id', $user->id)
            ->first();

        if (!$payment) {
            return response()->json([
                'success' => false,
                'message' => 'Payment not found or you do not have access to this record.',
            ], 404);
        }

        // Only allow if the user is the owner
        if ($user->id !== $payment->homeowner_id && $user->role !== 'admin') {
            return response()->json(['error' => 'Unauthorized access'], 403);
        }

        $validated = $request->validate([
            'amount' => 'required|numeric|min:0.5',
            'currency' => 'required|string|size:3',
            'card_brand' => 'required|string|max:40',
            'card_last4number' => 'required|numeric|digits:4',
            'exp_month' => 'required|string|size:2',
            'exp_year' => 'required|string|size:4',
        ]);

        if ($validated['exp_month'] < 1 || $validated['exp_month'] > 12) {
            return response()->json([
                'success' => false,
                'message' => 'Expiration month must be between 01 and 12.',
            ], 400);
        } elseif ($validated['exp_year'] < date('Y')) {
            return response()->json([
                'success' => false,
                'message' => 'Expiration year cannot be in the past.',
            ], 400);
        } elseif ($validated['exp_year'] == date('Y') && $validated['exp_month'] < date('m')) {
            return response()->json([
                'success' => false,
                'message' => 'Expiration month cannot be in the past for the current year.',
            ], 400);
        } elseif ($validated['exp_year'] > date('Y') + 20) {
            return response()->json([
                'success' => false,
                'message' => 'Expiration year is too far in the future.',
            ], 400);
        }

        // Encrypt sensitive fields if they are being updated
        if (isset($validated['card_brand'])) {
            $validated['card_brand'] = Crypt::encryptString($validated['card_brand']);
        }
        if (isset($validated['card_last4number'])) {
            $validated['card_last4number'] = Crypt::encryptString($validated['card_last4number']);
        }
        if (isset($validated['exp_month'])) {
            $validated['exp_month'] = Crypt::encryptString($validated['exp_month']);
        }
        if (isset($validated['exp_year'])) {
            $validated['exp_year'] = Crypt::encryptString($validated['exp_year']);
        }

        $payment->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Payment updated successfully.',
            'data' => $payment,
        ]);
    }

    public function viewDecryptedPayment(Request $request, $id)
    {
        $user = $request->user();

        $payment = \App\Models\Payment::where('id', $id)
            ->where('homeowner_id', $user->id)
            ->first();

        if (!$payment) {
            return response()->json([
                'success' => false,
                'message' => 'Payment not found or you do not have access to this record.',
            ], 404);
        }

        if ($user->id !== $payment->homeowner_id && $user->role !== 'admin') {
            return response()->json(['error' => 'Unauthorized access'], 403);
        }

        // Initialize decrypted array
        $decrypted = [
            'amount' => $payment->amount,
            'currency' => $payment->currency,
            'card_brand' => null,
            'card_last4number' => null,
            'exp_month' => null,
            'exp_year' => null,
        ];

        try {
            // Attempt decryption for each field individually
            if ($payment->card_brand) {
                try {
                    $decrypted['card_brand'] = Crypt::decryptString($payment->card_brand);
                } catch (\Exception $e) {
                    $decrypted['card_brand'] = $payment->card_brand; // fallback to raw
                }
            }
            if ($payment->card_last4number) {
                try {
                    $decrypted['card_last4number'] = Crypt::decryptString($payment->card_last4number);
                } catch (\Exception $e) {
                    $decrypted['card_last4number'] = $payment->card_last4number;
                }
            }
            if ($payment->exp_month) {
                try {
                    $decrypted['exp_month'] = Crypt::decryptString($payment->exp_month);
                } catch (\Exception $e) {
                    $decrypted['exp_month'] = $payment->exp_month;
                }
            }
            if ($payment->exp_year) {
                try {
                    $decrypted['exp_year'] = Crypt::decryptString($payment->exp_year);
                } catch (\Exception $e) {
                    $decrypted['exp_year'] = $payment->exp_year;
                }
            }

            // Log successful access
            \App\Models\PaymentAccessLog::create([
                'homeowner_id' => $user->id,
                'payment_id' => $payment->id,
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'success' => true,
            ]);

            return response()->json([
                'message' => 'Decrypted data accessed successfully',
                'data' => $decrypted,
            ]);
        } catch (\Exception $e) {
            // Log failed access
            \App\Models\PaymentAccessLog::create([
                'homeowner_id' => $user->id ?? null,
                'payment_id' => $payment->id,
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'success' => false,
            ]);

            return response()->json(['error' => 'Failed to decrypt data'], 500);
        }
    }


        public function paymentHistory(Request $request)
    {
        try {
            $user = $request->user();
            
            $payments = Payment::where('homeowner_id', $user->id)
                ->with(['booking' => function($query) {
                    $query->with(['tradie', 'service']);
                }])
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function($payment) {
                    return [
                        'id' => $payment->id,
                        'booking_id' => $payment->booking_id,
                        'amount' => $payment->amount,
                        'currency' => $payment->currency,
                        'status' => $payment->status,
                        'card_last4number' => $payment->card_last4number,
                        'card_brand' => $payment->card_brand,
                        'created_at' => $payment->created_at,
                        'booking' => $payment->booking ? [
                            'id' => $payment->booking->id,
                            'booking_start' => $payment->booking->booking_start,
                            'booking_end' => $payment->booking->booking_end,
                            'total_price' => $payment->booking->total_price,
                            'tradie' => $payment->booking->tradie,
                            'service' => $payment->booking->service,
                        ] : null,
                    ];
                });

            return response()->json([
                'payments' => $payments,
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching payment history', ['error' => $e->getMessage()]);
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}