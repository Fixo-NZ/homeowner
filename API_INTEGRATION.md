# API Integration Guide

## Laravel API Setup

### Required Endpoints

Your Laravel API should provide these endpoints for the Tradie app:

#### Authentication Endpoints

1. **POST /auth/login**
   ```json
   // Request
   {
     "email": "tradie@example.com",
     "password": "password123"
   }
   
   // Response (Success - 200)
   {
     "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
     "token_type": "Bearer",
     "expires_in": 3600,
     "user": {
       "id": 1,
       "first_name": "John",
       "middle_name": null,
       "last_name": "Smith",
       "email": "tradie@example.com",
       "phone": "+64 21 123 4567",
       "avatar": null,
       "bio": "Experienced electrician",
       "address": "123 Main St",
       "city": "Auckland",
       "region": "Auckland",
       "postal_code": "1010",
       "latitude": -36.8485,
       "longitude": 174.7633,
       "business_name": "Smith Electrical",
       "license_number": "EL12345",
       "insurance_details": "Public liability $2M",
       "years_experience": 10,
       "hourly_rate": 85.00,
       "availability_status": "available",
       "service_radius": 50,
       "created_at": "2024-01-01T00:00:00.000000Z",
       "updated_at": "2024-01-01T00:00:00.000000Z"
     }
   }
   
   // Response (Error - 401)
   {
     "message": "Invalid credentials",
     "errors": {
       "email": ["The provided credentials are incorrect."]
     }
   }
   ```

2. **POST /auth/register**
   ```json
   // Request
   {
     "first_name": "John",
     "middle_name": null,
     "last_name": "Smith",
     "email": "tradie@example.com",
     "password": "password123",
     "password_confirmation": "password123",
     "phone": "+64 21 123 4567"
   }
   
   // Response (Success - 201)
   {
     "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
     "token_type": "Bearer",
     "expires_in": 3600,
     "user": {
       // Same user object as login response
     }
   }
   
   // Response (Error - 422)
   {
     "message": "The given data was invalid.",
     "errors": {
       "email": ["The email has already been taken."],
       "password": ["The password confirmation does not match."]
     }
   }
   ```

3. **POST /auth/logout** (Requires Authentication)
   ```json
   // Headers
   Authorization: Bearer {access_token}
   
   // Response (Success - 200)
   {
     "message": "Successfully logged out"
   }
   ```

4. **POST /auth/refresh** (Requires Authentication)
   ```json
   // Headers
   Authorization: Bearer {access_token}
   
   // Response (Success - 200)
   {
     "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
     "token_type": "Bearer",
     "expires_in": 3600
   }
   ```

### Laravel Implementation Example

#### Migration
```php
Schema::create('tradies', function (Blueprint $table) {
    $table->id();
    $table->string('first_name');
    $table->string('middle_name')->nullable();
    $table->string('last_name');
    $table->string('email')->unique();
    $table->timestamp('email_verified_at')->nullable();
    $table->string('password');
    $table->string('phone')->nullable();
    $table->string('avatar')->nullable();
    $table->text('bio')->nullable();
    $table->text('address')->nullable();
    $table->string('city')->nullable();
    $table->string('region')->nullable();
    $table->string('postal_code')->nullable();
    $table->decimal('latitude', 10, 8)->nullable();
    $table->decimal('longitude', 11, 8)->nullable();
    $table->string('business_name')->nullable();
    $table->string('license_number')->nullable();
    $table->text('insurance_details')->nullable();
    $table->integer('years_experience')->nullable();
    $table->decimal('hourly_rate', 8, 2)->nullable();
    $table->enum('availability_status', ['available', 'busy', 'unavailable'])->default('available');
    $table->integer('service_radius')->default(50);
    $table->rememberToken();
    $table->timestamps();
});
```

#### Controller Example
```php
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Tradie;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (!Auth::guard('tradie')->attempt($request->only('email', 'password'))) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $tradie = Auth::guard('tradie')->user();
        $token = $tradie->createToken('tradie-token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => 3600,
            'user' => $tradie,
        ]);
    }

    public function register(Request $request)
    {
        $request->validate([
            'first_name' => 'required|string|max:255',
            'middle_name' => 'nullable|string|max:255',
            'last_name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:tradies',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'nullable|string|max:20',
        ]);

        $tradie = Tradie::create([
            'first_name' => $request->first_name,
            'middle_name' => $request->middle_name,
            'last_name' => $request->last_name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone' => $request->phone,
        ]);

        $token = $tradie->createToken('tradie-token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => 3600,
            'user' => $tradie,
        ], 201);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Successfully logged out'
        ]);
    }
}
```

## Flutter App Configuration

### Update API Base URL

In `lib/core/config/app_config.dart`, update the API base URL:

```dart
static const String apiBaseUrl = 'https://your-laravel-api.com/api';
```

For local development:
- Android Emulator: `http://10.0.2.2:8000/api`
- iOS Simulator: `http://localhost:8000/api`
- Physical Device: `http://YOUR_LOCAL_IP:8000/api`

### CORS Configuration

Make sure your Laravel API has CORS configured to allow requests from your Flutter app. In `config/cors.php`:

```php
'paths' => ['api/*'],
'allowed_methods' => ['*'],
'allowed_origins' => ['*'], // Configure appropriately for production
'allowed_headers' => ['*'],
'exposed_headers' => [],
'max_age' => 0,
'supports_credentials' => false,
```

### Testing the Integration

1. Start your Laravel API server
2. Update the API base URL in the Flutter app
3. Run the Flutter app
4. Test login and registration flows

The app will automatically handle:
- Token storage and retrieval
- Adding Authorization headers to requests
- Handling 401 responses (automatic logout)
- Network error handling
- Form validation and error display